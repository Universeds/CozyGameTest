--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(script.Parent.Config)
local NetworkTransport = require(script.Parent.NetworkTransport)

local ReplicationManager = {}
ReplicationManager.__index = ReplicationManager

local IS_SERVER = RunService:IsServer()

export type ComponentUpdate = {
	entityId: number,
	componentName: string,
	data: any,
	transport: "Reliable" | "Unreliable",
}

function ReplicationManager.new(world)
	local self = setmetatable({}, ReplicationManager)
	
	self.world = world
	self.transport = NetworkTransport.new()
	
	self.replicatedComponents = {} -- { [componentName] = { owner: "Server" | "Client", transport: "Reliable" | "Unreliable", factory } }
	
	self.reliableQueue = {} -- Array of ComponentUpdate
	self.unreliableQueue = {} -- Array of ComponentUpdate
	
	self.replicatedEntities = {} -- Set of entity IDs
	
	self.uniqueIdToEntity = {} -- Map: uniqueId → entityId
	self.entityToUniqueId = {} -- Map: entityId → uniqueId
	
	-- Last batch send time
	self.lastBatchTime = 0
	
	self:_bindNetworkListeners()
	
	return self
end

function ReplicationManager:registerComponent(componentName: string, config: { owner: string, transport: string }, factory)
	self.replicatedComponents[componentName] = {
		owner = config.owner,
		transport = config.transport,
		factory = factory,
	}
	
	if Config.debugMode then
		print(`[Replication] Registered component: {componentName} (Owner: {config.owner}, Transport: {config.transport})`)
	end
end

function ReplicationManager:addReplicatedEntity(entityId: number, uniqueId: string?)
	self.replicatedEntities[entityId] = true
	
	if uniqueId then
		self:registerUniqueId(entityId, uniqueId)
	end
end

function ReplicationManager:removeReplicatedEntity(entityId: number)
	self.replicatedEntities[entityId] = nil
	
	local uniqueId = self.entityToUniqueId[entityId]
	if uniqueId then
		self.uniqueIdToEntity[uniqueId] = nil
		self.entityToUniqueId[entityId] = nil
	end
end

function ReplicationManager:registerUniqueId(entityId: number, uniqueId: string)
	self.uniqueIdToEntity[uniqueId] = entityId
	self.entityToUniqueId[entityId] = uniqueId
	
	if Config.debugMode then
		print(`[Replication] Registered unique ID {uniqueId} for entity {entityId}`)
	end
end

function ReplicationManager:getEntityByUniqueId(uniqueId: string): number?
	return self.uniqueIdToEntity[uniqueId]
end

function ReplicationManager:getUniqueId(entityId: number): string?
	return self.entityToUniqueId[entityId]
end

function ReplicationManager:attachToInstance(entityId: number, instance: Instance)
	local uniqueId = self.entityToUniqueId[entityId]
	if not uniqueId then
		warn(`[Replication] Cannot attach entity {entityId} to instance: no unique ID registered`)
		return
	end
	
	instance:SetAttribute("EntityUniqueId", uniqueId)
	
	if Config.debugMode then
		print(`[Replication] Attached entity {entityId} (unique ID: {uniqueId}) to instance {instance:GetFullName()}`)
	end
end

function ReplicationManager:getEntityFromInstance(instance: Instance): number?
	local uniqueId = instance:GetAttribute("EntityUniqueId")
	if not uniqueId then
		return nil
	end
	
	return self.uniqueIdToEntity[uniqueId]
end

function ReplicationManager:queueUpdate(entityId: number, componentNameOrFactory: any, data: any)
	local componentName = componentNameOrFactory
	local componentInfo = nil
	
	if type(componentNameOrFactory) == "string" then
		componentInfo = self.replicatedComponents[componentNameOrFactory]
	else
		for name, info in pairs(self.replicatedComponents) do
			if info.factory == componentNameOrFactory then
				componentName = name
				componentInfo = info
				break
			end
		end
	end
	
	if not componentInfo then
		warn(`[Replication] Attempted to queue update for unregistered component: {componentName}`)
		return
	end
	
	local shouldQueue = false
	if IS_SERVER and componentInfo.owner == "Server" then
		shouldQueue = true
	elseif not IS_SERVER and componentInfo.owner == "Client" then
		shouldQueue = true
	end
	
	if not shouldQueue then
		return
	end
	
	local update: ComponentUpdate = {
		entityId = entityId,
		componentName = componentName,
		data = data,
		transport = componentInfo.transport,
	}
	
	if componentInfo.transport == "Reliable" then
		table.insert(self.reliableQueue, update)
	else
		table.insert(self.unreliableQueue, update)
	end
end

function ReplicationManager:processBatches(currentTime: number)
	if currentTime - self.lastBatchTime < Config.batchInterval then
		return
	end
	
	self.lastBatchTime = currentTime
	
	self:_sendBatch(self.reliableQueue, "Reliable")
	
	self:_sendBatch(self.unreliableQueue, "Unreliable")
end

function ReplicationManager:_sendBatch(queue: {ComponentUpdate}, transport: "Reliable" | "Unreliable")
	if #queue == 0 then
		return
	end
	
	local batchSize = Config.batchSize
	
	while #queue > 0 do
		local batch = {}
		local count = math.min(batchSize, #queue)
		
		for i = 1, count do
			table.insert(batch, table.remove(queue, 1))
		end
		
		local payload = {
			type = "ComponentUpdates",
			updates = batch,
		}
		
		if IS_SERVER then
			self.transport:sendToClient(transport, nil, payload)
		else
			self.transport:sendToServer(transport, payload)
		end
		
		if Config.debugMode then
			print(`[Replication] Sent {transport} batch with {#batch} updates`)
		end
	end
end

function ReplicationManager:syncPlayerOnJoin(player: Player)
	if not IS_SERVER then
		return
	end
	
	local syncData = {}
	
	for entityId, _ in pairs(self.replicatedEntities) do
		local entityData = {
			entityId = entityId,
			components = {},
		}
		
		for componentName, componentInfo in pairs(self.replicatedComponents) do
			if componentInfo.owner == "Server" then
				local comp = componentInfo.factory.get(entityId)
				if comp then
					local data = comp.state or comp
					entityData.components[componentName] = data
				end
			end
		end
		
		table.insert(syncData, entityData)
	end
	
	local payload = {
		type = "InitialSync",
		entities = syncData,
	}
	
	self.transport:sendToClient("Reliable", player, payload)
	
	if Config.debugMode then
		print(`[Replication] Synced {#syncData} entities to player {player.Name}`)
	end
end

function ReplicationManager:_bindNetworkListeners()
	if IS_SERVER then
		self.transport:onClientMessage("Reliable", function(player, payload)
			self:_handleIncomingMessage(player, payload)
		end)
		
		self.transport:onClientMessage("Unreliable", function(player, payload)
			self:_handleIncomingMessage(player, payload)
		end)
	else
		self.transport:onServerMessage("Reliable", function(payload)
			self:_handleIncomingMessage(nil, payload)
		end)
		
		self.transport:onServerMessage("Unreliable", function(payload)
			self:_handleIncomingMessage(nil, payload)
		end)
	end
end

function ReplicationManager:_handleIncomingMessage(player: Player?, payload: any)
	if Config.debugMode then
		print(`[Replication] Received message type: {payload.type}`)
	end
	
	if payload.type == "ComponentUpdates" then
		self:_applyComponentUpdates(payload.updates)
	elseif payload.type == "InitialSync" then
		self:_applyInitialSync(payload.entities)
	end
end

function ReplicationManager:_applyComponentUpdates(updates: {ComponentUpdate})
	for _, update in ipairs(updates) do
		local componentInfo = self.replicatedComponents[update.componentName]
		if not componentInfo then
			continue
		end
		
		local comp = componentInfo.factory.get(update.entityId)
		if comp then
			if comp.state then
				for key, value in pairs(update.data) do
					comp.state[key] = value
				end
			else
				for key, value in pairs(update.data) do
					comp[key] = value
				end
			end
			
			if Config.debugMode then
				print(`[Replication] Updated {update.componentName} on entity {update.entityId}`)
			end
		else
			componentInfo.factory.add(update.entityId, update.data)
			
			if Config.debugMode then
				print(`[Replication] Added {update.componentName} to entity {update.entityId}`)
			end
		end
	end
end

function ReplicationManager:_applyInitialSync(entities: any)
	if IS_SERVER then
		return
	end
	
	for _, entityData in ipairs(entities) do
		local entity = entityData.entityId
		
		for componentName, data in pairs(entityData.components) do
			local componentInfo = self.replicatedComponents[componentName]
			if componentInfo then
				local existingComp = componentInfo.factory.get(entity)
				if existingComp then
					if existingComp.state and existingComp.state.set then
						existingComp.state:set(data)
					else
						for key, value in pairs(data) do
							existingComp[key] = value
						end
					end
				else
					componentInfo.factory.add(entity, data)
				end
			end
		end
	end
	
	if Config.debugMode then
		print(`[Replication] Applied initial sync for {#entities} entities`)
	end
end

return ReplicationManager

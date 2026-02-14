--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TableValue = require(ReplicatedStorage.Packages.TableValue)

local Config = require(script.Config)
local ReplicatedEntityDef = require(script.ReplicatedEntity)
local ReplicationManager = require(script.ReplicationManager)

local Replication = {}

local manager = nil
local world = nil

function Replication.init(customWorld, customConfig: { [string]: any }?)
	world = customWorld
	
	if customConfig then
		for key, value in pairs(customConfig) do
			Config[key] = value
		end
	end
	
	manager = ReplicationManager.new(world)
	
	Replication.ReplicatedEntity = world.factory(ReplicatedEntityDef)
	
	local originalAdded = world.added
	function world:added(factory, entity, component)
		if originalAdded then
			originalAdded(self, factory, entity, component)
		end
		
		if factory == Replication.ReplicatedEntity then
			manager:addReplicatedEntity(entity, component.uniqueId)
			
			if component.instance then
				manager:attachToInstance(entity, component.instance)
			end
		end
	end
	
	local originalRemoved = world.removed
	function world:removed(factory, entity, component)
		if originalRemoved then
			originalRemoved(self, factory, entity, component)
		end
		
		if factory == Replication.ReplicatedEntity then
			manager:removeReplicatedEntity(entity)
		end
	end
	
	if Config.debugMode then
		print("[Replication] System initialized")
	end
	
	return Replication
end

function Replication.createReplicatedComponent(config: {
	owner: "Server" | "Client",
	transport: "Reliable" | "Unreliable"
}, componentDef: { add: any, remove: any })
	if not manager then
		error("[Replication] You must call Replication.init() before creating replicated components")
	end
	
	local wrappedDef = {}
	
	function wrappedDef:add(entity, initialData)
		local replicatedEntity = world.get(entity, Replication.ReplicatedEntity)
		if not replicatedEntity and RunService:IsServer() then
			error(`[Replication] Cannot add replicated component to non-replicated entity {entity}`)
		end
		
		local comp = componentDef.add(self, entity, initialData)
		
		if comp.state and typeof(comp.state) == "table" and comp.state.onChange then
			comp.state:onChange(function(newValue)
				-- Queue update for replication
				local componentName = debug.info(componentDef.add, "s")
				manager:queueUpdate(entity, componentName, newValue)
			end)
		end
		
		return comp
	end
	
	function wrappedDef:remove(entity, comp)
		if componentDef.remove then
			componentDef.remove(self, entity, comp)
		end
	end
	
	local factory = world.factory(wrappedDef)
	
	local componentName = debug.info(componentDef.add, "s")
	manager:registerComponent(componentName, config, factory)
	
	return factory
end

function Replication.getManager()
	return manager
end

function Replication.startReplicationLoop()
	if not manager then
		error("[Replication] You must call Replication.init() before starting the replication loop")
	end
	
	if RunService:IsServer() then
		game.Players.PlayerAdded:Connect(function(player)
			task.wait(1)
			manager:syncPlayerOnJoin(player)
		end)
	end
	
	return function()
		local currentTime = os.clock()
		manager:processBatches(currentTime)
	end
end

function Replication.getEntityByUniqueId(uniqueId: string): number?
	if not manager then
		error("[Replication] You must call Replication.init() before using getEntityByUniqueId")
	end
	return manager:getEntityByUniqueId(uniqueId)
end

function Replication.getUniqueId(entity: number): string?
	if not manager then
		error("[Replication] You must call Replication.init() before using getUniqueId")
	end
	return manager:getUniqueId(entity)
end

function Replication.attachToInstance(entity: number, instance: Instance)
	if not manager then
		error("[Replication] You must call Replication.init() before using attachToInstance")
	end
	manager:attachToInstance(entity, instance)
end

function Replication.getEntityFromInstance(instance: Instance): number?
	if not manager then
		error("[Replication] You must call Replication.init() before using getEntityFromInstance")
	end
	return manager:getEntityFromInstance(instance)
end

return Replication

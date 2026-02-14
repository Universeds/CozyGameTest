--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Net = require(ReplicatedStorage.Packages.Net)
local Config = require(script.Parent.Config)

local NetworkTransport = {}
NetworkTransport.__index = NetworkTransport

local IS_SERVER = RunService:IsServer()

function NetworkTransport.new()
	local self = setmetatable({}, NetworkTransport)
	
	self.reliableRemote = Net:RemoteEvent(Config.remoteNamespace .. "/Reliable")
	self.unreliableRemote = Net:UnreliableRemoteEvent(Config.remoteNamespace .. "/Unreliable")
	
	return self
end

function NetworkTransport:sendToClient(transport: "Reliable" | "Unreliable", player: Player?, data: any)
	if not IS_SERVER then
		warn("[Replication] sendToClient called on client")
		return
	end
	
	local remote = transport == "Reliable" and self.reliableRemote or self.unreliableRemote
	
	if player then
		remote:FireClient(player, data)
	else
		remote:FireAllClients(data)
	end
end

function NetworkTransport:sendToServer(transport: "Reliable" | "Unreliable", data: any)
	if IS_SERVER then
		warn("[Replication] sendToServer called on server")
		return
	end
	
	local remote = transport == "Reliable" and self.reliableRemote or self.unreliableRemote
	remote:FireServer(data)
end

function NetworkTransport:onClientMessage(transport: "Reliable" | "Unreliable", callback: (player: Player, data: any) -> ())
	if not IS_SERVER then
		warn("[Replication] onClientMessage called on client")
		return
	end
	
	local remote = transport == "Reliable" and self.reliableRemote or self.unreliableRemote
	remote.OnServerEvent:Connect(callback)
end

function NetworkTransport:onServerMessage(transport: "Reliable" | "Unreliable", callback: (data: any) -> ())
	if IS_SERVER then
		warn("[Replication] onServerMessage called on server")
		return
	end
	
	local remote = transport == "Reliable" and self.reliableRemote or self.unreliableRemote
	remote.OnClientEvent:Connect(callback)
end

return NetworkTransport

--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local localFolder = if RunService:IsServer()
	then ServerStorage.Server
	else ReplicatedStorage.Client

local World = require(script.World)

local Replication = require(ReplicatedStorage.Vendor.Replication)

Replication.init(World, {
	debugMode = false,
})


return {
	Packages = ReplicatedStorage.Packages,
	Vendor = ReplicatedStorage.Vendor,
	Assets = ReplicatedStorage.Assets,
	Shared = ReplicatedStorage.Shared,
	Local = localFolder,
	World = World,
	Schedules = require(script.Schedules),
	Util = require(script.Util),
	DEBUG = require(script.DebugUtil),
	InjectLifecycleSignals = require(script.InjectLifecycleSignals),
}

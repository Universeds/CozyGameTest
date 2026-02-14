--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Replication = require(Global.Vendor.Replication)

local replicationUpdate = Replication.startReplicationLoop()

return Global.Schedules.Heartbeat.job(replicationUpdate)

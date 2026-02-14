--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Global = require(ReplicatedStorage.Shared.Global)

Global.Util.requireDescendants(Global.Local)
Global.Util.requireDescendants(Global.Shared)

Global.Schedules.Init.start()
Global.Schedules.Boot.start()

for scheduleName, schedule in Global.Schedules do
	pcall(function()
		RunService[scheduleName]:Connect(schedule.start)
	end)
end

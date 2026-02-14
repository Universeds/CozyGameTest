local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Shared.Global)
local mainCmdr = require(ReplicatedStorage.Packages.Cmdr)

local function SetupCmdr()
	mainCmdr:RegisterCommandsIn(script.Parent.Parent.Commands)
	mainCmdr:RegisterHooksIn(script.Parent.Parent.Hooks)
end

return Global.Schedules.Boot.job(SetupCmdr)

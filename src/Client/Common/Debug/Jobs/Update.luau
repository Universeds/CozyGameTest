local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Shared.Global)

local Debug = require(Global.Local.Debug.Component)

local function UpdateDebugGizmos(entity, comp, dt)
    if not comp then return end
    if not comp.enabled then
        return
    end
    for _, drawer in ipairs(comp.drawers) do
        drawer(entity, comp, dt)
    end
end

return Global.Schedules.RenderStepped.job(function(dt)
	for entity, comp in Global.World.query(Debug) do
        local Component = comp[Debug]
		UpdateDebugGizmos(entity, Component, dt)
	end
end)

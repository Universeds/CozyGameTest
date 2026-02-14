local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local NPCIdentity = require(Global.Shared.NPC.Components.NPCIdentity)
local NPCBrain = require(Global.Shared.NPC.Components.NPCBrain)
local PlannerRegistry = require(Global.Shared.NPC.Modules.PlannerRegistry)

local function initializeNPCGOAPPlanners()
    NPCBrain.onAdded:Connect(function(entity)
        local identity = NPCIdentity.get(entity)
        if identity then
            PlannerRegistry.getOrCreatePlanner(entity, identity.npcType)
        end
    end)
    
    NPCBrain.onRemoved:Connect(function(entity)
        PlannerRegistry.removePlanner(entity)
    end)
end

return Global.Schedules.Boot.job(initializeNPCGOAPPlanners)

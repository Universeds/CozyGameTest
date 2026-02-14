--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local GOAPPlanner = require(Global.Shared.NPC.GOAP.GOAPPlanner)

local PlannerRegistry = {}

local npcPlanners: { [number]: any } = {}

local function loadGOAPConfig(npcType: string)
    local typeFolder = ReplicatedStorage.Shared.NPC.NPCTypes:FindFirstChild(npcType)
    if not typeFolder then return nil end
    
    local configModule = typeFolder:FindFirstChild("GOAPConfig")
    if not configModule then return nil end
    
    local success, config = pcall(require, configModule)
    return success and config or nil
end

function PlannerRegistry.getOrCreatePlanner(entity: number, npcType: string)
    if npcPlanners[entity] then
        return npcPlanners[entity]
    end
    
    local config = loadGOAPConfig(npcType)
    if not config then return nil end
    
    local planner = GOAPPlanner.new()
    
    for _, goal in config.Goals do
        planner:registerGoal(goal)
    end
    
    for _, action in config.Actions do
        planner:registerAction(action)
    end
    
    npcPlanners[entity] = planner
    return planner
end

function PlannerRegistry.getPlanner(entity: number)
    return npcPlanners[entity]
end

function PlannerRegistry.removePlanner(entity: number)
    npcPlanners[entity] = nil
end

function PlannerRegistry.getAllPlanners()
    return npcPlanners
end

return PlannerRegistry

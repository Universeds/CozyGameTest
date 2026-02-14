local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Global = require(ReplicatedStorage.Shared.Global)
local World = Global.World

local NPCIdentity = require(Global.Shared.NPC.Components.NPCIdentity)
local NPCBrain = require(Global.Shared.NPC.Components.NPCBrain)
local NPCClientSim = require(Global.Shared.NPC.Components.NPCClientSim)

local WorldStateBuilder = require(Global.Shared.NPC.GOAP.WorldStateBuilder)
local StateController = require(Global.Shared.NPC.StateController)
local PlannerRegistry = require(Global.Shared.NPC.Modules.PlannerRegistry)

local IS_CLIENT = RunService:IsClient()
local BRAIN_UPDATE_INTERVAL = 0.5

local lastUpdateTime = 0

local function tickNPCBrainGOAP()
    local currentTime = os.clock()
    if currentTime - lastUpdateTime < BRAIN_UPDATE_INTERVAL then return end
    lastUpdateTime = currentTime
    
    for entity in World.query(NPCIdentity, NPCBrain) do
        local identity = NPCIdentity.get(entity)
        local brain = NPCBrain.get(entity)
        local clientSim = IS_CLIENT and NPCClientSim.get(entity) or nil
        
        if not identity or not brain then continue end
        
        local planner = PlannerRegistry.getOrCreatePlanner(entity, identity.npcType)
        if not planner then continue end
        
        local worldState = WorldStateBuilder.build(entity, brain.worldState)
        local goalName, nextState = planner:getNextAction(worldState)
        
        if goalName then
            brain.currentGoal = goalName
        end
        
        if nextState and IS_CLIENT and clientSim then
            if not clientSim.stateController then
                clientSim.stateController = StateController.new(entity, identity.npcType, worldState)
                clientSim.stateController:transition("Idle")
            end
            
            local currentStateName = clientSim.stateController:getCurrentStateName()
            if currentStateName ~= nextState then
                clientSim.stateController:transition(nextState)
            end
        end
    end
end

return Global.Schedules.Heartbeat.job(tickNPCBrainGOAP)

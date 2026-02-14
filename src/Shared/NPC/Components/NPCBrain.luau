local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Replication = require(Global.Vendor.Replication)

export type NPCBrainData = {
    currentGoal: string?,
    goalPriority: number,
    worldState: { [string]: any },
    planQueue: { string },
}

local NPCBrain = {}

function NPCBrain:add(entity: number, data: NPCBrainData?)
    return {
        currentGoal = data and data.currentGoal or nil,
        goalPriority = data and data.goalPriority or 0,
        worldState = data and data.worldState or {},
        planQueue = data and data.planQueue or {},
    }
end

function NPCBrain:remove(entity: number, comp: NPCBrainData) end

return Global.InjectLifecycleSignals(Replication.createReplicatedComponent({
    owner = "Server",
    transport = "Reliable",
}, NPCBrain))
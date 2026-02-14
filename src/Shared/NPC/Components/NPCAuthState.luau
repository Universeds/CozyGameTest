local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Replication = require(Global.Vendor.Replication)

export type NPCAuthStateData = {
    health: number,
    maxHealth: number,
    stateName: string,
    stateStartTime: number,
    flags: { [string]: boolean },
}

local NPCAuthState = {}

function NPCAuthState:add(entity: number, data: NPCAuthStateData?)
    return {
        health = data and data.health or 100,
        maxHealth = data and data.maxHealth or 100,
        stateName = data and data.stateName or "Idle",
        stateStartTime = data and data.stateStartTime or os.clock(),
        flags = data and data.flags or {},
    }
end

function NPCAuthState:remove(entity: number, comp: NPCAuthStateData) end

return Global.InjectLifecycleSignals(Replication.createReplicatedComponent({
    owner = "Server",
    transport = "Reliable",
}, NPCAuthState))
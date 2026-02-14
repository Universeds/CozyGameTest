local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Replication = require(Global.Vendor.Replication)

export type NPCIdentityData = {
    npcId: string,
    npcType: string,
    displayName: string,
    spawnPoint: Vector3,
    spawnRotation: number?,
}

local NPCIdentity = {}

function NPCIdentity:add(entity: number, data: NPCIdentityData)
    return {
        npcId = data.npcId,
        npcType = data.npcType,
        displayName = data.displayName,
        spawnPoint = data.spawnPoint,
        spawnRotation = data.spawnRotation or 0,
    }
end

function NPCIdentity:remove(entity: number, comp: NPCIdentityData) end

return Global.InjectLifecycleSignals(Replication.createReplicatedComponent({
    owner = "Server",
    transport = "Reliable",
}, NPCIdentity))
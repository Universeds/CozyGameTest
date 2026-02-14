local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Replication = require(Global.Vendor.Replication)

export type NPCTransformData = {
    position: Vector3,
    rotation: CFrame,
    velocity: Vector3,
    targetPosition: Vector3?,
}

local NPCTransform = {}

function NPCTransform:add(entity: number, data: NPCTransformData?)
    return {
        position = data and data.position or Vector3.zero,
        rotation = data and data.rotation or CFrame.identity,
        velocity = data and data.velocity or Vector3.zero,
        targetPosition = data and data.targetPosition or nil,
    }
end

function NPCTransform:remove(entity: number, comp: NPCTransformData) end

return Global.InjectLifecycleSignals(Replication.createReplicatedComponent({
    owner = "Server",
    transport = "Unreliable",
}, NPCTransform))

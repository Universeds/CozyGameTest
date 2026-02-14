--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local Global = require(ReplicatedStorage.Shared.Global)
local World = Global.World
local Replication = require(Global.Vendor.Replication)

local NPCIdentity = require(Global.Shared.NPC.Components.NPCIdentity)
local NPCBrain = require(Global.Shared.NPC.Components.NPCBrain)
local NPCAuthState = require(Global.Shared.NPC.Components.NPCAuthState)
local NPCTransform = require(Global.Shared.NPC.Components.NPCTransform)

local SpawnNPCs = {}

function SpawnNPCs.spawn(config: {
    npcType: string,
    displayName: string,
    position: Vector3,
    rotation: number?,
    modelTemplate: Model?,
})
    local entity = World.entity()
    local uniqueId = HttpService:GenerateGUID(false)
    
    local model = config.modelTemplate and config.modelTemplate:Clone() or nil
    if model then
        local rootPart = model:FindFirstChild("HumanoidRootPart") :: BasePart?
        if rootPart then
            model:PivotTo(CFrame.new(config.position) * CFrame.Angles(0, math.rad(config.rotation or 0), 0))
        end
        model.Parent = workspace.NPCs or workspace
    end
    
    Replication.ReplicatedEntity.add(entity, {
        uniqueId = uniqueId,
        instance = model,
    })
    
    NPCIdentity.add(entity, {
        npcId = uniqueId,
        npcType = config.npcType,
        displayName = config.displayName,
        spawnPoint = config.position,
        spawnRotation = config.rotation or 0,
    })
    
    NPCBrain.add(entity)
    NPCAuthState.add(entity)
    NPCTransform.add(entity, {
        position = config.position,
        rotation = CFrame.new(config.position) * CFrame.Angles(0, math.rad(config.rotation or 0), 0),
        velocity = Vector3.zero,
    })
    
    return entity, uniqueId
end

function SpawnNPCs.despawn(entity: number)
    local replicatedEntity = Replication.ReplicatedEntity.get(entity)
    if replicatedEntity and replicatedEntity.instance then
        replicatedEntity.instance:Destroy()
    end
    
    World.destroy(entity)
end

return SpawnNPCs

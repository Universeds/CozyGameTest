local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local World = Global.World
local Replication = require(Global.Vendor.Replication)

local NPCIdentity = require(Global.Shared.NPC.Components.NPCIdentity)
local NPCTransform = require(Global.Shared.NPC.Components.NPCTransform)
local NPCAuthState = require(Global.Shared.NPC.Components.NPCAuthState)
local NPCBrain = require(Global.Shared.NPC.Components.NPCBrain)

local SYNC_INTERVAL = 0.1
local lastSyncTime = 0

--#TODO make entities only on the client and positional data on server

local function syncNPCTransformFromModel(entity: number)
    local identity = NPCIdentity.get(entity)
    local transform = NPCTransform.get(entity)
    
    if not identity or not transform then return end
    
    local replicatedEntity = Replication.ReplicatedEntity.get(entity)
    if not replicatedEntity or not replicatedEntity.instance then return end
    
    local model = replicatedEntity.instance :: Model
    local rootPart = model:FindFirstChild("HumanoidRootPart") :: BasePart?
    
    if rootPart then
        local newPosition = rootPart.Position
        local newRotation = rootPart.CFrame
        local newVelocity = rootPart.AssemblyLinearVelocity
        
        if (newPosition - transform.position).Magnitude > 0.1 then
            transform.position = newPosition
            transform.rotation = newRotation
            transform.velocity = newVelocity
        end
    end
end

local function syncAllNPCTransforms()
    local currentTime = os.clock()
    if currentTime - lastSyncTime < SYNC_INTERVAL then return end
    lastSyncTime = currentTime
    
    for entity in World.query(NPCIdentity, NPCTransform) do
        syncNPCTransformFromModel(entity)
    end
end

return Global.Schedules.Heartbeat.job(syncAllNPCTransforms)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local World = Global.World

local NPCIdentity = require(Global.Shared.NPC.Components.NPCIdentity)
local NPCTransform = require(Global.Shared.NPC.Components.NPCTransform)
local NPCAuthState = require(Global.Shared.NPC.Components.NPCAuthState)

export type WorldState = { [string]: any }

local WorldStateBuilder = {}

function WorldStateBuilder.build(entity: number, customData: { [string]: any }?): WorldState
    local worldState: WorldState = {}
    
    local identity = NPCIdentity.get(entity)
    local transform = NPCTransform.get(entity)
    local authState = NPCAuthState.get(entity)
    
    if identity then
        worldState.npcType = identity.npcType
        worldState.spawnPoint = identity.spawnPoint
    end
    
    if transform then
        worldState.position = transform.position
        worldState.hasTarget = transform.targetPosition ~= nil
        worldState.targetDistance = transform.targetPosition 
            and (transform.position - transform.targetPosition).Magnitude 
            or math.huge
    end
    
    if authState then
        worldState.health = authState.health
        worldState.maxHealth = authState.maxHealth
        worldState.healthPercent = authState.health / authState.maxHealth * 100
        worldState.isDead = authState.flags.isDead or false
        worldState.isStunned = authState.flags.isStunned or false
        worldState.currentState = authState.stateName
    end
    
    worldState.nearbyThreats = 0
    worldState.nearbyNPCs = {}
    worldState.nearbyPlayers = {}
    
    if customData then
        for key, value in customData do
            worldState[key] = value
        end
    end
    
    return worldState
end

function WorldStateBuilder.update(worldState: WorldState, key: string, value: any): WorldState
    worldState[key] = value
    return worldState
end

return WorldStateBuilder

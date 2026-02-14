--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local World = Global.World
local Replication = require(Global.Vendor.Replication)

local NPCIdentity = require(Global.Shared.NPC.Components.NPCIdentity)
local NPCClientSim = require(Global.Shared.NPC.Components.NPCClientSim)
local StateController = require(Global.Shared.NPC.StateController)

local function setupClientNPCs()
    NPCIdentity.onAdded:Connect(function(entity)
        local identity = NPCIdentity.get(entity)
        if not identity then return end
        
        local replicatedEntity = Replication.ReplicatedEntity.get(entity)
        local model = replicatedEntity and replicatedEntity.instance or nil
        
        NPCClientSim.add(entity, { model = model })
        
        local clientSim = NPCClientSim.get(entity)
        if clientSim then
            local worldState = {}
            clientSim.stateController = StateController.new(entity, identity.npcType, worldState)
            clientSim.stateController:transition("Idle")
        end
    end)
    
    NPCIdentity.onRemoved:Connect(function(entity)
        local clientSim = NPCClientSim.get(entity)
        if clientSim then
            if clientSim.stateController then
                clientSim.stateController:destroy()
            end
            NPCClientSim.remove(entity)
        end
    end)
end

return Global.Schedules.Boot.job(setupClientNPCs)

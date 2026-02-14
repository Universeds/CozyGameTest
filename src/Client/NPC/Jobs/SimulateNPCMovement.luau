--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Global = require(ReplicatedStorage.Shared.Global)
local World = Global.World

local NPCTransform = require(Global.Shared.NPC.Components.NPCTransform)
local NPCClientSim = require(Global.Shared.NPC.Components.NPCClientSim)

local POSITION_CORRECTION_THRESHOLD = 3
local CORRECTION_LERP_SPEED = 10

local function simulateNPCClientMovement(dt)    
    for entity in World.query(NPCTransform, NPCClientSim) do
        local transform = NPCTransform.get(entity)
        local clientSim = NPCClientSim.get(entity)
        
        if not transform or not clientSim then continue end
        if not clientSim.rootPart then continue end
        
        local actualPosition = clientSim.rootPart.Position
        local serverPosition = transform.position
        
        local drift = (actualPosition - serverPosition).Magnitude
        
        if drift > POSITION_CORRECTION_THRESHOLD then
            local correctedPos = actualPosition:Lerp(serverPosition, CORRECTION_LERP_SPEED * dt)
            clientSim.rootPart.CFrame = CFrame.new(correctedPos) * (clientSim.rootPart.CFrame - clientSim.rootPart.Position)
        end
        
        clientSim.predictedPosition = actualPosition
    end
end

return Global.Schedules.Heartbeat.job(simulateNPCClientMovement)

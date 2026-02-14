local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(Global.Packages.Janitor)

local NPCTransform = require(Global.Shared.NPC.Components.NPCTransform)
local NPCClientSim = require(Global.Shared.NPC.Components.NPCClientSim)

local Flee = {}
Flee.Name = "Flee"

local FLEE_DISTANCE = 30
local SAFE_DISTANCE = 40

function Flee.enter(entity: number, context: any, threatPosition: Vector3?)
    local janitor = Janitor.new()
    
    local transform = NPCTransform.get(entity)
    local clientSim = NPCClientSim.get(entity)
    
    local fleeDirection = Vector3.new(1, 0, 0)
    if transform and threatPosition then
        fleeDirection = (transform.position - threatPosition).Unit
    end
    
    local fleeTarget = (transform and transform.position or Vector3.zero) + fleeDirection * FLEE_DISTANCE
    
    janitor:Add(RunService.Heartbeat:Connect(function(dt)
        local currentTransform = NPCTransform.get(entity)
        if not currentTransform then return end
        
        if threatPosition then
            local distanceToThreat = (currentTransform.position - threatPosition).Magnitude
            if distanceToThreat >= SAFE_DISTANCE then
                context.requestStateChange("Idle")
                return
            end
        end
        
        if clientSim and clientSim.humanoid then
            clientSim.humanoid.WalkSpeed = 20
            clientSim.humanoid:MoveTo(fleeTarget)
        end
    end), "Disconnect")
    
    janitor:Add(function()
        if clientSim and clientSim.humanoid then
            clientSim.humanoid.WalkSpeed = 16
        end
    end, true)
    
    return janitor
end

function Flee.canTransitionTo(targetState: string, context: any): boolean
    return targetState == "Idle"
end

return Flee

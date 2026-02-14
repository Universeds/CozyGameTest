local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(Global.Packages.Janitor)

local NPCTransform = require(Global.Shared.NPC.Components.NPCTransform)
local NPCClientSim = require(Global.Shared.NPC.Components.NPCClientSim)

local Wander = {}
Wander.Name = "Wander"

local WANDER_RADIUS = 20
local ARRIVAL_THRESHOLD = 2

local function getRandomWanderPoint(origin: Vector3): Vector3
    local angle = math.random() * math.pi * 2
    local distance = math.random() * WANDER_RADIUS
    return origin + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
end

function Wander.enter(entity: number, context: any)
    local janitor = Janitor.new()
    
    local transform = NPCTransform.get(entity)
    local clientSim = NPCClientSim.get(entity)
    
    local origin = transform and transform.position or Vector3.zero
    local targetPos = getRandomWanderPoint(origin)
    
    if transform then
        transform.targetPosition = targetPos
    end
    
    janitor:Add(RunService.Heartbeat:Connect(function(dt)
        local currentTransform = NPCTransform.get(entity)
        if not currentTransform then return end
        
        local distance = (currentTransform.position - targetPos).Magnitude
        
        if distance <= ARRIVAL_THRESHOLD then
            context.requestStateChange("Idle")
            return
        end
        
        if clientSim and clientSim.humanoid and clientSim.rootPart then
            clientSim.humanoid:MoveTo(targetPos)
        end
    end), "Disconnect")
    
    janitor:Add(function()
        if clientSim and clientSim.humanoid then
            clientSim.humanoid:MoveTo(clientSim.rootPart and clientSim.rootPart.Position or Vector3.zero)
        end
    end, true)
    
    return janitor
end

function Wander.canTransitionTo(targetState: string, context: any): boolean
    return targetState == "Idle" or targetState == "Interact" or targetState == "Flee"
end

return Wander

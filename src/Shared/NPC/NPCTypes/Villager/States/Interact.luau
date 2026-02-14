local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(Global.Packages.Janitor)

local NPCClientSim = require(Global.Shared.NPC.Components.NPCClientSim)

local Interact = {}
Interact.Name = "Interact"

local INTERACT_DURATION = 5

function Interact.enter(entity: number, context: any, targetEntity: number?)
    local janitor = Janitor.new()
    
    local interactTime = 0
    local clientSim = NPCClientSim.get(entity)
    
    if clientSim and clientSim.humanoid then
        clientSim.humanoid:MoveTo(clientSim.rootPart and clientSim.rootPart.Position or Vector3.zero)
    end
    
    janitor:Add(RunService.Heartbeat:Connect(function(dt)
        interactTime += dt
        
        if interactTime >= INTERACT_DURATION then
            context.requestStateChange("Idle")
        end
    end), "Disconnect")
    
    return janitor
end

function Interact.canTransitionTo(targetState: string, context: any): boolean
    return targetState == "Idle" or targetState == "Flee"
end

return Interact

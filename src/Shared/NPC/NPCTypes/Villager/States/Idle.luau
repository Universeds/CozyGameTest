local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(Global.Packages.Janitor)

local Idle = {}
Idle.Name = "Idle"

function Idle.enter(entity: number, context: any)
    local janitor = Janitor.new()
    
    local idleTime = 0
    local maxIdleTime = math.random(3, 8)
    
    janitor:Add(RunService.Heartbeat:Connect(function(dt)
        idleTime += dt
        
        if idleTime >= maxIdleTime then
            context.requestStateChange("Wander")
        end
    end), "Disconnect")
    
    return janitor
end

function Idle.canTransitionTo(targetState: string, context: any): boolean
    return targetState == "Wander" or targetState == "Interact" or targetState == "Flee"
end

return Idle

--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local World = Global.World

local Gizmo = require(Global.Packages.imgizmo)

local Debug = require(Global.Local.Debug.Component)
local NPCIdentity = require(Global.Shared.NPC.Components.NPCIdentity)
local NPCBrain = require(Global.Shared.NPC.Components.NPCBrain)
local NPCTransform = require(Global.Shared.NPC.Components.NPCTransform)
local NPCClientSim = require(Global.Shared.NPC.Components.NPCClientSim)

local STATE_COLORS = {
    Idle = Color3.fromRGB(100, 200, 100),
    Wander = Color3.fromRGB(100, 150, 255),
    Interact = Color3.fromRGB(255, 200, 100),
    Flee = Color3.fromRGB(255, 100, 100),
}

local function drawNPCState(entity: number, debugComp: any, dt: number)
    local identity = NPCIdentity.get(entity)
    local brain = NPCBrain.get(entity)
    local transform = NPCTransform.get(entity)
    local clientSim = NPCClientSim.get(entity)
    
    if not identity or not transform then return end
    
    local position = transform.position
    local currentState = "Unknown"
    
    if clientSim and clientSim.stateController then
        currentState = clientSim.stateController:getCurrentStateName() or "None"
    end
    
    local stateColor = STATE_COLORS[currentState] or Color3.fromRGB(150, 150, 150)
    
    Gizmo.SetStyle(stateColor, 0.5)
    Gizmo.Sphere:Draw(
        CFrame.new(position + Vector3.new(0, 4, 0)),
        0.5
    )
    
    Gizmo.SetStyle(stateColor)
    Gizmo.Text:Draw(
        CFrame.new(position + Vector3.new(0, 5.5, 0)),
        `{identity.displayName or identity.npcType}\n[{currentState}]`
    )
    
    if brain and brain.currentGoal then
        Gizmo.SetStyle(Color3.fromRGB(200, 200, 255))
        Gizmo.Text:Draw(
            CFrame.new(position + Vector3.new(0, 4.8, 0)),
            `Goal: {brain.currentGoal}`
        )
    end
    
    if transform.targetPosition then
        local targetPos = transform.targetPosition
        
        Gizmo.SetStyle(Color3.fromRGB(255, 255, 100), 0.3)
        Gizmo.Sphere:Draw(
            CFrame.new(targetPos),
            0.4
        )
        
        Gizmo.SetStyle(Color3.fromRGB(255, 255, 100), 0.5)
        Gizmo.Line:Draw(
            position + Vector3.new(0, 0.5, 0),
            targetPos + Vector3.new(0, 0.5, 0)
        )
    end
    
    if transform.velocity and transform.velocity.Magnitude > 0.1 then
        local velDir = transform.velocity.Unit * 2
        
        Gizmo.SetStyle(Color3.fromRGB(100, 255, 200))
        Gizmo.Arrow:Draw(
            position + Vector3.new(0, 1, 0),
            position + Vector3.new(0, 1, 0) + velDir
        )
    end
end

local function setupNPCDebugVisualization()
    NPCIdentity.added:Connect(function(entity)
        local debugComp = Debug.get(entity)
        if debugComp then
            Debug.registerDrawer(debugComp, drawNPCState)
        end
    end)
    
    Debug.added:Connect(function(entity)
        local identity = NPCIdentity.get(entity)
        if identity then
            local debugComp = Debug.get(entity)
            if debugComp then
                Debug.registerDrawer(debugComp, drawNPCState)
            end
        end
    end)
end

return Global.Schedules.Boot.job(setupNPCDebugVisualization)

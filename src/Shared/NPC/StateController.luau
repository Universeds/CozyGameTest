--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(Global.Packages.Janitor)
local Signal = require(Global.Packages.Signal)

export type StateModule = {
    Name: string,
    enter: (entity: number, context: StateContext) -> any,
    canTransitionTo: ((targetState: string, context: StateContext) -> boolean)?,
}

export type StateContext = {
    entity: number,
    npcType: string,
    worldState: { [string]: any },
    requestStateChange: (stateName: string, ...any) -> (),
    getState: (stateName: string) -> StateModule?,
}

export type StateController = {
    entity: number,
    npcType: string,
    states: { [string]: StateModule },
    currentState: StateModule?,
    currentJanitor: any?,
    stateChanged: any,
    context: StateContext,
    
    transition: (self: StateController, stateName: string, ...any) -> boolean,
    getCurrentStateName: (self: StateController) -> string?,
    destroy: (self: StateController) -> (),
}

local StateController = {}
StateController.__index = StateController

--#todo maybe cache loaded states across all controllers of the same npc type
local function loadStatesForType(npcType: string): { [string]: StateModule }
    local states = {}
    local statesFolder = ReplicatedStorage.Shared.NPC.NPCTypes:FindFirstChild(npcType)
    
    if not statesFolder then
        warn(`No states folder found for NPC type: {npcType}`)
        return states
    end
    
    local statesSubFolder = statesFolder:FindFirstChild("States")
    if not statesSubFolder then
        warn(`No States subfolder found for NPC type: {npcType}`)
        return states
    end
    
    for _, moduleScript in statesSubFolder:GetChildren() do
        if moduleScript:IsA("ModuleScript") then
            local success, stateModule = pcall(require, moduleScript)
            if success and stateModule.Name then
                states[stateModule.Name] = stateModule
            else
                warn(`Failed to load state: {moduleScript.Name}`)
            end
        end
    end
    
    return states
end

function StateController.new(entity: number, npcType: string, worldState: { [string]: any }?): StateController
    local self = setmetatable({}, StateController)
    
    self.entity = entity
    self.npcType = npcType
    self.states = loadStatesForType(npcType)
    self.currentState = nil
    self.currentJanitor = nil
    self.stateChanged = Signal.new()
    
    self.context = {
        entity = entity,
        npcType = npcType,
        worldState = worldState or {},
        requestStateChange = function(stateName: string, ...)
            self:transition(stateName, ...)
        end,
        getState = function(stateName: string)
            return self.states[stateName]
        end,
    }
    
    return self
end

function StateController:transition(stateName: string, ...): boolean
    local targetState = self.states[stateName]
    
    if not targetState then
        warn(`State not found: {stateName} for NPC type: {self.npcType}`)
        return false
    end
    
    if self.currentState then
        if self.currentState.canTransitionTo then
            if not self.currentState.canTransitionTo(stateName, self.context) then
                return false
            end
        end
        
        if self.currentJanitor then
            self.currentJanitor:Destroy()
            self.currentJanitor = nil
        end
    end
    
    local previousState = self.currentState
    self.currentState = targetState
    self.currentJanitor = targetState.enter(self.entity, self.context, ...)
    
    self.stateChanged:Fire(previousState and previousState.Name, stateName)
    
    return true
end

function StateController:getCurrentStateName(): string?
    return self.currentState and self.currentState.Name or nil
end

function StateController:destroy()
    if self.currentJanitor then
        self.currentJanitor:Destroy()
        self.currentJanitor = nil
    end
    
    self.stateChanged:Destroy()
    self.currentState = nil
end

return StateController

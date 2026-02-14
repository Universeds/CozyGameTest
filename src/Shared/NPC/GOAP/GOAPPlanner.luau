local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type WorldState = { [string]: any }

export type Goal = {
    name: string,
    priority: number,
    desiredState: { [string]: any },
    relevance: (worldState: WorldState) -> boolean,
}

export type Action = {
    name: string,
    cost: number,
    preconditions: { [string]: any },
    effects: { [string]: any },
    associatedState: string,
}

export type Plan = {
    goal: Goal,
    actions: { Action },
    totalCost: number,
}

--#todo might wanna add action sequences/chaining for more complex behaviors
--#todo could add heuristics to the a* search for better performance

local GOAPPlanner = {}
GOAPPlanner.__index = GOAPPlanner

local function meetsCondition(worldState: WorldState, key: string, condition: any): boolean
    local value = worldState[key]
    
    if type(condition) == "table" then
        if condition.min and value < condition.min then return false end
        if condition.max and value > condition.max then return false end
        if condition.equals ~= nil and value ~= condition.equals then return false end
        return true
    end
    
    return value == condition
end

local function meetsAllConditions(worldState: WorldState, conditions: { [string]: any }): boolean
    for key, condition in conditions do
        if not meetsCondition(worldState, key, condition) then
            return false
        end
    end
    return true
end

local function applyEffects(worldState: WorldState, effects: { [string]: any }): WorldState
    local newState = table.clone(worldState)
    for key, value in effects do
        newState[key] = value
    end
    return newState
end

local function goalSatisfied(worldState: WorldState, goal: Goal): boolean
    return meetsAllConditions(worldState, goal.desiredState)
end

function GOAPPlanner.new()
    local self = setmetatable({}, GOAPPlanner)
    self.goals = {} :: { Goal }
    self.actions = {} :: { Action }
    return self
end

function GOAPPlanner:registerGoal(goal: Goal)
    table.insert(self.goals, goal)
    table.sort(self.goals, function(a, b)
        return a.priority > b.priority
    end)
end

function GOAPPlanner:registerAction(action: Action)
    table.insert(self.actions, action)
end

function GOAPPlanner:getAvailableActions(worldState: WorldState): { Action }
    local available = {}
    for _, action in self.actions do
        if meetsAllConditions(worldState, action.preconditions) then
            table.insert(available, action)
        end
    end
    return available
end

--#todo this a* search could use some optimization, maybe cache partial plans
function GOAPPlanner:findPlan(worldState: WorldState, goal: Goal, maxDepth: number?): Plan?
    maxDepth = maxDepth or 10
    
    if goalSatisfied(worldState, goal) then
        return { goal = goal, actions = {}, totalCost = 0 }
    end
    
    local openSet = {{
        state = worldState,
        actions = {},
        cost = 0,
    }}
    
    local visited = {}
    
    while #openSet > 0 do
        table.sort(openSet, function(a, b)
            return a.cost < b.cost
        end)
        
        local current = table.remove(openSet, 1)
        
        if #current.actions >= maxDepth then
            continue
        end
        
        local stateKey = ""
        for k, v in current.state do
            stateKey = stateKey .. tostring(k) .. "=" .. tostring(v) .. ";"
        end
        
        if visited[stateKey] then
            continue
        end
        visited[stateKey] = true
        
        local availableActions = self:getAvailableActions(current.state)
        
        for _, action in availableActions do
            local newState = applyEffects(current.state, action.effects)
            local newActions = table.clone(current.actions)
            table.insert(newActions, action)
            local newCost = current.cost + action.cost
            
            if goalSatisfied(newState, goal) then
                return {
                    goal = goal,
                    actions = newActions,
                    totalCost = newCost,
                }
            end
            
            table.insert(openSet, {
                state = newState,
                actions = newActions,
                cost = newCost,
            })
        end
    end
    
    return nil
end

function GOAPPlanner:selectGoalAndPlan(worldState: WorldState): (Goal?, Plan?)
    for _, goal in self.goals do
        if goal.relevance(worldState) then
            local plan = self:findPlan(worldState, goal)
            if plan and #plan.actions > 0 then
                return goal, plan
            end
        end
    end
    return nil, nil
end

function GOAPPlanner:getNextAction(worldState: WorldState): (string?, string?)
    local goal, plan = self:selectGoalAndPlan(worldState)
    
    if plan and #plan.actions > 0 then
        local firstAction = plan.actions[1]
        return goal.name, firstAction.associatedState
    end
    
    return nil, nil
end

return GOAPPlanner

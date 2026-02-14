return function(context, stateName)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Global = require(ReplicatedStorage.Shared.Global)

    local stateMachine = Global.World.StateMachine
    if not stateMachine then
        return "State machine not initialized yet"
    end

    local newState = stateMachine[stateName]
    if not newState then
        return string.format("State '%s' does not exist", stateName)
    end

    if newState == stateMachine.CurrentState then
        return string.format("Already in state '%s'", stateName)
    end

    stateMachine:Transition(newState)
    return string.format("Successfully transitioned to '%s' state", stateName)
end
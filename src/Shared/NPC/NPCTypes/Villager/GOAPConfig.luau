local GOAPConfig = {}

GOAPConfig.Goals = {
    {
        name = "StaySafe",
        priority = 100,
        desiredState = {
            nearbyThreats = 0,
        },
        relevance = function(worldState)
            return worldState.nearbyThreats > 0
        end,
    },
    {
        name = "Socialize",
        priority = 50,
        desiredState = {
            recentlyInteracted = true,
        },
        relevance = function(worldState)
            return worldState.nearbyNPCs and #worldState.nearbyNPCs > 0 
                and not worldState.recentlyInteracted
        end,
    },
    {
        name = "Explore",
        priority = 20,
        desiredState = {
            hasExplored = true,
        },
        relevance = function(worldState)
            return not worldState.hasExplored
        end,
    },
    {
        name = "Rest",
        priority = 10,
        desiredState = {
            isResting = true,
        },
        relevance = function(worldState)
            return true
        end,
    },
}

GOAPConfig.Actions = {
    {
        name = "FleeFromThreat",
        cost = 1,
        preconditions = {
            nearbyThreats = { min = 1 },
        },
        effects = {
            nearbyThreats = 0,
        },
        associatedState = "Flee",
    },
    {
        name = "TalkToNPC",
        cost = 5,
        preconditions = {
            nearbyThreats = 0,
        },
        effects = {
            recentlyInteracted = true,
        },
        associatedState = "Interact",
    },
    {
        name = "WanderAround",
        cost = 3,
        preconditions = {
            nearbyThreats = 0,
        },
        effects = {
            hasExplored = true,
        },
        associatedState = "Wander",
    },
    {
        name = "StandIdle",
        cost = 1,
        preconditions = {},
        effects = {
            isResting = true,
        },
        associatedState = "Idle",
    },
}

return GOAPConfig

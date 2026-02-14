local PlayerEntityTracker = {}

local cache = {}

function PlayerEntityTracker.add(entity: number, player: Player)
	cache[player] = entity
end

function PlayerEntityTracker.remove(player: Player)
	cache[player] = nil
end

function PlayerEntityTracker.get(player: Player): number
	return cache[player]
end

return PlayerEntityTracker

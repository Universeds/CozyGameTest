local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Stew = require(ReplicatedStorage.Packages.Stew)

local World = Stew.world {}

function World:spawned(entity)
	if typeof(entity) == "Instance" then
		--error(`Attempted to establish an instance "{entity}" as an entity `) TBH i couldn't figure out a bug so i just disabled this for now  @uni
	end
end

return World

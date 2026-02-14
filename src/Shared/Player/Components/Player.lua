local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Janitor = require(Global.Packages.Janitor)

local PlayerEntityTracker =
	require(Global.Shared.Player.Modules.PlayerEntityTracker)

local Component = {}

function Component:add(entity, instance: Player)
	PlayerEntityTracker.add(entity, instance)
	return {
		janitor = Janitor.new(),
		instance = instance,
	}
end

function Component:remove(_, comp)
	PlayerEntityTracker.remove(comp.instance)
	comp.janitor:Destroy()
end

return Global.World.factory(Global.InjectLifecycleSignals(Component))

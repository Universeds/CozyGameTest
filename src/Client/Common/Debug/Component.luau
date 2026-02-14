--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Janitor = require(Global.Packages.Janitor)
local Gizmo = require(Global.Packages.imgizmo)

Gizmo.Init()

export type DebugDrawer = (entity: any, comp: any, dt: number) -> nil

local Debug = {}

function Debug:add(_, model)
	local janitor = Janitor.new()
	local comp = {
		janitor = janitor,
		drawers = {} :: { DebugDrawer },
		enabled = false,
	}

	return comp
end

function Debug:remove(_, comp)
	comp.janitor:Destroy()
end

function Debug.registerDrawer(comp: any, drawer: DebugDrawer)
	table.insert(comp.drawers, drawer)
end

function Debug.clearDrawers(comp: any)
	table.clear(comp.drawers)
end

return Global.World.factory(Global.InjectLifecycleSignals(Debug))

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(Global.Packages.Janitor)

local DebugPanel = {}

function DebugPanel:add(_, entity)
	local janitor = Janitor.new()
	
	local comp = {
		janitor = janitor,
		enabled = false,
		selectedObject = nil,
		selectionHighlight = nil,
		offsetX = 0,
		offsetY = 0,
		offsetZ = 0,
		cameraSettings = {
			subjectName = "Head",
			bendToFollowCamera = true,
			rotateCharacterYawToFollowCamera = true,
			minTorsoPercent = 1,
			maxTorsoPercent = 1,
			torsoWeight = 1,
		},
	}
	
	return comp
end

function DebugPanel:remove(_, comp)
	if comp.selectionHighlight then
		comp.selectionHighlight:Destroy()
	end
	comp.janitor:Destroy()
end

return Global.World.factory(Global.InjectLifecycleSignals(DebugPanel))

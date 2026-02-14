local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(Global.Packages.Janitor)

local ObjectSelector = {}
ObjectSelector.__index = ObjectSelector

function ObjectSelector.new()
	local self = setmetatable({}, ObjectSelector)
	self.janitor = Janitor.new()
	self.selectedObject = nil
	self.highlight = nil
	self.enabled = false
	self.onSelectionChanged = nil
	return self
end

function ObjectSelector:enable()
	self.enabled = true
	
	self.janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if not self.enabled then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:trySelect()
		end
	end))
end

function ObjectSelector:disable()
	self.enabled = false
	self.janitor:Cleanup()
	self:clearSelection()
end

function ObjectSelector:trySelect()
	local camera = workspace.CurrentCamera
	local mouse = Players.LocalPlayer:GetMouse()
	
	local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local character = Players.LocalPlayer.Character
	if character then
		raycastParams.FilterDescendantsInstances = {character}
	end
	
	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
	
	if result and result.Instance then
		self:select(result.Instance)
	else
		self:clearSelection()
	end
end

function ObjectSelector:select(object)
	self:clearSelection()
	
	self.selectedObject = object
	
	self.highlight = Instance.new("Highlight")
	self.highlight.FillColor = Color3.fromRGB(0, 170, 255)
	self.highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	self.highlight.FillTransparency = 0.7
	self.highlight.OutlineTransparency = 0
	self.highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	
	local target = object
	if object:IsA("BasePart") then
		local model = object:FindFirstAncestorOfClass("Model")
		if model then
			target = model
		end
	end
	
	self.highlight.Adornee = target
	self.highlight.Parent = workspace
	
	if self.onSelectionChanged then
		self.onSelectionChanged(self.selectedObject)
	end
end

function ObjectSelector:clearSelection()
	if self.highlight then
		self.highlight:Destroy()
		self.highlight = nil
	end
	
	local hadSelection = self.selectedObject ~= nil
	self.selectedObject = nil
	
	if hadSelection and self.onSelectionChanged then
		self.onSelectionChanged(nil)
	end
end

function ObjectSelector:getSelectedObject()
	return self.selectedObject
end

function ObjectSelector:applyOffset(offset: Vector3)
	if not self.selectedObject then return end
	
	if self.selectedObject:IsA("BasePart") then
		self.selectedObject.CFrame = self.selectedObject.CFrame + offset
	elseif self.selectedObject:IsA("Model") and self.selectedObject.PrimaryPart then
		self.selectedObject:SetPrimaryPartCFrame(self.selectedObject.PrimaryPart.CFrame + offset)
	end
end

function ObjectSelector:destroy()
	self:clearSelection()
	self.janitor:Destroy()
end

return ObjectSelector

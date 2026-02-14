local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Global = require(ReplicatedStorage.Shared.Global)
local Iris = require(Global.Packages.Iris)
local OffsetCamera = require(Global.Assets.RBXPackages.OffsetCamera)
local ObjectSelector = require(script.Parent.Parent.Modules.ObjectSelector)

local panelEnabled = false
local selector = ObjectSelector.new()

local subjectName = Iris.State("Head")
local bendToFollowCamera = Iris.State(true)
local rotateCharacterYaw = Iris.State(true)
local minTorsoPercent = Iris.State(1)
local maxTorsoPercent = Iris.State(1)
local torsoWeight = Iris.State(1)
local cameraEnabled = Iris.State(true)

local firstPersonOffsetX = Iris.State(0)
local firstPersonOffsetY = Iris.State(0.5)
local firstPersonOffsetZ = Iris.State(-0.5)

local thirdPersonOffsetX = Iris.State(0)
local thirdPersonOffsetY = Iris.State(0)
local thirdPersonOffsetZ = Iris.State(0)

local attachedObject = nil
local attachedObjectName = Iris.State("None")
local attachOffsetX = Iris.State(0)
local attachOffsetY = Iris.State(2)
local attachOffsetZ = Iris.State(5)

local attachRotX = Iris.State(0)
local attachRotY = Iris.State(180)
local attachRotZ = Iris.State(0)

local cameraWindowOpen = Iris.State(true)
local mainWindowOpen = Iris.State(true)
local pickerActive = Iris.State(false)
local playerNamesHidden = Iris.State(false)

local function applyCameraSettings()
	OffsetCamera.settings.subjectName = subjectName:get()
	OffsetCamera.settings.bendToFollowCamera = bendToFollowCamera:get()
	OffsetCamera.settings.rotateCharacterYawToFollowCamera = rotateCharacterYaw:get()
	OffsetCamera.settings.MinTorsoPercent = minTorsoPercent:get()
	OffsetCamera.settings.MaxTorsoPercent = maxTorsoPercent:get()
	OffsetCamera.settings.TorsoWeight = torsoWeight:get()
	
	OffsetCamera.settings.offsets = {
		[Players.LocalPlayer.CameraMinZoomDistance] = CFrame.new(
			firstPersonOffsetX:get(),
			firstPersonOffsetY:get(),
			firstPersonOffsetZ:get()
		),
		[3] = CFrame.new(
			thirdPersonOffsetX:get(),
			thirdPersonOffsetY:get(),
			thirdPersonOffsetZ:get()
		),
	}
	
	if cameraEnabled:get() then
		OffsetCamera.enable()
	else
		OffsetCamera.disable()
	end
end

local function attachCameraToObject(obj)
	attachedObject = obj
	if obj then
		attachedObjectName:set(obj.Name)
	else
		attachedObjectName:set("None")
	end
end

local function updateAttachedCamera()
	if not attachedObject then return end
	if not attachedObject:IsA("BasePart") and not attachedObject:IsA("Model") then return end
	
	local targetPart = attachedObject
	if attachedObject:IsA("Model") then
		targetPart = attachedObject.PrimaryPart or attachedObject:FindFirstChildWhichIsA("BasePart")
	end
	
	if not targetPart then return end
	
	local offset = CFrame.new(attachOffsetX:get(), attachOffsetY:get(), attachOffsetZ:get())
	local rotation = CFrame.Angles(
		math.rad(attachRotX:get()),
		math.rad(attachRotY:get()),
		math.rad(attachRotZ:get())
	)
	local targetCFrame = targetPart.CFrame * offset * rotation
	
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = targetCFrame
end

local function applyPresetForward()
	attachOffsetX:set(0)
	attachOffsetY:set(0)
	attachOffsetZ:set(-5)
	attachRotX:set(0)
	attachRotY:set(0)
	attachRotZ:set(0)
end

local function applyPresetRight()
	attachOffsetX:set(5)
	attachOffsetY:set(0)
	attachOffsetZ:set(0)
	attachRotX:set(0)
	attachRotY:set(-90)
	attachRotZ:set(0)
end

local function applyPresetUp()
	attachOffsetX:set(0)
	attachOffsetY:set(5)
	attachOffsetZ:set(0)
	attachRotX:set(90)
	attachRotY:set(0)
	attachRotZ:set(0)
end

local function resetPosition()
	attachOffsetX:set(0)
	attachOffsetY:set(2)
	attachOffsetZ:set(5)
end

local function resetRotation()
	attachRotX:set(0)
	attachRotY:set(180)
	attachRotZ:set(0)
end

local function detachCamera()
	attachedObject = nil
	attachedObjectName:set("None")
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end

local function togglePlayerNames()
	local hidden = not playerNamesHidden:get()
	playerNamesHidden:set(hidden)
	
	for _, player in Players:GetPlayers() do
		if player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.DisplayDistanceType = hidden and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
			end
		end
	end
end

local function renderCameraWindow()
	if not cameraWindowOpen:get() then return end
	
	Iris.Window({"Camera Settings"}, {
		size = Iris.State(Vector2.new(320, 450)),
		position = Iris.State(Vector2.new(380, 100)),
		isOpened = cameraWindowOpen,
	})
	
	Iris.SameLine()
	Iris.Checkbox({"OffsetCamera Enabled"}, {isChecked = cameraEnabled})
	Iris.End()
	
	Iris.Separator()
	
	Iris.InputText({"Subject Name"}, {text = subjectName})
	Iris.Checkbox({"Bend To Follow Camera"}, {isChecked = bendToFollowCamera})
	Iris.Checkbox({"Rotate Character Yaw"}, {isChecked = rotateCharacterYaw})
	
	Iris.Separator()
	Iris.Text({"Torso Settings"})
	
	Iris.DragNum({"Min Torso %", 0.01, 0, 1}, {number = minTorsoPercent})
	Iris.DragNum({"Max Torso %", 0.01, 0, 1}, {number = maxTorsoPercent})
	Iris.DragNum({"Torso Weight", 0.01, 0, 1}, {number = torsoWeight})
	
	Iris.Separator()
	Iris.Text({"First Person Offset"})
	
	Iris.DragNum({"1P X", 0.1, -10, 10}, {number = firstPersonOffsetX})
	Iris.DragNum({"1P Y", 0.1, -10, 10}, {number = firstPersonOffsetY})
	Iris.DragNum({"1P Z", 0.1, -10, 10}, {number = firstPersonOffsetZ})
	
	Iris.Separator()
	Iris.Text({"Third Person Offset"})
	
	Iris.DragNum({"3P X", 0.1, -10, 10}, {number = thirdPersonOffsetX})
	Iris.DragNum({"3P Y", 0.1, -10, 10}, {number = thirdPersonOffsetY})
	Iris.DragNum({"3P Z", 0.1, -10, 10}, {number = thirdPersonOffsetZ})
	
	Iris.Separator()
	
	if Iris.Button({"Apply Settings"}).clicked() then
		applyCameraSettings()
	end
	
	Iris.End()
end

local function togglePicker()
	local isActive = pickerActive:get()
	pickerActive:set(not isActive)
	
	if not isActive then
		selector:enable()
	else
		selector:disable()
	end
end

local function renderMainWindow()
	if not mainWindowOpen:get() then return end
	
	Iris.Window({"Debug Panel"}, {
		size = Iris.State(Vector2.new(350, 600)),
		position = Iris.State(Vector2.new(20, 100)),
		isOpened = mainWindowOpen,
	})
	
	Iris.Text({"Press G to toggle panel"})
	
	Iris.Separator()
	
	local utilsHeader = Iris.CollapsingHeader({"Utilities"})
	
	if utilsHeader.state.isUncollapsed.value then
		local namesButtonText = playerNamesHidden:get() and "Show Player Names" or "Hide Player Names"
		if Iris.Button({namesButtonText}).clicked() then
			togglePlayerNames()
		end
	end
	
	Iris.End()
	
	local attachHeader = Iris.CollapsingHeader({"Camera Attachment"})
	
	if attachHeader.state.isUncollapsed.value then
		local pickerButtonText = pickerActive:get() and "Stop Picking" or "Pick Object"
		if Iris.Button({pickerButtonText}).clicked() then
			togglePicker()
		end
		
		if pickerActive:get() then
			Iris.Text({"Click on an object to select it"})
		end
		
		Iris.Separator()
		
		Iris.Text({"Attached to: " .. attachedObjectName:get()})
		
		if attachedObject then
			local targetPart = attachedObject
			if attachedObject:IsA("Model") then
				targetPart = attachedObject.PrimaryPart or attachedObject:FindFirstChildWhichIsA("BasePart")
			end
			
			if targetPart and targetPart:IsA("BasePart") then
				local pos = targetPart.Position
				Iris.Text({string.format("Position: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)})
			end
		end
		
		Iris.Separator()
		
		Iris.SameLine()
		Iris.Text({"Position Offset"})
		if Iris.Button({"Reset Pos"}).clicked() then
			resetPosition()
		end
		Iris.End()
		
		Iris.SameLine()
		Iris.DragNum({"X##pos", 0.5, -50, 50}, {number = attachOffsetX})
		if Iris.Button({"0##posx"}).clicked() then
			attachOffsetX:set(0)
		end
		Iris.End()
		
		Iris.SameLine()
		Iris.DragNum({"Y##pos", 0.5, -50, 50}, {number = attachOffsetY})
		if Iris.Button({"0##posy"}).clicked() then
			attachOffsetY:set(0)
		end
		Iris.End()
		
		Iris.SameLine()
		Iris.DragNum({"Z##pos", 0.5, -50, 50}, {number = attachOffsetZ})
		if Iris.Button({"0##posz"}).clicked() then
			attachOffsetZ:set(0)
		end
		Iris.End()
		
		Iris.Separator()
		
		Iris.SameLine()
		Iris.Text({"Rotation Offset"})
		if Iris.Button({"Reset Rot"}).clicked() then
			resetRotation()
		end
		Iris.End()
		
		Iris.SameLine()
		Iris.DragNum({"X##rot", 1, -180, 180}, {number = attachRotX})
		if Iris.Button({"0##rotx"}).clicked() then
			attachRotX:set(0)
		end
		Iris.End()
		
		Iris.SameLine()
		Iris.DragNum({"Y##rot", 1, -180, 180}, {number = attachRotY})
		if Iris.Button({"0##roty"}).clicked() then
			attachRotY:set(0)
		end
		Iris.End()
		
		Iris.SameLine()
		Iris.DragNum({"Z##rot", 1, -180, 180}, {number = attachRotZ})
		if Iris.Button({"0##rotz"}).clicked() then
			attachRotZ:set(0)
		end
		Iris.End()
		
		Iris.Separator()
		Iris.Text({"Presets"})
		
		Iris.SameLine()
		if Iris.Button({"Forward"}).clicked() then
			applyPresetForward()
		end
		if Iris.Button({"Right"}).clicked() then
			applyPresetRight()
		end
		if Iris.Button({"Up"}).clicked() then
			applyPresetUp()
		end
		Iris.End()
		
		Iris.Separator()
		
		if Iris.Button({"Detach Camera"}).clicked() then
			detachCamera()
		end
	end
	
	Iris.End()
	
	Iris.Separator()
	
	if not cameraWindowOpen:get() then
		if Iris.Button({"Open Camera Window"}).clicked() then
			cameraWindowOpen:set(true)
		end
	end
	
	Iris.End()
end

local function renderDebugPanel()
	if attachedObject then
		updateAttachedCamera()
	end
	
	if not panelEnabled then return end
	
	renderMainWindow()
	renderCameraWindow()
end

local function setupDebugPanel()
	Iris.Init()
	
	selector.onSelectionChanged = function(obj)
		if obj then
			attachCameraToObject(obj)
			pickerActive:set(false)
			selector:disable()
		end
	end
	
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.G then
			panelEnabled = not panelEnabled
			
			if panelEnabled then
				mainWindowOpen:set(true)
				cameraWindowOpen:set(true)
			end
		end
	end)
	
	Iris:Connect(renderDebugPanel)
end

return Global.Schedules.Init.job(setupDebugPanel)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Global = require(ReplicatedStorage.Shared.Global)

local PlayerEntityTracker =
	require(Global.Shared.Player.Modules.PlayerEntityTracker)

local Player = require(Global.Shared.Player.Components.Player)


local function BootPlayer(playerInstance)
	local playerEntity = Global.World.entity()
	Player.add(playerEntity, playerInstance)
end

local function ListenPlayerAdded()
	Global.DEBUG("SetupPlayers Booted!")

	for _, playerInstance in Players:GetPlayers() do
		BootPlayer(playerInstance)
	end

	Players.PlayerAdded:Connect(BootPlayer)
	Players.PlayerRemoving:Connect(function(playerInstance)
		local playerEntity = PlayerEntityTracker.get(playerInstance)
		assert(playerEntity, "Player entity not found for player: " .. playerInstance.Name)
		
		Player.remove(playerEntity)
	end)
end

return Global.Schedules.Boot.job(ListenPlayerAdded)

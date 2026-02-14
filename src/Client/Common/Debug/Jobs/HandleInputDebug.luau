local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Global = require(ReplicatedStorage.Shared.Global)
local Debug = require(Global.Local.Debug.Component)

local LocalCharacter = require(Global.Local.Characters.LocalCharacter.Component)
local PlayerEntityTracker = require(Global.Shared.Player.Modules.PlayerEntityTracker)

local function setupInputDebug()
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == Enum.KeyCode.K and not gameProcessedEvent then
            local entity = PlayerEntityTracker.get(Players.LocalPlayer)
            if not entity then return end

           local DebugComp = Debug.get(entity)

           DebugComp.enabled = not DebugComp.enabled
        end
    end)
end


return Global.Schedules.Init.job(setupInputDebug)
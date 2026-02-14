local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local NPCService = require(Global.Local.NPC.Modules.NPCService)

--#todo also gotta make sure to make a clean up asystem for npcs
local function spawnNPCs()
    NPCService.spawn({
        npcType = "Villager", 
        name = "Bob", 
        position = Vector3.new(0, 10, 0), 
        modelTemplate = ReplicatedStorage.Assets.NPC
    })

end

return Global.Schedules.Boot.job(spawnNPCs)
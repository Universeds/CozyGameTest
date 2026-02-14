--!strict

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local ReplicatedEntity = {}

function ReplicatedEntity:add(entity, initialData)
	local uniqueId = initialData and initialData.uniqueId
	
	if not uniqueId and RunService:IsServer() then
		uniqueId = HttpService:GenerateGUID(false)
	end
	
	return {
		uniqueId = uniqueId,
		ownerId = initialData and initialData.ownerId or nil,
		instance = initialData and initialData.instance or nil,
	}
end

function ReplicatedEntity:remove(entity, comp)
	if comp.instance and comp.instance:IsA("Instance") then
		comp.instance:SetAttribute("EntityUniqueId", nil)
	end
end

return ReplicatedEntity

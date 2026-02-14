local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(Global.Packages.Janitor)

export type NPCClientSimData = {
    predictedPosition: Vector3,
    humanoid: Humanoid?,
    rootPart: BasePart?,
    model: Model?,
    stateController: any?,
    janitor: any,
}

local NPCClientSim = {}

function NPCClientSim:add(entity: number, data: { model: Model? }?)
    local janitor = Janitor.new()
    local model = data and data.model or nil
    
    return {
        predictedPosition = Vector3.zero,
        humanoid = model and model:FindFirstChildOfClass("Humanoid") or nil,
        rootPart = model and model:FindFirstChild("HumanoidRootPart") or nil,
        model = model,
        stateController = nil,
        janitor = janitor,
    }
end

function NPCClientSim:remove(entity: number, comp: NPCClientSimData)
    if comp.janitor then
        comp.janitor:Destroy()
    end
end

return Global.World.factory(Global.InjectLifecycleSignals(NPCClientSim))

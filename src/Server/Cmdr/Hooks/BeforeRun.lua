return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		local Player: Player = context.Executor
		if Player:GetRankInGroup(9667466) < 250 then
			return "You don't have permission to run this command"
		end
	end)
end

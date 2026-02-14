return {
	Name = "changestate",
	Aliases = {"cs"},
	Description = "Changes the current game state",
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "stateName",
			Description = "The name of the state to change to (e.g. Lobby, TNTTag)",
		},
	},
}

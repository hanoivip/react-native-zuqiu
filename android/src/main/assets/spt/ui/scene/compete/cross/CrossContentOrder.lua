local CrossContentOrder =
{
	Universe_Knockout = "1", -- 宇宙淘汰赛
	Universe_Team = "2", -- 宇宙小组
	Universe_Additional = "3", -- 宇宙预选
	Galaxy_Knockout = "4", -- 银河淘汰
	Galaxy_Team = "5", -- 银河小组
	Galaxy_Additional = "6", -- 银河预选
	TeamScore = "teamScore", -- 小组积分赛
}

CrossContentOrder.Type = 
{
	UniverseType = 1,
	GalaxyType = 2,
}

CrossContentOrder.UniverseSortOrder = 
{
	[CrossContentOrder.Universe_Knockout] = 4,
	[CrossContentOrder.Universe_Team] = 2,
	[CrossContentOrder.TeamScore] = 3,
	[CrossContentOrder.Universe_Additional] = 1,
}

CrossContentOrder.GalaxySortOrder = 
{
	[CrossContentOrder.Galaxy_Knockout] = 4,
	[CrossContentOrder.Galaxy_Team] = 2,
	[CrossContentOrder.TeamScore] = 3,
	[CrossContentOrder.Galaxy_Additional] = 1,
}

CrossContentOrder.TeamScoreKey = 
{
	[CrossContentOrder.Type.UniverseType] = 2,
	[CrossContentOrder.Type.GalaxyType] = 5,
}

return CrossContentOrder
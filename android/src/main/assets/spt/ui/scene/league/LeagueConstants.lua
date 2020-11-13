local LeagueConstants = {}

--- 联赛欢迎界面中联赛等级金字塔上的指引线数据
LeagueConstants.PyramidLineData = {
    {
        POINT = {X = -252.1, Y = -206.3},
    },
    {
        POINT = {X = -247, Y = -169.4},
    },
    {
        POINT = {X = -242, Y = -131.7},
    },
    {
        POINT = {X = -237, Y = -94.7},
    },
    {
        POINT = {X = -231.4, Y = -57.7},
    },
    {
        POINT = {X = -226.4, Y = -20},
    },
    {
        POINT = {X = -220.8, Y = 17.8},
    },
    {
        POINT = {X = -215.4, Y = 54.8},
    },
    {
        POINT = {X = -209.9, Y = 92.5},
    },
    {
        POINT = {X = -205, Y = 130.2},
    },
}

--- 联赛排行榜界面中联赛等级金字塔上的指引线数据
LeagueConstants.RankPyramidLineData = {
    {
        POINT = {X = -160, Y = -111},
    },
    {
        POINT = {X = -173.3, Y = -81.2},
    },
    {
        POINT = {X = -186, Y = -53.3},
    },
    {
        POINT = {X = -200.6, Y = -22.1},
    },
    {
        POINT = {X = -214.6, Y = 7.5},
    },
    {
        POINT = {X = -228.8, Y = 37.3},
    },
    {
        POINT = {X = -242.4, Y = 66.9},
    },
    {
        POINT = {X = -256.5, Y = 98.1},
    },
    {
        POINT = {X = -271.4, Y = 130},
    },
    {
        POINT = {X = -284.4, Y = 156.9},
    },
}

--- 联赛最大等级
LeagueConstants.LeagueMaxLevel = 10

--- 联赛每日比赛次数
LeagueConstants.MaxMatchTimes = 5

--- 参赛队伍总数
LeagueConstants.TeamSum = 8

--- 队伍类型
LeagueConstants.TeamType = {
    PLAYER = "player",
    NPC = "npc",
}

--- 队伍主客场类型
LeagueConstants.HomeAndAway = {
    -- 客场
    AWAY = 0,
    -- 主场
    HOME = 1,
    -- 中立
    NEUTRAL = 2,
}

--- 赞助商类型
LeagueConstants.SponsorType = {
    -- 赛季开始一次性获得赞助费
    PAY_IN_FULL = 1,
    -- 每赢一场比赛获得一次赞助费
    EVERY_TIME_TO_PAY = 2,
}

--- 主界面动画位置列表
LeagueConstants.MainPageAnimPosList = {
    {POS = {-200, 0, 100}, ALPHA = 0.3},
    {POS = {0, 0, 0}, ALPHA = 1},
    {POS = {200, 0, 100}, ALPHA = 0.3},
}

--- 主界面动画位置列表中间位置索引
LeagueConstants.MainPageMiddleAnimPosIndex = 2

--- 名次名称
LeagueConstants.RankName = {"1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th"}

--- 榜单类型
LeagueConstants.BoardType = {
    -- 积分榜
    SCORE = 1,
    -- 射手榜
    SHOOT = 2,
    -- 助攻榜
    ASSIST = 3,
}

return LeagueConstants
local VideoReplayConstants = {}

-- 比赛类型定义
VideoReplayConstants.MatchType = {
    -- 副本
    QUEST = "quest",
    -- 特殊条件副本
    SPECIAL_QUEST = "questSpc",
    -- 联赛
    LEAGUE = "league",
    -- 生涯赛
    CAREER = "career",
    -- 友谊赛
    FRIEND = "friend",
    -- 天梯赛
    LADDER = "ladder",
    -- 竞技场
    ARENA = "arena",
    -- 白银竞技场
    ARENA_SILVER = "silver",
    -- 黄金竞技场
    ARENA_GOLD = "gold",
    -- 黑金竞技场
    ARENA_BLACKGOLD = "black",
    -- 白金竞技场
    ARENA_PLATINUM = "platinum",
    -- 红金竞技场
    ARENA_RED = "red",
    -- 周年纪念竞技场
    ARENA_ANN = "anniversary",
    -- 巅峰竞技场
    ARENA_BLUE = "arenaPeak",
    -- 公会副本
    GUILD_QUEST = "guildQuest",
    -- 公会战
    GUILD_WAR = "guildWar",
    -- 征途限时活动玩法
    QUESTLIMIT = "questLimit",
    -- 讨伐战玩法
    CRUSADE = "crusade",

}

-- 玩家主客场类型
VideoReplayConstants.HomeAwayType = {
    AWAY = 0,
    HOME = 1,
    NEUTRAL = 2,
}

return VideoReplayConstants
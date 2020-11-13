local MatchConstants = {}

--- 球场上的特定位置
MatchConstants.SpecificPosNum = {
    -- 最小的位置
    MIN_POS = 1,
    -- 除了守门员之外最大的位置
    MAX_POS_EXCEPT_GOALKEEPER = 25,
    -- 守门员的位置
    GOALKEEPER_POS = 26,
}

--- 队伍类型
MatchConstants.TeamType = {
    PLAYER = "player",
    NPC = "npc",
    ROBOT = "robot",
}

--- 默认的模型信息
MatchConstants.DefaultModelInfo = {
    MODEL_ID = "10001",
    HEAD_ID = "1002",
    HAIR_ID = "1002",
    FACE_ID = "1002",
    HEIGHT = 180,
    COLOR = 1,
}

--- 射门时进度条持续的时间
MatchConstants.ShootProgressTime = 5

--- 球队的上场人数
MatchConstants.PlayersNumOnField = 11

--- 比赛中加时和点球的组合枚举
MatchConstants.MatchTime = {
    -- 加时和点球都有
    BOTH = 1,
    -- 加时和点球都没有
    NEITHER = 2,
    -- 只有点球
    ONLY_PENALTY_KICK = 3,
    -- 只有加时
    ONLY_OVERTIME = 4,
    -- 由上一场比赛结果决定
    ACCORDING_TO_LAST_MATCH = 5,
}

--- 玩家是主场还是客场
MatchConstants.Home = {
    -- 客场
    AWAY_GROUND = 0,
    -- 主场
    HOME_GROUND = 1,
    -- 中立
    NEUTRALITY = 2,
}

--- 队伍定位类型
MatchConstants.TeamLocateType = {
    -- 客场
    AWAY_GROUND = "away",
    -- 主场
    HOME_GROUND = "home",
}

--- 犯规类型
MatchConstants.FoulType = {
    -- 犯规
    FOUL = 1,
    -- 越位
    OFFSIDE = 2,
    -- 黄牌
    YELLOW_CARD = 3,
    -- 红牌
    RED_CARD = 4,
}

--- 比赛类型
MatchConstants.MatchType = {
    -- 副本
    QUEST = "quest",
    -- 联赛
    LEAGUE = "league",
    -- 天梯
    LADDER = "ladder",
    -- 巅峰对决
    PEAK = "peak",
    -- 好友
    FRIEND = "friend",
    -- 冠军联赛
    ARENA = "arena",
    SILVER = "silver",
    GOLD = "gold",
    BLACK = "black",
    PLATINUM = "platinum",
    RED = 'red',
    YELLOW = "anniversary",
    BLUE = "arenaPeak",

    CRUSADE = "crusade",

    --公会挑战赛
    GUILDCHALLENGE = "guildChallenge",

    -- 特殊赛事
    SPECIFIC="specific",
    -- 劫镖行动
    TRANSPORT = "transport",
     -- 劫镖行动
    WORLDBOSS = "worldBoss",

    --争霸赛
    COMPETE = "worldTournament",
	--绿茵征途
	ADVENTURE = "adventure",
}

-- 比赛结算类型图标
MatchConstants.MatchTypeIcon = {
    [MatchConstants.MatchType.ARENA] = "Arena",
    [MatchConstants.MatchType.COMPETE] = "Compete",
    [MatchConstants.MatchType.LADDER] = "Ladder",
    [MatchConstants.MatchType.PEAK] = "Peak",
    [MatchConstants.MatchType.SPECIFIC] = "Special",
    [MatchConstants.MatchType.TRANSPORT] = "Transport",
}

--- 比赛中换人总数量
MatchConstants.SubstitutionSum = 3

--- 比赛中的UI类型
MatchConstants.CurrentUIPanel = {
    PLAYER_NAME_PANEL = 1,
    TEAM_SCORE_PANEL = 2,
    PLAYER_GOAL_PANEL = 4,
    FOUL_PANEL = 5,
    PLAYER_SHOOT_PANEL = 6,
    NOTE_MENU_PANEL = 7,
    SKIP_BUTTON = 11,
    SKIP_BEGINNING = 12,
    SCORE_BAR_GOAL = 13,
    SETTLEMENT_SYSTEM = 14,
    SHOOT_BALL_EFFECT = 15,
    STATE_PANEL = 16,
    REPLAY_LOGO_PANEL = 17,
}

--- 射门评价类型
MatchConstants.ShootEvaluationType = {
    PERFECT = 1,
    GOOD = 2,
    NOT_GOOD = 3,
    MISS = 4,
}

--- 进球事件
MatchConstants.GoalEvent = {
    "First goal！",
    "Second goal！",
    "Hat-trick！",
    "God like！",
}

--- 进球事件localization key
MatchConstants.GoalEventKey = {
    "match_constants_first_goal",
    "match_constants_second_goal",
    "match_constants_hat_trick",
    "match_constants_god_like",
}

return MatchConstants
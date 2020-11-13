local FormationConstants = {}

-- 场上位置的字母表示到球场上12个位置的映射
FormationConstants.PositionLetterMap = {
    FL = 1,
    ML = 2,
    DL = 3,
    FR = 4,
    MR = 5,
    DR = 6,
    FC = 7,
    AMC = 8,
    MC = 9,
    DMC = 10,
    DC = 11,
    GK = 12,
}

FormationConstants.PositionLetterMap = {"FL", "FC", "FR", "ML", "AMC", "MR", "MC", "DMC", "DC", "DL", "DR", "GK"}

-- 场上位置的字母对应的场上的26个位置
FormationConstants.PositionToNumber = {
    FL = {"1", "6"},
    ML = {"11"},
    DL = {"16", "21"},
    FR = {"5", "10"},
    MR = {"15"},
    DR = {"20", "25"},
    FC = {"2", "3", "4"},
    AMC = {"7", "8", "9"},
    MC = {"12", "13", "14"},
    DMC = {"17", "18", "19"},
    DC = {"22", "23", "24"},
    GK = {"26"},
}

-- 球员圆形卡牌的显示信息类型
FormationConstants.CardShowType = {
    -- 显示头像、姓名、战力、品质
    MAIN_INFO = 1,
    -- 显示等级、位置、姓名、品质
    LEVEL_INFO = 2,
    -- 只在比赛中临场指挥/换人时出现，显示等级、位置、姓名、品质、体力条
    ONLY_IN_MATCH = 3,
    -- 只显示添加图标
    EMPTY = 4,
}
--最佳拍档显示状态
FormationConstants.CoupleState = {
    --隐藏
    HIDE = 0,
    -- 显示
    SHOW = 1,
}
-- 在阵型中球员的分类
FormationConstants.PlayersClassifyInFormation = {
    -- 首发球员
    INIT = 1,
    -- 替补球员
    REPLACE = 2,
    -- 候补球员
    WAIT = 3,
}

-- 球队类型定义(与服务器字段对应)
FormationConstants.TeamType = {
    -- 普通
    NORMAL = "normal",
    -- 副本
    QUEST = "quest",
    -- 特殊条件副本
    SPECIAL_QUEST = "special",
    -- 白银竞技场
    CWAR_SILVER = "silver",
    -- 黄金竞技场
    CWAR_GOLD = "gold",
    -- 黑金竞技场
    CWAR_BLACKGOLD = "black",
    -- 白金竞技场
    CWAR_PLATINUM = "platinum",
    -- 红金竞技场
    CWAR_RED = "red",
    --周年竞技场
    CWAR_ANN = "anniversary",
    --巅峰竞技场
    CWAR_Blue = "arenaPeak",
	-- 竞技场
	ARENA = "arena",
    -- 争霸赛
    COMPETE = "worldTournament",
    -- 特殊赛事
    SPECIFIC = "specific",
    -- 巡回赛
    TRANSPORT = "transport",
    -- 天梯
    LADDER = "ladder",
    -- 巅峰
    PEAK = "peak",
	-- 巅峰1
	PEAK1 = "peak1",
	-- 巅峰2
	PEAK2 = "peak2",
	-- 巅峰3
	PEAK3 = "peak3",
    -- 联赛
    LEAGUE = "league",
}

-- 替补球员位置编号列表
FormationConstants.ReplacePlayersPosArr = {"27", "28", "29", "30", "31", "32", "33"}

-- 阵型分类
FormationConstants.FormationCategory = {
    -- 3后卫阵型
    THREE_GUARD = 1,
    -- 4后卫阵型
    FOUR_GUARD = 2,
    -- 5后卫阵型
    FIVE_GUARD = 3,
    -- 1前锋
    ONE_FORWARD = 4,
    -- 2前锋
    TWO_FORWARD = 5,
    -- 3前锋
    THREE_FORWARD = 6,
}

-- 排序类型
FormationConstants.SortType = {
    -- 战力
    POWER = 1,
    -- 品质
    QUALITY = 2,
    -- 入手顺序
    GET_TIME = 3,
    -- 名字排序
    NAME = 4,
}

-- 关键球员类型
FormationConstants.KeyPlayerType = {
    CAPTAIN = "captain",
    FREEKICKSHOOT = "freeKickShoot",
    FREEKICKPASS = "freeKickPass",
    SPOTKICK = "spotKick",
    CORNER = "corner",
}

-- 战术类型
FormationConstants.FormationTacticsType = {
    PASSTACTIC = "passTactic", -- 传球策略
    ATTACKEMPHASIS = "attackEmphasis", -- 进攻偏好
    ATTACKRHYTHM = "attackRhythm", -- 战术节奏
    ATTACKMENTALITY = "attackMentality", -- 比赛心态
    DEFENSEMENTALITY = "defenseMentality", -- 防守策略
    ATTACKEMPHASISDETAIL = "attackEmphasisDetail",
    SIDETACTICSLEFT = "left",
    SIDETACTICSRIGHT = "right"
}

-- 战术类型缺省值
FormationConstants.TacticsDefault = {
    ATTACKEMPHASIS = 3,
    ATTACKMENTALITY = 3,
    DEFENSEMENTALITY = 3,
    PASSTACTIC = 3,
    ATTACKRHYTHM = 3,
    ATTACKEMPHASISDETAIL = 3,
    SIDETACTICSLEFT = 0,
    SIDETACTICSRIGHT = 0,
    SIDEGUARDTACTICSLEFT = 0,
    SIDEGUARDTACTICSRIGHT = 0,
    SIDEMIDFIELDTACTICSLEFT = 0,
    SIDEMIDFIELDTACTICSRIGHT = 0
}

-- 阵型是否有效类型
FormationConstants.FormationValidType = {
    VALID = 1,
    NOVALID_INITPLAYERS_NOTENOUGH = 2,
    NOVALID_HASSAMEPLAYER = 3,
    NOVALID_EXTRA_SUBSTITUTION_SUM = 4
}

-- 一键上阵排序位置
FormationConstants.FormationRecommendOrderPosition = {
    ["26"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["7"] = 5,
    ["8"] = 6,
    ["9"] = 7,
    ["12"] = 8,
    ["13"] = 9,
    ["14"] = 10,
    ["17"] = 11,
    ["18"] = 12,
    ["19"] = 13,
    ["22"] = 14,
    ["23"] = 15,
    ["24"] = 16,
    ["1"] = 17,
    ["6"] = 18,
    ["5"] = 19,
    ["10"] = 20,
    ["11"] = 21,
    ["15"] = 22,
    ["16"] = 23,
    ["21"] = 24,
    ["20"] = 25,
    ["25"] = 26
}

-- 多套阵容编号
FormationConstants.MultiFormationId = 
{
    FIRST_FORMATION = 0,
    SECOND_FORMATION = 1,
    THIRD_FORMATION = 2
}

-- 首发球员最大位置
FormationConstants.InitPlayerMaxPos = 26

return FormationConstants
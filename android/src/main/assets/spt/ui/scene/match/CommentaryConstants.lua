local CommentaryConstants = {}

--- 音频优先级
CommentaryConstants.AudioPriority = {
    ENTER_MATCH = 50000,
    START_MATCH = 60000,
    HEROIC_MOMENT = 2000,
    DRIBBLE = 3000,
    PASS = 4000,
    SHOOT = 7000,
    INTERCEPT = 5000,
    STEAL = 5000,
    SAVE = 8000,
    SKILL = 10000,
}

--- 比赛事件类型
CommentaryConstants.MatchEventType = {
    -- 无效
    INVALID = 0,
    -- 开场前
    PREPARE_TO_KICKOFF = 1,
    -- 半场开球前
    NONTIMEED_KICKOFF = 2,
    -- 比赛中进球
    TIMED_KICKOFF = 3,
    -- 比赛中
    NORMAL_PLAYON = 4,
    -- 点球
    PENALTY_KICK = 5,
    -- 犯规任意球（直接打门）
    CNETER_DIRECT_FREEKICK = 6,
    -- 犯规任意球（传球）
    WING_DIRECT_FREEKICK = 7,
    -- 越位任意球
    INDIRECT_FREEKICK = 8,
    -- 换人
    SUBSTITUTION = 9,
    -- 掷界外球
    THROW_IN = 10,
    -- 球门球
    GOALKICK = 11,
    -- 角球
    CORNERKICK = 12,
    -- 点球决战
    PENALTY_SHOOTOUT = 13,
    -- 比赛结束
    GAME_OVER = 14,
}

CommentaryConstants.ActionType = {
    NONE = 0,
    -- 移动
    MOVE = 1,
    -- 运球
    DRIBBLE = 2,
    -- 传球
    PASS = 3,
    -- 射门
    SHOOT = 4,
    -- 截球
    INTERCEPT = 5,
    -- 抢断
    STEAL = 6,
    -- 救球
    SAVE = 7,
    -- 接球
    CATCH = 8,
    -- shoot的下一帧
    POST_SHOOT = 9,
    -- 玩家操作
    MANUAL_OPERATE = 10,
}

--- 队伍类型
CommentaryConstants.TeamType = {
    -- 空
    NONE = 0,
    -- 主场
    HOME = 1,
    -- 客场
    AWAY = 2,
}

--- 比赛类型
CommentaryConstants.QuestNatureType = {
    -- 联赛
    LEAGUE = 1,
    -- 超级杯
    SUPER_CUP = 2,
    -- 普通杯赛
    NORMAL_CUP = 3,
    -- 小耳朵杯
    SMALL_EAR_CUP = 4,
    -- 大耳朵杯
    BIG_EAR_CUP = 5,
}

--- 国家类型
CommentaryConstants.QuestCountryType = {
    -- 葡萄牙
    Portugal = "POR",
    -- 荷兰
    Netherlands = "NED",
    -- 法国
    France = "FRA",
    -- 意大利
    Italy = "ITA",
    -- 英格兰
    England = "ENG",
    -- 西班牙
    Spain = "SPA",
}

-- 射门类型
CommentaryConstants.ShootAnimationType = {
    NormalShoot = 0, --普通射门
    Header = 1, --头球
    VolleyShoot = 2, --凌空
    OffTheBallGround = 3, --地面球抢点
}

--- 长传球的最低距离
CommentaryConstants.BallPassDistanceLowerLimit = 22

--- 一声哨响的音频名
CommentaryConstants.KickOffWhistleAudio = "whistle_kickoff"

--- 两声哨响的音频名
CommentaryConstants.HalfTimeWhistleAudio = "whistle_halftime"

--- 三声哨响的音频名
CommentaryConstants.GameOverWhistleAudio = "whistle_gameover"

--- 犯规哨响
CommentaryConstants.FoulWhistleAudio = "whistle_foul"

return CommentaryConstants
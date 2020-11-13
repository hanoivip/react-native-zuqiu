local AudienceAudioConstants = {}

--- 事件类型
AudienceAudioConstants.EventType = {
    -- 进攻
    OFFENCE = 1,
    -- 抢断
    STEEL = 2,
    -- 进球
    GOAL = 3,
    -- 没进球
    MISS = 4,
    -- 手动射门
    MANUAL_SHOOT = 5,
    -- 手动射门结束
    MANUAL_SHOOT_OVER = 6,
    -- 踢球
    KICK = 7,
    -- 停止进攻
    STOP_OFFENCE = 8,
    -- 犯规
    FOUL = 9,
    -- 截球
    INTERCEPT = 10,
    -- 点球
    PENALTY = 11,
    -- 技能
    SKILL = 12,
}

--- 比赛音频路径
AudienceAudioConstants.MatchAudioPath = "Assets/CapstonesRes/Game/Audio/Match/"

--- 踢中球的声音
AudienceAudioConstants.KickBallAudioPath = AudienceAudioConstants.MatchAudioPath .. "kick.wav"

--- 射门时的滑屏声音
AudienceAudioConstants.SwipeScreenAudioPath = AudienceAudioConstants.MatchAudioPath .. "swipe_screen.wav"

return AudienceAudioConstants
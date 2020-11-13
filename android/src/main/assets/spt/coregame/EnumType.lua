local EnumType = {}

EnumType.ActionType =
{
    None = 0,
    Move = 1,
    Dribble = 2,
    Pass = 3,
    Shoot = 4,
    Intercept = 5,
    Steal = 6,
    Save = 7,
    Catch = 8,
    PostShoot = 9,
    ManualOperate = 10,
}

EnumType.MatchEventType =
{
    Invalid = 0,
    PrepareToKickOff = 1,
    NontimedKickOff = 2,
    TimedKickOff = 3,
    NormalPlayOn = 4,
    PenaltyKick = 5,
    CenterDirectFreeKick = 6,
    WingDirectFreeKick = 7,
    IndirectFreeKick = 8,
    Substitution = 9,
    ThrowIn = 10,
    GoalKick = 11,
    CornerKick = 12,
    PenaltyShootOut = 13,
    GameOver = 14,
    PenaltyShootOutKick = 15,
}

EnumType.MatchBreakReason =
{
    Invalid = 0,
    Offside = 1,
    Foul = 2,
}

EnumType.BroadcastSpot =
{
    MainSpot = 0,
    LeftSideSpot = 1,
    RightSideSpot = 2,
    BaseLineSpot = 3,
    Special = 4,
    PlayBackNormal = 5,
    PlayBackSpecial = 6,
    PlayBackGoalView = 7
}

EnumType.BallActionType =
{
    Dribble = 0,
    Prepass = 1,
    Pass = 2,
    Shoot = 3
}

EnumType.BallPassType =
{
    PassSimulatedDribble = 0,
    UnloadBall = 1,
    Lob = 2,
    PassGroundStraight = 3,
    PassAirStraight = 4,
    PassRainbow = 5,
    PassRainbowInCurve = 6,
    PassRainbowOutCurve = 7,
    PassBounceOnce = 8,
    DoubleHandsThrow = 9,
    HeaderPass = 10,
}

EnumType.BallFreeFlyType =
{
    SaveFreeFly = 0,
    HitCrossBarFreeFly = 1,
    HitGoalPostFreeFly = 2
}

EnumType.PassType =
{
    Ground = 0,
    Bounce = 1,
    High = 2,
}

EnumType.ShootResult =
{
    Goal = 0,
    Catched = 1,
    Bounced = 2,
    Miss = 3,
}

EnumType.ManualOperateType =
{
    Invalid = -1,
    Auto = 0,
    Pass = 1,
    Dribble = 2,
    Shoot = 3,
}

EnumType.GoalCollider =
{
    Invalid = 0,
    Back = 1,
    Side = 2,
    Up = 3,
    AdBoard = 4,
}

EnumType.PlaybackClipType =
{
    Goal_Ordinary = 0,
    Goal_ThroughPassAssist = 1,
    Goal_OverheadPassAssist = 2,
    Goal_HeaderPassAssist = 3,
    Goal_DirectFreeKick = 4,
    Goal_Penalty = 5,
    Goal_CornerKick = 6,
    Offside = 7
}

EnumType.MatchStage = {
    None = 0,
    FirstHalf = 1,
    SecondHalf = 2,
    FirstOverTime = 3,
    SecondOverTime = 4,
    PenaltyShootOut = 5,
    GameOver = 6
}

EnumType.PenaltyShootOutScore = {
    Idle = 0,
    Goal = 1,
    Miss = 2,
}

return EnumType
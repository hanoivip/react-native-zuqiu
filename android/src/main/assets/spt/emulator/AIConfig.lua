local Skills = import("./skills/Skills")

local AIConfig = {}

AIConfig.WithBallSkillNames = {
    Skills.HeavyGunner.__cname,
    Skills.ThroughBall.__cname,
    Skills.OverHeadBall.__cname,
    Skills.CrossLowEx1.__cname,
    Skills.CrossLow.__cname,
    Skills.Diving.__cname,
    Skills.BreakThrough.__cname,
    Skills.Metronome.__cname,
}

AIConfig.NotEnterManualOperationSkills = {
    Skills.HeavyGunner,
    Skills.CalmShoot,
    Skills.BreakThrough,
    Skills.Metronome,
    Skills.HighSpeedDribble,
}

return AIConfig

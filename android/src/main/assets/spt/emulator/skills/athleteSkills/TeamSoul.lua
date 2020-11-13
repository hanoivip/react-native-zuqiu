local Skill = import("../Skill")
local ChargeTrumpet = import("./ChargeTrumpet")
local Metronome = import("./Metronome")
local FightTogether = import("./FightTogether")
local PenaltyBoxSignalFireTurret = import("./PenaltyBoxSignalFireTurret")

local TeamSoul = class(Skill, "TeamSoul")
TeamSoul.id = "F09"
TeamSoul.alias = "球队灵魂"

local minAddConfig = 0.35
local maxAddConfig = 2.825

function TeamSoul:ctor(level)
    if level < 1 or level > 200 then
        error("wrong level")
    end

    self.remainingCooldown = 0
    self.level = level
    self.initRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.addRatio = self.initRatio
    -- 如果有多个球员有该技能，标识当前技能在这一组技能中的发动顺序
    self.launchIndex = nil

    -- 增强冲锋号角buff的效果
    self.chargeTrumpetBuff = {
        skill = self,
        originalSkillClass = ChargeTrumpet,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }

    -- 增强节拍器buff的效果
    self.metronomeBuff = {
        skill = self,
        originalSkillClass = Metronome,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isDefendRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }

    -- 增强众志成城buff的效果
    self.fightTogetherBuff = {
        skill = self,
        originalSkillClass = FightTogether,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }

    -- 增强禁区烽火台buff的效果
    self.penaltyBoxSignalFireTurretBuff = {
        skill = self,
        originalSkillClass = PenaltyBoxSignalFireTurret,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole()
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.addRatio
        end,
    }
end

function TeamSoul:enterField(athlete)
    local team = athlete.team

    if self.launchIndex == nil then
        Skill.calcLaunchIndex(team, TeamSoul)
    end

    self.initRatio = self.initRatio / math.pow(2, (self.launchIndex - 1))

    if math.cmpf(self.initRatio, 0.01) < 0 then
        self.initRatio = 0.01
    end

    athlete:castSkill(TeamSoul, self.initRatio)
end

return TeamSoul

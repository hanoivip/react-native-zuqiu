if jit then jit.off(true, true) end

local Athlete = import("./Core")
local Skills = import("../skills/Skills")
local AIUtils = import("../AIUtils")
local AIConfig = import("../AIConfig")
local selector = import("../libs/selector")
local Field = import("../Field")
local vector2 = import("../libs/vector")

function Athlete:hasSkill(skill, notIncludeSubclass)
    for i, skillInstance in ipairs(self.skills) do
        if skillInstance:isTypeOf(skill) then
            return true
        end
    end
    return false
end

function Athlete:hasBuff(skill, buffRemark)
    for i, buff in ipairs(self.buffs) do
        if buff.type.skill and buff.type.skill:isTypeOf(skill) and (not buffRemark or buff.type.remark == buffRemark) then
            return true
        end
    end
    return false
end

function Athlete:getFirstBuffSkill(skill)
    for i, buff in ipairs(self.buffs) do
        if buff.type.skill and buff.type.skill:isTypeOf(skill) then
            return buff.type.skill
        end
    end
    return nil
end

function Athlete:getCooldownSkill(skill, notIncludeSubclass)
    for i, skillInstance in ipairs(self.skills) do
        if skillInstance:isTypeOf(skill) and not skillInstance.isDisabled and math.sign(skillInstance.remainingCooldown) <= 0 then
            return skillInstance
        end
    end
end

function Athlete:getSkill(skill, notIncludeSubclass)
    for i, skillInstance in ipairs(self.skills) do
        if skillInstance:isTypeOf(skill) then
            return skillInstance
        end
    end
end

function Athlete:resetSkillDiabledStates()
    if not self:hasBuff(Skills.TigerShootEx1, "mark") and not self:hasBuff(Skills.ImpactWaveEx1, "mark") and not self:hasBuff(Skills.PenaltyKickKillerEx1, "mark") then
        for i, skillInstance in ipairs(self.skills) do
            if skillInstance.isDisabled and skillInstance:isTypeOf(Skills.PerpetualMotionMachine) then
                for j = 1, skillInstance.count, 1 do
                    if skillInstance.buff then
                        self:addBuff(skillInstance.buff, self)
                    end
                end
            end
            skillInstance.isDisabled = nil
        end
    end
end

function Athlete:isFullyMarked()
    for i, skillInstance in ipairs(self.skills) do
        if not skillInstance.isDisabled and not (skillInstance:isLowPowerSkill() or skillInstance:isMedalSkill()) then
            return false
        end
    end

    return true
end

function Athlete:getUnmarkedNonFStartSkills()
    local unmarkedNonFStartSkills = { }
    for i, skillInstance in ipairs(self.skills) do
        if not skillInstance.isDisabled and not (skillInstance:isLowPowerSkill() or skillInstance:isMedalSkill()) then
            table.insert(unmarkedNonFStartSkills, skillInstance)
        end
    end

    return unmarkedNonFStartSkills
end

function Athlete:castSkill(skill, displayValue, targetOnFieldId, showCaster)
    -- we assume each skill type only appear once in one athlete's skill list
    -- showCaster:头顶弹图标的人特殊处理
    if showCaster then
        for i, skillInstance in ipairs(self.skills) do
            if skillInstance.class == skill then
                table.insert(showCaster.outputSkills, {
                    id = skillInstance.id,
                    parameter1 = displayValue and math.round(displayValue * 100),
                    target = targetOnFieldId and targetOnFieldId - 1,
                })
                return skillInstance
            end
        end
    else
        for i, skillInstance in ipairs(self.skills) do
            if skillInstance.class == skill then
                self:logInfo("Casted skill name = " .. skill.__cname)

                skillInstance.remainingCooldown = skillInstance.cooldown or 0 -- skill.cooldown may be nil
                table.insert(self.outputSkills, {
                    id = skillInstance.id,
                    parameter1 = displayValue and math.round(displayValue * 100),
                    target = targetOnFieldId and targetOnFieldId - 1,
                })

                return skillInstance
            end
        end
    end
end

function Athlete:castPassSkills()
    for i, buff in ipairs(self.buffs) do
        if buff.type.skill then
            local skillInstance = buff.type.skill
            if skillInstance:isTypeOf(Skills.CorePlayMaker)
            or (skillInstance:isTypeOf(Skills.ThroughBall) and buff.type.remark == "base")
            or (skillInstance:isTypeOf(Skills.OverHeadBall) and buff.type.remark == "base")
            or (skillInstance:isTypeOf(Skills.CrossLow) and self:hasBuff(Skills.CrossLow, "base"))
            or skillInstance:isTypeOf(Skills.PuntKick) or skillInstance:isTypeOf(Skills.LongPassDispatch) then
                buff.caster:castSkill(skillInstance.class, math.min(self.passSuccessProbability, 0.99))
            end
        end
    end
    local nouCampElvesSkill = self:getSkill(Skills.NouCampElves)
    if nouCampElvesSkill then
        self:castSkill(nouCampElvesSkill.class)
    end
end

function Athlete:castPlannedSkills()
    for _, skill in ipairs(self.toBeCastedSkills) do
        self:castSkill(skill)
    end

    self.toBeCastedSkills = { }
end

function Athlete:isArrayIncludeSkill(skillClassList, targetSkillClass)
    for i, skillClass in ipairs(skillClassList) do
        if skillClass.isSubClassOf(targetSkillClass) then
            return true
        end
    end

    return false
end

function Athlete:castPlannedShootSkills()
    if self:isArrayIncludeSkill(self.toBeCastedSkills, Skills.ImpactWave) then
        local enemyGk = self.enemyTeam.athleteOfRole[26]
        local skill = self:getSkill(Skills.ImpactWave)
        enemyGk:addBuff(skill.buff, self)
        self:judgeImpactWaveEx1()

        for _, blockAthlete in ipairs(self.enemyTeam.blockAthletes) do
            blockAthlete:addBuff(skill.blockBuff, self)
        end
    end

    local nouCampElvesSkill = self:getSkill(Skills.NouCampElves)
    if nouCampElvesSkill then
        table.insert(self.toBeCastedSkills, nouCampElvesSkill.class)
    end
    self:castPlannedSkills()
end

function Athlete:castPlannedGkSkills(shootAthlete)
    if self:isArrayIncludeSkill(self.toBeCastedSkills, Skills.Handing) then
        if shootAthlete.chosenDPSAction.shootResult == AIUtils.shootResult.catch or self:hasBuff(Skills.ImpactWave) then
            self:removeBuffs(Skills.ImpactWave)
        end
    end

    self:castPlannedSkills()
end

local function calcAbility(base, coachBonus, trainerBonus, type, isAdept)
    return base[type].value * (1 + (base[type].bonus or 0) + (coachBonus and coachBonus[type] or 0) + (trainerBonus or 0)) * (isAdept and 1 or 0.01)
end

local function isAdeptRole(currentRole, adeptRole)
    if adeptRole == nil then
        return true
    end
    for i, role in ipairs(adeptRole) do
        if currentRole == role then
            return true
        end
    end
    return false
end

local function calcAbilitySum(abilities)
    return abilities.dribble + abilities.pass + abilities.shoot + abilities.intercept + abilities.steal
        + abilities.goalkeeping + abilities.anticipation + abilities.commanding + abilities.composure + abilities.launching
end

local function makeAbilitiesAddRatioEffect(cachedAbilities, buff, initAbilities)
    cachedAbilities.dribble = math.max(1, cachedAbilities.dribble + initAbilities.dribble * buff.value)
    cachedAbilities.pass = math.max(1, cachedAbilities.pass + initAbilities.pass * buff.value)
    cachedAbilities.shoot = math.max(1, cachedAbilities.shoot + initAbilities.shoot * buff.value)
    cachedAbilities.steal = math.max(1, cachedAbilities.steal + initAbilities.steal * buff.value)
    cachedAbilities.intercept = math.max(1, cachedAbilities.intercept + initAbilities.intercept * buff.value)
    cachedAbilities.goalkeeping = math.max(1, cachedAbilities.goalkeeping + initAbilities.goalkeeping * buff.value)
    cachedAbilities.anticipation = math.max(1, cachedAbilities.anticipation + initAbilities.anticipation * buff.value)
    cachedAbilities.commanding = math.max(1, cachedAbilities.commanding + initAbilities.commanding * buff.value)
    cachedAbilities.composure = math.max(1, cachedAbilities.composure + initAbilities.composure * buff.value)
    cachedAbilities.launching = math.max(1, cachedAbilities.launching + initAbilities.launching * buff.value)
end

local function addGrassAbilityEffect(cachedAbilities, initAbilities, grassTechEffect, immunityRatio)
    cachedAbilities.dribble = math.max(1, cachedAbilities.dribble - initAbilities.dribble * grassTechEffect.dribble * immunityRatio)
    cachedAbilities.pass = math.max(1, cachedAbilities.pass - initAbilities.pass * grassTechEffect.pass * immunityRatio)
    cachedAbilities.shoot = math.max(1, cachedAbilities.shoot - initAbilities.shoot * grassTechEffect.shoot * immunityRatio)
    cachedAbilities.steal = math.max(1, cachedAbilities.steal - initAbilities.steal * grassTechEffect.steal * immunityRatio)
    cachedAbilities.intercept = math.max(1, cachedAbilities.intercept - initAbilities.intercept * grassTechEffect.intercept * immunityRatio)
end

function Athlete:getAbilities()
    if self.cachedAbilities == nil or self.cachedAbilities.isDirty then
        self.cachedAbilities = clone(self.abilities)
        self.cachedAbilities.isDirty = false

        local isAdept = isAdeptRole(self.role, self.adeptRole)
        local posStr = AIUtils.getPosStr(self.role)
        local coachBonus = self.team.coachBonus and self.team.coachBonus[posStr]
        local trainerBonus = self.team.trainerBonus and self.team.trainerBonus[posStr]
        self.cachedAbilities.dribble = calcAbility(self.abilities, coachBonus, trainerBonus, "dribble", isAdept)
        self.cachedAbilities.pass = calcAbility(self.abilities, coachBonus, trainerBonus, "pass", isAdept)
        self.cachedAbilities.shoot = calcAbility(self.abilities, coachBonus, trainerBonus, "shoot", isAdept)
        self.cachedAbilities.steal = calcAbility(self.abilities, coachBonus, trainerBonus, "steal", isAdept)
        self.cachedAbilities.intercept = calcAbility(self.abilities, coachBonus, trainerBonus, "intercept", isAdept)
        self.cachedAbilities.goalkeeping = calcAbility(self.abilities, coachBonus, trainerBonus, "goalkeeping", isAdept)
        self.cachedAbilities.anticipation = calcAbility(self.abilities, coachBonus, trainerBonus, "anticipation", isAdept)
        self.cachedAbilities.commanding = calcAbility(self.abilities, coachBonus, trainerBonus, "commanding", isAdept)
        self.cachedAbilities.composure = calcAbility(self.abilities, coachBonus, trainerBonus, "composure", isAdept)
        self.cachedAbilities.launching = calcAbility(self.abilities, coachBonus, trainerBonus, "launching", isAdept)

        for i, buff in ipairs(self.buffs) do
            if buff.type.abilitiesAddRatio then
                if not (math.cmpf(buff.value, 0) < 0 and self:isDebuffBlocked()) then
                    makeAbilitiesAddRatioEffect(self.cachedAbilities, buff, self.initAbilities)
                end
            elseif buff.type.abilitiesModifier then
                buff.type.abilitiesModifier(self.cachedAbilities, buff.caster, self)
            end
        end

        if self.team.side == "away" and not self:isGoalkeeper() then
            local immunityRatio = self:getAdaptionMasterImmunityRatio()
            addGrassAbilityEffect(self.cachedAbilities, self.initAbilities, self.match.grassTechEffect, immunityRatio)
        end
    end

    return self.cachedAbilities
end

function Athlete:getAbilitiesSum()
    local abilities = self:getAbilities()
    return self:isGoalkeeper() and abilities.goalkeeping + abilities.anticipation + abilities.commanding + abilities.composure + abilities.launching
        or abilities.dribble + abilities.pass + abilities.shoot + abilities.intercept + abilities.steal
end

function Athlete:getMaxAbility()
    local maxValue = 0
    local abilities = self:getAbilities()
    maxValue = math.max(abilities.dribble, abilities.pass)
    maxValue = math.max(maxValue, abilities.shoot)
    maxValue = math.max(maxValue, abilities.intercept)
    maxValue = math.max(maxValue, abilities.steal)
    return maxValue
end

function Athlete:setCachedAbilitiesDirty()
    if self.cachedAbilities ~= nil then
        self.cachedAbilities.isDirty = true
    end
end

function Athlete:outputStartBuff(buffInstance)
    --output start buff
    if buffInstance.type.skill then
        table.insert(self.outputStartBuffs, buffInstance)
    end
end

function Athlete:outputEndBuff(buffInstance)
    --output end buff
    if buffInstance.type.skill then
        table.insert(self.outputEndBuffs, buffInstance)
    end
end

function Athlete:cannotAddBuff(buff, caster)
    if buff.abilitiesAddRatio and math.cmpf(buff.abilitiesAddRatio(caster, self), 0) > 0 and buff.remark ~= "ignoreCannotAddBuffDebuff" then
        if self:hasBuff(Skills.HandingEx1, "cannotAddBuff")
        or self:hasBuff(Skills.AttackDeterrent, "cannotAddBuff")
        or self:hasBuff(Skills.GpiquePenetrateEverything, "mark") -- 皮看穿的盯人也要不能加buff
        or self:hasBuff(Skills.DefendDeterrent, "cannotAddBuff") then
            return true
        end
    end
    return false
end

function Athlete:addBuff(buff, caster)
    if self:cannotAddBuff(buff, caster) then
        return
    end

    local buffInstance = {
        id = self.match:generateBuffId(),
        type = buff,
        value = buff.abilitiesAddRatio and buff.abilitiesAddRatio(caster, self) or 0,
        remainingTime = buff.duration, -- buff.duration may be nil
        caster = caster,
        markedSkillId = buff.markedSkillId, -- for skill MarkedSkillId
    }

    table.insert(self.buffs, buffInstance)
    self:outputStartBuff(buffInstance)
    self:setCachedAbilitiesDirty()
end

local function checkRemovalCondition(athlete)
    local needToSetCachedAbilitiesDirty = false

    for i, buff in ipairs(athlete.buffs) do
        if buff.remainingTime then  -- buff.remainingTime may be nil
            buff.remainingTime = buff.remainingTime - TIME_STEP
        end
        buff.toBeRemoved = buff.type.removalCondition(buff.remainingTime, buff.caster, athlete)
        if buff.toBeRemoved then
            athlete:outputEndBuff(buff)
            needToSetCachedAbilitiesDirty = true
        end
    end

    if needToSetCachedAbilitiesDirty then
        athlete:setCachedAbilitiesDirty()
    end
end

local function shrinkBuffs(athlete)
    local i, j, maxN = 1, 1, #athlete.buffs

    while i <= maxN do
        while i <= maxN and athlete.buffs[i] ~= nil and not athlete.buffs[i].toBeRemoved do i = i + 1 end

        if i <= maxN then -- here we found an empty value in the array
            athlete.buffs[i] = nil
            j = i + 1
            while j <= maxN and (athlete.buffs[j] == nil or athlete.buffs[j].toBeRemoved) do
                if athlete.buffs[j] ~= nil and athlete.buffs[j].toBeRemoved then
                    athlete.buffs[j] = nil
                end
                j = j + 1
            end
            if j <= maxN then -- here we found the next non-empty value in the array
                athlete.buffs[i] = athlete.buffs[j]
                athlete.buffs[j] = nil
                i = i + 1
            else
                break
            end
        end
    end
end

local function updateBuffs(athlete)
    if #athlete.buffs == 0 then
        return
    end

    checkRemovalCondition(athlete)
    shrinkBuffs(athlete)
end

local function checkToBeRemovedBuffs(athlete, skill, remark)
    local needToSetCachedAbilitiesDirty

    for i, buff in ipairs(athlete.buffs) do
        if buff and buff.type.skill:isTypeOf(skill) and (not remark or buff.type.remark == remark) then
            buff.toBeRemoved = true
            athlete:outputEndBuff(buff)
            needToSetCachedAbilitiesDirty = true
        end
    end

    if needToSetCachedAbilitiesDirty then
        athlete:setCachedAbilitiesDirty()
    end
end

function Athlete:removeBuffs(skill, remark)
    if #self.buffs == 0 then
        return
    end

    checkToBeRemovedBuffs(self, skill, remark)
    shrinkBuffs(self)
end

local function updateSkills(athlete)
    for i, skill in ipairs(athlete.skills) do
        if math.sign(skill.remainingCooldown) > 0 then
            skill.remainingCooldown = skill.remainingCooldown - TIME_STEP
        end
        if skill.update ~= nil then
            skill:update(athlete)
        end
    end
end

function Athlete:updateBuffAndSkillRemainingTime()
    updateBuffs(self)
    updateSkills(self)
end

function Athlete:enterField()
    for i, skill in ipairs(self.skills) do
        if skill.enterField ~= nil then
            skill:enterField(self)
        end
    end

    self.isEntryModifierExecuted = true
end

function Athlete:resetBuffs()
    --clear all current buffs
    for i, buff in ipairs(self.buffs) do
        self:outputEndBuff(buff)
    end

    --collect all persistent buffs
    local persistentBuffs = {}
    for i, buff in ipairs(self.buffs) do
        if buff.type.persistent == true then
            table.insert(persistentBuffs, buff)
        end
    end
    self.buffs = persistentBuffs

    for i, buff in ipairs(self.buffs) do
        self:outputStartBuff(buff)
    end
end

function Athlete:isDebuffBlocked()
     return self:hasBuff(Skills.BreakThroughEx1, "debuffBlocked") or self:hasBuff(Skills.MidfieldMaestrosEx1, "debuffBlocked")
     or self:hasBuff(Skills.PerpetualMotionMachineEx1, "debuffBlocked")
end

function Athlete:isDivingEx1Blocked()
    return self:hasBuff(Skills.DivingEx1, "canNotDefend")
end

function Athlete:checkAdeptRoleState()
    if not isAdeptRole(self.role, self.adeptRole) then
        for _, skill in ipairs(self.skills) do
            skill:decreaseProbability()
        end
    end
end

function Athlete:isPuntKickTriggered()
    local skill = self:getCooldownSkill(Skills.PuntKick)
    return skill and selector.tossCoin(skill.probability)
        and self:judgePuntKickTeammate()
end

function Athlete:isSatisfyThroughBall()
    local skill = self:getCooldownSkill(Skills.ThroughBall)
    return skill and Field.isInThroughBallArea(self.position, self.team:getSign())
        and self:judgeThroughBallTeammate()
end

function Athlete:isSatisfyOverHeadBall()
    local skill = self:getCooldownSkill(Skills.OverHeadBall)
    return skill and (self.isSideAthlete
        and Field.isInSideOverHeadBallArea(self.position, self.team:getSign())
        or Field.isInOverHeadBallArea(self.position, self.team:getSign()))
        and self:judgeOverHeadBallTeammate()
end

function Athlete:isSatisfyCrossLow()
    local skill = self:getCooldownSkill(Skills.CrossLow)
    local isSatisfyArea = Field.isInCrossLowArea(self.position, self.team:getSign())
    return skill and isSatisfyArea and self:judgeCrossLowTeammate()
end

function Athlete:isSatisfyCrossLowEx1()
    local skill = self:getCooldownSkill(Skills.CrossLowEx1)
    local isSatisfyArea = Field.isInCrossLowEx1Area(self.position, self.team:getSign())
    return skill and isSatisfyArea and self:judgeCrossLowTeammate()
end

function Athlete:isSatisfyHeavyGunner()
    local skill = self:getCooldownSkill(Skills.HeavyGunner)
    if skill then
        local enemyGoalAngle = vector2.angle(self.enemyTeam.goal.center - self.position, self.bodyDirection)
        if Field.isInHeavyGunnerArea(self.position, self.team:getSign()) and math.cmpf(enemyGoalAngle, math.pi / 2) <= 0 then
            return true
        end
    end
    return false
end

function Athlete:isSatisfyBreakThrough()
    local skill = self:getCooldownSkill(Skills.BreakThrough)
    if skill == nil then
        return false
    end

    local enemies = self:findEnemyAthletesInFront(self.bodyDirection, 7, math.pi)
    if #enemies >= 1 and not Field.isInForceShootArea(self.position, self.team:getSign()) then
        for _, enemy in ipairs(enemies) do
            self.candidateEnemyForBreakThrough = enemy
            self:setCandidateBreakThroughAnimations()

            if #self.candidateBreakThroughAnimations ~= 0 then
                return true
            end
        end
    end
    return false
end

function Athlete:isSatisfyDiving()
    local skill = self:getCooldownSkill(Skills.Diving)
    local nearestEnemyAthlete = self.enemyTeam:selectNearestAthlete(self.position)
    return skill and Field.isInDivingArea(self.position, self.team:getSign())
        and math.cmpf(vector2.sqrdist(nearestEnemyAthlete.position, self.position), 3 ^ 2) <= 0
end

function Athlete:isSatisfyMetronome()
    local skill = self:getCooldownSkill(Skills.Metronome)
    return skill and not skill.hasLaunched
            and Field.isMetronomeArea(self.position, self.team:getSign())
            and self:hasEnemyAthleteInFront(vector2.norm(self.enemyTeam.goal.center - self.position), 12.5, 3 * math.pi / 4)
end

function Athlete:judgeCorePlayMaker()
    if self.chosenDPSAction.type == "Ground" and math.cmpf(vector2.sqrdist(self.position, self.chosenDPSAction.targetPosition), 25 ^ 2) <= 0 then
        local selfCorePlayMakerSkill = self:getCooldownSkill(Skills.CorePlayMaker)
        local targetAthleteCorePlayMakerSkill = self.chosenDPSAction.targetAthlete:getCooldownSkill(Skills.CorePlayMaker)

        if selfCorePlayMakerSkill then
            self:addBuff(selfCorePlayMakerSkill.buff, self)
        end

        if targetAthleteCorePlayMakerSkill then
            self:addBuff(targetAthleteCorePlayMakerSkill.buff, self.chosenDPSAction.targetAthlete)
        end
    end
end

function Athlete:judgeKnifeGuard()
    local knifeGuardSkillEx = self:getCooldownSkill(Skills.KnifeGuardEx1)
    if knifeGuardSkillEx and
        (self.match.ball.nextTask.frozenType == "CornerKick" or self.match.ball.nextTask.frozenType == "WingDirectFreeKick") then
        self:castSkill(knifeGuardSkillEx.class)
        self:addBuff(knifeGuardSkillEx.buff, self)
        return
    end

    local knifeGuardSkill = self:getCooldownSkill(Skills.KnifeGuard)
    if knifeGuardSkill and
        (self.match.ball.nextTask.frozenType == "CornerKick" or self.match.ball.nextTask.frozenType == "WingDirectFreeKick") then
        self:castSkill(knifeGuardSkill.class)
        self:addBuff(knifeGuardSkill.buff, self)
    end
end

function Athlete:judgePoacher()
    local poacherSkill = self:getCooldownSkill(Skills.Poacher)
    if not self:isDivingEx1Blocked() and poacherSkill 
    and selector.tossCoin(poacherSkill.probability) and Field.isInEnemyArea(self.position, self.team:getSign()) then
        self:addBuff(poacherSkill.buff, self)
    end
end

function Athlete:judgeRationalSteal()
    local skill = self:getCooldownSkill(Skills.RationalSteal)
    if skill and selector.tossCoin(skill.probability)then
        self:addBuff(skill.buff, self)
    end
end

function Athlete:judgeRationalIntercept()
    local candidiateIntercepts = AIUtils.getCandidateInterceptsForHighPass(self)
    for i, intercept in ipairs(candidiateIntercepts) do
        local interceptAthlete = intercept.key.athlete
        local skill = interceptAthlete:getSkill(Skills.RationalIntercept)
        if skill and selector.tossCoin(skill.probability)then
            interceptAthlete:castSkill(skill.class)
            self:addBuff(skill.buff, interceptAthlete)
        end
    end
end

function Athlete:judgeInterceptMasterEx1(currentSuccessProbility)
    local skill = self:getCooldownSkill(Skills.InterceptMasterEx1)
    if skill ~= nil and selector.tossCoin(skill.probability) then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
        return skill.buff.successProbilityModifier(currentSuccessProbility)
    end
    return currentSuccessProbility
end

function Athlete:judgeStealMasterEx1(currentSuccessProbility)
    local skill = self:getCooldownSkill(Skills.StealMasterEx1)
    if skill~= nil and selector.tossCoin(skill.probability)then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
        return skill.buff.successProbilityModifier(currentSuccessProbility)
    end
    return currentSuccessProbility
end

function Athlete:judgeWithBallSkill()
    local skillProbabilities = { }
    for _, skillName in ipairs(AIConfig.WithBallSkillNames) do
        if self["isSatisfy" .. skillName](self) then
            table.insert(skillProbabilities, {key = self:getSkill(Skills[skillName]).id, probability = self:getCooldownSkill(Skills[skillName]).probability})
        end
    end

    self:weightProbabilityArray(skillProbabilities)
    return selector.random(skillProbabilities)
end

function Athlete:judgeSelfConfidence()
    local skill = self:getCooldownSkill(Skills.SelfConfidence)
    if skill then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
    end
end

function Athlete:judgePatronSaint()
    local skill = self:getCooldownSkill(Skills.PatronSaint)
    if skill then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
    end
end

function Athlete:judgeDesperateFight()
    local skill = self:getCooldownSkill(Skills.DesperateFight)
    if skill then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
    end
end

function Athlete:judgeToughGetGoing()
    local skill = self:getCooldownSkill(Skills.ToughGetGoing)
    if skill then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
    end
end

function Athlete:judgeFrustrationDebuff()
    local skill = self:getCooldownSkill(Skills.Frustration)
    if skill then
        self:castSkill(skill.class)
        self:addBuff(skill.debuff, self)
    end
end

function Athlete:judgeLeaderMaster()
    local leaderMasterSkill = self:getCooldownSkill(Skills.LeaderMaster)
    if leaderMasterSkill then
        self:castSkill(leaderMasterSkill.class)
        self:addBuff(leaderMasterSkill.buff, self)
    end
end

function Athlete:judgeLaggerMaster()
    local laggerMasterSkill = self:getCooldownSkill(Skills.LaggerMaster)
    if laggerMasterSkill then
        self:castSkill(laggerMasterSkill.class)
        self:addBuff(laggerMasterSkill.buff, self)
    end
end

function Athlete:judgeDefendTactics()
    local skill = self:getCooldownSkill(Skills.DefendTactics)
    if skill then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
    end
end

function Athlete:judgeSoulFluctuationOnGoal()
    local skill = self:getCooldownSkill(Skills.SoulFluctuation)
    if skill then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
    end
end

function Athlete:judgeSoulFluctuationOnShootMiss()
    local skill = self:getCooldownSkill(Skills.SoulFluctuation)
    if skill then
        self:castSkill(skill.class)
        self:addBuff(skill.debuff, self)
    end
end

function Athlete:judgeSpurWithLongAccumulationWithFirstGoal()
    local skill = self:getCooldownSkill(Skills.SpurWithLongAccumulation)
    if skill then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
    end
end

function Athlete:judgeSpurWithLongAccumulationWithoutFirstGoal()
    local skill = self:getCooldownSkill(Skills.SpurWithLongAccumulation)
    if skill then
        self:castSkill(skill.class)
        self:addBuff(skill.debuff, self)
    end
end

function Athlete:judgeTopAssister()
    local skill = self:getCooldownSkill(Skills.TopAssister)
    if skill then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
    end
end

function Athlete:judgeBattery()
    local skill = self:getCooldownSkill(Skills.Battery)
    if skill and not Field.isInPenaltyArea(self.match.shootAthletePosition, self.team:getSign()) then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
    end
end

function Athlete:checkAndRemoveBuff(buffSkillClass, rootSkillClass)
    for i, buff in ipairs(self.buffs) do
        if buff.type.skill and buff.type.skill:isTypeOf(buffSkillClass) and buff.type.originalSkillClass and buff.type.originalSkillClass.isSubClassOf(rootSkillClass) then
            buff.toBeRemoved = true
            self:outputEndBuff(buff)
        end
    end
    self:setCachedAbilitiesDirty()
    shrinkBuffs(self)
end

function Athlete:RemoveBuff(buff)
    if buff ~= nil then
        buff.toBeRemoved = true
        self:outputEndBuff(buff)
        self:setCachedAbilitiesDirty()
        shrinkBuffs(self)
    end
end

function Athlete:judgeEmotional(rootSkill)
    local skill = self:getCooldownSkill(Skills.Emotional)
    if skill and rootSkill then
        skill.addRatio = skill.initRatio * rootSkill.addRatio
        self:castSkill(skill.class)

        if rootSkill:isTypeOf(Skills.ChargeTrumpet) then
            self:addBuff(skill.chargeTrumpetBuff, self)
        elseif rootSkill:isTypeOf(Skills.FightTogether) then
            self:addBuff(skill.fightTogetherBuff, self)
        elseif rootSkill:isTypeOf(Skills.Metronome) then
            self:checkAndRemoveBuff(Skills.Emotional, rootSkill.class)
            self:addBuff(skill.metronomeBuff, self)
        end
    end
end

function Athlete:judgeTeamSoul(rootSkill)
    local skill = self:getCooldownSkill(Skills.TeamSoul)
    
    if skill and rootSkill then
        skill.addRatio = skill.initRatio * rootSkill.addRatio

        -- 冲锋号角
        if rootSkill:isTypeOf(Skills.ChargeTrumpet) then
            self:addBuff(skill.chargeTrumpetBuff, self)
        -- 众志成城
        elseif rootSkill:isTypeOf(Skills.FightTogether) then
            self:addBuff(skill.fightTogetherBuff, self)
        -- 节拍器
        elseif rootSkill:isTypeOf(Skills.Metronome) then
            self:checkAndRemoveBuff(Skills.TeamSoul, rootSkill.class)
            self:addBuff(skill.metronomeBuff, self)
        -- 禁区烽火台
        elseif rootSkill:isTypeOf(Skills.PenaltyBoxSignalFireTurret) then
            self:addBuff(skill.penaltyBoxSignalFireTurretBuff, self)
        end
    end
end

function Athlete:getAdaptionMasterImmunityRatio()
    local skill = self:getCooldownSkill(Skills.AdaptionMaster)
    return skill and skill.immunityRatio or 1
end

function Athlete:judgeInterceptSkills()
    self:judgeRationalIntercept()
    if self.chosenDPSAction.type == "High" and not AIUtils.isSkillIdCorrespondSkill(self.passSkillId, Skills.ThroughBall) then
        self:judgeFlakTower()
        self:judgeAirDominator()
    else
        self:judgeAccurateAnticipation()
    end
end

function Athlete:setToBeCastedInterceptSkills()
    for i, buff in ipairs(self.buffs) do
        if buff.type.skill then
            local skillInstance = buff.type.skill
            if skillInstance:isTypeOf(Skills.AirDominator) or skillInstance:isTypeOf(Skills.FlakTower)
            or skillInstance:isTypeOf(Skills.AccurateAnticipation) or skillInstance:isTypeOf(Skills.Poacher)
            or skillInstance:isTypeOf(Skills.RationalIntercept) or 
            (skillInstance:isTypeOf(Skills.BlackHeart) and buff.type.remark == "self") then
                table.insert(self.toBeCastedSkills, skillInstance.class)
            end
        end
    end
end

function Athlete:judgeCathexisEx1()
    local skill = self:getCooldownSkill(Skills.CathexisEx1)
    if skill ~= nil and selector.tossCoin(skill.probability) then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
    end
end

function Athlete:judgeSaveMasterEx1(currentSuccessProbility)
    local skill = self:getCooldownSkill(Skills.SaveMasterEx1)
    if skill ~= nil and selector.tossCoin(skill.probability) then
        self:castSkill(skill.class)
        self:addBuff(skill.buff, self)
        return skill.buff.successProbilityModifier(currentSuccessProbility)
    end
    return currentSuccessProbility
end

function Athlete:judgeCornerKickMasterEx1(caster)
    local skill = caster:getCooldownSkill(Skills.CornerKickMasterEx1)
    if skill ~= nil then
        self:addBuff(skill.ex1Buff, caster)
    end
end

function Athlete:judgeSlidingTackleEx1(targetEnemy)
    local skill = self:getSkill(Skills.SlidingTackleEx1)
    if not self:isDivingEx1Blocked() and skill and selector.tossCoin(skill.ex1Probability) then
        targetEnemy:addBuff(skill.ex1Debuff, self)
    end
end

function Athlete:judgePenaltyBoxSignalFireTurretEx1()
    local skill = self:getSkill(Skills.PenaltyBoxSignalFireTurretEx1)
    if skill and self.team.hasSignalFireTurretBuff and self.team.isStealOrIntercept and selector.tossCoin(skill.ex1Probability) then
        self:addBuff(skill.ex1Buff, self)
    end
    self.team.hasSignalFireTurretBuff = nil
    self.team.isStealOrIntercept = nil
end

function Athlete:judgeTigerShootEx1(buffType)
    if not self:hasBuff(Skills.TigerShootEx1) then
        return
    end

    local skill = self:getSkill(Skills.TigerShootEx1)

    if skill and selector.tossCoin(skill["ex1Probability" .. buffType]) then
        local enemyGk = self.enemyTeam.athleteOfRole[26]
        local enemySkills = enemyGk:getUnmarkedNonFStartSkills()
        if #enemySkills > 0 then
            local function disableSkill(enemyGk, targetSkill, skill, caster)
                targetSkill.isDisabled = true
                enemyGk:removeBuffs(targetSkill.class)
                skill["ex1Buff" .. buffType].markedSkillId = targetSkill.id
                enemyGk:addBuff(skill["ex1Buff" .. buffType], caster)
            end
            if skill:isTypeOf(Skills.FireDemonEx1) then
                for i, targetSkill in ipairs(enemySkills) do
                    disableSkill(enemyGk, targetSkill, skill, self)
                end
            else
                local targetSkill = selector.randomSelect(enemySkills)
                disableSkill(enemyGk, targetSkill, skill, self)
            end
        end
    end
end

function Athlete:judgeImpactWaveEx1()
    local skill = self:getSkill(Skills.ImpactWaveEx1)
    if skill and selector.tossCoin(skill.ex1Probability) then
        local targetEnemies = {}
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            if enemy:isBack() then
                table.insert(targetEnemies, enemy)
            end
        end

        if #targetEnemies <= 0 then
            return
        end

        local targetEnemy = selector.randomSelect(targetEnemies)
        if targetEnemy == nil then
            return
        end

        local enemySkills = targetEnemy:getUnmarkedNonFStartSkills()
        if #enemySkills <= 0 then
            return
        end

        local targetSkill = selector.randomSelect(enemySkills)
        if targetSkill then
            targetSkill.isDisabled = true
            skill.ex1Debuff.markedSkillId = targetSkill.id
            targetEnemy:removeBuffs(targetSkill.class)
            targetEnemy:addBuff(skill.ex1Debuff, self)
        end
    end
    -- EX旋风冲击
    if skill and skill:isTypeOf(Skills.WindBlastEx1) and selector.tossCoin(skill.exa1Probability) then
        local targetEnemy = self.enemyTeam.athleteOfRole[26]
        local enemySkills = targetEnemy:getUnmarkedNonFStartSkills()
        local targetSkill = selector.randomSelect(enemySkills)
        if targetSkill then
            targetSkill.isDisabled = true
            skill.exa1Debuff.markedSkillId = targetSkill.id
            targetEnemy:removeBuffs(targetSkill.class)
            targetEnemy:addBuff(skill.exa1Debuff, self)
        end
    end
end

function Athlete:judgePenaltyKickKillerEx1()
    local skill = self:getSkill(Skills.PenaltyKickKillerEx1)
    if skill and self:hasBuff(Skills.PenaltyKickKillerEx1, "buffSign") then
        local targetEnemies = {}
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            if not enemy:isGoalkeeper() then
                table.insert(targetEnemies, enemy)
            end
        end
        local targetEnemy = selector.randomSelect(targetEnemies)
        local enemySkills = targetEnemy:getUnmarkedNonFStartSkills()
        if #enemySkills <= 0 then
            return
        end
        for _, targetSkill in ipairs(enemySkills) do
            targetSkill.isDisabled = true
            targetEnemy:removeBuffs(targetSkill.class)
            skill.ex1MarkedDebuff.markedSkillId = targetSkill.id
            targetEnemy:addBuff(skill.ex1MarkedDebuff, self)
        end
        skill.ex1Debuff.targetEnemy = targetEnemy
        targetEnemy:addBuff(skill.ex1Debuff, self)
    end
end

function Athlete:judgePenaltyKickKillerEx1Sign()
    local skill = self:getSkill(Skills.PenaltyKickKillerEx1)
    if skill and selector.tossCoin(skill.ex1DebuffProbability) then
        self:addBuff(skill.ex1BuffSign, self)
    end
end

function Athlete:judgeThroughBallEx1(interceptor, passSkillId)
    if self:hasBuff(Skills.ThroughBallEx1) and passSkillId and (passSkillId == Skills.ThroughBall.id
        or passSkillId == Skills.ThroughBallEx1.id or passSkillId == Skills.GoldenWolfDirectEx1.id) then
        local skill = self:getSkill(Skills.ThroughBallEx1)
        if skill and interceptor then
            interceptor:addBuff(skill.ex1Debuff, self)
            if skill:isTypeOf(Skills.GoldenWolfDirectEx1) and selector.tossCoin(skill.exa1Probability) then
                local enemySkills = interceptor:getUnmarkedNonFStartSkills()
                local randomCount = math.random(math.min(2, #enemySkills), math.min(#enemySkills, 4))
                local targetSkills = selector.randomSelectCount(enemySkills, randomCount)
                for i, targetSkill in ipairs(targetSkills) do
                    targetSkill.isDisabled = true
                    skill.exa1Debuff.markedSkillId = targetSkill.id
                    interceptor:removeBuffs(targetSkill.class)
                    interceptor:addBuff(skill.exa1Debuff, self)
                end
            end
        end
    end
end

function Athlete:judgeOverHeadBallEx1(interceptor, passSkillId)
    if self:hasBuff(Skills.OverHeadBallEx1) and passSkillId and (passSkillId == Skills.OverHeadBall.id or passSkillId == Skills.OverHeadBallEx1.id) then
        local skill = self:getSkill(Skills.OverHeadBallEx1)
        if skill and interceptor then
            interceptor:addBuff(skill.ex1Debuff, self)
        end
    end
end

function Athlete:judgeMetronomeEx1()
    local skill = self:getSkill(Skills.MetronomeEx1)
    local hasMetronomeExtraBuff = false
    local hasFightTogetherBuff = false
    local hasChargeTrumpetBuff = false
    if skill and selector.tossCoin(skill.ex1Probability) then
        local targetFriend = nil
        while targetFriend == nil or targetFriend == self do
            targetFriend = selector.randomSelect(self.team.athletes)
            self.midfieldMaestrosEx1Friend = targetFriend
        end

        for _, buffInstance in ipairs(targetFriend.buffs) do
            local skillClass = buffInstance.type.skill.class
            -- 清队友debuff
            if math.cmpf(buffInstance.value, 0) < 0 then
                targetFriend:removeBuffs(skillClass)
            end
            -- 队友节拍器、众志成城、冲锋号角增益加强
            if math.cmpf(buffInstance.value, 0) > 0 then
                if skillClass:isTypeOf(Skills.Metronome) and not hasMetronomeExtraBuff then
                    targetFriend:addBuff(skill.ex1Buff, self)
                    hasMetronomeExtraBuff = true
                end
                if skillClass:isTypeOf(Skills.FightTogether) and not hasFightTogetherBuff then
                    targetFriend:addBuff(skill.ex1Buff, self)
                    hasFightTogetherBuff = true
                end
                if skillClass:isTypeOf(Skills.ChargeTrumpet) and not hasChargeTrumpetBuff then
                    targetFriend:addBuff(skill.ex1Buff, self)
                    hasChargeTrumpetBuff = true
                end
            end
        end
    end
end

function Athlete:judgeMidfieldMaestrosEx1(skill)
    if self.midfieldMaestrosEx1Friend ~= nil then
        if skill:isTypeOf(Skills.MidfieldMaestrosEx1) and 
            not self.midfieldMaestrosEx1Friend:hasBuff(Skills.MidfieldMaestrosEx1, "debuffBlocked") then
            self.midfieldMaestrosEx1Friend:addBuff(skill.exa1Buff, self)
        end
        self.midfieldMaestrosEx1Friend = nil
    end
end

function Athlete:judgePoacherEx1()
    local skill = self:getSkill(Skills.PoacherEx1)
    if not self:isDivingEx1Blocked() and skill and Field.isInEnemyArea(self.position, self.team:getSign()) then
        for _, friend in ipairs(self.team.athletes) do
            friend:addBuff(skill.ex1Buff, self)
        end
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            enemy:addBuff(skill.ex1Debuff, self)
        end
        return true
    end
    return false
end

function Athlete:judgeCatenaccioEx1()
    local skill = self:getSkill(Skills.CatenaccioEx1)
    if skill then
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            enemy:addBuff(skill.ex1Debuff, self)
        end
    end
end

function Athlete:judgeHighQualityGkPassEx1BuffSign()
    local skill = self:getSkill(Skills.HighQualityGkPassEx1)
    if skill then
        local friends = {}
        for _, friend in ipairs(self.team.athletes) do
            if friend:isBack() or friend:isDefensiveMidfield() then
                table.insert(friends, friend)
            end
        end
        local targetFriends = selector.randomSelectCount(friends, math.min(skill.targetCount, #friends))
        for _, target in ipairs(targetFriends) do
            target:addBuff(skill.ex1BuffSign, self)            
        end
    end
end

function Athlete:isShortPassSuccess(targetPosition)
    return self:hasBuff(Skills.HighQualityGkPassEx1, "passSuccess")
     and math.cmpf(vector2.sqrdist(self.position, targetPosition), 100) <= 0
end

function Athlete:judgeBreakThroughEx1()
    local skill = self:getSkill(Skills.BreakThroughEx1)
    if skill and not self:hasBuff(Skills.BreakThroughEx1, "debuffBlocked") then
        self:addBuff(skill.ex1Buff, self)
    end
end

function Athlete:judgeCorePlayMakerEx1(caster)
    local skill = caster:getSkill(Skills.CorePlayMakerEx1)
    if skill then
        self:addBuff(skill.ex1Buff, caster)
    end
end

function Athlete:judgeFoxInTheBoxEx1(skillId)
    local skill = self:getSkill(Skills.FoxInTheBoxEx1)
    if skill and selector.tossCoin(skill.ex1Probability) and 
        (skillId == Skills.ThroughBall.id or skillId == Skills.ThroughBallEx1.id) then
        for _, selfSkill in ipairs(self.skills) do
            selfSkill.isDisabled = false
        end
    end
end

function Athlete:judgePowerfulHeaderEx1(skillId)
    local skill = self:getSkill(Skills.PowerfulHeaderEx1)
    if skill and selector.tossCoin(skill.ex1Probability) and 
        (skillId == Skills.CrossLow.id or skillId == Skills.CrossLowEx1.id
        or skillId == Skills.FreeKickMaster.id or skillId == Skills.CornerKickMaster.id
        or skillId == Skills.FreeKickMasterEx1.id or skillId == Skills.CornerKickMasterEx1.id) then
        for _, selfSkill in ipairs(self.skills) do
            selfSkill.isDisabled = false
        end
    end
end

function Athlete:judgeVolleyShootEx1(skillId)
    local skill = self:getSkill(Skills.VolleyShootEx1)
    if skill and selector.tossCoin(skill.ex1Probability) and 
        (skillId == Skills.OverHeadBall or skillId == Skills.OverHeadBallEx1
        or skillId == Skills.PuntKick or skillId == Skills.PuntKickEx1) then
        for _, selfSkill in ipairs(self.skills) do
            selfSkill.isDisabled = false
        end
    end
end

function Athlete:judgePerpetualMotionMachineEx1()
    local skill = self:getSkill(Skills.PerpetualMotionMachineEx1)
    if skill then
        for _, buffInstance in ipairs(self.buffs) do
            local skillClass = buffInstance.type.skill.class
            if math.cmpf(buffInstance.value, 0) < 0 then
                self:removeBuffs(skillClass)
                break
            end
        end

        local friends = {}
        for _, friend in ipairs(self.team.athletes) do
            if friend ~= self then
                table.insert(friends, friend)
            end
        end

        -- 如果已有buff则更新
        local baseFriend = selector.randomSelect(friends)
        local existBuff
        for i, buff in ipairs(baseFriend.buffs) do
            if buff.type.skill and buff.type.skill:isTypeOf(Skills.PerpetualMotionMachineEx1) and buff.type.remark == "debuffBlocked" then
                existBuff = buff
            end
        end
        if existBuff then
            baseFriend:RemoveBuff(existBuff)
        end
        baseFriend:addBuff(skill.ex1Buff, self)
    
        if skill:isTypeOf(Skills.TirelessEx1) then
            local targetFriend = selector.randomSelect(friends)
            while targetFriend == baseFriend do
                targetFriend = selector.randomSelect(friends)
            end
            targetFriend:addBuff(skill.exa1Buff, self)
        end
    end
end

function Athlete:judgeOrganizeWallEx1()
    local skill = self:getSkill(Skills.OrganizeWallEx1)
    if skill ~= nil then
        if self.match.frozenType == "WingDirectFreeKick" then
            for i, a in ipairs(self.team.athletes) do
                if a ~= self then
                    a:addBuff(skill.ex1BuffWing, self)
                end
            end
        elseif self.match.frozenType == "CenterDirectFreeKick" then
            self:addBuff(skill.ex1BuffCenter, self)
        end
    end
end

function Athlete:judgeTeamLeaderEx1(rootSkillInstance)
    local skill = self.team.captainPlayer:getSkill(Skills.TeamLeaderEx1)
    if skill ~= nil then
        rootSkillInstance.teamLeaderAddRatio = skill.ex1AddRatio * rootSkillInstance.addRatio
        self:addBuff(rootSkillInstance.teamLeaderBuff, self.team.captainPlayer)
    end
end

function Athlete:RemoveImpactWaveEx1Skill()
    if self:hasBuff(Skills.ImpactWaveEx1, "mark") then
        self:removeBuffs(Skills.ImpactWaveEx1, "mark")
    end
end

function Athlete:judgeHandingEx1()
    local skill = self:getSkill(Skills.HandingEx1)
    if skill ~= nil and selector.tossCoin(skill.ex1Probability) then
        local targetEnemy = selector.randomSelect(self.enemyTeam.athletes)
        targetEnemy:addBuff(skill.ex1Debuff, self)

        local targetBuffList = {}
        for i, buff in ipairs(targetEnemy.buffs) do
            if buff.value and math.cmpf(buff.value, 0) > 0 then
                table.insert(targetBuffList, buff)
            end
        end

        local targetBuff = selector.randomSelect(targetBuffList)
        targetEnemy:RemoveBuff(targetBuff)
    end
end

function Athlete:judgeFlakTowerEx1(targetEnemy, shootType, influenceCount)
    if self:isDivingEx1Blocked() then
        return 0, influenceCount
    end
    local skill = self:getSkill(Skills.FlakTowerEx1)
    if skill and math.cmpf(vector2.dist(self.position, targetEnemy.position), skill.influenceDistance) <= 0 then
        if shootType == AIUtils.shootAnimationType.header and selector.tossCoin(skill.headBallInfluenceProbability) then
            self:castSkill(skill.class)
            return math.max(0, skill.headBallInfluence * (1 - skill.decreaseRate * influenceCount)), influenceCount + 1
        elseif shootType == AIUtils.shootAnimationType.volleyShoot and selector.tossCoin(skill.volleyShootInfluenceProbability) then
            self:castSkill(skill.class)
            return math.max(0, skill.volleyShootInfluence * (1 - skill.decreaseRate * influenceCount)), influenceCount + 1
        end
    end
    return 0, influenceCount
end

function Athlete:judgePuntKickEx1()
    local skill = self:getSkill(Skills.PuntKickEx1)
    if skill and selector.tossCoin(skill.ex1Probability) then
        self:addBuff(skill.ex1Buff, self)
        local debuffList = {}
        for _, buff in ipairs (self.buffs) do
            if buff.value ~= nil and math.cmpf(buff.value, 0) < 0 then
                table.insert(debuffList, buff)
            end
        end
        local debuff = selector.randomSelect(debuffList)
        self:RemoveBuff(debuff)
    end
end

function Athlete:judgeHeavyGunnerEx1()
    local skill = self:getSkill(Skills.HeavyGunnerEx1)
    if skill and selector.tossCoin(skill.ex1Probability) then
        self:addBuff(skill.ex1MarkedBuff, self)
        self.heavyGunnerEx1BuffCount = self.heavyGunnerEx1BuffCount + 1
    end
end

function Athlete:clearHeavyGunnerEx1Count()
    if math.cmpf(self.heavyGunnerEx1BuffCount, 0) > 0 then
        self.heavyGunnerEx1BuffCount = 0
    end
end

function Athlete:judgeAccurateAnticipationEx1(passAthlete)
    if self:isDivingEx1Blocked() then
        return
    end

    local skill = self:getSkill(Skills.AccurateAnticipationEx1)
    local castSkill = false
    if skill then
        if selector.tossCoin(skill.ex1Probability) then
            passAthlete:addBuff(skill.ex1Debuff, self)
            castSkill = true
        end

        if selector.tossCoin(skill.ex1BlockProbability) then
            local skills = passAthlete:getUnmarkedNonFStartSkills()
            if #skills > 0 then
                local targetSkill = selector.randomSelect(skills)
                if targetSkill then
                    targetSkill.isDisabled = true
                    passAthlete:removeBuffs(targetSkill.class)
                    skill.ex1MarkedDebuff.markedSkillId = targetSkill.id
                end
                passAthlete:addBuff(skill.ex1MarkedDebuff, self)
            end
            castSkill = true
        end

        if castSkill then
            self:castSkill(skill.class)
        end
    end
end

function Athlete:judgeLongPassDispatch()
    local sqrdistance = vector2.sqrdist(self.position, self.chosenDPSAction.targetPosition)
    if math.cmpf(sqrdistance, 24 ^ 2) > 0 and math.cmpf(sqrdistance, 100 ^ 2) <= 0 then
        local selfLongPassDispatchSkill = self:getCooldownSkill(Skills.LongPassDispatch)
        local targetAthlete = self.chosenDPSAction.targetAthlete
        local targetAthleteLongPassDispatchSkill = targetAthlete:getCooldownSkill(Skills.LongPassDispatch)

        if selfLongPassDispatchSkill then
            self:addBuff(selfLongPassDispatchSkill.buff, self)
            self.passSkillId2 = selfLongPassDispatchSkill.class.id
            if selfLongPassDispatchSkill:isTypeOf(Skills.LongPassDispatchEx1) and selector.tossCoin(selfLongPassDispatchSkill.extraProbability) then
                for _, buffInstance in ipairs(targetAthlete.buffs) do
                    if math.cmpf(buffInstance.value, 0) < 0  or buffInstance.type.remark == "mark" or buffInstance.type.remark == "canNotDefend" then
                        targetAthlete:removeBuffs(buffInstance.type.skill.class)
                    end
                end
            end
        end

        if targetAthleteLongPassDispatchSkill then
            self:addBuff(targetAthleteLongPassDispatchSkill.buff, targetAthlete)
        end
    end
end

function Athlete:judgeLongPassDispatchCatcherEffect(catcher)
    local skill = self:getSkill(Skills.LongPassDispatch)
    if skill then
        catcher:addBuff(skill.extraBuff, self)
    end
end

function Athlete:judgeLegendaryBloodEx1()
    local skill = self:getCooldownSkill(Skills.LegendaryBloodEx1)
    if skill ~= nil and selector.tossCoin(skill.probability) then
        self:castSkill(skill.class)
        if self.team:isAttackRole() then
            for _, enemy in ipairs(self.enemyTeam.athletes) do
                enemy:addBuff(skill.attackBuff, self)
            end
        else
            for _, enemy in ipairs(self.enemyTeam.athletes) do
                enemy:addBuff(skill.defendBuff, self)
            end
        end
    end
end

function Athlete:judgeGamesmanshipEx1(targetEnemy)
    local skill = self:getSkill(Skills.GamesmanshipEx1)
    if skill and selector.tossCoin(skill.ex1Probability) then
        targetEnemy:judgeGamesmanshipEx1Influence(self, skill)
    end
end

function Athlete:judgeGamesmanshipEx1Influence(caster, casterSkill)
    local count = 0
    for _, buff in ipairs(self.buffs) do
        if (buff.type.skill.class:isTypeOf(Skills.Gamesmanship)) then
            count = count + 1
        end
    end

    if math.cmpf(count, casterSkill.debuffCount) >= 0 then
        for _, selfSkill in ipairs(self.skills) do
            if selfSkill:isShootSkill() then
                selfSkill.isDisabled = true
                casterSkill.ex1Debuff.markedSkillId = selfSkill.id
                self:removeBuffs(selfSkill.class)
                self:addBuff(casterSkill.ex1Debuff, caster)
            end
        end
    end
end

function Athlete:judgeGamesmanshipEx1GoalProbability(goalProbability)
    for _, buff in ipairs(self.buffs) do
        local skill = buff.type.skill
        if skill.class:isTypeOf(Skills.GamesmanshipEx1) then
            goalProbability = goalProbability + skill.ex1GoalProbability
        end
    end
    return goalProbability
end

function Athlete:judgeDivingEx1(fouler)
    local skill = self:getSkill(Skills.DivingEx1)
    if skill and selector.tossCoin(skill.ex1Probability) then
        fouler:addBuff(skill.ex1Debuff, self)
    end
end

function Athlete:judgeBlockEx1()
    local skill = self:getSkill(Skills.BlockEx1)
    if not self:isDivingEx1Blocked() and skill then
        return skill.ex1Probability
    end
    return 0
end

function Athlete:judgeTeamSoulEx1()
    local skill = self:getCooldownSkill(Skills.TeamSoulEx1)
    if skill and selector.tossCoin(skill.ex1Probability) then
        self:castSkill(skill.class)
        for _, buffInstance in ipairs(self.buffs) do
            local skillClass = buffInstance.type.skill.class
            if math.cmpf(buffInstance.value, 0) < 0 then
                self:removeBuffs(skillClass)
                break
            end
        end
    end
end

function Athlete:judgePonytailCaptainEx1()
    local skill = self:getCooldownSkill(Skills.PonytailCaptainEx1)
    if skill then
        for _, friend in ipairs(self.team.athletes) do
            if friend:isBack() then
                friend:addBuff(skill.exa1Buff, self)
            end
        end
        self:castSkill(skill.class)
    end
end

function Athlete:judgeFiercelyDogfightEx1()
    local skill = self:getCooldownSkill(Skills.FiercelyDogfightEx1)
    if skill and selector.tossCoin(skill.exa1Probability) then
        self:addBuff(skill.exa1Buff, self)
    end
end

function Athlete:judgeGreatSpeedEx1(type)
    local skill = self:getSkill(Skills.GreatSpeedEx1)
    if skill then
        if type == "Goal" then
            self:addBuff(skill.exa1GoalBuff, self)
        elseif type == "Foul" then
            self:addBuff(skill.exa1FoulBuff, self)
        end
    end
end

function Athlete:judgeGracefulArcsEx1(type)
    local skill = self:getCooldownSkill(Skills.GracefulArcsEx1)
    if skill then
        if type == "Catch" then
            if selector.tossCoin(skill.exa1AddProbability) then
                self:castSkill(skill.class)
                self:addBuff(skill.exa1CatchBuff, self)
            end
        elseif type == "Pass" then
            self:addBuff(skill.exa1PassBuff, self)
        end
    end
end

function Athlete:judgeLegendaryNO7()
    local skill = self:getCooldownSkill(Skills.LegendaryNO7)
    if skill then
        self:castSkill(skill.class)
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            if enemy:isBack() or enemy:isGoalkeeper() then
                enemy:addBuff(skill.debuff, self)
            end
        end
    end
end

function Athlete:judgeMagicFlute()
    local skill = self:getCooldownSkill(Skills.MagicFlute)
    if skill then
        self:castSkill(skill.class)
        for _, athlete in ipairs(self.team.athletes) do
            if athlete ~= self and athlete:isMidfield() then
                athlete:addBuff(skill.buff, self)
            end
        end
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            if enemy:isBack() then
                enemy:addBuff(skill.debuff, self)
            end
        end
    end
end

function Athlete:judgeDimensionReductionBlow()
    local skill = self:getCooldownSkill(Skills.DimensionReductionBlow)
    if skill then
        self:castSkill(skill.class)
        local ret = selector.randomSelectCount(self.enemyTeam.athletes, 2)
        for _, enemy in ipairs(ret) do
            enemy:addBuff(skill.debuff, self)
        end
    end
end

function Athlete:judgeDeviseStrategies()
    local skill = self:getCooldownSkill(Skills.DeviseStrategies)
    if skill then
        self:castSkill(skill.class)
        for _, athlete in ipairs(self.team.athletes) do
            athlete:addBuff(skill.buff, self)
        end
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            enemy:addBuff(skill.debuff, self)
        end
    end
end

function Athlete:judgeUnstableMentality(event)
    local skill = self:getCooldownSkill(Skills.UnstableMentality)
    if skill then
        self:castSkill(skill.class)
        if event == "goal" then
            self:addBuff(skill.buff, self)
        elseif event == "lose" then
            local totalAddRatio = 0
            local subRatio = skill.subRatio
            for i, buff in ipairs(self.buffs) do
                if buff.type.skill:isTypeOf(Skills.UnstableMentality) then
                    totalAddRatio = totalAddRatio + buff.value
                end
            end
            if totalAddRatio > 0 then
                if math.cmpf(totalAddRatio, math.abs(subRatio)) <= 0 then
                    skill.subRatio = -totalAddRatio
                end
                self:addBuff(skill.debuff, self)
                skill.subRatio = subRatio
            end
        end
    end
end

function Athlete:judgeWindChasingBoy(stealer)
    local skill = self:getCooldownSkill(Skills.WindChasingBoy)
    if skill ~= nil and selector.tossCoin(skill.stealFailedProbabilityConfig) then -- and not self.isDivingFail
        stealer.isStealFail = true
        self:castSkill(skill.class)
    end
end

function Athlete:judgeTopStudentOnField()
    local skill = self:getCooldownSkill(Skills.TopStudentOnField)
    if skill ~= nil then
        local friends = {}
        for _, athlete in ipairs(self.team.athletes) do
            if athlete ~= self and (athlete:isDefensiveMidfield() or athlete:isBack()) and not athlete:hasBuff(Skills.TopStudentOnField, "buffSign") then
                table.insert(friends, athlete)
            end
        end

        local targetAthlete = selector.randomSelect(friends)
        if targetAthlete then
            targetAthlete:addBuff(skill.buffSign, self)
            self:castSkill(skill.class)
        end
    end
end

function Athlete:judgeTopStudentOnFieldEffect(targetEnemy)
    if self:isDivingEx1Blocked() then
        return 0
    end
    for _, buffInstance in ipairs(self.buffs) do
        if buffInstance.type.skill:isTypeOf(Skills.TopStudentOnField) and buffInstance.type.remark == "buffSign" then
            local skill = buffInstance.caster:getSkill(Skills.TopStudentOnField)
            if skill and math.cmpf(vector2.dist(self.position, targetEnemy.position), skill.influenceDistance) <= 0 then
                return math.max(0, skill.influence)
            end
        end
    end
    return 0
end

function Athlete:judgeBlackHeartSelfBuff()
    local skill = self:getCooldownSkill(Skills.BlackHeart)
    if skill and self.blackHeartCount < 5 then
        self.blackHeartCount = self.blackHeartCount + 1
        self:addBuff(skill.buff, self)
        self:castSkill(skill.class)
    end
end

function Athlete:judgeBlackHeartEnemyBuff()
    local skill = self:getSkill(Skills.BlackHeart)
    if skill then
        self:removeBuffs(Skills.BlackHeart, "self")
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            for i = 1, self.blackHeartCount do
                enemy:addBuff(skill.debuff, self)
            end
        end
        self.blackHeartCount = 0
    end
end

function Athlete:judgeBrazilianHeavyGunner(shooter)
    local skill = self:getCooldownSkill(Skills.BrazilianHeavyGunner)
    if skill and selector.tossCoin(skill.probability) then
        shooter:addBuff(skill.buff, self)
        self:castSkill(skill.class)
    end
end

function Athlete:judgeGoldenWolfGuti()
    local skill = self:getCooldownSkill(Skills.GoldenWolfGuti)
    if skill and selector.tossCoin(skill.probability) then
        self:castSkill(skill.class)
        for _, athlete in ipairs(self.team.athletes) do
            athlete:addBuff(skill.buff, self)
        end
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            enemy:addBuff(skill.debuff, self)
        end
    end
end

function Athlete:judgeTheKingOfTheSamba()
    local skill = self:getCooldownSkill(Skills.TheKingOfTheSamba)
    if skill and selector.tossCoin(skill.probability) then
        for _, athlete in ipairs(self.team.athletes) do
            athlete:castSkill(skill.class, skill.addRatio)
            athlete:addBuff(skill.buff, self)
        end
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            enemy:castSkill(skill.class, skill.subRatio)
            enemy:addBuff(skill.debuff, self)
        end
    end
end

function Athlete:judgeSambaIronFenceSelfBuff()
    local skill = self:getCooldownSkill(Skills.SambaIronFence)
    if skill and selector.tossCoin(skill.probability) then
        self.sambaIronFenceCount = self.sambaIronFenceCount + 1
        self:addBuff(skill.buff, self)
        self:castSkill(skill.class)
    end
end

function Athlete:judgeSambaIronFenceFriendBuff()
    local skill = self:getCooldownSkill(Skills.SambaIronFence)
    if skill and self.sambaIronFenceCount > 0 then
        self:removeBuffs(Skills.SambaIronFence, "self")
        for _, athlete in ipairs(self.team.athletes) do
            if athlete ~= self then
                for i = 1, self.sambaIronFenceCount do
                    athlete:addBuff(skill.extraBuff, self)
                end
            end
        end
        self.sambaIronFenceCount = 0
    end
end

function Athlete:judgeTheSoulOfTheMatador()
    local skill = self:getCooldownSkill(Skills.TheSoulOfTheMatador)
    if skill and selector.tossCoin(skill.probability) then
        self:castSkill(skill.class)
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            enemy:addBuff(skill.debuff, self)
        end
    end
end

-- scoreState == DRAW 时调用
function Athlete:judgeIronWarrior()
    local skill = self:getCooldownSkill(Skills.IronWarrior)
    if skill and selector.tossCoin(skill.probability) then
        self:castSkill(skill.class)
        for _, ath in ipairs(self.team.athletes) do
            ath:addBuff(skill.buff, self)
        end
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            enemy:addBuff(skill.debuff, self)
        end
    end
end

function Athlete:judgeAllAroundFighter(actionType)
    if actionType then
        local skill = self:getCooldownSkill(Skills.AllAroundFighter)
        if skill and selector.tossCoin(skill.probability) then
            self:castSkill(skill.class)
            if actionType == "pass" or actionType == "shoot" then
                local ath = selector.randomSelect(self.team.athletes)
                if ath then
                    ath:addBuff(skill.buff, self)
                end
            elseif actionType == "intercept" or actionType == "steal" then
                local ath = selector.randomSelect(self.enemyTeam.athletes)
                if ath then
                    ath:addBuff(skill.debuff, self)
                end
            end
        end
    end
end

function Athlete:judgeHeavyGunnerPoogba()
    local skill = self:getCooldownSkill(Skills.HeavyGunnerPoogba)
    if skill and selector.tossCoin(skill.probability) then
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            enemy:addBuff(skill.debuff, self)
        end
    end
end

function Athlete:judgeThreeLionsGateGod()
    local skill = self:getCooldownSkill(Skills.ThreeLionsGateGod)
    if skill and selector.tossCoin(skill.probability) then
        self:addBuff(skill.buffSign, self)
        self:castSkill(skill.class)
        for _, friend in ipairs(self.team.athletes) do
            if friend ~= self and (friend:isBack() or friend:isDefensiveMidfield()) then
                friend:addBuff(skill.buff, self)
            end
        end
    end
end

function Athlete:judgeThreeLionsGateGodExtraBuff()
    if self:hasBuff(Skills.ThreeLionsGateGod, "buffSign") then
        local skill = self:getSkill(Skills.ThreeLionsGateGod)
        if skill then
            self:addBuff(skill.selfBuff, self)
        end
    end
end

function Athlete:judgeScarWarrior(withBallSkillId)
    if withBallSkillId and string.match(withBallSkillId, "B01") then
        local skill = self:getCooldownSkill(Skills.ScarWarrior)
        if skill and selector.tossCoin(skill.probability) then
            self:addBuff(skill.buff, self)
            self:addBuff(skill.buff1, self)
            self:castSkill(skill.class)
        end
    end 
end

function Athlete:judgeGpiquePenetrateEverything()
    local skill = self:getCooldownSkill(Skills.GpiquePenetrateEverything)
    if skill and selector.tossCoin(skill.probability) then
        self:castSkill(skill.class)
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            local unmarkedNonFStartSkills = enemy:getUnmarkedNonFStartSkills()
            local markedSkill = selector.randomSelect(unmarkedNonFStartSkills)
            if markedSkill then
                markedSkill.isDisabled = true
                enemy:removeBuffs(markedSkill.class)
                skill.markedBuff.markedSkillId = markedSkill.id
                enemy:addBuff(skill.markedBuff, self)
            end
        end
    end
end

function Athlete:judgeRomanWarSpirit(isAfterSwitchRole)
    local skill = self:getCooldownSkill(Skills.RomanWarSpirit)
    if skill then
        if isAfterSwitchRole then
            if selector.tossCoin(skill.probability) then
                self:castSkill(skill.class)
                for _, ath in ipairs(self.team.athletes) do
                    ath:addBuff(skill.buff)
                end
            end            
        else
            if selector.tossCoin(skill.probability1) then
                self:castSkill(skill.class)
                for _, ath in ipairs(self.team.athletes) do
                    for index, buffInstance in ipairs(ath.buffs) do
                        if math.cmpf(buffInstance.value, 0) < 0
                         or buffInstance.remark and (buffInstance.remark == "mark" or buffInstance.remark == "cannotAddBuff") then
                            ath:RemoveBuff(buffInstance)
                        end 
                    end
                end
            end
        end
    end
end

function Athlete:judgeLegendaryGoalkeeperAEx1()
    if self:isGoalkeeper() then
        local skill = self:getSkill(Skills.LegendaryGoalkeeperAEx1)
        if skill and selector.tossCoin(skill.exa1Probability) then
            self:castSkill(skill.class)
            for _, enemy in ipairs(self.enemyTeam.athletes) do
                enemy:addBuff(skill.exa1Debuff, self)
            end
        end
    end
end

function Athlete:judgeMatadorExcaliburEx1()
    local skill = self:getSkill(Skills.MatadorExcaliburEx1)
    if skill and selector.tossCoin(skill.exa1Probability) then
        self:castSkill(skill.class)
        self.enemyTeam.athleteOfRole[26]:addBuff(skill.exa1Debuff, self)
    end
end
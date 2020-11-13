local TeamStates = import("./teamStates/TeamStates")
local Athlete = import("./athlete/Athlete")
local Field = import("./Field")
local Skills = import("./skills/Skills")
local vector2 = import("./libs/vector")
local selector = import("./libs/selector")
local Ball = import("./Ball")
local AIUtils = import("./AIUtils")
local AIConstants = import("./AIConstants")

local Team = class()

function Team:ctor(match)
    self.name = "untitled_team"
    self.isPlayerTeam = nil
    self.match = match
    self.power = nil
    self.powerRatio = 1
    self.enemyTeam = nil
    self.score = 0
    self.shootOutScore = 0 -- penalty shootout score
    self.shootOutAttempts = 0
    self.penaltyShootOutResultsQueue = {}
    self.previousScore = 0 -- previous match score for Home-away

    self.shootTimes = 0
    self.shootOnGoalTimes = 0
    self.interceptTimes = 0
    self.dribbleTimes = 0
    self.mayBeStolenDribbleTimes = 0
    self.stealTimes = 0
    self.foulTimes = 0
    self.passTimes = 0
    self.highPassTimes = 0
    self.cornerKickTimes = 0
    self.interceptedCornerKickTimes = 0
    self.mayBeInterceptedPassTimes = 0
    self.cornerTimes = 0
    self.offsideTimes = 0
    self.manualOperateEnterTimes = 0
    self.manualOperateTriggerTimes = 0
    self.manualOperateRemainingCoolDown = 0
    self.possession = 0

    self.athletes = {}  -- athletes on field
    self.athleteOfRole = {}
    self.athletesAll = {}  -- all athletes (include banch player)
    self.side = "home" -- home/away/neutral
    self.role = "Attack" -- Attack/Defend
    self.goal = Field.goals.north
    self.field = "north"
    self.nearestAthleteToBall = nil
    self.hasJudgedSignalFireTurret = nil
    self.hasSignalFireTurretBuff = nil
    self.moveStatusCount = {}
    self.enemyAthleteWithBall = nil
    self.nearestAthleteToMarkEnemyAthleteWithBall = nil
    self.nearestAthleteToFillInEnemyAthleteWithBall = nil
    self.nearestAthleteToCoverEnemyAthleteWithBall = nil
    self.states = TeamStates.new(self)
    self.state = self.states.Idle

    self.scoreState = AIConstants.teamScoreState.DRAW

    self.captain = nil
    self.cornerKicker = nil
    self.penaltyKicker = nil
    self.freeKickShooter = nil
    self.freeKickPasser = nil
    self.leftFootCornerKickPlayer = nil
    self.rightFootCornerKickPlayer = nil
    self.kickOffPlayer = nil
    self.kickOffPassTargetPlayer = nil
    self.leftSideThrowInPlayer = nil
    self.rightSideThrowInPlayer = nil
    self.captainPlayer = nil
    self.penaltyKickPlayer = nil
    self.freeKickShootPlayer = nil
    self.freeKickPassPlayer = nil

    self.isStolenInOwnArea = false
    self.isFirstGoalTeam = nil
    self.isStealOrIntercept = nil

    self.formation = nil
    self.centerDirectFreeKickWall = nil
    self.wingDirectFreeKickWall = nil
    self.offsideLine = 0
    self.backLine = 0
    self.predictedBackLine = 0
    self.tactics = { }
    self.dcCount = 0
    self.continuousCatchPassCount = 0
    self.bestAttackDc = nil
    self.event = {} -- record match event
    self.coachBonus = nil
    self.trainerBonus = nil
    self.passingCooperationCount = 0
    self.catenaccioCount = 0
    self.catenaccioEx1Count = 0
    self.coachSkills = {}
    self.lastCoachSkillId = nil
    self.inManualOperating = nil --球队是否处于手动操作中
    self.manualOperateTimes = 0 --球队这一次的手动操作次数
    self.outputIsManualOperateEnded = nil
    self.latestPassAthlete = nil
    self.leadPassTimes = 0
    self.highLeadPassTimes = 0
    self.offTheBallTargetsStatus = {
        leftTarget = {position = nil, bestAthlete = nil},
        centerTarget = {position = nil, bestAthlete = nil},
        rightTarget = {position = nil, bestAthlete = nil}
    }
    self.runningForwardAthletes = {
        leftAthlete = nil,
        centerAthlete = nil,
        rightAthlete = nil
    }
    self.rankedPenaltyShootOutAthletes = {}
end

function Team:getMainRole(role)
    return Field.roleInfo[role]["mainRole"]
end

function Team:getIsSideAthlete(role)
    return Field.roleInfo[role]["isSideAthlete"]
end

function Team:updateAthleteOnField()
    self.athletes = {}
    for i, athlete in ipairs(self.athletesAll) do
        if athlete.onfieldId then
            athlete.mainRole = self:getMainRole(athlete.role)
            athlete.isSideAthlete = self:getIsSideAthlete(athlete.role)
            self.athleteOfRole[athlete.role] = athlete
            if athlete.onfieldId <= 11 then
                self.athletes[athlete.onfieldId] = athlete
            else
                self.athletes[athlete.onfieldId - 11] = athlete
            end
            athlete:checkAdeptRoleState()
        end
    end
    self.passingCooperationCount = self:getTeamSkillFactor(Skills.PassingCooperation)
    self.catenaccioCount = self:getTeamSkillFactor(Skills.Catenaccio)
    self.catenaccioEx1Count = self:getTeamSkillFactor(Skills.CatenaccioEx1)
end

function Team:initTeamAthletes(enemyTeam, teamInitializer, startId, startOnfieldId)
    self.enemyTeam = enemyTeam

    local i = 1
    local id, fid = startId, startOnfieldId
    for uid, _athlete in ipairs(teamInitializer.athletes) do
        local athlete = self.athletesAll[uid]
        if athlete == nil then
            athlete = Athlete.new()
        end
        athlete.id = _athlete.id or id
        athlete.team = self
        athlete.enemyTeam = enemyTeam
        athlete.number = i
        athlete.match = self.match

        table.insert(self.athletesAll, athlete)

        for k, v in pairs(_athlete) do
            if k ~= "skills" and k ~= "abilities" then
                athlete[k] = v
            end
        end

        -- Init athlete skills

        local skillList = {}
        for skillId, level in pairs(_athlete.skills) do
            table.insert(skillList, skillId)
        end
        table.sort(skillList)

        for i, skillId in ipairs(skillList) do
            local skill = AIUtils.getSkillById(skillId)
            if skill then
                local level = _athlete.skills[skillId]

                if table.isArrayInclude(self.match.weatherEffectSkillIds, skillId) then
                    level = level - self.match.weatherEffectSkillDecrease
                end

                if level > 0 then
                    table.insert(athlete.skills, skill.new(level))
                end
            end
        end

        --athlete.skills = { }

        -- Assign an onfieldId if the athlete is onfield
        if 1 <= athlete.role and athlete.role <= 25 then
            fid = fid + 1
            athlete.onfieldId = fid
        elseif athlete:isGoalkeeper() then
            -- Put goalKeeper at first position
            athlete.onfieldId = startOnfieldId
        end

        i = i + 1
        id = id + 1

        -- Init athlete abilities
        athlete.maxInitAbility = 0
        athlete.initAbilitiesSum = 0
        for k, v in pairs(_athlete.abilities) do
            athlete.abilities[k] = type(v) == "table" and v or { value = v, bonus = 0 }
            if type(v) == "number" then
                athlete.initAbilities[k] = v
                athlete.initAbilitiesSum = athlete.initAbilitiesSum + v
                if math.cmpf(v, athlete.maxInitAbility) > 0 then
                    athlete.maxInitAbility = v
                end
            end
        end
    end
    self:updateAthleteOnField()
    return id
end

function Team:getTeamAbilitiesSum()
    local abilitiesSum = 0

    for i, athlete in ipairs(self.athletes) do
        abilitiesSum = abilitiesSum + athlete:getAbilitiesSum()
    end

    return abilitiesSum
end

function Team:calculatePower()
    self.power = self:getTeamAbilitiesSum()
end

function Team:updateDcInfo()
    local bestAttackAbility = -1

    for i, athlete in ipairs(self.athletes) do
        if athlete.role == 22 or athlete.role == 23 or athlete.role == 24 then
            self.dcCount = self.dcCount + 1
            local attackAbility = athlete:getAbilities().pass + athlete:getAbilities().dribble + athlete:getAbilities().shoot
            if math.cmpf(attackAbility, bestAttackAbility) > 0 then
                bestAttackAbility = attackAbility
                self.bestAttackDc = athlete
            end
        end
    end
end

function Team:initTeamStates(teamInitializer)
    for k, v in pairs(teamInitializer) do
        if k ~= "athletes" and k ~= "coachSkill" then
            self[k] = v
        end
    end

    if teamInitializer.coachSkill ~= nil then
        for _, skillId in ipairs(teamInitializer.coachSkill) do
            local skill = AIUtils.getSkillById(tonumber(skillId))
            if skill ~= nil then
                table.insert(self.coachSkills, skill.new())
            end
        end
    end

    self.goal = self.field == "north" and Field.goals.north or Field.goals.south

    self:updateDcInfo()
    self:assignTeamRole()

    -- Default value in development
    if not self.tactics.attackRhythm then
        self.tactics.attackRhythm = 3
    end
end

function Team:substitute(roles)
    assert(#roles == #self.athletesAll)

    local originalCaptainAthlete = self.captainPlayer

    for k, v in ipairs(roles) do
        if v == 26 then
            local upAthlete = self.athletesAll[k]
            for idx, downAthlete in ipairs(self.athletesAll) do
                if downAthlete:isGoalkeeper() and upAthlete ~= downAthlete then
                    upAthlete.onfieldId, downAthlete.onfieldId = downAthlete.onfieldId, upAthlete.onfieldId
                    break
                end
            end
            break
        end
    end

    for k, v in ipairs(roles) do
        local upAthlete = self.athletesAll[k]
        if 1 <= v and v <= 26 and not upAthlete.onfieldId then
            for idx, downAthlete in ipairs(self.athletesAll) do
                if downAthlete.onfieldId and (1 > roles[idx] or roles[idx] > 26) then
                    upAthlete.onfieldId = downAthlete.onfieldId
                    downAthlete.onfieldId = nil
                    break
                end
            end
        end
        upAthlete.role = v
    end
    self:updateAthleteOnField()
    self:assignTeamRole()

    if self.captainPlayer ~= originalCaptainAthlete then
        self.isCaptainChanged = true
    else
        self.hasSubstituted = true
    end
end

function Team:checkTeamLeaderBuffs()
    if self.isCaptainChanged then
        self:updateTeamLeaderBuffs()
        self.isCaptainChanged = nil
    elseif self.hasSubstituted then
        self:addTeamLeaderBuffToUpAthletes()
        self.hasSubstituted = nil
    end
end

function Team:updateTeamLeaderBuffs()
    local teamLeaderSkill = self.captainPlayer:getSkill(Skills.TeamLeader)
    if teamLeaderSkill and (not self.captainPlayer.captainEnterFieldTime
        or math.cmpf(self.captainPlayer.captainEnterFieldTime, self.match.currentTime) ~= 0) then
        for _, athlete in ipairs(self.athletes) do
            athlete:addBuff(teamLeaderSkill.buff, self.captainPlayer)
            if teamLeaderSkill.ex1Buff then
                athlete:addBuff(teamLeaderSkill.ex1Buff, self.captainPlayer)
            end
        end
    end
end

function Team:addTeamLeaderBuffToUpAthletes()
    local teamLeaderSkill = self.captainPlayer:getSkill(Skills.TeamLeader)
    if teamLeaderSkill then
        for _, athlete in ipairs(self.athletes) do
            if not athlete:hasBuff(Skills.TeamLeader) then
                athlete:addBuff(teamLeaderSkill.buff, self.captainPlayer)
                if teamLeaderSkill.ex1Buff then
                    athlete:addBuff(teamLeaderSkill.ex1Buff, self.captainPlayer)
                end
            end
        end
    end
end

function Team:assignTeamRole()
    self.captainPlayer = self.athleteOfRole[self.captain]
    self.leftFootCornerKickPlayer = self.athleteOfRole[self.cornerKicker]
    self.rightFootCornerKickPlayer = self.athleteOfRole[self.cornerKicker]
    self.penaltyKickPlayer = self.athleteOfRole[self.penaltyKicker]
    self.freeKickShootPlayer = self.athleteOfRole[self.freeKickShooter]
    self.freeKickPassPlayer = self.athleteOfRole[self.freeKickPasser]
    self.kickOffPlayer = self.athleteOfRole[Field.formations[self.formation]["kickOffPlayerRole"]]
    self.kickOffPassTargetPlayer = self.athleteOfRole[Field.formations[self.formation]["kickOffPassTargetPlayerRole"]]
    self.leftSideThrowInPlayer = self.athleteOfRole[Field.formations[self.formation]["leftSideThrowInPlayerRole"]]
    self.rightSideThrowInPlayer = self.athleteOfRole[Field.formations[self.formation]["rightSideThrowInPlayerRole"]]
end

function Team:getSign()
    if self.field == "north" then
        return 1
    elseif self.field == "south" then
        return -1
    end
end

function Team:getPenaltyKickPosition()
    return self:getSign() > 0 and Field.penaltyKickPositions.south or Field.penaltyKickPositions.north
end

function Team:getCuttingReferencePosition()
    return vector2.new(0, -self:getSign() * 38.5)
end

function Team:getKickOffPass2TargetRoles()
    local candidateGuardTargets
    local candidateCenterTargets

    if self.tactics.attackEmphasisDetail == 1 then
        candidateGuardTargets = {21, 22, 23}
        candidateCenterTargets = {16, 17, 18}
    elseif self.tactics.attackEmphasisDetail == 3 then
        candidateGuardTargets = {23, 24, 25}
        candidateCenterTargets = {18, 19, 20}
    else
        candidateGuardTargets = {21, 22, 23, 24, 25}
        candidateCenterTargets = {16, 17, 18, 19, 20}
    end

    return candidateGuardTargets, candidateCenterTargets
end

function Team:changeState(stateName)
    if self.state ~= nil then
        self.state:Exit()
    end

    self.state = self.states[stateName]

    if stateName == "Attack" then
        self:judgeAttackDeterrent()
    elseif stateName == "Defend" then
        self:judgeDefendDeterrent()
    end

    self.state:Enter()
end

function Team:resetMetronomeSkill()
    for i, athlete in ipairs(self.athletes) do
        local metronomeSkill = athlete:getSkill(Skills.Metronome)
        if metronomeSkill then
            metronomeSkill.hasLaunched = false
            athlete:judgeTeamLeaderEx1(metronomeSkill)
        end
    end
end

function Team:judgeChargeTrumpetSkill()
    local maxLevel = 0
    local maxLevelBuff
    local maxLevelSkill
    for i, athlete in ipairs(self.athletes) do
        local chargeTrumpetSkill = athlete:getCooldownSkill(Skills.ChargeTrumpet)
        if chargeTrumpetSkill and selector.tossCoin(chargeTrumpetSkill.probability) then
            athlete:castSkill(chargeTrumpetSkill.class, chargeTrumpetSkill.addRatio)
            if chargeTrumpetSkill.level > maxLevel then
                maxLevel = chargeTrumpetSkill.level
                maxLevelBuff = chargeTrumpetSkill.buff
                maxLevelSkill = chargeTrumpetSkill
            end
        end
    end

    if maxLevelBuff then
        for j, selfAthlete in ipairs(self.athletes) do
            selfAthlete:addBuff(maxLevelBuff, athlete)
            selfAthlete:judgeEmotional(maxLevelSkill)
            selfAthlete:judgeTeamSoul(maxLevelSkill)
            local skillEx1 = selfAthlete:getSkill(Skills.ChargeTrumpetEx1)
            if skillEx1 then
                self.enemyTeam:judgeChargeTrumpetEx1Skill(selfAthlete, skillEx1)
            end
            selfAthlete:judgeTeamLeaderEx1(maxLevelSkill)
        end
    end
end

function Team:judgeChargeTrumpetEx1Skill(caster, skillInstance)
    for _, athlete in ipairs(self.athletes) do
        athlete:addBuff(skillInstance.ex1Debuff, caster)
    end
end

function Team:judgeFightTogetherSkill()
    local maxLevel = 0
    local maxLevelBuff
    local maxLevelSkill
    for i, athlete in ipairs(self.athletes) do
        local fightTogetherSkill = athlete:getCooldownSkill(Skills.FightTogether)
        if fightTogetherSkill and selector.tossCoin(fightTogetherSkill.probability) then
            athlete:castSkill(fightTogetherSkill.class, fightTogetherSkill.addRatio)
            if fightTogetherSkill.level > maxLevel then
                maxLevel = fightTogetherSkill.level
                maxLevelBuff = fightTogetherSkill.buff
                maxLevelSkill = fightTogetherSkill
            end
        end
    end

    if maxLevelBuff then
        for j, selfAthlete in ipairs(self.athletes) do
            selfAthlete:addBuff(maxLevelBuff, athlete)
            selfAthlete:judgeEmotional(maxLevelSkill)
            selfAthlete:judgeTeamSoul(maxLevelSkill)
            local skillEx1 = selfAthlete:getSkill(Skills.FightTogetherEx1)
            if skillEx1 then
                self.enemyTeam:judgeFightTogetherEx1Skill(selfAthlete, skillEx1)
            end
            selfAthlete:judgeTeamLeaderEx1(maxLevelSkill)
        end
    end
end

function Team:judgeFightTogetherEx1Skill(caster, skillInstance)
    for _, athlete in ipairs(self.athletes) do
        athlete:addBuff(skillInstance.ex1Debuff, caster)
    end
end

function Team:judgeTightMarkSkill()
    for i, athlete in ipairs(self.athletes) do
        if not athlete:isDivingEx1Blocked() then
            athlete:resetSkillDiabledStates()

            local notFullyMarkedEnemyCFs = { }
            for j, enemyAthlete in ipairs(self.enemyTeam.athletes) do
                if enemyAthlete:isCenterF() and not enemyAthlete:isFullyMarked() then
                    table.insert(notFullyMarkedEnemyCFs, enemyAthlete)
                end
            end

            local tightMarkSkill = athlete:getCooldownSkill(Skills.TightMark)
            if #notFullyMarkedEnemyCFs > 0 and tightMarkSkill then
                local markTargetAthlete = selector.randomSelect(notFullyMarkedEnemyCFs)
                local probability = AIUtils.calcDefenseSuccessProbability(
                    (athlete:getAbilitiesSum() + athlete.initAbilitiesSum * tightMarkSkill.addConfig)
                    / markTargetAthlete:getAbilitiesSum())
                if selector.tossCoin(probability) then
                    athlete:castSkill(tightMarkSkill.class, nil, markTargetAthlete.onfieldId)
                    local unmarkedNonFStartSkills = markTargetAthlete:getUnmarkedNonFStartSkills()
                    local markedSkill = selector.randomSelect(unmarkedNonFStartSkills)
                    markedSkill.isDisabled = true
                    markTargetAthlete:removeBuffs(markedSkill.class)
                    tightMarkSkill.buff.markedSkillId = markedSkill.id
                    markTargetAthlete:addBuff(tightMarkSkill.buff, athlete)

                    if tightMarkSkill:isTypeOf(Skills.TightMarkEx1) then
                        local ex1Probability = AIUtils.calcDefenseSuccessProbability(
                            (athlete:getAbilitiesSum() + athlete.initAbilitiesSum * tightMarkSkill.addConfigEx1)
                            / markTargetAthlete:getAbilitiesSum())
                        if selector.tossCoin(ex1Probability) then
                            local enemies = {}
                            for j, enemyAthlete in ipairs(self.enemyTeam.athletes) do
                                if table.isArrayInclude(tightMarkSkill.markRoles, enemyAthlete.role) and not enemyAthlete:isFullyMarked() then
                                    table.insert(enemies, enemyAthlete)
                                end
                            end
                            local extraMarkTarget = selector.randomSelect(enemies)
                            if extraMarkTarget then
                                local extraUnmarkedNonFStartSkills = extraMarkTarget:getUnmarkedNonFStartSkills()
                                local extraMarkedSkill = selector.randomSelect(extraUnmarkedNonFStartSkills)
                                extraMarkedSkill.isDisabled = true
                                extraMarkTarget:removeBuffs(extraMarkedSkill.class)
                                tightMarkSkill.ex1MarkedBuff.markedSkillId = extraMarkedSkill.id
                                extraMarkTarget:addBuff(tightMarkSkill.ex1MarkedBuff, athlete)
                            end
                        end
                    end
                end
            end
        end
    end
end

function Team:judgePenaltyBoxSignalFireTurret()
    local enemyGk = self.enemyTeam.athleteOfRole[26]
    local skill = enemyGk:getCooldownSkill(Skills.PenaltyBoxSignalFireTurret)
    if skill and not self.hasJudgedSignalFireTurret and Field.isInPenaltyBoxSignalFireTurretArea(self.match.ball.position, self:getSign()) then
        if selector.tossCoin(skill.probability) then
            local skill = enemyGk:castSkill(skill.class)

            for _, enemy in ipairs(self.enemyTeam.athletes) do
                if enemy.role >= 16 and enemy.role <= 25 then
                    enemy:addBuff(skill.buff, enemyGk)
                    enemy:judgeTeamSoul(skill)
                end
            end
            self.hasSignalFireTurretBuff = true
        end

        self.hasJudgedSignalFireTurret = true
    end
end

function Team:judgeLeaderMasterSkill()
    if self:isLeadByOneScore() then
        for _, athlete in ipairs(self.athletes) do
            athlete:judgeLeaderMaster()
        end
    end
end

function Team:judgeLaggerMasterSkill()
    if self.enemyTeam:isLeadByOneScore() then
        for _, athlete in ipairs(self.athletes) do
            athlete:judgeLaggerMaster()
        end
    end
end

function Team:judgeLeadershipSkill()
    if self.isStolenInOwnArea then
        local defenders = {}
        for _, athlete in ipairs(self.athletes) do
            if athlete:isBack() then
                table.insert(defenders, athlete)
            end
        end

        for _, athlete in ipairs(self.athletes) do
            local leadershipSkill = athlete:getCooldownSkill(Skills.Leadership)
            if leadershipSkill then
                athlete:castSkill(leadershipSkill.class)
                for index, defender in ipairs(defenders) do
                    defender:addBuff(leadershipSkill.buff, athlete)
                end
            end
        end
        self.isStolenInOwnArea = false
    end
end

function Team:judgeToughGetGoingSkill()
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeToughGetGoing()
    end
end

function Team:judgeFrustrationDebuff()
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeFrustrationDebuff()
    end
end

function Team:judgeDefendTacticsSkill()
    if self.match.stage == self.match.SECOND_HALF_STAGE
        and math.cmpf(self.match:getActualDisplayTime(), 45) <= 0
        and self.scoreState > AIConstants.teamScoreState.LAG then
        for _, athlete in ipairs(self.athletes) do
            athlete:judgeDefendTactics()
        end
    end
end

function Team:judgeAfterLosePointSkills()
    self:judgeToughGetGoingSkill()
    self:judgeFrustrationDebuff()
    self:judgeLaggerMasterSkill()
    self:RemoveImpactWaveEx1Skill()
    self:judgeUnstableMentalitySkill("lose")
    self:judgeSambaIronFenceFriendBuff()
end

function Team:judgeAfterGoalSkills()
    self:judgeLeaderMasterSkill()
    self:judgeDeviseStrategiesSkill()
    self:judgeUnstableMentalitySkill("goal")
    self:judgeIronWarrior()
end

function Team:selectNearestAthlete(targetPosition, excludedAthletes)
    local minSqrDist = math.huge
    local selectedAthlete = nil
    for i, athlete in ipairs(self.athletes) do
        if not excludedAthletes or not table.isArrayInclude(excludedAthletes, athlete) then
            local sqrDist = vector2.sqrdist(targetPosition, athlete.position)
            if math.cmpf(sqrDist, minSqrDist) < 0 then
                minSqrDist = sqrDist
                selectedAthlete = athlete
            end
        end
    end

    return selectedAthlete
end

function Team:selectNearestAthleteToBall()
    local excludeAthletes = {self.match.ball.owner}
    return self:selectNearestAthlete(self.match.ball.position, excludeAthletes)
end

function Team:selectNearestAthleteForClosing(targetPosition)
    local minSqrDist = math.huge
    local selectedAthlete = nil
    for i, athlete in ipairs(self.athletes) do
        local sqrDist = vector2.sqrdist(targetPosition, athlete.position)
        local sign = self:getSign()
        if math.cmpf(athlete.position.y * sign, targetPosition.y * sign) < 0 then
            sqrDist = athlete.mainRole == "f" and sqrDist * 10 or sqrDist * 4
        end

        if math.cmpf(sqrDist, minSqrDist) < 0 then
            minSqrDist = sqrDist
            selectedAthlete = athlete
        end
    end

    return selectedAthlete
end

function Team:selectNearestAthleteForFillingIn(enemyAthleteWithBallPosition, excludedAthletes)
    local minSqrDist = math.huge
    local selectedAthlete = nil
    for i, athlete in ipairs(self.athletes) do
        if (not excludedAthletes or not table.isArrayInclude(excludedAthletes, athlete)) then
            local sqrDist = vector2.sqrdist(enemyAthleteWithBallPosition, athlete.position)
            local sign = self:getSign()
            if math.cmpf(vector2.angle(self.goal.center - enemyAthleteWithBallPosition,
                athlete.position - enemyAthleteWithBallPosition), math.pi / 2) > 0 then
                sqrDist = sqrDist * (athlete:isForward() and 10 or 4)
            end

            if math.cmpf(sqrDist, minSqrDist) < 0 then
                minSqrDist = sqrDist
                selectedAthlete = athlete
            end
        end
    end

    return selectedAthlete
end

function Team:updateOffTheBallTargetsStatus()
    local sign = self:getSign()
    local ballPosition = self.match.ball.position

    if not Field.isInOffTheBallArea(ballPosition, sign) then
        self.offTheBallTargetsStatus.centerTarget.bestAthlete = nil
        self.offTheBallTargetsStatus.leftTarget.bestAthlete = nil
        self.offTheBallTargetsStatus.rightTarget.bestAthlete = nil
        return
    end

    local excludedAthletes = { self.athleteOfRole[26] }
    if self.match.ball.owner then
        table.insert(excludedAthletes, self.match.ball.owner)
    end

    for i, athlete in ipairs(self.athletes) do
        if not athlete:hasBall() and (athlete:isInOffSideArea() or athlete:isInCoolDownState(AIUtils.moveStatus.offTheBall)) then
            table.insert(excludedAthletes, athlete)
        end
    end

    if self.offTheBallTargetsStatus.centerTarget.bestAthlete then
        table.insert(excludedAthletes, self.offTheBallTargetsStatus.centerTarget.bestAthlete)
    end
    if self.offTheBallTargetsStatus.leftTarget.bestAthlete then
        table.insert(excludedAthletes, self.offTheBallTargetsStatus.leftTarget.bestAthlete)
    end
    if self.offTheBallTargetsStatus.rightTarget.bestAthlete then
        table.insert(excludedAthletes, self.offTheBallTargetsStatus.rightTarget.bestAthlete)
    end

    local centerContinue = self.offTheBallTargetsStatus.centerTarget.bestAthlete and self.offTheBallTargetsStatus.centerTarget.bestAthlete:isContinueOffTheBall()
    local leftContinue = self.offTheBallTargetsStatus.leftTarget.bestAthlete and self.offTheBallTargetsStatus.leftTarget.bestAthlete:isContinueOffTheBall()
    local rightContinue = self.offTheBallTargetsStatus.rightTarget.bestAthlete and self.offTheBallTargetsStatus.rightTarget.bestAthlete:isContinueOffTheBall()

    if not centerContinue then
        self.offTheBallTargetsStatus.centerTarget.position = vector2.new(0, -sign * 45)
        self.offTheBallTargetsStatus.centerTarget.bestAthlete = self:selectNearestAthlete(self.offTheBallTargetsStatus.centerTarget.position, excludedAthletes)
    end

    if not leftContinue and not rightContinue then
        table.insert(excludedAthletes, self.offTheBallTargetsStatus.centerTarget.bestAthlete)
        self.offTheBallTargetsStatus.leftTarget.position = vector2.new(9 * sign, self.offTheBallTargetsStatus.centerTarget.position.y)
        self.offTheBallTargetsStatus.leftTarget.bestAthlete = self:selectNearestAthlete(self.offTheBallTargetsStatus.leftTarget.position, excludedAthletes)

        table.insert(excludedAthletes, self.offTheBallTargetsStatus.leftTarget.bestAthlete)
        self.offTheBallTargetsStatus.rightTarget.position = vector2.new(-9 * sign, self.offTheBallTargetsStatus.centerTarget.position.y)
        self.offTheBallTargetsStatus.rightTarget.bestAthlete = self:selectNearestAthlete(self.offTheBallTargetsStatus.rightTarget.position, excludedAthletes)

        if self.offTheBallTargetsStatus.leftTarget.bestAthlete and self.offTheBallTargetsStatus.rightTarget.bestAthlete then
            if math.cmpf(vector2.sqrdist(self.offTheBallTargetsStatus.leftTarget.bestAthlete.position, self.offTheBallTargetsStatus.leftTarget.position),
                vector2.sqrdist(self.offTheBallTargetsStatus.rightTarget.bestAthlete.position, self.offTheBallTargetsStatus.rightTarget.position)) < 0 then
                self.offTheBallTargetsStatus.rightTarget.bestAthlete = nil
            else
                self.offTheBallTargetsStatus.leftTarget.bestAthlete = nil
            end
        end
    end
end

function Team:updateRunningForwardAthletes()
    local ballPosition = self.match.ball.position

    local currentLeftAthlete = self.runningForwardAthletes.leftAthlete
    local currentCenterAthlete = self.runningForwardAthletes.centerAthlete
    local currentRightAthlete = self.runningForwardAthletes.rightAthlete

    local leftContinue = false
    if currentLeftAthlete then
        leftContinue = currentLeftAthlete:isContinueRunningForward()
        if not leftContinue then
            self.runningForwardAthletes.leftAthlete = nil
        end
    end
    local centerContinue = false
    if currentCenterAthlete then
        centerContinue = currentCenterAthlete:isContinueRunningForward()
        if not centerContinue then
            self.runningForwardAthletes.centerAthlete = nil
        end
    end
    local rightContinue = false
    if currentRightAthlete then
        rightContinue = currentRightAthlete:isContinueRunningForward()
        if not rightContinue then
            self.runningForwardAthletes.rightAthlete = nil
        end
    end

    local minLeftDist = math.huge
    local minCenterDist = math.huge
    local minRightDist = math.huge
    local sign = self:getSign()
    for i, athlete in ipairs(self.athletes) do
        if math.cmpf(vector2.sqrdist(athlete.position, ballPosition), 625) <= 0
            and not athlete:isInOffSideArea()
            and not athlete:isInCoolDownState(AIUtils.moveStatus.runningForward)
            and not athlete:isSideGuardPreferKeepFormation()
            and not athlete:isSideMidFieldPreferKeepFormation() then
            local dist = math.abs(athlete.position.y + sign * Field.halfLength)

            if athlete:isSideGuardPreferRunningForward() then
                dist = 0.4 * dist
            end

            if athlete:isSideMidFieldPreferRunningForward() then
                dist = 0.4 * dist
            end

            if not leftContinue and Field.isInLeftRunningForwardArea(athlete.position, sign) then
                if math.cmpf(dist, minLeftDist) < 0 then
                    minLeftDist = dist
                    self.runningForwardAthletes.leftAthlete = athlete
                end
            elseif not centerContinue and Field.isInCenterRunningForwardArea(athlete.position, sign) then
                if math.cmpf(dist, minCenterDist) < 0 then
                    minCenterDist = dist
                    self.runningForwardAthletes.centerAthlete = athlete
                end
            elseif not rightContinue and Field.isInRightRunningForwardArea(athlete.position, sign) then
                if math.cmpf(dist, minRightDist) < 0 then
                    minRightDist = dist
                    self.runningForwardAthletes.rightAthlete = athlete
                end
            end
        end
    end
end

function Team:updateNearestAthleteToMarkEnemyAthleteWithBall()
    local enemyAthleteWithBall = self.enemyAthleteWithBall
    if not enemyAthleteWithBall then
        local nextTask = self.match.ball.nextTask
        if nextTask and nextTask.class == Ball.Pass then
            enemyAthleteWithBall = nextTask.receiver
        else
            self.nearestAthleteToMarkEnemyAthleteWithBall = nil
            return
        end
    end

    self.nearestAthleteToMarkEnemyAthleteWithBall = self:selectNearestAthleteForClosing(enemyAthleteWithBall.position + enemyAthleteWithBall.bodyDirection)

    local excludeAthletes = {self.nearestAthleteToMarkEnemyAthleteWithBall}
    self.nearestAthleteToFillInEnemyAthleteWithBall = self:selectNearestAthleteForFillingIn(enemyAthleteWithBall.position, excludeAthletes)
end

function Team:updateNearestAthleteToCoverEnemyAthleteWithBall()
    if not self.enemyAthleteWithBall then
        self.nearestAthleteToCoverEnemyAthleteWithBall = nil
        return
    end

    local enemyNextPosition = self.enemyAthleteWithBall.currentAnimation == nil and self.enemyAthleteWithBall.position or self.enemyAthleteWithBall.currentAnimation.targetPosition

    local minSqrDist = math.huge
    local selectedAthlete = nil
    local sign = self:getSign()
    for i, athlete in ipairs(self.athletes) do
        if math.cmpf(athlete.position.y * sign, self.enemyAthleteWithBall.position.y * sign) > 0 then
            local coverTargetPosition = athlete:isBack()
            and vector2.new(enemyNextPosition.x, self.predictedBackLine)
            or vector2.new(enemyNextPosition.x, athlete.area.center.y)

            local sqrDist = vector2.sqrdist(coverTargetPosition, athlete.position)
            if math.cmpf(sqrDist, minSqrDist) < 0 then
                minSqrDist = sqrDist
                selectedAthlete = athlete
            end
        end
    end

    self.nearestAthleteToCoverEnemyAthleteWithBall = selectedAthlete
end

function Team:findAthleteWithBall()
    return self.match.ball.owner
end

function Team:updateEnemyAthleteWithBall()
    self.enemyAthleteWithBall = self.enemyTeam:findAthleteWithBall()
end

function Team:updateArea()
    for i, athlete in ipairs(self.athletes) do
        athlete:updateArea()
    end
end

function Team:updateBackLine()
    local sign = self:getSign()
    local backLine = sign * self.athleteOfRole[Field.formations[self.formation]["backLineAthleteRole"]].area.center.y
    for i, athlete in ipairs(self.athletes) do
        if athlete.marking ~= nil then
            if math.cmpf(sign * athlete.position.y, backLine) > 0 then
                backLine = sign * athlete.position.y
            end
        end
    end

    self.backLine = sign * backLine
end

--预测backline
function Team:updatePredictedBackLine()
    self.predictedBackLine = self.backLine

    local sign = self:getSign()

    if self.enemyAthleteWithBall then
        local enemyNextPosition = self.enemyAthleteWithBall.currentAnimation == nil and self.enemyAthleteWithBall.position or self.enemyAthleteWithBall.currentAnimation.targetPosition
        local markVector = vector2.norm(self.goal.center - enemyNextPosition) * 1.5
        local markTargetPosition = enemyNextPosition + markVector

        if math.cmpf(markTargetPosition.y * sign, self.predictedBackLine * sign) > 0 then
            self.predictedBackLine = markTargetPosition.y
        end
    else
        local ball = self.match.ball
        if not ball.isFree and math.cmpf(ball.flyTargetPosition.y * sign, self.predictedBackLine * sign) > 0 then
            self.predictedBackLine = ball.flyTargetPosition.y
        end
    end

    if math.cmpf(math.abs(self.predictedBackLine), Field.halfLength - 3) > 0 then
        self.predictedBackLine = math.sign(self.predictedBackLine) * (Field.halfLength - 3)
    end
end

function Team:updateOffsideLine()
    local sign = self:getSign()
    local minY = 0
    for i, defenseAthlete in ipairs(self.match.defenseTeam.athletes) do
        if not defenseAthlete:isGoalkeeper() then
            local t = defenseAthlete.position.y * sign
            if math.cmpf(t, minY) < 0 then
                minY = t
            end
        end
    end

    local athleteWithBall = self:findAthleteWithBall()

    if athleteWithBall ~= nil then
        local t = athleteWithBall.position.y * sign
        if math.cmpf(t, minY) < 0 then
            minY = t
        end
    end

    self.offsideLine = minY * sign
end

function Team:getTeamSkillFactor(skill)
    local count = 0
    for i, athlete in ipairs(self.athletes) do
        if athlete:hasSkill(skill) then
            count = count + 1
        end
    end

    return count
end

function Team:randomSelectAthlete(roles, ballOwnerPosition)
    local candidates = {}
    for i, athlete in ipairs(self.athletes) do
        if math.cmpf(vector2.sqrdist(athlete.position, ballOwnerPosition), 25) >= 0
            and table.isArrayInclude(roles, athlete.role) then
                table.insert(candidates, athlete)
        end
    end
    return selector.randomSelect(candidates)
end

function Team:isAttackRole()
    return self.role == "Attack"
end

function Team:isDefendRole()
    return self.role == "Defend"
end

function Team:getPassing()
    return math.round((self.passTimes - (self.enemyTeam.stealTimes + self.enemyTeam.interceptTimes) + 1) / (self.passTimes + 1) * 90 + 5)
end

function Team:getPossession()
    return math.round((self.possession + 1) / (self.possession + self.enemyTeam.possession + 2) * 100)
end

function Team:update()
    self:clearOutput()
    self:updateCoachSkills()
    self:updateManualOperateRemainingCoolDown()
end

function Team:updateManualOperateRemainingCoolDown()
    if math.cmpf(self.manualOperateRemainingCoolDown, 0) > 0 then
        self.manualOperateRemainingCoolDown = self.manualOperateRemainingCoolDown - TIME_STEP
    end
end

function Team:updateCoachSkills()
    for _, skill in ipairs(self.coachSkills) do
        if skill.update ~= nil then
            skill:update(self)
        end
    end
end

function Team:judgeDesperateFight()
    if math.cmpf(self.match:getActualDisplayTime(), 60) == 0 then
        for _, athlete in ipairs(self.athletes) do
            athlete:judgeDesperateFight()
        end
    end
end

function Team:castCoachSkill(skillId)
    self.lastCoachSkillId = skillId
end

function Team:clearOutput()
    self.lastCoachSkillId = nil
    self.outputIsManualOperateEnded = nil
end

function Team:enterStage()
    for _, skill in ipairs(self.coachSkills) do
        if skill.enterStage ~= nil then
            skill:enterStage(self)
        end
    end
end

function Team:onGoal()
    if self.role == self.match.attackTeam.role then
        if self.match.isInPenaltyShootOut then
            self.shootOutScore = self.shootOutScore + 1
        else
            self.score = self.score + 1
        end
    end

    for _, skill in ipairs(self.coachSkills) do
        if skill.onGoal ~= nil then
            skill:onGoal(self)
        end
    end
end

function Team:clearTeamManualOperate()
    if self.inManualOperating then
        self.outputIsManualOperateEnded = true
        self.manualOperateRemainingCoolDown = AIUtils.manualOperateCoolDown
    end
    self.inManualOperating = nil
    self.manualOperateTimes = 0
end

function Team:calcRankedPenaltyShootOutAthletes()
    for _, athlete in ipairs(self.athletes) do
        athlete.penaltyShootAbility = athlete:getAbilities().shoot

        local PenaltyKickMasterSkill = athlete:getSkill(Skills.PenaltyKickMaster)
        if PenaltyKickMasterSkill then
            athlete.penaltyShootAbility = athlete.penaltyShootAbility + athlete.maxInitAbility * PenaltyKickMasterSkill.maxAbilityMultiply - athlete.initAbilities.shoot
        end

        table.insert(self.rankedPenaltyShootOutAthletes, athlete)
    end

    table.sort(self.rankedPenaltyShootOutAthletes, function(a, b) return math.cmpf(a.penaltyShootAbility, b.penaltyShootAbility) > 0 end)
end

function Team:initTeamPenaltyShootOutResultsQueue()
    for i = 1, 5 do
        table.insert(self.penaltyShootOutResultsQueue, AIUtils.penaltyShootOutKickState.idle)
    end
end

function Team:updateTeamPenaltyShootOutResultsQueue()
    table.remove(self.penaltyShootOutResultsQueue, 1)
    table.insert(self.penaltyShootOutResultsQueue, AIUtils.penaltyShootOutKickState.idle)
end

function Team:isLeadByOneScore()
    return self.score - self.enemyTeam.score == 1
end

function Team:judgeSpurWithLongAccumulationWithFirstGoal()
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeSpurWithLongAccumulationWithFirstGoal()
    end
end

function Team:judgeSpurWithLongAccumulationWithoutFirstGoal()
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeSpurWithLongAccumulationWithoutFirstGoal()
    end
end

function Team:judgeAfterSwitchRoleSkills()
    if self:isAttackRole() then
        self:judgeChargeTrumpetSkill()
        self:updateOffsideLine()
        self:castBlauwbrugBrainEx1()
    elseif self:isDefendRole() then
        self:judgeFightTogetherSkill()
        self:judgeTightMarkSkill()
        self:resetMetronomeSkill()
        self:judgeLeadershipSkill()
        self:clearHeavyGunnerEx1Count()
        self:judgeThreeLionsGateGod()
        self:judgeGpiquePenetrateEverything()
        self:judgeRomanWarSpirit()
    end
    self.hasJudgedSignalFireTurret = nil

    for _, athlete in ipairs(self.athletes) do
        athlete:judgeCathexisEx1()
        athlete:judgeLegendaryBloodEx1()
        athlete:judgeTeamSoulEx1()
    end
    self:judgeAttackCoreEx1()
    self:judgeGlobalCommandEx1()
end

function Team:RemoveImpactWaveEx1Skill()
    for _, athlete in ipairs(self.athletes) do
        athlete:RemoveImpactWaveEx1Skill()
    end
end

function Team:judgeHeavyGunnerEx1()
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeHeavyGunnerEx1()
    end
end

function Team:clearHeavyGunnerEx1Count()
    for _, athlete in ipairs(self.athletes) do
        athlete:clearHeavyGunnerEx1Count()
    end
end

function Team:judgeAccurateAnticipationEx1(passAthlete)
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeAccurateAnticipationEx1(passAthlete)
    end
end

function Team:judgeAttackCoreEx1()
    local maxLevel = 0
    local maxLevelAthlete
    local maxLevelSkill
    for i, athlete in ipairs(self.athletes) do
        local attackCoreEx1Skill = athlete:getCooldownSkill(Skills.AttackCoreEx1)
        if attackCoreEx1Skill and selector.tossCoin(attackCoreEx1Skill.ex1Probability) then
            athlete:castSkill(attackCoreEx1Skill.class)
            if attackCoreEx1Skill.level > maxLevel then
                maxLevel = attackCoreEx1Skill.level
                maxLevelAthlete = athlete
                maxLevelSkill = attackCoreEx1Skill
            end
        end
    end
    if maxLevelAthlete then
        for j, selfAthlete in ipairs(self.athletes) do
            if selfAthlete:isForward() or selfAthlete:isAttackMidField() then
                if self:isAttackRole() then
                    selfAthlete:addBuff(maxLevelSkill.ex1AttackBuff, maxLevelAthlete)
                else
                    selfAthlete:addBuff(maxLevelSkill.ex1DefendBuff, maxLevelAthlete)
                end
            end
        end
    end
end

function Team:judgeGlobalCommandEx1()
    local maxLevel = 0
    local maxLevelAthlete
    local maxLevelSkill
    for i, athlete in ipairs(self.athletes) do
        local globalCommandEx1Skill = athlete:getCooldownSkill(Skills.GlobalCommandEx1)
        if globalCommandEx1Skill and selector.tossCoin(globalCommandEx1Skill.ex1Probability) then
            athlete:castSkill(globalCommandEx1Skill.class)
            if globalCommandEx1Skill.level > maxLevel then
                maxLevel = globalCommandEx1Skill.level
                maxLevelAthlete = athlete
                maxLevelSkill = globalCommandEx1Skill
            end
        end
    end
    if maxLevelAthlete then
        for j, selfAthlete in ipairs(self.athletes) do
            if selfAthlete:isBack() or selfAthlete:isDefensiveMidfield() then
                if self:isAttackRole() then
                    selfAthlete:addBuff(maxLevelSkill.ex1AttackBuff, maxLevelAthlete)
                else
                    selfAthlete:addBuff(maxLevelSkill.ex1DefendBuff, maxLevelAthlete)
                end
            end
        end
    end
end

-- 短传20米
function Team:judgeBlauwbrugBrainEx1(receiver, targetPosition)
    if receiver:isMidfield() and math.cmpf(vector2.sqrdist(receiver.position, targetPosition), 400) < 0 then
        for _, athlete in ipairs(self.athletes) do
            local skill = athlete:getSkill(Skills.BlauwbrugBrainEx1)
            if skill then
                receiver:addBuff(skill.exa1Buff, athlete)
            end
        end
    end
end

function Team:castBlauwbrugBrainEx1()
    local skill = nil
    local caster = nil
    for _, athlete in ipairs(self.athletes) do
        if athlete:hasSkill(Skills.BlauwbrugBrainEx1) then
            skill = athlete:getSkill(Skills.BlauwbrugBrainEx1)
            caster = athlete
            break
        end
    end

    if skill then
        for _, athlete in ipairs(self.athletes) do
            if athlete:isMidfield() then
                caster:castSkill(skill.class, nil, nil, athlete)
            end
        end
    end
end

function Team:judgeAttackDeterrent()
    local maxLevel = 0
    local maxLevelAthlete
    local maxLevelSkill
    for _, athlete in ipairs(self.athletes) do
        local skill = athlete:getCooldownSkill(Skills.AttackDeterrent)
        if skill and selector.tossCoin(skill.probability) then
            athlete:castSkill(skill.class)
            if skill:isTypeOf(Skills.AttackDeterrentEx1) then -- EX可以叠加
                for _, enemy in ipairs(self.enemyTeam.athletes) do
                    enemy:addBuff(skill.debuff, athlete)
                end
            else -- 普通不能叠加
                if skill.level > maxLevel then
                    maxLevel = skill.level
                    maxLevelAthlete = athlete
                    maxLevelSkill = skill
                end
            end
        end
    end

    if maxLevelAthlete then
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            enemy:addBuff(maxLevelSkill.debuff, maxLevelAthlete)
        end
    end
end

function Team:judgeDefendDeterrent()
    local maxLevel = 0
    local maxLevelAthlete
    local maxLevelSkill
    for _, athlete in ipairs(self.athletes) do
        local skill = athlete:getCooldownSkill(Skills.DefendDeterrent)
        if skill and selector.tossCoin(skill.probability) then
            athlete:castSkill(skill.class)
            if skill:isTypeOf(Skills.DefendDeterrentEx1) then -- EX可以叠加
                for _, enemy in ipairs(self.enemyTeam.athletes) do
                    enemy:addBuff(skill.debuff, athlete)
                end
            else -- 普通不能叠加
                if skill.level > maxLevel then
                    maxLevel = skill.level
                    maxLevelAthlete = athlete
                    maxLevelSkill = skill
                end
            end
        end
    end

    if maxLevelAthlete then
        for _, enemy in ipairs(self.enemyTeam.athletes) do
            enemy:addBuff(maxLevelSkill.debuff, maxLevelAthlete)
        end
    end
end

function Team:judgeDimensionReductionBlow()
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeDimensionReductionBlow()
    end
end

function Team:judgeDeviseStrategiesSkill()
    if self:isLeadByOneScore() then
        for _, athlete in ipairs(self.athletes) do
            athlete:judgeDeviseStrategies()
        end
    end
end

function Team:judgeUnstableMentalitySkill(event)
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeUnstableMentality(event)
    end
end

function Team:judgeTopStudentOnFieldSkill()
    for i = 1, 8 do
        if math.cmpf(self.match:getActualDisplayTime(), i * 10) == 0 then
            for _, athlete in ipairs(self.athletes) do
                athlete:judgeTopStudentOnField()
            end
        end
    end
end

function Team:judgeBrazilianHeavyGunner(shooter)
    for _, athlete in ipairs(self.athletes) do
        if athlete ~= shooter then
            athlete:judgeBrazilianHeavyGunner(shooter)
        end
    end
end

function Team:judgeSambaIronFenceSelfBuff()
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeSambaIronFenceSelfBuff()
    end
end

function Team:judgeSambaIronFenceFriendBuff()
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeSambaIronFenceFriendBuff()
    end
end

function Team:judgeIronWarrior()
    if self.scoreState == AIConstants.teamScoreState.DRAW then
        for _, athlete in ipairs(self.athletes) do
            athlete:judgeIronWarrior()
        end
    end
end

function Team:judgeThreeLionsGateGod()
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeThreeLionsGateGod()
    end
end

function Team:judgeThreeLionsGateGodExtraBuff()
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeThreeLionsGateGodExtraBuff()
    end
end

function Team:judgeGpiquePenetrateEverything()
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeGpiquePenetrateEverything()
    end
end

function Team:judgeRomanWarSpirit()
    for _, athlete in ipairs(self.athletes) do
        athlete:judgeRomanWarSpirit(true)
    end
end

return Team

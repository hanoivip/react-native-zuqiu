if jit then jit.off(true, true) end

local selector = import("./libs/selector")
local vector2 = import("./libs/vector")

local Actions = import("./actions/Actions")
local Ball = import("./Ball")
local BT = import("./behaviorTree/BehaviorTree")
local Field = import("./Field")
local Skills = import("./skills/Skills")
local Animations = import("./animations/Animations")
local AIUtils = import("./AIUtils")

local Behavior

local entryModifierExecutionCondition = BT.Condition.new( {
    name = "EntryModifierExecutionCondition",
    run = function(self, athlete)
        return athlete.isEntryModifierExecuted and "fail" or "success"
    end
} )

local enterFieldTask = BT.Task.new( {
    name = "EnterFieldTask",
    run = function(self, athlete, isRunning)
        athlete:enterField()
        return "success"
    end
} )

local desperateFightDisplayTimeCondition = BT.Condition.new( {
    name = "desperateFightDisplayTimeCondition",
    run = function(self, athlete)
        return math.cmpf(athlete.match:getActualDisplayTime(), 60) == 0 and "success" or "fail"
    end
} )

local judgeDesperateFightTask = BT.Task.new( {
    name = "judgeDesperateFightTask",
    run = function(self, athlete, isRunning)
        athlete:judgeDesperateFight()
        return "success"
    end
} )

local attackCondition = BT.Condition.new( {
    name = "AttackCondition",
    run = function(self, athlete)
        return athlete.team:isAttackRole() and "success" or "fail"
    end
} )

local defendCondition = BT.Condition.new( {
    name = "DefendCondition",
    run = function(self, athlete)
        return athlete.team:isDefendRole() and "success" or "fail"
    end
} )

local hasBallCondition = BT.Condition.new( {
    name = "HasBallCondition",
    run = function(self, athlete)
        return athlete:hasBall() and "success" or "fail"
    end
} )

local postSavePassCondition = BT.Condition.new( {
    name = "postSavePassCondition",
    run = function(self, athlete)
        return athlete.graspBall and "success" or "fail"
    end
} )

local goalKickCondition = BT.Condition.new( {
    name = "goalKickCondition",
    run = function(self, athlete)
        if athlete.upComingAction == "GoalKick" then
            athlete.upComingAction = nil
            return "success"
        else
            return "fail"
        end
    end
} )

local goalKickTask = BT.Task.new( {
    name = "goalKickTask",
    run = function(self, athlete, isRunning)
        athlete:logInfo("goalKick")
        local targetAthlete

        repeat
            targetAthlete = selector.randomSelect(athlete.team.athletes)
        until targetAthlete ~= athlete

        local bestPassTarget = athlete:selectBestPassTargetForOneAthlete(targetAthlete)
        athlete:setPassAction(bestPassTarget.targetAthlete, bestPassTarget.targetPosition, bestPassTarget.type, bestPassTarget.isLeadPass)
        athlete.noNeedJudgeOffside = true

        athlete.bodyDirection = vector2.norm(bestPassTarget.targetPosition - athlete.position)
        athlete:selectAndPushAnimation("GoalKick", nil, true)
        athlete:startPass(bestPassTarget.type == "Ground")

        return "success"
    end
} )

local indirectFreeKickCondition = BT.Condition.new( {
    name = "IndirectFreeKickCondition",
    run = function(self, athlete)
        if athlete.upComingAction == "IndirectFreeKick" then
            athlete.upComingAction = nil
            return "success"
        else
            return "fail"
        end
    end
} )

local indirectFreeKickTask = BT.Task.new( {
    name = "IndirectFreeKickTask",
    run = function(self, athlete, isRunning)
        athlete:logInfo("IndirectFreeKick")
        local targetAthlete

        repeat
            targetAthlete = selector.randomSelect(athlete.team.athletes)
        until targetAthlete ~= athlete and not targetAthlete:isGoalkeeper()

        local bestPassTarget = athlete:selectBestPassTargetForOneAthlete(targetAthlete)
        athlete:setPassAction(bestPassTarget.targetAthlete, bestPassTarget.targetPosition, bestPassTarget.type, bestPassTarget.isLeadPass)

        athlete.bodyDirection = vector2.norm(athlete.chosenDPSAction.targetPosition - athlete.position)

        athlete:selectPassAnimation()
        athlete:startPass(athlete:isGoalkeeper() and bestPassTarget.type == "Ground")

        return "success"
    end
} )

local centerDirectFreeKickCondition = BT.Condition.new( {
    name = "CenterDirectFreeKickCondition",
    run = function(self, athlete)
        if athlete.upComingAction == "CenterDirectFreeKick" then
            athlete.upComingAction = nil
            return "success"
        else
            return "fail"
        end
    end
} )

local centerDirectFreeKickPrepareTask = BT.Task.new( {
    name = "CenterDirectFreeKickPrepareTask",
    run = function(self, athlete, isRunning)
        athlete:logInfo("CenterDirectFreeKickPrepare")
        athlete.chosenDPSAction = athlete:getNewShootAction(vector2.new((1 - 2 * math.random()) * Field.halfGoalWidth, athlete.enemyTeam.goal.center.y))
        return "success"
    end
} )

local judgeOrganizeWallTask = BT.Task.new( {
    name = "judgeOrganizeWallTask",
    run = function(self, athlete, isRunning)
        local enemyGk = athlete.enemyTeam.athleteOfRole[26]
        local skill = enemyGk:getCooldownSkill(Skills.OrganizeWall)

        if skill ~= nil then
            enemyGk:castSkill(skill.class)
            enemyGk:addBuff(skill.buff, enemyGk)
            enemyGk:judgeOrganizeWallEx1()
        end

        return "success"
    end
} )

local wingDirectFreeKickCondition = BT.Condition.new( {
    name = "WingDirectFreeKickCondition",
    run = function(self, athlete)
        if athlete.upComingAction == "WingDirectFreeKick" then
            athlete.upComingAction = nil
            return "success"
        else
            return "fail"
        end
    end
} )

local wingDirectFreeKickDecisionTask = BT.Task.new( {
    name = "wingDirectFreeKickDecisionTask",
    run = function(self, athlete, isRunning)
        local targetAthlete = selector.weightedRandom(athlete.match.candidateWingDirectFreeKickTargets)
        local bestPassTarget = athlete:selectBestPassTargetForOneAthlete(targetAthlete, true)
        athlete:setPassAction(bestPassTarget.targetAthlete, bestPassTarget.targetPosition, bestPassTarget.type, bestPassTarget.isLeadPass)
        athlete.chosenDPSAction.isWingDirectFreeKick = true

        return "success"
    end
} )

local wingDirectFreeKickTask = BT.Task.new( {
    name = "WingDirectFreeKickTask",
    run = function(self, athlete, isRunning)
        athlete:logInfo("WingDirectFreeKickTask")

        if athlete:hasBuff(Skills.FreeKickMaster) then
            athlete.passSkillId = athlete:getSkill(Skills.FreeKickMaster).class.id
        end
        athlete.match.defenseTeam.athleteOfRole[26]:judgeOrganizeWallEx1()
        athlete:startPass()

        return "success"
    end
} )

local throwInCondition = BT.Condition.new( {
    name = "ThrowInCondition",
    run = function(self, athlete)
        if athlete.upComingAction == "ThrowIn" then
            athlete.upComingAction = nil
            return "success"
        else
            return "fail"
        end
    end
} )

local throwInTask = BT.Task.new( {
    name = "ThrowInTask",
    run = function(self, athlete, isRunning)
        athlete:logInfo("ThrowInTask")
        local target = athlete.match.throwInTarget
        athlete:setPassAction(target.targetAthlete, target.targetPosition, "High", false)
        athlete.noNeedJudgeOffside = true

        athlete.bodyDirection = vector2.norm(target.targetPosition - athlete.position)

        athlete:startPass()

        return "success"
    end
} )

local preKickOffCondition = BT.Condition.new( {
    name = "preKickOffCondition",
    run = function(self, athlete)
        if athlete.upComingAction == "PreKickOff" then
            athlete.upComingAction = nil
            return "success"
        else
            return "fail"
        end
    end
} )

local preKickOffTask = BT.Task.new( {
    name = "preKickOffTask",
    run = function(self, athlete, isRunning)
        if not isRunning then
            athlete.upComingAction = "KickOff"
            athlete:selectAndPushAnimation("PreKickOff", nil, true)
            athlete:updateOutputDribbleActionStatus()
        end

        if athlete:isAnimationEnd(athlete.match.nextTime) then
            local excludeAttackAthletes = {athlete, athlete.team.kickOffPlayer}
            local excludeDefendAthletes = { }

            athlete.match:unfreeze(excludeAttackAthletes, excludeDefendAthletes)
            return "success"
        end

        return "running"
    end
} )

local kickOffCondition = BT.Condition.new( {
    name = "KickOffCondition",
    run = function(self, athlete)
        if athlete.upComingAction == "KickOff" then
            athlete.upComingAction = nil
            return "success"
        else
            return "fail"
        end
    end
} )

local kickOffTask = BT.Task.new( {
    name = "KickOffTask",
    run = function(self, athlete, isRunning)
        local targetAthlete = athlete.team.kickOffPassTargetPlayer
        athlete:setPassAction(targetAthlete, targetAthlete.position, "Ground", false)

        athlete.bodyDirection = vector2.norm(targetAthlete.position - athlete.position)
        targetAthlete.upComingAction = "KickOffPass2"

        athlete:selectPassAnimation()
        athlete:startPass(true)

        return "success"
    end
} )

local kickOffPass2Condition = BT.Condition.new( {
    name = "KickOffPass2Condition",
    run = function(self, athlete)
        if athlete.upComingAction == "KickOffPass2" then
            athlete.upComingAction = nil
            return "success"
        else
            return "fail"
        end
    end
} )

local kickOffPass2Task = BT.Task.new( {
    name = "KickOffPass2Task",
    run = function(self, athlete, isRunning)
        if not isRunning then
            local candidateGuardTargets, candidateCenterTargets = athlete.team:getKickOffPass2TargetRoles()

            local kickOffTargetAthlete = athlete.team:randomSelectAthlete(candidateGuardTargets, athlete.position)
            kickOffTargetAthlete = kickOffTargetAthlete or athlete.team:randomSelectAthlete(candidateCenterTargets, athlete.position)
            athlete.kickOffPassTarget = athlete:selectBestPassTargetForOneAthlete(kickOffTargetAthlete)
            athlete:setPassAction(athlete.kickOffPassTarget.targetAthlete, athlete.kickOffPassTarget.targetPosition, athlete.kickOffPassTarget.type, false)

            if not athlete:hasAppropriatePassAnimation() then
                athlete:choosePassAdjustAction()
                athlete:startDribble()
                athlete:updateOutputDribbleActionStatus()

                return "running"
            end
        end

        if athlete.chosenDPSAction and athlete.chosenDPSAction.name == "Dribble" and not athlete:isAnimationEnd(athlete.match.currentTime) then
            return "running"
        end

        athlete:setPassAction(athlete.kickOffPassTarget.targetAthlete, athlete.kickOffPassTarget.targetPosition, athlete.kickOffPassTarget.type, false)
        athlete:selectPassAnimation()
        athlete:startPass(true)

        return "success"
    end
} )

local cornerKickCondition = BT.Condition.new( {
    name = "CornerKickCondition",
    run = function(self, athlete)
        if athlete.upComingAction == "CornerKick" then
            athlete.upComingAction = nil
            return "success"
        else
            return "fail"
        end
    end
} )

local cornerKickDecisionTask = BT.Task.new( {
    name = "cornerKickDecisionTask",
    run = function(self, athlete, isRunning)
        local targetAthlete = selector.weightedRandom(athlete.match.candidateCornerKickTargets)
        local bestPassTarget = athlete:selectBestPassTargetForOneAthlete(targetAthlete, math.cmpf(vector2.sqrdist(athlete.match.ball.position, athlete.position), 225) > 0)
        athlete:setPassAction(bestPassTarget.targetAthlete, bestPassTarget.targetPosition, bestPassTarget.type, bestPassTarget.isLeadPass,
        nil, Field.isHeaderArea(bestPassTarget.targetPosition, athlete.team:getSign()))
        athlete.chosenDPSAction.isCornerkick = true

        return "success"
    end
} )

local cornerKickTask = BT.Task.new( {
    name = "CornerKickTask",
    run = function(self, athlete, isRunning)
        athlete:logInfo("CornerKickTask")

        if athlete:hasBuff(Skills.CornerKickMaster, "base") then
            athlete.passSkillId = athlete:getSkill(Skills.CornerKickMaster).class.id
        end

        athlete:startPass()

        athlete.team.cornerKickTimes = athlete.team.cornerKickTimes + 1
        if athlete.selectedIntercept then
            athlete.team.interceptedCornerKickTimes = athlete.team.interceptedCornerKickTimes + 1
        end

        return "success"
    end
} )

local penaltyKickCondition = BT.Condition.new( {
    name = "PenaltyKickCondition",
    run = function(self, athlete)
        if athlete.upComingAction == "PenaltyKick" then
            athlete.upComingAction = nil
            return "success"
        else
            return "fail"
        end
    end
} )

local penaltyKickPrepareTask = BT.Task.new( {
    name = "PenaltyKickPrepareTask",
    run = function(self, athlete, isRunning)
        athlete:logInfo("PenaltyKickPrepare")
        athlete.chosenDPSAction = athlete:getNewShootAction(vector2.new((1 - 2 * math.random()) * Field.halfGoalWidth, athlete.enemyTeam.goal.center.y))
        return "success"
    end
} )

local judgePenaltyKickKillerTask = BT.Task.new( {
    name = "judgePenaltyKickKillerTask",
    run = function(self, athlete, isRunning)
        local enemyGk = athlete.enemyTeam.athleteOfRole[26]
        local skill = enemyGk:getCooldownSkill(Skills.PenaltyKickKiller)

        if skill ~= nil then
            enemyGk:castSkill(skill.class)
            enemyGk:addBuff(skill.buff, enemyGk)
            enemyGk:judgePenaltyKickKillerEx1()
        end

        return "success"
    end
} )

local judgeWithBallSkillTask = BT.Task.new( {
    name = "judgeWithBallSkillTask",
    run = function(self, athlete, isRunning)
        athlete.selectedSkillId = athlete:judgeWithBallSkill()
        athlete:judgeBreakThroughEx1()
        athlete:judgeScarWarrior(athlete.selectedSkillId)
        return athlete.selectedSkillId and "success" or "fail"
    end
} )

local clearWithBallSkillTask = BT.Task.new( {
    name = "clearWithBallSkillTask",
    run = function(self, athlete, isRunning)
        athlete.selectedSkillId = nil
        return "success"
    end
} )

local heavyGunnerCondition = BT.Condition.new( {
    name = "heavyGunnerCondition",
    run = function(self, athlete)
        return (AIUtils.isSkillIdCorrespondSkill(athlete.selectedSkillId, Skills.HeavyGunner) or AIUtils.isSkillIdCorrespondSkill(athlete.manualOperateSkillId, Skills.HeavyGunner)) and "success" or "fail"
    end
} )

local heavyGunnerTask = BT.Task.new( {
    name = "HeavyGunnerTask",
    run = function(self, athlete, isRunning)
        athlete.isHeavyGunner = true
        athlete:calculateNoAreaConstraintShootAction()

        local skill = athlete:getSkill(Skills.HeavyGunner)
        athlete:castSkill(skill.class)
        athlete:addBuff(skill.buff, athlete)

        return "success"
    end
} )

local throughBallCondition = BT.Condition.new( {
    name = "throughBallCondition",
    run = function(self, athlete)
        return (AIUtils.isSkillIdCorrespondSkill(athlete.selectedSkillId, Skills.ThroughBall) or AIUtils.isSkillIdCorrespondSkill(athlete.manualOperateSkillId, Skills.ThroughBall)) and "success" or "fail"
    end
} )

local throughBallTask = BT.Task.new( {
    name = "ThroughBallTask",
    run = function(self, athlete, isRunning)
        local skill = athlete:getSkill(Skills.ThroughBall)
        athlete:addBuff(skill.buff, athlete)

        athlete.passSkillId = skill.class.id

        athlete:setPassAction(athlete.throughBallAction.targetAthlete, athlete.throughBallAction.targetPosition,
            athlete.throughBallAction.type, athlete.throughBallAction.isLeadPass)

        athlete:selectPassAnimation()
        athlete:startPass()

        return "success"
    end
} )

local overHeadBallCondition = BT.Condition.new( {
    name = "overHeadBallCondition",
    run = function(self, athlete)
        return (AIUtils.isSkillIdCorrespondSkill(athlete.selectedSkillId, Skills.OverHeadBall) or AIUtils.isSkillIdCorrespondSkill(athlete.manualOperateSkillId, Skills.OverHeadBall)) and "success" or "fail"
    end
} )

local overHeadBallTask = BT.Task.new( {
    name = "OverHeadBallTask",
    run = function(self, athlete, isRunning)
        local skill = athlete:getSkill(Skills.OverHeadBall)
        athlete:addBuff(skill.buff, athlete)

        athlete.passSkillId = skill.class.id

        athlete:setPassAction(athlete.overHeadBallAction.targetAthlete, athlete.overHeadBallAction.targetPosition,
            athlete.overHeadBallAction.type, athlete.overHeadBallAction.isLeadPass)

        athlete:selectPassAnimation()
        athlete:startPass()

        return "success"
    end
} )

local crossLowCondition = BT.Condition.new( {
    name = "crossLowCondition",
    run = function(self, athlete)
        return (AIUtils.isSkillIdCorrespondSkill(athlete.selectedSkillId, Skills.CrossLow) or AIUtils.isSkillIdCorrespondSkill(athlete.manualOperateSkillId, Skills.CrossLow)) and "success" or "fail"
    end
} )

local crossLowTask = BT.Task.new( {
    name = "CrossLowTask",
    run = function(self, athlete, isRunning)
        if not isRunning then
            local lastAnimationType
            if athlete.currentAnimation then
                lastAnimationType = athlete.currentAnimation.type
            end

            local toTargetPositionVector = vector2.norm(athlete.chosenDPSAction.targetPosition - athlete.position)
            if lastAnimationType ~= "CrossLowAdjust" and lastAnimationType ~= "BreakThrough" and lastAnimationType ~= "ManualOperateDribble"
                and athlete:hasNonGkEnemyAthleteInFront(toTargetPositionVector, 3, math.pi / 2) then

                if athlete:chooseCrossLowAdjustAction() then
                    athlete:startDribble()
                    athlete:updateOutputDribbleActionStatus()

                    return "running"
                end
            end
        end

        if athlete.chosenDPSAction and athlete.chosenDPSAction.name == "Dribble" and not athlete:isAnimationEnd(athlete.match.currentTime) then
            return "running"
        end

        local skill = athlete:getSkill(Skills.CrossLow)
        athlete:addBuff(skill.buff, athlete)

        athlete.passSkillId = skill.class.id

        athlete:setPassAction(athlete.crossLowAction.targetAthlete, athlete.crossLowAction.targetPosition,
            athlete.crossLowAction.type, athlete.crossLowAction.isLeadPass, nil, true)

        athlete:logInfo("CrossLow")

        athlete:selectCrossLowAnimation()
        athlete:startPass()

        return "success"
    end
} )

local judgeCatchCrossLowTask = BT.Task.new( {
    name = "judgeCatchCrossLowTask",
    run = function(self, athlete, isRunning)
        local skill = athlete:getCooldownSkill(Skills.CrossLow)
        if athlete.catchType == AIUtils.catchType.CatchCrossPass and skill and selector.tossCoin(skill.probability) then
            athlete:addBuff(skill.buff, athlete)
            athlete.passSkillId = skill.class.id
        end

        return "success"
    end
} )

local divingCondition = BT.Condition.new( {
    name = "divingCondition",
    run = function(self, athlete)
        return (AIUtils.isSkillIdCorrespondSkill(athlete.selectedSkillId, Skills.Diving) or AIUtils.isSkillIdCorrespondSkill(athlete.manualOperateSkillId, Skills.Diving)) and "success" or "fail"
    end
} )

local selectDivingActionTask = BT.Task.new( {
    name = "selectDivingActionTask",
    run = function(self, athlete, isRunning)
        local skill = athlete:getSkill(Skills.Diving)
        athlete:castSkill(skill.class)
        athlete:addBuff(skill.buff, athlete)
        athlete.animationQueue = {}

        local candidateDivingAnimations = athlete.candidateDivingAnimations or Animations.Tag.RapidDribble
        local dribbleAnimation = selector.randomSelect(candidateDivingAnimations)

        athlete.candidateDivingAnimations = nil

        local candidateActions = { }
        local divingAction = Actions.Dribble.new()
        divingAction.animation = dribbleAnimation
        divingAction.animationType = "Diving"
        table.insert(candidateActions, { key = divingAction, weight = 1 })

        athlete.candidateDribbleActions = candidateActions
        athlete.candidatePassActions = { }
        athlete.candidateShootActions = { }

        athlete:DPSChoose()
        athlete:startDribble()

        return "success"
   end
} )

local judgeDivingForceFoulTask = BT.Task.new( {
    name = "judgeDivingForceFoulTask",
    run = function(self, athlete, isRunning)
        if not athlete.dribbleState.stealAthlete then
            local fouler = athlete.enemyTeam:selectNearestAthlete(athlete.position)

            local selectedFoul = {
                foulAthlete = fouler,
                dribbleTimeBeforeFouled = 0.1,
                foulPosition = athlete.position,
                foulAnimation = {animation = selector.randomSelect(Animations.Tag.DivingFoul), startBodyDirection = fouler.bodyDirection},
                destMatchState = Field.isInPenaltyArea(athlete.position, athlete.team:getSign()) and "PenaltyKick"
                    or (Field.isInCenterDirectFreeKickArea(athlete.position, athlete.team:getSign()) and "CenterDirectFreeKick" or "WingDirectFreeKick"),
            }

            athlete:addFoulTask(selectedFoul, true)
            athlete:judgeDivingEx1(fouler)
        end

        return "success"
   end
} )

local calculateDribbleTask = BT.Task.new( {
    name = "CalculateDribbleTask",
    run = function(self, athlete, isRunning)
        athlete:calculateDribble()
        return "success"
    end
} )

local calculatePassTask = BT.Task.new( {
    name = "CalculatePassTask",
    run = function(self, athlete, isRunning)
        athlete:calculatePass()
        return "success"
    end
} )

local calculateShootTask = BT.Task.new( {
    name = "CalculateShootTask",
    run = function(self, athlete, isRunning)
        athlete:calculateShoot()
        return "success"
    end
} )

local metronomeCondition = BT.Condition.new( {
    name = "metronomeCondition",
    run = function(self, athlete)
        return (AIUtils.isSkillIdCorrespondSkill(athlete.selectedSkillId, Skills.Metronome) or AIUtils.isSkillIdCorrespondSkill(athlete.manualOperateSkillId, Skills.Metronome)) and "success" or "fail"
    end
} )

local metronomeSkillTask = BT.Task.new( {
    name = "metronomeSkillTask",
    run = function(self, athlete, isRunning)
        local skill = athlete:getSkill(Skills.Metronome)
        athlete:castSkill(skill.class, skill.addRatio)
        skill.hasLaunched = true

        local existedMetronomeBuffSkill = athlete:getFirstBuffSkill(Skills.Metronome)
        if not existedMetronomeBuffSkill or skill.level > existedMetronomeBuffSkill.level then
            for i, attackAthlete in ipairs(athlete.team.athletes) do
                attackAthlete:removeBuffs(Skills.Metronome, "base")
                attackAthlete:addBuff(skill.buff, athlete)
                attackAthlete:judgeEmotional(skill)
                attackAthlete:judgeTeamSoul(skill)
                attackAthlete:judgeTeamLeaderEx1(skill)
            end
            athlete:judgeMetronomeEx1()
        end

        athlete:judgeMidfieldMaestrosEx1(skill)

        athlete:calculateMetronome()
        athlete.candidatePassActions = {}
        athlete.candidateShootActions = {}

        return "success"
    end
} )

local DPSChooseTask = BT.Task.new( {
    name = "DPSChooseTask",
    run = function(self, athlete, isRunning)
        athlete:DPSChoose()

        return "success"
    end
} )

local DPSAdjustTask = BT.Task.new( {
    name = "DPSAdjustTask",
    run = function(self, athlete, isRunning)
        athlete:DPSAdjust()

        return "success"
    end
} )

local dribbleCondition = BT.Condition.new( {
    name = "DribbleCondition",
    run = function(self, athlete)
        return athlete.chosenDPSAction.name == "Dribble" and "success" or "fail"
    end
} )

local startDribbleTask = BT.Task.new( {
    name = "StartDribbleTask",
    run = function(self, athlete, isRunning)
        athlete:startDribble()
        return "success"
    end
} )

local stealAndFoulJudgeTask = BT.Task.new( {
    name = "stealAndFoulJudgeTask",
    run = function(self, athlete, isRunning)
        if athlete:hasBuff(Skills.Diving) or athlete:isMeetStealAndFoulConditions() then
            athlete:judgeEnemyRationalSteal()
            athlete:judgeEnemySlidingTackle()
            athlete:judgeEnemyStealAndFoul()
        end

        return "success"
    end
} )

local doDribbleTask = BT.Task.new( {
    name = "doDribbleTask",
    run = function(self, athlete, isRunning)
        if not isRunning then
            athlete:updateOutputDribbleActionStatus()
        end

        if athlete.dribbleState.stealAthlete ~= nil then
            if athlete.dribbleState.stealAthlete.isStealFail then
                athlete.animationQueue = {}
                athlete:pushAnimation(Animations.RawData.B_E021, true, vector2.norm(athlete.dribbleState.stealAthlete.position - athlete.position))
                athlete.dribbleState.stealAthlete = nil
                athlete.match.ball.nextTask = nil
                athlete:updateOutputDribbleActionStatus()
                return "running"
            end
            if math.cmpf(athlete.match.currentTime, athlete.match.ball.nextTask.stealTime) == 0 then
                athlete:clearManualOperate()
                return "success"
            end
            return "running"
        elseif athlete.dribbleState.foulAthlete ~= nil then
            if math.cmpf(athlete.match.currentTime, athlete.match.ball.nextTask.foulTime) == 0 then
                athlete:clearManualOperate()
                return "success"
            end
            return "running"
        else
            local isDribbleEnded = athlete:isAnimationEnd(athlete.match.nextTime)
            if isDribbleEnded then
                if athlete.isManualFollowedDribble or athlete.inManualOperating then
                    athlete:clearManualOperate()
                end
            end

            return isDribbleEnded and "success" or "running"
        end
    end,
} )

local passCondition = BT.Condition.new( {
    name = "PassCondition",
    run = function(self, athlete)
        return athlete.chosenDPSAction.name == "Pass" and "success" or "fail"
    end
} )

local highPassCondition = BT.Condition.new( {
    name = "highPassCondition",
    run = function(self, athlete)
        return athlete.chosenDPSAction.type == "High" and "success" or "fail"
    end
} )

local groundPassCondition = BT.Condition.new( {
    name = "GroundPassCondition",
    run = function(self, athlete)
        return athlete.chosenDPSAction.type == "Ground" and "success" or "fail"
    end
} )

local selectPassAnimationTask = BT.Task.new( {
    name = "selectPassAnimationTask",
    run = function(self, athlete, isRunning)
        if athlete:isNormalCrossLow(athlete.chosenDPSAction.targetPosition) then
            athlete:selectAndPushPassAnimationByTargetPosition("CrossPass", athlete.chosenDPSAction.targetPosition, true)
        else
            athlete:selectPassAnimation()
        end
        return "success"
    end
} )

local startPassTask = BT.Task.new( {
    name = "startPassTask",
    run = function(self, athlete, isRunning)
        athlete:startPass()
        return "success"
    end
} )

local doPassTask = BT.Task.new( {
    name = "doPassTask",
    run = function(self, athlete, isRunning)
        if not isRunning then
            athlete:setBallPassTask()
            athlete:updateOutputPassActionStatus()
        end

        if athlete.currentAnimation and athlete:isBallOut(athlete.match.currentTime) then
            -- 动作做到出球点的时候
            athlete:passBall()
            if athlete.match.frozenType ~= "KickOff" and athlete.match.isFrozen then
                local nextTask = athlete.match.ball.nextTask
                local excludeAttackAthletes
                local excludeDefendAthletes
                if athlete.team:isAttackRole() then
                    excludeAttackAthletes = {athlete, nextTask.receiver}
                    excludeDefendAthletes = {nextTask.interceptor}
                else
                    excludeAttackAthletes = {nextTask.interceptor}
                    excludeDefendAthletes = {athlete, nextTask.receiver}
                end

                athlete.match:unfreeze(excludeAttackAthletes, excludeDefendAthletes)
            end
        end
        local isAnimationEnd = athlete:isAnimationEnd(athlete.match.nextTime)

        if isAnimationEnd then
            athlete.match:checkCanBeEndedNow()
            return "success"
        end

        return "running"
    end
})

local shootCondition = BT.Condition.new( {
    name = "ShootCondition",
    run = function(self, athlete)
        return athlete.chosenDPSAction.name == "Shoot" and "success" or "fail"
    end
} )

local calmShootJudgeTask = BT.Task.new( {
    name = "CalmShootJudgeTask",
    run = function(self, athlete, isRunning)
        local skill = athlete:getCooldownSkill(Skills.CalmShoot)
        local enemyGk = athlete.enemyTeam.athleteOfRole[26]
        if skill and selector.tossCoin(skill.probability) then
            athlete.isCalmShoot = true
            athlete:castSkill(skill.class)
            athlete:addBuff(skill.buff, athlete)
        end

        return "success"
    end
} )

local selectNormalShootAnimationTask = BT.Task.new( {
    name = "selectNormalShootAnimationTask",
    run = function(self, athlete, isRunning)
        athlete:selectShootAnimation("NormalShoot")
        return "success"
    end
} )

local selectHeavyGunnerAnimationTask = BT.Task.new( {
    name = "selectHeavyGunnerAnimationTask",
    run = function(self, athlete, isRunning)
        athlete:selectShootAnimation("HeavyGunner")
        return "success"
    end
} )

local shootTask = BT.Task.new( {
    name = "shootTask",
    run = function(self, athlete, isRunning)
        if not isRunning then
            athlete:judgeTigerShoot()
            athlete:judgeImpactWave()
            athlete:preShoot()
        end

        if athlete:isPreShootEndFrame(athlete.match.currentTime, 0.1) then
            athlete:shootPause()
        end

        if athlete:isPreShootEndFrame(athlete.match.currentTime) then
            athlete:castPlannedShootSkills()
            athlete:judgeAllAroundFighter("shoot")
            athlete.enemyTeam.athleteOfRole[26]:castPlannedGkSkills(athlete)
            athlete:shoot()
            --退出手动操作视角
            athlete.team:clearTeamManualOperate()
            if athlete.match.ball.preTouchAthlete ~= nil and athlete.match.ball.preTouchAthlete ~= athlete then
                athlete.match.ball.preTouchAthlete:judgeMagicFlute()
            end
        end

        return athlete:isAnimationEnd(athlete.match.nextTime) and "success" or "running"
    end
} )

local ballNextTaskCondition = BT.Condition.new( {
    name = "BallNextTaskCondition",
    run = function(self, athlete)
        return athlete.match.ball.nextTask and "success" or "fail"
    end
} )

local ballPassCondition = BT.Condition.new( {
    name = "BallPassCondition",
    run = function(self, athlete)
        return athlete.match.ball.nextTask.class == Ball.Pass and "success" or "fail"
    end
} )

local ballPassInterceptCondition = BT.Condition.new( {
    name = "BallPassInterceptCondition",
    run = function(self, athlete)
        return athlete.match.ball.nextTask.class == Ball.PassAndIntercept and "success" or "fail"
    end
} )

local ballPassReceiverCondition = BT.Condition.new( {
    name = "BallPassReceiverCondition",
    run = function(self, athlete)
        return athlete.match.ball.nextTask.receiver == athlete and "success" or "fail"
    end
} )

local ballPassMoveToTimeCondition = BT.Condition.new( {
    name = "BallPassMoveToTimeCondition",
    run = function(self, athlete)
        return math.cmpf(athlete.match.ball.nextTask.receiverArriveTime, athlete.match.nextTime) >= 0 and "success" or "fail"
    end
} )

local catchMoveToTask = BT.Task.new( {
    name = "CatchMoveToTask",
    run = function(self, athlete, isRunning)
        local ball = athlete.match.ball
        if not isRunning then
            ball.nextTask.startTime = athlete.match.currentTime
            athlete.animationQueue = { }
        end

        local nextTask = ball.nextTask
        local nextTime = athlete.match.nextTime

        local targetPosition = nextTask.class == Ball.PassAndIntercept and nextTask.interceptPosition or nextTask.receiverArrivePosition
        local towardPosition
        if nextTask.isLeadPass then
            if Field.isInForceShootArea(targetPosition, athlete.team:getSign()) then
                towardPosition = athlete.enemyTeam.goal.center
            else
                towardPosition = vector2.new(athlete.position.x, athlete.enemyTeam.goal.center.y)
            end
        else
            if nextTask.passer.catchType == AIUtils.catchType.CatchPass
                or nextTask.passer.catchType == AIUtils.catchType.CatchCrossPass
                or nextTask.passer.catchType == AIUtils.catchType.InterceptCatchPass then
                towardPosition = nextTask.passer.position
            else
                towardPosition = ball.owner and ball.owner.position or ball.flyStartPosition
            end
        end

        local willHeadingDual = nextTask.class == Ball.PassAndIntercept and nextTask.passType == "High"
                and math.cmpf(vector2.sqrdist(athlete.position, nextTask.interceptor.position), 4) < 0
        local movePriority = (nextTask.isLeadPass and not willHeadingDual) and AIUtils.movePriority.speed or AIUtils.movePriority.toward

        local targetTime = nextTask.class == Ball.PassAndIntercept and nextTask.interceptorArriveTime or nextTask.receiverArriveTime
        athlete:catchMoveTo(targetPosition, towardPosition, vector2.dist(targetPosition, athlete.position) / (targetTime - athlete.match.currentTime), movePriority)

        if math.cmpf(nextTime, targetTime) >= 0 then
            if willHeadingDual then
                athlete.shouldHeadingDual = true
                athlete.animationQueue = { }
            end
            return "success"
        end

        return "running"
    end
} )

local volleyShootCondition = BT.Condition.new( {
    name = "volleyShootCondition",
    run = function(self, athlete)
        return athlete.catchType == AIUtils.catchType.VolleyShoot and "success" or "fail"
    end
} )

local addVolleyShootBuffTask = BT.Task.new( {
    name = "addVolleyShootBuffTask",
    run = function(self, athlete, isRunning)
        local skill = athlete:getSkill(Skills.VolleyShoot)
        athlete:castSkill(skill.class)
        athlete:addBuff(skill.buff, athlete)

        return "success"
    end
} )

local catchPassCondition = BT.Condition.new( {
    name = "catchPassCondition",
    run = function(self, athlete)
        return (athlete.catchType == AIUtils.catchType.CatchPass
            or athlete.catchType == AIUtils.catchType.CatchCrossPass
            or athlete.catchType == AIUtils.catchType.InterceptCatchPass) and "success" or "fail"
    end
} )

local catchPassTask = BT.Task.new( {
    name = "catchPassTask",
    run = function(self, athlete, isRunning)
        athlete:catch()

        local passAction = athlete.match.ball.nextTask.catchAnimation.passAction
        athlete:setPassAction(passAction.targetAthlete, passAction.targetPosition, passAction.type, passAction.isLeadPass, nil, passAction.isCrossLow)
        athlete:startPass()

        return "success"
    end
} )

local catchInterceptPassTask = BT.Task.new( {
    name = "catchInterceptPassTask",
    run = function(self, athlete, isRunning)
        athlete:catch()

        local passAction = athlete.match.ball.nextTask.catchAnimation.passAction
        athlete:setPassAction(passAction.targetAthlete, passAction.targetPosition, passAction.type, passAction.isLeadPass, nil, passAction.isCrossLow)
        athlete:startPass(true)

        return "success"
    end
} )

local powerfulHeaderCondition = BT.Condition.new( {
    name = "powerfulHeaderCondition",
    run = function(self, athlete)
        return athlete.catchType == AIUtils.catchType.PowerfulHeader and "success" or "fail"
    end
} )

local addPowerfulHeaderBuffTask = BT.Task.new( {
    name = "addPowerfulHeaderBuffTask",
    run = function(self, athlete, isRunning)
        local skill = athlete:getSkill(Skills.PowerfulHeader)
        athlete:castSkill(skill.class)
        athlete:addBuff(skill.buff, athlete)

        return "success"
    end
} )

local normalCatchShootCondition = BT.Condition.new( {
    name = "normalCatchShootCondition",
    run = function(self, athlete)
        return (athlete.catchType == AIUtils.catchType.NormalHeader
            or athlete.catchType == AIUtils.catchType.NormalVolleyShoot
            or athlete.catchType == AIUtils.catchType.OffTheBall)
            and "success" or "fail"
    end
} )

local catchAndShootTask = BT.Task.new( {
    name = "catchAndShootTask",
    run = function(self, athlete, isRunning)
        athlete:catch()
        athlete.chosenDPSAction = athlete:getNewShootAction(vector2.new((1 - 2 * math.random()) * Field.halfGoalWidth, athlete.enemyTeam.goal.center.y))

        return "success"
    end
} )

local foxInTheBoxJudgeTask = BT.Task.new( {
    name = "foxInTheBoxJudgeTask",
    run = function(self, athlete, isRunning)
        if athlete.catchType == AIUtils.catchType.OffTheBall then
            local skill = athlete:getCooldownSkill(Skills.FoxInTheBox)
            if skill and selector.tossCoin(skill.probability) then
                athlete:castSkill(skill.class)
                athlete:addBuff(skill.buff, athlete)
            end
        end

        return "success"
    end
} )

local judgeHighQualityGkPassTask = BT.Task.new( {
    name = "judgeHighQualityGkPassTask",
    run = function(self, athlete, isRunning)
        local ball = athlete.match.ball
        local skill = ball.lastTouchAthlete:getCooldownSkill(Skills.HighQualityGkPass)
        if ball.lastTouchAthlete:isGoalkeeper() and skill and selector.tossCoin(skill.probability) then
            ball.lastTouchAthlete:castSkill(skill.class)
            athlete:addBuff(skill.passTargetBuff, ball.lastTouchAthlete)
            ball.lastTouchAthlete:judgeHighQualityGkPassEx1BuffSign()
        end

        return "success"
    end
} )

local judgeCatenaccioTask = BT.Task.new( {
    name = "judgeCatenaccioTask",
    run = function(self, athlete, isRunning)
        for _, enemyAthlete in ipairs(athlete.enemyTeam.athletes) do
            local skill = enemyAthlete:getCooldownSkill(Skills.Catenaccio)
            if not enemyAthlete:isDivingEx1Blocked() and skill then
                enemyAthlete:castSkill(skill.class, skill.addRatio)
                enemyAthlete:addBuff(skill.buff, enemyAthlete)
                enemyAthlete:judgeCatenaccioEx1()
            end
        end

        return "success"
    end
} )

local selectCatchAnimationTask = BT.Task.new( {
    name = "selectCatchAnimationTask",
    run = function(self, athlete, isRunning)
        athlete:selectCatchAnimation()

        return "success"
    end
} )

local ballCatchTask= BT.Task.new( {
    name = "BallCatchTask",
    run = function(self, athlete, isRunning)
        if not isRunning then
            athlete:catch()
            athlete:updateOutputCatchActionStatus()
        end

        local nextTask = athlete.match.ball.nextTask
        if nextTask and math.cmpf(athlete.match.currentTime, nextTask.receiveTime) == 0 then
            athlete.match.ball:setOwner(athlete)

            if nextTask.class == Ball.PassAndIntercept then
                athlete:judgeCounterRunningForward()
            end

            if athlete.match.noNeedJudgeBallOutOfField then
                athlete.match.noNeedJudgeBallOutOfField = false
            end

            athlete.match.ball.nextTask = nil
        end

        local isCatchEnded = athlete:isAnimationEnd(athlete.match.nextTime)
        if isCatchEnded then
            if athlete.team.inManualOperating then
                local dribbleAction = Actions.Dribble.new()
                --P_C001 P_C002
                dribbleAction.animation = Animations.RawData.P_C002
                dribbleAction.animationType = "Dribble"
                athlete.chosenDPSAction = dribbleAction
                athlete.isManualFollowedDribble = true
            end
        end

        return isCatchEnded and "success" or "running"
    end
} )

local moveAttackDecideTask = BT.Task.new( {
    name = "MoveAttackDecideTask",
    run = function(self, athlete, isRunning)
        athlete:moveAttackDecide()
        return "success"
    end
} )

local ballStealCondition = BT.Condition.new( {
    name = "BallStealCondition",
    run = function(self, athlete)
        local nextTask = athlete.match.ball.nextTask
        return (nextTask and nextTask.class == Ball.Steal and nextTask.stealer == athlete) and "success" or "fail"
    end
} )

local foulCondition = BT.Condition.new( {
    name = "FoulCondition",
    run = function(self, athlete)
        local nextTask = athlete.match.ball.nextTask
        return (nextTask and nextTask.class == Ball.Foul and nextTask.fouler == athlete) and "success" or "fail"
    end
} )

local ballInterceptorCondition = BT.Condition.new( {
    name = "BallInterceptorCondition",
    run = function(self, athlete)
        return athlete.match.ball.nextTask.interceptor == athlete and "success" or "fail"
    end
} )

local ballSaverCondition = BT.Condition.new( {
    name = "BallSaverCondition",
    run = function(self, athlete)
        local nextTask = athlete.match.ball.nextTask
        return nextTask.class == Ball.ShootAndSave and nextTask.saver == athlete and "success" or "fail"
    end
} )

local ballInterceptMoveToTimeCondition = BT.Condition.new( {
    name = "BallInterceptMoveToTimeCondition",
    run = function(self, athlete)
        return math.cmpf(athlete.match.ball.nextTask.interceptorArriveTime, athlete.match.nextTime) >= 0 and "success" or "fail"
    end
} )

local ballSaveMoveToAnimationCondition = BT.Condition.new( {
    name = "ballSaveMoveToAnimationCondition",
    run = function(self, athlete)
        return #athlete.animationQueue > 0 and "success" or "fail"
    end
} )

local interceptMoveToTask = BT.Task.new( {
    name = "InterceptMoveToTask",
    run = function(self, athlete, isRunning)
        if not isRunning then
            athlete.match.ball.nextTask.startTime = athlete.match.currentTime
            athlete.animationQueue = { }
        end

        local nextTask = athlete.match.ball.nextTask
        athlete:catchMoveTo(nextTask.interceptPosition, nextTask.interceptPosition,
        vector2.dist(nextTask.interceptPosition, athlete.position) / (nextTask.interceptorArriveTime - athlete.match.currentTime), AIUtils.movePriority.speed)

        if math.cmpf(athlete.match.nextTime, nextTask.interceptorArriveTime) >= 0 then
            athlete.animationQueue = { }
            return "success"
        end

        return "running"
    end,
} )

local saveMoveToTask = BT.Task.new( {
    name = "SaveMoveToTask",
    run = function(self, athlete, isRunning)
        if not isRunning then
            athlete.match.ball.nextTask.startTime = athlete.match.currentTime
        end

        return athlete:isAnimationEnd(athlete.match.nextTime) and "success" or "running"
    end,
} )

local interceptTask = BT.Task.new( {
    name = "InterceptTask",
    run = function(self, athlete, isRunning)
        athlete:intercept()
        return "success"
    end
} )

local saveTask = BT.Task.new( {
    name = "SaveTask",
    run = function(self, athlete, isRunning)
        local nextTask = athlete.match.ball.nextTask

        if not isRunning then
            athlete:startSave()
        end

        if math.cmpf(nextTask.saveTime, athlete.match.currentTime) == 0 then
            athlete:save()
        end

        if not Field.isInside(athlete.position) then
            athlete.position = vector2.new(athlete.position.x, athlete.team:getSign() * Field.halfLength)
        end

        if math.cmpf(nextTask.saveTime, athlete.match.currentTime) <= 0 and athlete:isAnimationEnd(athlete.match.nextTime) then
            athlete.match.ball.nextTask = nil

            --当门将扑住球动作做完后，指示进行点球大战下一轮点球判断
            if athlete.graspBall and athlete.match.isInPenaltyShootOut then
                athlete.match.willJudgePenaltyShootOutKickAfterGrasp = true
            end

            return "success"
        end
        return "running"
    end
} )

local puntKickSkillCondition = BT.Condition.new( {
    name = "puntKickSkillCondition",
    run = function(self, athlete)
        return athlete:isPuntKickTriggered() and "success" or "fail"
    end
} )

local puntKickTask = BT.Task.new( {
    name = "puntKickTask",
    run = function(self, athlete, isRunning)
        local skill = athlete:getSkill(Skills.PuntKick)
        athlete:addBuff(skill.buff, athlete)

        athlete.passSkillId = skill.class.id

        athlete.currentAnimation = nil

        athlete.position.y = math.sign(athlete.position.y) * math.min(math.abs(athlete.position.y), Field.halfLength)
        athlete.bodyDirection = vector2.norm(athlete.chosenDPSAction.targetPosition - athlete.position)

        if athlete.graspBall then
            athlete:selectAndPushAnimation("GKLongPass", nil, true)
        else
            athlete:selectPassAnimation()
        end
        athlete:startPass()

        return "success"
    end
} )

local gkStayWithBallTask = BT.Task.new( {
    name = "gkStayWithBallTask",
    run = function(self, athlete, isRunning)
        if not isRunning then
            athlete.dribbleState.stealAthlete = nil
            athlete.dribbleState.foulAthlete = nil

            athlete:selectAndPushAnimation("GKStay", function (animation)
            return Field.isInside(athlete.position + vector2.vyrotate(animation.targetPosition, athlete.bodyDirection)) end, true)
            athlete:updateOutputDribbleActionStatus()
        end

        return athlete:isAnimationEnd(athlete.match.currentTime) and "success" or "running"
    end
} )

local judgeSoulFluctuationTask = BT.Task.new( {
    name = "judgeSoulFluctuationTask",
    run = function(self, athlete, isRunning)
        athlete.match:judgeAfterShootMissSkills()

        return "success"
    end
} )

local postSavePassTask = BT.Task.new( {
    name = "postSavePassTask",
    run = function(self, athlete, isRunning)
        athlete:logInfo("postSavePassTask")

        local candidateTargetAthletes = { }
        for i, friend in ipairs(athlete.team.athletes) do
            if friend ~= athlete and math.cmpf(vector2.sqrdist(athlete.position, friend.position), 25) >= 0 and math.cmpf(friend.position.y * athlete.team:getSign(), 45) < 0 then
                table.insert(candidateTargetAthletes, friend)
            end
        end

        local targetAthlete
        if #candidateTargetAthletes ~= 0 then
            targetAthlete = selector.randomSelect(candidateTargetAthletes)
        else
            repeat
                targetAthlete = selector.randomSelect(athlete.team.athletes)
            until targetAthlete ~= athlete
        end

        local bestPassTarget = athlete:selectBestPassTargetForOneAthlete(targetAthlete)
        athlete.bodyDirection = vector2.norm(bestPassTarget.targetPosition - athlete.position)

        local passAnimationType
        local passType
        local passSqrDist = vector2.sqrdist(bestPassTarget.targetPosition, athlete.position)
        if math.cmpf(passSqrDist, 225) < 0 then
            passAnimationType = "GKShortThrow"
            passType = "Ground"
        elseif math.cmpf(passSqrDist, 900) < 0 then
            passAnimationType = "GKLongThrow"
            passType = "High"
        else
            passAnimationType = "GKLongPass"
            passType = "High"
        end

        athlete:setPassAction(bestPassTarget.targetAthlete, bestPassTarget.targetPosition, passType, bestPassTarget.isLeadPass)

        athlete:selectAndPushAnimation(passAnimationType, nil, true)
        athlete:startPass(passAnimationType ~= "GKLongPass")

        return "success"
    end
} )

local stealTask = BT.Task.new( {
    name = "StealTask",
    run = function(self, athlete, isRunning)
        if not isRunning then
            athlete:startSteal()
            athlete:logInfo("Steal Task")
        end

        if not athlete.isStealFail and not athlete.match.ballOutOfField and math.cmpf(athlete.match.currentTime, athlete.match.ball.nextTask.stealTime) == 0 then
            athlete:steal()
            athlete.match.ball:setOwner(athlete)
        end

        if athlete:isAnimationEnd(athlete.match.nextTime) then
            athlete.isStealFail = false
            return "success"
        else
            return "running"
        end
    end
} )

local foulTask = BT.Task.new( {
    name = "FoulTask",
    run = function(self, athlete, isRunning)
        if not isRunning then
            athlete:startFoul()
        end

        if not athlete.match.ballOutOfField and math.cmpf(athlete.match.currentTime, athlete.match.ball.nextTask.foulTime) == 0 then
            athlete:foul()
        end

        if athlete:isAnimationEnd(athlete.match.nextTime) then
            if not athlete.match.ballOutOfField then
                athlete.match.isFoulFrame = true
                athlete:logInfo("foul")
                athlete.enemyTeam:clearTeamManualOperate()
            end
            return "success"
        end

        return "running"
    end
} )

local isGkCondition = BT.Condition.new( {
    name = "isGkCondition",
    run = function(self, athlete)
        return athlete:isGoalkeeper() and "success" or "fail"
    end
} )

local isNonGkCondition = BT.Condition.new( {
    name = "isNonGkCondition",
    run = function(self, athlete)
        return not athlete:isGoalkeeper() and "success" or "fail"
    end
} )

local frozenDefendTask = BT.Task.new( {
    name = "frozenDefendTask",
    run = function(self, athlete, isRunning)
        if athlete.match.isFrozen then
            if (athlete.match.frozenType == "CornerKick" and athlete == athlete.match.cornerKickDefender)
                or (athlete.match.frozenType == "WingDirectFreeKick" and athlete == athlete.match.wingDirectFreeKickDefender) then
                return "fail"
            end

            athlete:frozenDefend()
            return "success"
        else
            return "fail"
        end
    end
} )

local gkMoveDefendDecideTask = BT.Task.new( {
    name = "gkMoveDefendDecideTask",
    run = function(self, athlete, isRunning)
        athlete:gkMoveDefendDecide()
        return "success"
    end
} )

local nonGkMoveDefendDecideTask = BT.Task.new( {
    name = "nonGkMoveDefendDecideTask",
    run = function(self, athlete, isRunning)
        athlete:nonGkMoveDefendDecide()
        return "success"
    end
} )

local hasBreakThroughSkillCondition = BT.Condition.new( {
    name = "hasBreakThroughSkillCondition",
    run = function(self, athlete)
        return athlete:getCooldownSkill(Skills.BreakThrough) and "success" or "fail"
    end
} )

local breakThroughCondition = BT.Condition.new( {
    name = "breakThroughCondition",
    run = function(self, athlete)
        return (AIUtils.isSkillIdCorrespondSkill(athlete.selectedSkillId, Skills.BreakThrough) or AIUtils.isSkillIdCorrespondSkill(athlete.manualOperateSkillId, Skills.BreakThrough)) and "success" or "fail"
    end
} )

local calculateBreakThroughDPSTask = BT.Task.new( {
    name = "calculateBreakThroughDPSTask",
    run = function(self, athlete, isRunning)
        local res = athlete:calculateBreakThrough()
        local enemy = athlete.candidateEnemyForBreakThrough
        athlete.candidateEnemyForBreakThrough = nil

        if res then
            athlete.candidatePassActions = {}
            athlete.candidateShootActions = {}

            local skill = athlete:getSkill(Skills.BreakThrough)
            athlete:castSkill(skill.class)
            athlete:addBuff(skill.buff, athlete)
            athlete.breakThroughSkillTime = athlete.match.currentTime
            athlete:judgeTheKingOfTheSamba()

            return "success"
        else
            return "fail"
        end
    end
} )

local breakThroughSuccessBuffAddingTask = BT.Task.new( {
    name = "breakThroughSuccessBuffAddingTask",
    run = function(self, athlete, isRunning)
        if not athlete.dribbleState.stealAthlete and not athlete.dribbleState.foulAthlete then
            athlete:addBuff(athlete:getSkill(Skills.BreakThrough).afterSuccessBuff, athlete)
        end

        return "success"
    end
} )

local calculateBreakThroughDefendInfoTask = BT.Task.new( {
    name = "calculateBreakThroughDefendInfoTask",
    run = function(self, athlete, isRunning)
        athlete:calculateBreakThroughDefendInfo()

        return "success"
    end
} )

local gamesmanshipJudgeTask = BT.Task.new( {
    name = "gamesmanshipJudgeTask",
    run = function(self, athlete, isRunning)
        for i, enemy in ipairs(athlete.enemyTeam.athletes) do
            local skill = enemy:getCooldownSkill(Skills.Gamesmanship)
            local sqrdist = vector2.sqrdist(enemy.position, athlete.position)
            if not enemy:isDivingEx1Blocked() and skill ~= nil
            and selector.tossCoin(skill.probability) and math.cmpf(sqrdist, 9) <= 0 then
                enemy:castSkill(skill.class, skill.addRatio)
                athlete:addBuff(skill.buff, enemy)
                enemy:judgeGamesmanshipEx1(athlete)
            end
        end

        return "success"
    end
} )

local judgeFreeKickMasterSkillTask = BT.Task.new( {
    name = "JudgeFreeKickMasterSkillTask",
    run = function(self, athlete)
        local skill = athlete:getCooldownSkill(Skills.FreeKickMaster)

        if skill then
            athlete:castSkill(skill.class)
            athlete:addBuff(skill.buff, athlete)
        end
        return "success"
    end
} )

local judgePenaltyKickMasterSkillTask = BT.Task.new( {
    name = "JudgePenaltyKickMasterSkillTask",
    run = function(self, athlete)
        local skill = athlete:getCooldownSkill(Skills.PenaltyKickMaster)

        if skill then
            athlete:castSkill(skill.class)
            athlete:addBuff(skill.buff, athlete)
        end
        return "success"
    end
} )

local judgeCornerKickMasterSkillTask = BT.Task.new( {
    name = "JudgeCornerKickMasterSkillTask",
    run = function(self, athlete)
        local skill = athlete:getCooldownSkill(Skills.CornerKickMaster)

        if skill then
            athlete:castSkill(skill.class)
            athlete:addBuff(skill.buff, athlete)
        end
        return "success"
    end
} )

local judgePlaceKickTalentTask = BT.Task.new( {
    name = "JudgePlaceKickTalentTask",
    run = function(self, athlete)
        local skill = athlete:getCooldownSkill(Skills.PlaceKickTalent)

        if skill then
            athlete:castSkill(skill.class)
            if athlete.match.frozenType == "WingDirectFreeKick" or athlete.match.frozenType == "CornerKick" then
                athlete:addBuff(skill.passBuff, athlete)
            else
                athlete:addBuff(skill.shootBuff, athlete)
            end
        end
        return "success"
    end
} )

local judgePopeyeSkillTask = BT.Task.new( {
    name = "JudgePopeyeSkillTask",
    run = function(self, athlete)
        local skill = athlete:getCooldownSkill(Skills.Popeye)

        if skill then
            athlete:castSkill(skill.class)
            athlete:addBuff(skill.buff, athlete)
        end
        return "success"
    end
} )

local blockTask = BT.Task.new( {
    name = "BlockTask",
    run = function(self, athlete, isRunning)
        if not isRunning and not athlete.shouldBlock then
            return "fail"
        end
        if athlete.shouldBlock then
            athlete.shouldBlock = nil
            athlete:predictMoveDefendOfBlock()
            athlete.blockEnemy = nil
        end

        return athlete:isAnimationEnd(athlete.match.nextTime) and "success" or "running"
    end
} )

local headingDuelTask = BT.Task.new( {
    name = "headingDuelTask",
    run = function(self, athlete, isRunning)
        if not isRunning and not athlete.shouldHeadingDual then
            return "success"
        end
        if athlete.shouldHeadingDual then
            athlete.shouldHeadingDual = nil
            athlete:selectHeadingDualAnimation()
            athlete.blockEnemy = nil
        end

        return athlete:isAnimationEnd(athlete.match.nextTime) and "success" or "running"
    end
} )

local staggerTask = BT.Task.new( {
    name = "StaggerTask",
    run = function(self, athlete, isRunning)
        if not isRunning and not athlete.shouldStagger then
            return "fail"
        end
        if athlete.shouldStagger then
            athlete:logInfo('Stagger: ' .. athlete.staggerAnimationName .. ', direction: ' .. tostring(athlete.staggerStartBodyDirection))
            athlete:pushAnimation(Animations.RawData[athlete.staggerAnimationName], nil, athlete.staggerStartBodyDirection)
            athlete.shouldStagger = nil
            athlete.staggerAnimationName = nil
            athlete.staggerStartBodyDirection = nil
        end

        return athlete:isAnimationEnd(athlete.match.nextTime) and "success" or "running"
    end
} )

local breakThroughDefendTask = BT.Task.new( {
    name = "BreakThroughDefendTask",
    run = function(self, athlete, isRunning)
        local btDefendInfo = athlete.breakThroughDefendInfo

        if not isRunning and not btDefendInfo then
            return "fail"
        end

        if math.cmpf(btDefendInfo.startTime, athlete.match.currentTime) == 0 and math.cmpf(btDefendInfo.delay, 0) > 0 then
            -- 处理被过动作的开始前的延迟
            athlete:breakThroughDefendStay(vector2.norm(btDefendInfo.targetAthlete.position - athlete.position), btDefendInfo.delay)
            return "running"
        elseif math.cmpf(athlete.match.currentTime, btDefendInfo.startTime + btDefendInfo.delay) < 0 then
            return "running"
        elseif math.cmpf(btDefendInfo.startTime + btDefendInfo.delay, athlete.match.currentTime) == 0 then
            -- 开始播放被过动作
            athlete:breakThroughDefend()
            return "running"
        end

        if athlete:isAnimationEnd(athlete.match.nextTime) then
            athlete.breakThroughDefendInfo = nil
            return "success"
        else
            return "running"
        end
    end
} )

local manualOperateCondition = BT.Condition.new( {
    name = "ManualOperateCondition",
    run = function(self, athlete)
        if not athlete.match.allowManualOperation then
            return "fail"
        end

        if 12 <= athlete.onfieldId then
            return "fail"
        end

        if math.cmpf(athlete.team.manualOperateRemainingCoolDown, 0) > 0 then
            return "fail"
        end

        local maxFrameInManualOperateAnimation = athlete.team.manualOperateEnterTimes < 1
            and AIUtils.firstTimeMaxFrameInManualOperateAnimation
            or AIUtils.maxFrameInManualOperateAnimation
        local manualOperateAreaType = athlete.team.manualOperateEnterTimes < 1 and "isInFirstEnterManualOperateArea" or "isInManualOperateArea"
        if not athlete.currentAnimation.isDribble or
            (maxFrameInManualOperateAnimation <= athlete.currentAnimation.animationInfo.totalFrame - athlete.currentAnimation.animationInfo.lastTouch) then
            return "fail"
        end
        if AIUtils.maxManualOperateTimes <= athlete.team.manualOperateTimes then
            return "fail"
        end
        if athlete.team.inManualOperating then
            if athlete.isManualFollowedDribble then
                return "fail"
            end

            athlete:calcManualOperate()
            return athlete:validOperationExist() and "success" or "fail"
        else
            local lastTouchPos = athlete.currentAnimation.startPosition +
                    vector2.vyrotate(Animations.getLastTouchPosition(athlete.currentAnimation.animationInfo), athlete.currentAnimation.startBodyDirection)
            if not Field[manualOperateAreaType](lastTouchPos, athlete.team:getSign()) then
                return "fail"
            end
            if Field.isInForceShootArea(athlete.position, athlete.team:getSign()) and athlete:isInNormalShootArea() then
                return "fail"
            end

            if athlete.inManualOperating or not athlete:hasBall() then
                return "fail"
            end

            athlete:calcManualOperate()
            return athlete:validOperationExist() and "success" or "fail"
        end
    end
} )

local followedDribbleCondition = BT.Condition.new( {
    name = "followedDribbleCondition",
    run = function(self, athlete)
        return athlete.isManualFollowedDribble and "success" or "fail"
    end
} )

local manualOperateTask = BT.Task.new( {
    name = "ManualOperateTask",
    run = function(self, athlete, isRunning)
        if not athlete.inManualOperating then
            athlete:outputManualOperateAction()
        end

        if athlete.inManualOperating and athlete.manualOperateType == -1 then
            athlete.manualOperateType = 0
            return "running"
        end

        athlete.team.manualOperateTriggerTimes = athlete.team.manualOperateTriggerTimes + 1
        if athlete.team.manualOperateTimes == 1 then
            athlete.team.manualOperateEnterTimes = athlete.team.manualOperateEnterTimes + 1
        end

        if athlete.team.manualOperateTriggerTimes == 1 then
            athlete.match.firstManualOperateTime = athlete.match.currentTime
        end
        return "success"
    end
} )

local manualDPSCondition = BT.Condition.new( {
    name = "ManualDPSCondition",
    run = function(self, athlete)
        local ret = (athlete.inManualOperating and athlete.manualOperateType ~= -1 and athlete.manualOperateType ~= 0) and
            "success" or "fail"
        athlete:logInfo('manualDPSCondition: ' .. ret)
        return ret
    end
} )

local isManualOperateSkillCondition = BT.Condition.new( {
    name = "ManualOperateSkillCondition",
    run = function(self, athlete)
        local ret = athlete.manualOperateSkillId and "success" or "fail"
        return ret
    end
} )

local notBallOutOfFieldCountDownCondition = BT.Condition.new( {
    name = "NotBallOutOfFieldCountDownCondition",
    run = function(self, athlete)
        return (not athlete.match.ballOutOfField) and "success" or "fail"
    end
} )

local selectOneSkillTask =
BT.Priority.new( { name = "SelectOneSkill", children = {
    BT.Sequence.new( { name = "HeavyGunner", children = {
        heavyGunnerCondition,
        heavyGunnerTask,
        selectHeavyGunnerAnimationTask,
        shootTask
    } } ),
    BT.Sequence.new( { name = "ThroughBall", children = {
        throughBallCondition,
        throughBallTask,
        doPassTask
    } } ),
    BT.Sequence.new( { name = "OverHeadBall", children = {
        overHeadBallCondition,
        overHeadBallTask,
        doPassTask
    } } ),
    BT.Sequence.new( { name = "CrossLow", children = {
        crossLowCondition,
        crossLowTask,
        doPassTask
    } } ),
    BT.Sequence.new( { name = "Diving", children = {
        divingCondition,
        selectDivingActionTask,
        stealAndFoulJudgeTask,
        judgeDivingForceFoulTask,
        doDribbleTask,
    } } ),
    BT.Sequence.new( { name = "BreakThrough", children = {
        breakThroughCondition,
        calculateBreakThroughDPSTask,
        DPSChooseTask,
        gamesmanshipJudgeTask,
        startDribbleTask,
        stealAndFoulJudgeTask,
        calculateBreakThroughDefendInfoTask,
        breakThroughSuccessBuffAddingTask,
        doDribbleTask,
    } } ),
    BT.Sequence.new( { name = "Metronome", children = {
        metronomeCondition,
        metronomeSkillTask,
        DPSChooseTask,
        gamesmanshipJudgeTask,
        startDribbleTask,
        doDribbleTask,
    } } ),
} } )

local executeDPSTask =
BT.Priority.new( { name = "ExecuteDPSTask", children = {
    BT.Sequence.new( { name = "Dribble", children = {
        dribbleCondition,
        gamesmanshipJudgeTask,
        startDribbleTask,
        stealAndFoulJudgeTask,
        calculateBreakThroughDefendInfoTask,
        doDribbleTask,
    } } ),
    BT.Sequence.new( { name = "Pass", children = {
        passCondition,
        selectPassAnimationTask,
        startPassTask,
        doPassTask
    } } ),
    BT.Sequence.new( { name = "Shoot", children = {
        shootCondition,
        calmShootJudgeTask,
        selectNormalShootAnimationTask,
        shootTask
    } } ),
} } )

local autoDPSDecision =
BT.Sequence.new( { name = "AutoDPSDecision", children = {
    BT.Priority.new( { name = "ActDPSDecision", children = {
        BT.Sequence.new( { name = "WithBallSkills", children = {
            judgeWithBallSkillTask,
            selectOneSkillTask,
            clearWithBallSkillTask,
        } } ),
        BT.Sequence.new( { name = "NormalDPSDecision", children = {
            BT.Sequence.new( { name = "NormalDPSCalculation", children = {
                calculateDribbleTask,
                calculatePassTask,
                calculateShootTask,
            } } ),
            DPSChooseTask,
            DPSAdjustTask,
            executeDPSTask,
        } } ),
    } } ),
} } )

local AttackBehavior =
BT.Sequence.new( { name = "Attack", children = {
    attackCondition,
    BT.Priority.new( { name = "AttackActionSelect", children = {
        BT.Sequence.new( { name = "HasBall", children = {
            notBallOutOfFieldCountDownCondition,
            hasBallCondition,
            BT.Priority.new( { name = "HasBallSelection", children = {
                BT.Sequence.new( { name = "PostSavePass", children = {
                    postSavePassCondition,
                    judgeSoulFluctuationTask,
                    BT.Priority.new( { name = "PostSavePassSelection", children = {
                        BT.Sequence.new ( { name = "PuntKick", children = {
                            puntKickSkillCondition,
                            puntKickTask,
                        } } ),
                        BT.Sequence.new ( { name = "PostSavePass", children = {
                            gkStayWithBallTask,
                            postSavePassTask,
                        } } ),
                    } } ),
                    doPassTask,
                } } ),
                BT.Sequence.new( { name = "GoalKick", children = {
                    goalKickCondition,
                    BT.Priority.new( { name = "GoalKickSelection", children = {
                        BT.Sequence.new ( { name = "PuntKick", children = {
                            puntKickSkillCondition,
                            puntKickTask,
                        } } ),
                        goalKickTask,
                    } } ),
                    doPassTask,
                } } ),
                BT.Sequence.new( { name = "IndirectFreeKick", children = {
                    indirectFreeKickCondition,
                    BT.Priority.new( { name = "GoalKickSelection", children = {
                        BT.Sequence.new ( { name = "PuntKick", children = {
                            isGkCondition,
                            puntKickSkillCondition,
                            puntKickTask,
                        } } ),
                        indirectFreeKickTask,
                    } } ),
                    doPassTask,
                } } ),
                BT.Sequence.new( { name = "CenterDirectFreeKick", children = {
                    centerDirectFreeKickCondition,
                    centerDirectFreeKickPrepareTask,
                    judgePlaceKickTalentTask,
                    judgeOrganizeWallTask,
                    judgeFreeKickMasterSkillTask,
                    shootTask,
                } } ),
                BT.Sequence.new( { name = "WingDirectFreeKick", children = {
                    wingDirectFreeKickCondition,
                    judgeFreeKickMasterSkillTask,
                    wingDirectFreeKickDecisionTask,
                    judgePlaceKickTalentTask,
                    wingDirectFreeKickTask,
                    doPassTask,
                } } ),
                BT.Sequence.new( { name = "ThrowIn", children = {
                    throwInCondition,
                    judgePopeyeSkillTask,
                    throwInTask,
                    doPassTask,
                } } ),
                BT.Sequence.new( { name = "PreKickOff", children = {
                    preKickOffCondition,
                    preKickOffTask,
                } } ),
                BT.Sequence.new( { name = "KickOff", children = {
                    kickOffCondition,
                    kickOffTask,
                    doPassTask,
                } } ),
                BT.Sequence.new( { name = "KickOffPass2", children = {
                    kickOffPass2Condition,
                    kickOffPass2Task,
                    doPassTask,
                } } ),
                BT.Sequence.new( { name = "CornerKick", children = {
                    cornerKickCondition,
                    judgeCornerKickMasterSkillTask,
                    cornerKickDecisionTask,
                    judgePlaceKickTalentTask,
                    cornerKickTask,
                    doPassTask,
                } } ),
                BT.Sequence.new( { name = "PenaltyKick", children = {
                    penaltyKickCondition,
                    penaltyKickPrepareTask,
                    judgePlaceKickTalentTask,
                    judgePenaltyKickKillerTask,
                    judgePenaltyKickMasterSkillTask,
                    shootTask,
                } } ),
                BT.Priority.new( { name = "DPSDecision", children = {
                    BT.Priority.new( { name = "ManualOperateDecision", children = {
                        BT.Sequence.new( { name = "ManualOperate", children = {
                            manualOperateCondition,
                            manualOperateTask,
                            BT.Priority.new( { name = "ManualDPSSelect", children = {
                                BT.Sequence.new( { name = "ManualDPS", children = {
                                    manualDPSCondition,
                                    BT.Priority.new( { name = "ManualOperateExecute", children = {
                                        BT.Sequence.new( { name = "ManualOperateSkill", children = {
                                            isManualOperateSkillCondition,
                                            selectOneSkillTask,
                                        } } ),
                                    executeDPSTask,
                                    } } )
                                } } ),
                                autoDPSDecision,
                            } } )
                        } } ),
                        BT.Sequence.new( { name = "FollowedDribble", children = {
                            followedDribbleCondition,
                            notBallOutOfFieldCountDownCondition,
                            executeDPSTask,
                        } } ),
                    } } ),
                    autoDPSDecision,
                } } ),
            } } ),
        } } ), -- End of HasBall
        BT.Sequence.new( { name = "MoveTo", children = {
            ballNextTaskCondition,
            BT.Priority.new( { name = "BallPassBegin", children = {
                BT.Sequence.new( {name = "BallPass", children = {
                    ballPassCondition, ballPassMoveToTimeCondition
                } } ),
                BT.Sequence.new( {name = "BallPassAndIntercept", children = {
                    ballPassInterceptCondition, ballInterceptMoveToTimeCondition
                } } ),
            } } ),
            ballPassReceiverCondition, catchMoveToTask, notBallOutOfFieldCountDownCondition, headingDuelTask
        } } ),
        BT.Sequence.new( { name = "Catch", children = {
            notBallOutOfFieldCountDownCondition,
            ballNextTaskCondition,
            ballPassCondition,
            ballPassReceiverCondition,
            judgeHighQualityGkPassTask,
            judgeCatenaccioTask,
            selectCatchAnimationTask,
            BT.Priority.new( { name = "CatchActionSelect", children = {
                BT.Sequence.new( { name = "VolleyShoot", children = {
                    volleyShootCondition,
                    addVolleyShootBuffTask,
                    catchAndShootTask,
                    shootTask
                } } ),
                BT.Sequence.new( { name = "PowerfulHeader", children = {
                    powerfulHeaderCondition,
                    addPowerfulHeaderBuffTask,
                    catchAndShootTask,
                    shootTask
                } } ),
                BT.Sequence.new( { name = "NormalCatchShoot", children = {
                    normalCatchShootCondition,
                    catchAndShootTask,
                    foxInTheBoxJudgeTask,
                    shootTask
                } } ),
                BT.Sequence.new( { name = "CatchPass", children = {
                    catchPassCondition,
                    judgeCatchCrossLowTask,
                    catchPassTask,
                    doPassTask,
                } } ),
                ballCatchTask,
            } } ),
        } } ), -- End of Catch
        BT.Sequence.new( { name = "MoveAttack", children = {
            moveAttackDecideTask,
        } } )
    } } ),
} } ) -- End of AttackBehavior

local DefendBehavior =
BT.Sequence.new( { name = "Defend", children = {
    defendCondition,
    BT.Priority.new( { name = "DefendActionSelect", children = {
        BT.Sequence.new ( { name = "BallNextTask", children = {
            ballNextTaskCondition,
            BT.Priority.new( { name = "BallNextTaskSelect", children = {
                BT.Priority.new( { name = "DefendMoveToSelect", children = {
                    BT.Sequence.new ( { name = "InterceptMoveTo", children = {
                        ballInterceptorCondition,
                        ballInterceptMoveToTimeCondition,
                        interceptMoveToTask,
                    } } ),
                    BT.Sequence.new ( { name = "SaveMoveTo", children = {
                        ballSaverCondition,
                        ballSaveMoveToAnimationCondition,
                        saveMoveToTask,
                    } } ),
                } } ),
                BT.Sequence.new ( { name = "Intercept", children = {
                    ballInterceptorCondition,
                    interceptTask,
                    selectCatchAnimationTask,
                    BT.Priority.new( { name = "CatchActionSelect", children = {
                        BT.Sequence.new( { name = "CatchPass", children = {
                            isNonGkCondition,
                            catchPassCondition,
                            catchInterceptPassTask,
                            doPassTask,
                        } } ),
                        ballCatchTask,
                    } } ),
                } } ),
                BT.Sequence.new ( { name = "Save", children = {
                    ballSaverCondition,
                    saveTask,
                } } ),
                BT.Sequence.new ( { name = "Steal", children = {
                    ballStealCondition,
                    stealTask,
                } } ),
                BT.Sequence.new ( { name = "Foul", children = {
                    foulCondition,
                    foulTask,
                } } ),
            } } ),
        } } ),
        blockTask,
        staggerTask,
        breakThroughDefendTask,
        BT.Priority.new( { name = "MoveDefend", children = {
            frozenDefendTask,
            BT.Sequence.new ( { name = "GkMoveDefendSelection", children = {
                isGkCondition,
                gkMoveDefendDecideTask
            } } ),
            nonGkMoveDefendDecideTask,
        } } ),
    } } ),
} } ) -- End of DefendBehavior

Behavior = BT.new( { tree = BT.Sequence.new( { name = "Athlete", children = {
    BT.AlwaysSuccessDecorator.new( { name = "EntryModifierWrapper", child =
        BT.Sequence.new( { name = "EntryModifier", children = {
            entryModifierExecutionCondition,
            enterFieldTask,
        } } ),
    } ),
    BT.Priority.new( { name = "Main", children = {
        AttackBehavior,
        DefendBehavior,
    } } ),
} } ) } )

return Behavior

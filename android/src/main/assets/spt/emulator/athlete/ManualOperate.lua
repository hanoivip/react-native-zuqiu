local Athlete = import("./Core")
local Actions = import("../actions/Actions")
local Animations = import("../animations/Animations")
local vector2 = import("../libs/vector")
local selector = import("../libs/selector")
local AIUtils = import("../AIUtils")
local Field = import("../Field")
local Skills = import("../skills/Skills")

local BORDER_ANGLE_MIN = -math.pi / 2
local BORDER_ANGLE_MAX = math.pi * 3 / 2
local DEFENDER_ANGLE = math.pi / 6
local ENABLED_MIN_ANGLE_RANGE = math.pi / 12 --如果两个可用区域的间隔角度小于15，画面上摆个箭头会挨着防守人
local BREAK_THROUGH_ANGLE_RANGE = math.pi / 2

local MAX_DRIBBLE_COUNT = 2
local MAX_PASS_COUNT = 3
local MIN_DRIBBLE_COUNT = 1
local MIN_PASS_COUNT = 1

function Athlete:calcManualOperate()
    if self.outputActionStatus ~= nil then
        return --TODO 没必要？
    end

    local dribbleList = {}
    local passList = {}
    self:calcManualOperateSkillOptions(dribbleList, passList)
    self:selectDribbleAnimations(dribbleList)
    self:selectManualPassList(passList)

    local manualOperateAction = Actions.ManualOperate.new()
    manualOperateAction.dribbleList = dribbleList
    manualOperateAction.passList = passList
    manualOperateAction.shootEnabledSkillId = self.manualOperateShootEnabledSkillId
    if self.manualOperateShootEnabledSkillId then
        manualOperateAction.isShootEnabled = true
    else
        manualOperateAction.isShootEnabled = self:isInNormalShootArea()
    end
    manualOperateAction.manualOperateTimes = self.team.manualOperateTimes + 1
    self.manualOperateAction = manualOperateAction
    self.manualPassList = passList
    self.manualDribbleList = dribbleList
end

function Athlete:getRankedCandidateManualOperateDribbleSelections()
    local originalDistanceToBottomLine = self:calcAttackDistance(self.position)

    local isPreferCutting = self:getIsPreferCutting()
    local isPreferToCorner = self:getIsPreferToCorner()

    local rankedCandidateManualOperateDribbleSelections = { }
    for _, animation in ipairs(Animations.Tag.ManualOperateDribble) do
        local wrappedAnimation = {animation = animation}
        local targetPosition = self.position + vector2.vyrotate(self:getAnimationTargetPosition(animation), self.bodyDirection)
        local candidateManualOperateDribbleSelection = {
            animation = animation,
            targetPosition = targetPosition,
            score = self:calculateDribbleScore(wrappedAnimation, targetPosition, originalDistanceToBottomLine, isPreferCutting, isPreferToCorner)
        }

        if math.cmpf(candidateManualOperateDribbleSelection.score, 0) > 0 then
            if #rankedCandidateManualOperateDribbleSelections == 0 then
                table.insert(rankedCandidateManualOperateDribbleSelections, candidateManualOperateDribbleSelection)
            else
                for j, existedCandidateManualOperateDribbleSelection in ipairs(rankedCandidateManualOperateDribbleSelections) do
                    if math.cmpf(candidateManualOperateDribbleSelection.score, existedCandidateManualOperateDribbleSelection.score) > 0 then
                        table.insert(rankedCandidateManualOperateDribbleSelections, j, candidateManualOperateDribbleSelection)
                        break
                    elseif j == #rankedCandidateManualOperateDribbleSelections then
                        table.insert(rankedCandidateManualOperateDribbleSelections, candidateManualOperateDribbleSelection)
                        break
                    end
                end
            end
        end
    end

    return rankedCandidateManualOperateDribbleSelections
end

--普通带球动作的夹角和过人动作的夹角应该超过45度
function Athlete:selectDribbleAnimations(dribbleList)
    -- 选出在持球人正面，并且在3m范围内的防守人
    -- 以自己为起点，防守人为终点，这条线左右15度范围内为不可带球区域
    -- 遍历Cross带球动作，将其加入到某个可以带球区域
    -- 随机挑选两个有动作的可带球区域
    -- 从可带球区域中随机挑选一个带球动作

    local rankedCandidateManualOperateDribbleSelections = self:getRankedCandidateManualOperateDribbleSelections()

    for i, candidateDribbleSelection in ipairs(rankedCandidateManualOperateDribbleSelections) do
        local isLegal = true
        local dribbleDirection = candidateDribbleSelection.targetPosition - self.position
        for j, existedDribbleSelection in ipairs(dribbleList) do
            local existedDribbleDirection = existedDribbleSelection.targetPosition - self.position
            if math.cmpf(vector2.angle(dribbleDirection, existedDribbleDirection), math.pi / 3) < 0 then
                isLegal = false
                break
            end
        end

        if isLegal then
            table.insert(
                dribbleList,
                {
                    index = #dribbleList + 1,
                    animation = candidateDribbleSelection.animation,
                    targetPosition = candidateDribbleSelection.targetPosition,
                    successProbability = self:calcDribbleSuccessProbability(candidateDribbleSelection.animation)
                }
            )
        end

        if #dribbleList >= MAX_DRIBBLE_COUNT then
            break
        end
    end
end

function Athlete:clearManualOperate()
    self.inManualOperating = nil
    self.manualDribbleList = nil
    self.manualPassList = nil
    self.manualOperateType = -1
    self.isManualFollowedDribble = nil
    self.manualOperateSkillId = nil
    self.manualOperateSuccessProbability = nil
    self.manualOperateShootEnabledSkillId = nil

    if self.team.inManualOperating and AIUtils.maxManualOperateTimes <= self.team.manualOperateTimes then
        --这里不能调用team:clearManualOperate清除调用team的manual operate状态，否则3次计数就失效了
        self.team.outputIsManualOperateEnded = true
        self.team.inManualOperating = nil

        self.team.manualOperateRemainingCoolDown = AIUtils.manualOperateCoolDown
    end
end

local function isPassAthleteExist(passList, athleteOnfieldId)
    for _, passTarget in ipairs(passList) do
        if passTarget.onfieldId == athleteOnfieldId then
            return true
        end
    end
    return false
end

function Athlete:selectManualPassList(passList)
    local tempPassList = {}
    for onfieldId, athlete in ipairs(self.team.athletes) do
        --TODO onfieldId
        if onfieldId ~= self.onfieldId and not isPassAthleteExist(passList, onfieldId) then
            local passTarget = self:selectBestPassTargetForOneAthlete(athlete)
            local passAnimationType = self:getPassAnimationTypeCore(passTarget.targetPosition, passTarget.type, true)

            if 0 < passTarget.score and self:hasAppropriatePassAnimationCore(passTarget.targetPosition, passAnimationType) then
                passTarget.onfieldId = onfieldId
                passTarget.passAnimationType = passAnimationType
                table.insert(tempPassList, passTarget)
            end
        end
    end

    local selectedPass = selector.maxn(tempPassList, MAX_PASS_COUNT - #passList, function(t) return t.score end)

    for _, passTarget in ipairs(selectedPass) do
        local animation = self:selectPassAnimationByTargetPosition(passTarget.passAnimationType, passTarget.targetPosition)
        local passSuccessProbability = self:calcPassSuccessProbability(self.team.athletes[passTarget.onfieldId], passTarget.targetPosition, passTarget.type, animation)
        table.insert(
            passList,
            {
                onfieldId = passTarget.onfieldId,
                targetPosition = passTarget.targetPosition,
                successProbability = passSuccessProbability,
                animation = animation,
                type = passTarget.type,
                isLeadPass = passTarget.isLeadPass,
                isCrossLow = passTarget.isCrossLow,
            })
    end
end

function Athlete:validOperationExist()
    if self.manualOperateAction == nil then
        return false
    end

    if self.manualOperateAction.dribbleList and MIN_DRIBBLE_COUNT <= #self.manualOperateAction.dribbleList and
        self.manualOperateAction.passList and MIN_PASS_COUNT <= #self.manualOperateAction.passList then
        return true
    end

    return false
end

function Athlete:outputManualOperateAction()
    self.outputActionStatus = self.manualOperateAction
    self.inManualOperating = true
    self.manualOperateType = -1
    self.team.inManualOperating = true
    self.team.manualOperateTimes = self.team.manualOperateTimes + 1

    self.manualOperateAction = nil
end

function Athlete:calcManualOperateSkillOptions(dribbleList, passList)
    local skillId = self:judgeWithBallSkill(true)

    if skillId then
        self:calcManualOperateDribbleSkill(skillId, dribbleList)
        self:calcManualOperateShootSkill(skillId)
        self:calcManualOperatePassSkill(skillId, passList)
    end
end

function Athlete:calcManualOperateShootSkill(skillId)
    if AIUtils.isSkillIdCorrespondSkill(skillId, Skills.HeavyGunner) then
        self.manualOperateShootEnabledSkillId = skillId
    end
end

function Athlete:calcManualOperateDribbleSkill(skillId, dribbleList)
    local candidateAnimation = nil
    if AIUtils.isSkillIdCorrespondSkill(skillId, Skills.BreakThrough) then
        candidateAnimation = selector.randomSelect(self.candidateBreakThroughAnimations)
        self.candidateBreakThroughAnimations = {candidateAnimation}
    elseif AIUtils.isSkillIdCorrespondSkill(skillId, Skills.Diving) then
        local animationInfo = selector.randomSelect(Animations.Tag.RapidDribble)
        self.candidateDivingAnimations = {animationInfo}
        candidateAnimation = {animation = animationInfo}
    elseif AIUtils.isSkillIdCorrespondSkill(skillId, Skills.Metronome) then
        local candidateMetronomeAnimations = self:getCandidateMetronomeAnimations()
        local animationInfo = selector.randomSelect(candidateMetronomeAnimations)
        self.candidateMetronomeAnimations = {animationInfo}
        candidateAnimation = {animation = animationInfo}
    end

    if candidateAnimation then
        local targetPosition = self.position + vector2.vyrotate(self:getAnimationTargetPosition(candidateAnimation.animation), self.bodyDirection)
        table.insert(
            dribbleList,
            {
                index = 1,
                animation = candidateAnimation,
                targetPosition = targetPosition,
                successProbability = self:calcDribbleSuccessProbability(candidateAnimation.animation, skillId),
                skillId = skillId
            }
        )
    end
end

function Athlete:calcManualOperatePassSkill(skillId, passList)
    local manualOperationActions
    local candidateSkillName

    if AIUtils.isSkillIdCorrespondSkill(skillId, Skills.ThroughBall) then
        manualOperationActions = self:getManualOperationThroughBallActions()
    elseif AIUtils.isSkillIdCorrespondSkill(skillId, Skills.OverHeadBall) then
        manualOperationActions = self:getManualOperationOverHeadBallActions()
    elseif AIUtils.isSkillIdCorrespondSkill(skillId, Skills.CrossLow) then
        manualOperationActions = self:getManualOperationCrossLowActions()
    else
        return
    end

    for _, passAction in ipairs(manualOperationActions) do
        local targetAthlete = passAction.targetAthlete
        local targetPosition = passAction.targetPosition
        local passType = passAction.type
        local isLeadPass = passAction.isLeadPass

        local passAnimationType = nil
        if AIUtils.isSkillIdCorrespondSkill(skillId, Skills.CrossLow) then
            passAnimationType = "CrossPass"
        else
            passAnimationType = self:getPassAnimationTypeCore(targetPosition, passType, true)
        end

        local animation = self:selectPassAnimationByTargetPosition(passAnimationType, targetPosition)
        local passSuccessProbability = self:calcPassSuccessProbability(targetAthlete, targetPosition, passType, animation, skillId)

        table.insert(
            passList,
            {
                onfieldId = targetAthlete.onfieldId,
                targetPosition = targetPosition,
                successProbability = passSuccessProbability,
                animation = animation,
                type = passType,
                isLeadPass = isLeadPass,
                skillId = skillId,
                isCrossLow = passAction.isCrossLow
            }
        )
    end
end

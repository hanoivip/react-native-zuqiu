local EnumType = require("coregame.EnumType")
local ActionType = EnumType.ActionType
local ManualOperateType = EnumType.ManualOperateType
local ActionLayerConfig = require("coregame.actionlayer.ActionLayerConfig")
local ActionLayerUtils = require("coregame.actionlayer.ActionLayerUtils")

local HeadIKHandler = class()

local StareCatcherTimeBeforePass = 0.8
local PeekBallTimeBeforePass = 0.3
local PeekBallTimeBeforeNPOPass = 0.5

local PeekGateTimeBeforeShoot = 0.8
local PeekBallTimeBeforeShoot = 0.5
local PeekBallTimeBeforeNPOShoot = 0.7

local PeekGateOrPlayerTimeBeforeCatch = 0.9
local PeekBallTimeBeforeCatch = 0.5

local PeekGateDefaultDuration = 0.3
local PeekBallDefaultDuration = 0.3
local PeekPlayerDefaultDuration = 0.3
local EndIKDuration = 0.1
local PeekPlayerManualOperateDuration = 0.5

local DisableIKDurationBeforeShoot = 0.2

local TargetId = {
    Default = -1,
    Ball = 8000,
    Gate = 200,
    LeftShoulder = 100,
    RightShoulder = 101
}

local IKType = {
    None = -1,
    EndIK = 0,
    StareBall = 1,
    PeekPlayer = 2,
    PeekGate = 3,
    PeekBall = 4
}

local IKAction = {
    PeekPlayer = {
        [1] = {
            ikType = IKType.PeekPlayer,
            startWeight = 0,
            targetWeight = 1,
            bodyWeight = 0.2,
            headWeight = 1,
            eyesWeight = 0,
            clampWeight = 0.5,
            targetId = TargetId.Default,
            duration = 0.2,
            lookSmoother = 8
        },
        [2] = {
            ikType = IKType.PeekPlayer,
            startWeight = 1,
            targetWeight = 0,
            bodyWeight = 0.2,
            headWeight = 1,
            eyesWeight = 0,
            clampWeight = 0.5,
            targetId = TargetId.Default,
            duration = EndIKDuration,
            lookSmoother = 8
        }
    },
    PeekGate = {
        [1] = {
            ikType = IKType.PeekGate,
            startWeight = 0,
            targetWeight = 1,
            bodyWeight = 0.2,
            headWeight = 1,
            eyesWeight = 0,
            clampWeight = 0.5,
            targetId = TargetId.Gate,
            duration = 0.2,
            lookSmoother = 8
        },
        [2] = {
            ikType = IKType.PeekGate,
            startWeight = 1,
            targetWeight = 0,
            bodyWeight = 0.2,
            headWeight = 1,
            eyesWeight = 0,
            clampWeight = 0.5,
            targetId = TargetId.Gate,
            duration = EndIKDuration,
            lookSmoother = 8 
        }
    },
    PeekBall = {
        [1] = {
            ikType = IKType.PeekBall,
            startWeight = 0,
            targetWeight = 1,
            bodyWeight = 0.2,
            headWeight = 1,
            eyesWeight = 0,
            clampWeight = 0.5,
            targetId = TargetId.Ball,
            duration = 0.2,
            lookSmoother = 8
        },
        [2] = {
            ikType = IKType.PeekBall,
            startWeight = 1,
            targetWeight = 0,
            bodyWeight = 0.2,
            headWeight = 1,
            eyesWeight = 0,
            clampWeight = 0.5,
            targetId = TargetId.Ball,
            duration = EndIKDuration,
            lookSmoother = 8
        }
    },
    StareBall = {
        [1] = {
            ikType = IKType.StareBall,
            startWeight = 0,
            targetWeight = 1,
            bodyWeight = 0.1,
            headWeight = 1,
            eyesWeight = 0,
            clampWeight = 0.5,
            targetId = TargetId.Ball,
            duration = 1024,
            lookSmoother = 5
        }
    },
    EndIK = {
        [1] = {
            ikType = IKType.EndIK,
            startWeight = 1,
            targetWeight = 0,
            bodyWeight = 0.2,
            headWeight = 1,
            eyesWeight = 0,
            clampWeight = 0.5,
            targetId = TargetId.Default,
            duration = EndIKDuration,
            lookSmoother = 10
        }
    }
}

local Zone = {
    Forward_Center = 0,
    Forward_Left = 1,
    Forward_Right = 2,
    Middle_Center = 3,
    Middle_Left = 4,
    Middle_Right = 5,
    Back_Center = 6,
    Back_Left = 7,
    Back_Right = 8
}

local function isNorthFormation(playerId)
    if ___upperBodyUtil.isPlayerAttackingNorth == true then
        if playerId >= 0 and playerId <= 10 then
            return true
        else
            return false
        end
    elseif ___upperBodyUtil.isPlayerAttackingNorth == false then
        if playerId >= 0 and playerId <= 10 then
            return false
        else
            return true
        end
    else
        return nil
    end
end

local function checkZone(playerId, playerPositionX, playerPositionZ)
    local isNorth = isNorthFormation(playerId)
    if isNorth == true then
        if playerPositionZ >= 25 then
            if playerPositionX <= -15 then
                return Zone.Forward_Left
            elseif playerPositionX < 15 then
                return Zone.Forward_Center
            else
                return Zone.Forward_Right
            end
        elseif playerPositionZ > -25 then
            if playerPositionX <= -15 then
                return Zone.Middle_Left
            elseif playerPositionX < 15 then
                return Zone.Middle_Center
            else
                return Zone.Middle_Right
            end
        else
            if playerPositionX <= -15 then
                return Zone.Back_Left
            elseif playerPositionX < 15 then
                return Zone.Back_Center
            else
                return Zone.Back_Right
            end
        end
    elseif isNorth == false then
        if playerPositionZ >= 25 then
            if playerPositionX <= -15 then
                return Zone.Back_Right
            elseif playerPositionX < 15 then
                return Zone.Back_Center
            else
                return Zone.Back_Left
            end
        elseif playerPositionZ > -25 then
            if playerPositionX <= -15 then
                return Zone.Middle_Right
            elseif playerPositionX < 15 then
                return Zone.Middle_Center
            else
                return Zone.Middle_Left
            end
        else
            if playerPositionX <= -15 then
                return Zone.Forward_Right
            elseif playerPositionX < 15 then
                return Zone.Forward_Center
            else
                return Zone.Forward_Left
            end
        end
    else
        return nil
    end 
end

--look up name hash in: \Assets\CapstonesRes\Game\Config\AnimationClipListHolder.asset
local function isDribbleForward(nameHash)
    return nameHash == 1791194381 --B_D006
        or nameHash == -1315523910 --B_D020
        or nameHash == 279622833 --B_D025_1
        or nameHash == 317459176 --B_D026_1
        or nameHash == 804398873 --B_D027
        or nameHash == 321806559 --B_D027_1
        or nameHash == -1977142939 --B_D027_2
        or nameHash == -48233997 --B_D027_3
        or nameHash == 1665438800 --B_D027_4
        or nameHash == 339977414 --B_D027_5
        or nameHash == -1924467332 --B_D027_6
        or nameHash == -1085457784 --B_D028        
        or nameHash == -934671842 --B_D029
        or nameHash == 410134498 --B_D028_1
        or nameHash == 430984661 --B_D029_1
        or nameHash == 246394889 --B_D046
        or nameHash == 2041086111 --B_D047
        or nameHash == -384328434 --B_D048
        or nameHash == -1643074152 --B_D049
        or nameHash == -19454851 --B_D050
        or nameHash == -2029282087 --B_D059
        or nameHash == -705005634 --B_D060
end

function HeadIKHandler:AddIKAction(playerId, template, startTime, targetId, startWeight, duration)
    local ikAction = {}
    ikAction.startWeight = startWeight or template.startWeight
    ikAction.targetWeight = template.targetWeight
    ikAction.bodyWeight = template.bodyWeight
    ikAction.headWeight = template.headWeight
    ikAction.eyesWeight = template.eyesWeight
    ikAction.clampWeight = template.clampWeight
    ikAction.targetId = targetId or template.targetId
    ikAction.startTime = startTime
    ikAction.duration = duration or template.duration
    ikAction.lookSmoother = template.lookSmoother
    ikAction.ikType = template.ikType

    self.ikEndTime[playerId] = ikAction.startTime + ikAction.duration
    self.currentIKType[playerId] = ikAction.ikType
    self.currentTarget[playerId] = ikAction.targetId

    GameHubWrap.AddIKAction(playerId, ikAction)
end

function HeadIKHandler:ClearAllAndAddIKAction(playerId, template, startTime, targetId, duration)
    targetId = targetId or template.targetId
    duration = duration or template.duration
    if startTime >= self.ikEndTime[playerId] then
        self:AddIKAction(playerId, template, startTime, targetId, nil, duration)
    else
        local currentIKAction = GameHubWrap.GetCurrentIKAction(playerId)
        GameHubWrap.ClearAllIKActions(playerId)
        if currentIKAction.targetId ~= targetId then
            self:AddIKAction(playerId, IKAction.EndIK[1], startTime, currentIKAction.targetId, currentIKAction.weight, nil)
            startTime = startTime + IKAction.EndIK[1].duration
            self:AddIKAction(playerId, template, startTime, targetId, nil, duration - IKAction.EndIK[1].duration)
        else
            self:AddIKAction(playerId, template, startTime, targetId, currentIKAction.weight, duration)
        end
    end
end

function HeadIKHandler:EndIK(playerId)
    local hasCurrentIKAction = GameHubWrap.HasCurrentIKAction(playerId)
    if hasCurrentIKAction == true then
        local currentIKAction = GameHubWrap.GetCurrentIKAction(playerId)
        local startTime = TimeLineWrap.TLTime()
        GameHubWrap.ClearAllIKActions(playerId)
        self:AddIKAction(playerId, IKAction.EndIK[1], startTime, currentIKAction.targetId, currentIKAction.weight, nil)
    end
end

function HeadIKHandler:AddTwoStepIK(ikModel, playerId, startTime, targetId, duration)
    local stepOneDuration = nil
    if duration then
        stepOneDuration = duration - EndIKDuration
    else
        stepOneDuration = ikModel[1].duration
    end
    if startTime then
        local currentTime = TimeLineWrap.TLTime()
        if startTime < currentTime then
            if startTime + stepOneDuration <= currentTime then
                return
            else
                local offset = startTime - currentTime
                stepOneDuration = stepOneDuration + offset
                startTime = currentTime
            end
        end
    else
        startTime = TimeLineWrap.TLTime()
    end
    self:ClearAllAndAddIKAction(playerId, ikModel[1], startTime, targetId, stepOneDuration)
    startTime = startTime + stepOneDuration

    self:AddIKAction(playerId, ikModel[2], startTime, targetId, nil, EndIKDuration)
    return startTime + EndIKDuration
end

function HeadIKHandler:StareBall(playerId, startTime)
    self:ClearAllAndAddIKAction(playerId, IKAction.StareBall[1], startTime, nil, nil)
end

function HeadIKHandler:PeekPlayer(playerId, targetId, startTime, duration)
    return self:AddTwoStepIK(IKAction.PeekPlayer, playerId, startTime, targetId, duration)
end

function HeadIKHandler:PeekBall(playerId, startTime, duration)
    return self:AddTwoStepIK(IKAction.PeekBall, playerId, startTime, nil, duration)
end

function HeadIKHandler:PeekGate(playerId, startTime, duration)
    return self:AddTwoStepIK(IKAction.PeekGate, playerId, startTime, nil, duration)
end

function HeadIKHandler:Start()
    self.lastPeekBallTime = 0.0
    self.lastDribbleForwardTime = 0
    self.ikEndTime = {}
    self.currentIKType = {}
    self.currentTarget = {}
    for i = 0, 21 do
        self.ikEndTime[i] = 0
        self.currentIKType[i] = IKType.None
        self.currentTarget[i] = nil
    end
    self.manualOperatePasser = -1
    self.manualOperatePasserInPlayback = {}
end

function HeadIKHandler:Destroy()
    self.ikEndTime = nil
    self.currentIKType = nil
end

function HeadIKHandler:OnNewActionStart(playerId, action)
    if action.isStartOnNormalPlayOn == true then

        self.ikEndTime[playerId] = action.actionStartFrame.time
        self.currentIKType[playerId] = IKType.None
        self.currentTarget[playerId] = nil

        if action.isWithBallAction ~= true then
            self:StareBall(playerId, self.ikEndTime[playerId])
        else
            local actionType = action.athleteAction.athleteActionType
            if actionType == ActionType.Pass then
                self:OnNPOPassStart(playerId, action)
            elseif actionType == ActionType.Shoot then
                self:OnNPOShootStart(playerId, action)
            end
        end
    else
        local actionType = action.athleteAction.athleteActionType
        if action.isWithBallAction == true then
            if actionType == ActionType.Dribble then
                self:OnDribbleStart(playerId, action)
            elseif actionType == ActionType.Catch then
                self:OnCatchStart(playerId, action)
            elseif actionType == ActionType.Pass then
                self:OnPassStart(playerId, action)
            elseif actionType == ActionType.Shoot then
                self:OnShootStart(playerId, action)
            elseif actionType == ActionType.Save then
                self:OnSaveStart(playerId, action)
            end
        else -- 无球球员
            if actionType == ActionType.None or actionType == ActionType.Move then
                if playerId == ___upperBodyUtil.currentCatcher then -- 球员为当前接球人，执行接球IK
                    self:PrepareToCatch(playerId, action)
                else
                    if self.currentIKType[playerId] ~= IKType.StareBall then -- 球员不是当前接球人，且没有在看球，则使其看球
                        self:StareBall(playerId, self.ikEndTime[playerId])
                    end
                end
            end
        end
    end
end

function HeadIKHandler:OnFirstTouchBall(playerId, action)
    local actionType = action.athleteAction.athleteActionType
    if actionType == ActionType.Catch then
        self:OnCatchFTB(playerId, action)
    elseif actionType == ActionType.Steal then
        self:OnStealFTB(playerId, action)
    elseif actionType == ActionType.Intercept then
        self:OnInterceptFTB(playerId, action)
    end
end

function HeadIKHandler:OnLastTouchBall(playerId, action)
    local actionType = action.athleteAction.athleteActionType
    if actionType == ActionType.Dribble then
        self:OnDribbleLTB(playerId, action)
    elseif actionType == ActionType.Pass then
        self:OnPassLTB(playerId, action)
    elseif actionType == ActionType.Shoot then
        self:OnShootLTB(playerId, action)
    end
end

function HeadIKHandler:OnDribbleStart(playerId, action)
    local startTime = action.actionStartFrame.time
    local nextAction = GameHubWrap.PeekNextAction(playerId)
    local nextActionType = nextAction.athleteAction.athleteActionType

    if nextActionType == ActionType.ManualOperate then
        self:EndIK(playerId)
        return
    end

    local endTime = startTime + action.lastBallOffset.deltaTime
    if nextAction.nameHash ~= 0 and nextAction.isWithBallAction == true then
        if nextActionType == ActionType.Pass then
            self:DribbleToPass(playerId, action, nextAction, action.actionStartFrame.time)
            return
        elseif nextActionType == ActionType.Shoot then
            self:DribbleToShoot(playerId, action, nextAction, action.actionStartFrame.time)
            return
        elseif nextActionType == ActionType.Dribble then
            endTime = nextAction.actionStartFrame.time
        end
    end
    self:DoDribbleIK(playerId, action, nil, endTime, nil)
end

function HeadIKHandler:OnDribbleLTB(playerId, action)
    local startTime = action.actionStartFrame.time + action.lastBallOffset.deltaTime
    if self.ikEndTime[playerId] <= startTime then
        local nextAction = GameHubWrap.PeekNextAction(playerId)
        if nextAction.nameHash ~= 0 and nextAction.isWithBallAction == true then
            local nextActionType = nextAction.athleteAction.athleteActionType
            if nextActionType == ActionType.Pass then
                self:DribbleToPass(playerId, action, nextAction, startTime)
            elseif nextActionType == ActionType.Shoot then
                self:DribbleToShoot(playerId, action, nextAction, startTime)
            elseif nextActionType == ActionType.Dribble then
                self:DoDribbleIK(playerId, action, startTime, nextAction.actionStartFrame.time, nil)
            end
        end
    end
end

--dribble to dribble, dribble to none
function HeadIKHandler:DoDribbleIK(playerId, action, startTime, endTime, dribblingForward)
    startTime = startTime or action.actionStartFrame.time
    dribblingForward = dribblingForward or isDribbleForward(action.nameHash)
    
    if endTime > startTime then
        if dribblingForward == true then
            local playerPos = GameHubWrap.GetPlayerPosition(playerId)
            local zone = checkZone(playerId, playerPos.x, playerPos.z)
            if zone == Zone.Forward_Center or zone == Zone.Forward_Left or zone == Zone.Forward_Right then --进攻三区
                if endTime - startTime >= PeekGateDefaultDuration then
                    self:PeekGate(playerId, startTime, PeekGateDefaultDuration)
                    startTime = startTime + PeekGateDefaultDuration
                end
            elseif zone == Zone.Middle_Center or zone == Zone.Middle_Left or zone == Zone.Middle_Right then --中场
                local leftPlayer, leftDis, rightPlayer, rightDis = ActionLayerUtils.FindClosestTeammateAhead(playerId)
                if leftPlayer or rightPlayer then
                    if endTime - startTime >= PeekPlayerDefaultDuration * 2 then
                        if leftPlayer then
                            self:PeekPlayer(playerId, leftPlayer, startTime, PeekPlayerDefaultDuration)
                            startTime = startTime + PeekPlayerDefaultDuration
                        end
                        if rightPlayer then
                            self:PeekPlayer(playerId, rightPlayer, startTime, PeekPlayerDefaultDuration)
                            startTime = startTime + PeekPlayerDefaultDuration
                        end
                    elseif endTime - startTime >= PeekPlayerDefaultDuration then
                        local targetId = nil
                        if leftPlayer and rightPlayer then
                            targetId = leftDis > rightDis and rightPlayer or leftPlayer --look at the closest teammate
                        else
                            targetId = leftPlayer or rightPlayer
                        end
                        if targetId then
                            self:PeekPlayer(playerId, targetId, startTime, PeekPlayerDefaultDuration)
                            startTime = startTime + PeekPlayerDefaultDuration
                        end
                    end
                else
                    if endTime - startTime >= PeekGateDefaultDuration then
                        self:PeekGate(playerId, startTime, PeekGateDefaultDuration)
                        startTime = startTime + PeekGateDefaultDuration
                    end
                end
            elseif zone == Zone.Back_Center or zone == Zone.Back_Left or zone == Zone.Back_Right then --后场
                if endTime - startTime >= PeekGateDefaultDuration then
                    self:PeekGate(playerId, startTime, PeekGateDefaultDuration)
                    startTime = startTime + PeekGateDefaultDuration
                end
            end
            if endTime - startTime >= PeekBallDefaultDuration then
                self:PeekBall(playerId, startTime, endTime - startTime)
            end
        end
    end
end

--从带球到传球，在“当前时间”到“传球动作最后触球时间的前0.8s”的时间段内，做带球头部IK
function HeadIKHandler:DribbleToPass(playerId, action, nextAction, startTime)
    local nextLTBDelta = nextAction.lastBallOffset.deltaTime
    local nextLTBTime = nextAction.actionStartFrame.time + nextLTBDelta

    local pivotTime = nextLTBTime - StareCatcherTimeBeforePass
    self:DoDribbleIK(playerId, action, startTime, pivotTime, nil)
    self:ReadyToPass(playerId, pivotTime, nextAction.athleteAction.passAction.targetAthlete, nextLTBDelta)
end

--从带球到射门，在“当前时间”到“射门动作最后触球时间的前0.8s”的时间段内，做带球头部IK
function HeadIKHandler:DribbleToShoot(playerId, action, nextAction, startTime)
    local nextLTBDelta = nextAction.lastBallOffset.deltaTime - DisableIKDurationBeforeShoot
    local nextLTBTime = nextAction.actionStartFrame.time + nextLTBDelta

    local pivotTime = nextLTBTime - PeekGateTimeBeforeShoot
    self:DoDribbleIK(playerId, action, startTime, pivotTime, nil)
    self:ReadyToShoot(playerId, pivotTime, nextLTBDelta)
end

function HeadIKHandler:OnCatchStart(playerId, action)
    local firstPeekDuration = PeekGateOrPlayerTimeBeforeCatch - PeekBallTimeBeforeCatch
    local ftbDelta = action.firstBallOffset.deltaTime
    local ftbTime = action.actionStartFrame.time + ftbDelta
    local startTime = ftbTime - PeekGateOrPlayerTimeBeforeCatch
    if ftbDelta >= PeekGateOrPlayerTimeBeforeCatch then
        self:FirstPeekBeforeCatch(playerId, startTime, firstPeekDuration)
        self:PeekBall(playerId, startTime + firstPeekDuration, PeekBallTimeBeforeCatch)
    elseif ftbDelta >= PeekBallTimeBeforeCatch then
        self:PeekBall(playerId, startTime + firstPeekDuration, PeekBallTimeBeforeCatch)
    else
        -- do nothing
    end
end

--peek next action, be ready for pass or shoot
function HeadIKHandler:OnCatchFTB(playerId, action)
    local nextAction = GameHubWrap.PeekNextAction(playerId)
    local actionStartTime = action.actionStartFrame.time
    local startTime = actionStartTime + action.firstBallOffset.deltaTime
    local endTime = actionStartTime + action.lastBallOffset.deltaTime
    if nextAction.nameHash ~= 0 and nextAction.isWithBallAction == true then
        local nextActionType = nextAction.athleteAction.athleteActionType
        if nextActionType == ActionType.Pass then
            self:CatchToPass(playerId, action, nextAction, startTime)
            return
        elseif nextActionType == ActionType.Shoot then
            self:CatchToShoot(playerId, action, nextAction, startTime)
            return
        elseif nextActionType == ActionType.Dribble then
            endTime = nextAction.actionStartFrame.time
        end
    end
    self:DoDribbleIK(playerId, action, startTime, endTime, true)
end

function HeadIKHandler:CatchToPass(playerId, action, nextAction, startTime)
    local nextLTBDelta = nextAction.lastBallOffset.deltaTime
    local nextLTBTime = nextAction.actionStartFrame.time + nextLTBDelta

    local pivotTime = nextLTBTime - StareCatcherTimeBeforePass
    self:DoDribbleIK(playerId, action, startTime, pivotTime, true)
    self:ReadyToPass(playerId, pivotTime, nextAction.athleteAction.passAction.targetAthlete, nextLTBDelta)
end

function HeadIKHandler:CatchToShoot(playerId, action, nextAction, startTime)
    local nextLTBDelta = nextAction.lastBallOffset.deltaTime - DisableIKDurationBeforeShoot
    local nextLTBTime = nextAction.actionStartFrame.time + nextLTBDelta

    local pivotTime = nextLTBTime - PeekGateTimeBeforeShoot
    self:DoDribbleIK(playerId, action, startTime, pivotTime, true)
    self:ReadyToShoot(playerId, pivotTime, nextLTBDelta)
end

function HeadIKHandler:OnPassStart(playerId, action)
    if PlaybackCenterWrap.InPlaybackMode() == true then
        if self:IsManualOperatePasserInPlayback(playerId, action) then
            self:PeekPlayer(playerId, action.athleteAction.passAction.targetAthlete, action.actionStartFrame.time, action.lastBallOffset.deltaTime)
            return
        end
    else
        if playerId == self.manualOperatePasser then
            self:PeekPlayer(playerId, action.athleteAction.passAction.targetAthlete, action.actionStartFrame.time, action.lastBallOffset.deltaTime)
            self:AddManualOperatePasserInPlayback(playerId, action)
            self.manualOperatePasser = -1
            return
        end
    end
    local ltbDelta = action.lastBallOffset.deltaTime
    local ltbTime = action.actionStartFrame.time + ltbDelta
    local startTime = ltbTime - StareCatcherTimeBeforePass
    local stareCatcherDuration = StareCatcherTimeBeforePass - PeekBallTimeBeforePass
    if ltbDelta >= StareCatcherTimeBeforePass then
        self:PeekPlayer(playerId, action.athleteAction.passAction.targetAthlete, startTime, stareCatcherDuration)
        self:PeekBall(playerId, startTime + stareCatcherDuration, PeekBallTimeBeforePass)
    elseif ltbDelta >= PeekBallTimeBeforePass then
        self:PeekBall(playerId, startTime + stareCatcherDuration, PeekBallTimeBeforePass)
    else
        -- do nothing
    end
end

-- normal play on pass
function HeadIKHandler:OnNPOPassStart(playerId, action)
    local ltbDelta = action.lastBallOffset.deltaTime
    local startTime = action.actionStartFrame.time
    local stareCatcherDuration = ltbDelta - PeekBallTimeBeforeNPOPass
    self:PeekPlayer(playerId, action.athleteAction.passAction.targetAthlete, startTime, stareCatcherDuration)
    self:PeekBall(playerId, startTime + stareCatcherDuration, PeekBallTimeBeforeNPOPass)
end

function HeadIKHandler:OnPassLTB(playerId, action)
    self:StareBall(playerId, TimeLineWrap.TLTime())
end

function HeadIKHandler:OnShootStart(playerId, action)
    local ltbDelta = action.lastBallOffset.deltaTime - DisableIKDurationBeforeShoot
    local ltbTime = action.actionStartFrame.time + ltbDelta
    local startTime = ltbTime - PeekGateTimeBeforeShoot
    local peekGateDuration = PeekGateTimeBeforeShoot - PeekBallTimeBeforeShoot
    if ltbDelta >= PeekGateTimeBeforeShoot then
        self:PeekGate(playerId, startTime, peekGateDuration)
        self:PeekBall(playerId, startTime + peekGateDuration, PeekBallTimeBeforeShoot)
    elseif ltbDelta >= PeekBallTimeBeforePass then
        self:PeekBall(playerId, startTime + peekGateDuration, PeekBallTimeBeforeShoot)
    else
        -- do nothing
    end
end

function HeadIKHandler:OnNPOShootStart(playerId, action)
    local ltbDelta = action.lastBallOffset.deltaTime - DisableIKDurationBeforeShoot
    local startTime = action.actionStartFrame.time
    local peekGateDuration = ltbDelta - PeekBallTimeBeforeNPOShoot
    self:PeekGate(playerId, startTime, peekGateDuration)
    self:PeekBall(playerId, startTime + peekGateDuration, PeekBallTimeBeforeNPOShoot)
end

function HeadIKHandler:OnShootLTB(playerId, action)
    self:StareBall(playerId, TimeLineWrap.TLTime())
end

--peek next action, be ready for pass or shoot
function HeadIKHandler:OnStealFTB(playerId, action)
    self:OnCatchFTB(playerId, action)
end

--peek next action, be ready for pass or shoot
function HeadIKHandler:OnInterceptFTB(playerId, action)
    self:OnCatchFTB(playerId, action)
end

function HeadIKHandler:OnSaveStart(playerId, action)
    self:EndIK(playerId)
end

function HeadIKHandler:PrepareToCatch(playerId, action)
    local nextAction = GameHubWrap.PeekNextAction(playerId)
    if nextAction.nameHash ~= 0 and nextAction.isWithBallAction == true then
        local nextActionType = nextAction.athleteAction.athleteActionType
        if nextActionType == ActionType.Catch then
            self:NoneToCatch(playerId, action, nextAction)
        elseif nextActionType == ActionType.Pass then
            self:NoneToPass(playerId, action, nextAction)
        elseif nextActionType == ActionType.Shoot then
            self:NoneToShoot(playerId, action, nextAction)
        end
    end
end

function HeadIKHandler:NoneToCatch(playerId, action, nextAction)
    local nextFTBDelta = nextAction.firstBallOffset.deltaTime
    local nextFTBTime = nextAction.actionStartFrame.time + nextFTBDelta

    local startTime = nextFTBTime - PeekGateOrPlayerTimeBeforeCatch
    self:ReadyToCatch(playerId, startTime, nextFTBDelta)
end

function HeadIKHandler:NoneToPass(playerId, action, nextAction)
    local nextLTBDelta = nextAction.lastBallOffset.deltaTime
    local nextLTBTime = nextAction.actionStartFrame.time + nextLTBDelta

    local startTime = nextLTBTime - StareCatcherTimeBeforePass
    self:ReadyToPass(playerId, startTime, nextAction.athleteAction.passAction.targetAthlete, nextLTBDelta)
end

function HeadIKHandler:NoneToShoot(playerId, action, nextAction)
    local nextLTBDelta = nextAction.lastBallOffset.deltaTime - DisableIKDurationBeforeShoot
    local nextLTBTime = nextAction.actionStartFrame.time + nextLTBDelta

    local startTime = nextLTBTime - PeekGateTimeBeforeShoot
    self:ReadyToShoot(playerId, startTime, nextLTBDelta)
end

--准备传球，从Dribble、None、Steal、Intercept或者Save开始
--最后触球前0.8s开始看接球人，持续0.5s
--最后出球前0.3s开始看球，持续0.3s
function HeadIKHandler:ReadyToPass(playerId, startTime, targetAthlete, passLTBDelta)
    local stareCatcherDuration = StareCatcherTimeBeforePass - PeekBallTimeBeforePass
    if passLTBDelta >= StareCatcherTimeBeforePass then

    elseif passLTBDelta >= PeekBallTimeBeforePass then
        self:PeekPlayer(playerId, targetAthlete, startTime, stareCatcherDuration)
    else
        self:PeekPlayer(playerId, targetAthlete, startTime, stareCatcherDuration)
        self:PeekBall(playerId, startTime + stareCatcherDuration, PeekBallTimeBeforePass)
    end
end

--准备射门，从Dribble、None、Steal或者Intercept开始
--最后触球前0.8s开始瞥球门，持续0.3s
--最后出球前0.5s开始看球，持续0.5s
function HeadIKHandler:ReadyToShoot(playerId, startTime, shootLTBDelta)
    local peekGateDuration = PeekGateTimeBeforeShoot - PeekBallTimeBeforeShoot
    if shootLTBDelta >= PeekGateTimeBeforeShoot then

    elseif shootLTBDelta >= PeekBallTimeBeforeShoot then
        self:PeekGate(playerId, startTime, peekGateDuration)
    else
        self:PeekGate(playerId, startTime, peekGateDuration)
        self:PeekBall(playerId, startTime + peekGateDuration, PeekBallTimeBeforeShoot)
    end
end

--准备做接球动作，从None开始
--第一次触球前0.8s，根据来球和身体朝向的关系决定看球门还是看背后的防守人，持续0.3s
--第一次触球前0.5s开始看球，持续0.5s
function HeadIKHandler:ReadyToCatch(playerId, startTime, catchFTBDelta)
    local firstPeekDuration = PeekGateOrPlayerTimeBeforeCatch - PeekBallTimeBeforeCatch
    if catchFTBDelta < PeekGateOrPlayerTimeBeforeCatch then        
        if catchFTBDelta >= PeekBallTimeBeforeCatch then
            self:FirstPeekBeforeCatch(playerId, startTime, firstPeekDuration)
        else
            self:FirstPeekBeforeCatch(playerId, startTime, firstPeekDuration)
            self:PeekBall(playerId, startTime + firstPeekDuration, PeekBallTimeBeforeCatch)
        end
    end
end

function HeadIKHandler:FirstPeekBeforeCatch(playerId, startTime, duration)
    local forward = GameHubWrap.GetPlayerForward(playerId)
    local isBallFromBehind = ActionLayerUtils.IsBallComingFromBehind(forward, ___upperBodyUtil.passDirection)
    if isBallFromBehind == true then
        self:PeekGate(playerId, startTime, duration)
    else
        local targetId = ActionLayerUtils.FindClosestRivalBehind(playerId)
        if targetId then
            self:PeekPlayer(playerId, targetId, startTime, duration)
        else
            self:PeekGate(playerId, startTime, duration)
        end
    end
end

function HeadIKHandler:OnManualOperateStart(id, manualOperateAction)
    self.manualOperateId = id
    self.manualOperatePasser = -1
    self.manualOperatePasserInPlayback = {}
    self:EndIK(id)
end

function HeadIKHandler:OnManualOperateChoice(manualOperateType, id)
    if manualOperateType == ManualOperateType.Pass then
        self.manualOperatePasser = self.manualOperateId
    end
end

function HeadIKHandler:AddManualOperatePasserInPlayback(id, action)
    if not self.manualOperatePasserInPlayback[id] then
        self.manualOperatePasserInPlayback[id] = {}
    end
    table.insert(self.manualOperatePasserInPlayback[id], action.actionStartFrame.time)
end

function HeadIKHandler:IsManualOperatePasserInPlayback(id, action)
    local passerActions = self.manualOperatePasserInPlayback[id]
    if passerActions then
        for i = 1, #passerActions do
            if math.cmpf(passerActions[i], action.actionStartFrame.time) == 0 then
                return true
            end
        end
    end
    return false
end

function HeadIKHandler:OnPlaybackStarts()
    for i = 0, 21 do
        self.ikEndTime[i] = 0
        self.currentIKType[i] = IKType.None
        self.currentTarget[i] = nil
    end
end

function HeadIKHandler:OnPlaybackEnds()
    self.manualOperatePasserInPlayback = {}
end

function HeadIKHandler:OnShootBallEnds(ballShoot)
    for i = 0, 21 do
        self:EndIK(i)
    end
end

return HeadIKHandler

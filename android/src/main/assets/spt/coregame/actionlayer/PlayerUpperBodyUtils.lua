local HeadIKHandler = require("coregame.actionlayer.HeadIKHandler")
local UpperBodyLayerHandler = require("coregame.actionlayer.UpperBodyLayerHandler")
local ActionLayerConfig = require("coregame.actionlayer.ActionLayerConfig")
local EnumType = require("coregame.EnumType")
local ActionType = EnumType.ActionType
local MatchEventType = EnumType.MatchEventType

local PlayerUpperBodyUtils = class()

function PlayerUpperBodyUtils:Start()
    ___upperBodyUtil = self
    self.ballHandler = nil
    self.preBallHandler = nil
    self.currentCatcher = nil
    self.passDirection = nil
    self.isPlayerAttackingNorth = nil
    self.playerGKStartPosition = nil
    self.opponentGKStartPosition = nil
    self.inPenaltyShootOut = nil
    self.headIKHandler = HeadIKHandler.new()
    self.headIKHandler:Start()
    self.upperBodyLayerHandler = UpperBodyLayerHandler.new()
    self.upperBodyLayerHandler:Start()
end

function PlayerUpperBodyUtils:Destroy()
    self.ballHandler = nil
    self.preBallHandler = nil
    self.headIKHandler:Destroy()
    self.headIKHandler = nil
    self.upperBodyLayerHandler:Destroy()
    self.upperBodyLayerHandler = nil
end

function PlayerUpperBodyUtils:OnNewActionStart(playerId, action)
    if action.isStartOnNormalPlayOn == true then
        if playerId == 0 then
            self.playerGKStartPosition = action.actionStartFrame.position
            self:CheckPlayerAttackDirection()
        elseif playerId == 11 then
            self.opponentGKStartPosition = action.actionStartFrame.position
            self:CheckPlayerAttackDirection()
        end
    end

    if action.isWithBallAction == true then
        if not self.ballHandler then
            self.ballHandler = playerId
        elseif playerId ~= self.ballHandler then
            self.preBallHandler = self.ballHandler
            self.ballHandler = playerId
        end
        self.currentCatcher = nil
        if action.athleteAction.athleteActionType == ActionType.Pass then
            self.currentCatcher = action.athleteAction.passAction.targetAthlete
            local startPosition = action.actionStartFrame.position
            local targetPosition = action.athleteAction.passAction.targetPosition
            self.passDirection = {}
            self.passDirection.x = targetPosition.x - startPosition.x
            self.passDirection.y = 0
            self.passDirection.z = targetPosition.y - startPosition.y
        end
    end
    if not self.inPenaltyShootOut then
        self.upperBodyLayerHandler:OnNewActionStart(playerId, action)
        self.headIKHandler:OnNewActionStart(playerId, action)
    end
end

function PlayerUpperBodyUtils:OnFirstTouchBall(playerId, action)
    if not self.inPenaltyShootOut then  
        self.headIKHandler:OnFirstTouchBall(playerId, action)
        self.upperBodyLayerHandler:OnFirstTouchBall(playerId, action)
    end
end

function PlayerUpperBodyUtils:OnLastTouchBall(playerId, action)
    if not self.inPenaltyShootOut then
        self.headIKHandler:OnLastTouchBall(playerId, action)
        self.upperBodyLayerHandler:OnLastTouchBall(playerId, action)
    end
end

function PlayerUpperBodyUtils:OnAthleteSkill(skill)
    self.upperBodyLayerHandler:OnAthleteSkill(skill)
end

function PlayerUpperBodyUtils:IsOfDefenseTeam(playerId)
    if self.ballHandler then
        if self.ballHandler >= 1 and self.ballHandler <= 10 then
            return playerId >= 12 and playerId <= 21
        elseif self.ballHandler >= 12 and self.ballHandler <= 21 then
            return playerId >= 1 and playerId <= 10
        end
    end
    return nil
end

function PlayerUpperBodyUtils:CheckPlayerAttackDirection()
    if self.playerGKStartPosition and self.opponentGKStartPosition then
        local gateNorth = Vector2Lua(0, ActionLayerConfig.GoalPositionZ)
        local gateSouth = Vector2Lua(0, -ActionLayerConfig.GoalPositionZ)
        local playerGKNorthDis = Vector2Lua.SqrDistance(self.playerGKStartPosition, gateNorth)
        local playerGKSouthDis = Vector2Lua.SqrDistance(self.playerGKStartPosition, gateSouth)
        local opponentGKNorthDis = Vector2Lua.SqrDistance(self.opponentGKStartPosition, gateNorth)
        local opponentGKSouthDis = Vector2Lua.SqrDistance(self.opponentGKStartPosition, gateSouth)
        if math.min(playerGKNorthDis, playerGKSouthDis) < math.min(opponentGKNorthDis, opponentGKSouthDis) then
            self.isPlayerAttackingNorth = self.playerGKStartPosition.y < 0
        else
            self.isPlayerAttackingNorth = self.opponentGKStartPosition.y > 0
        end
        self.playerGKStartPosition = nil
        self.opponentGKStartPosition = nil
    else
        self.isPlayerAttackingNorth = nil
    end
end

function PlayerUpperBodyUtils:OnManualOperateStart(id, manualOperateAction)
    self.headIKHandler:OnManualOperateStart(id, manualOperateAction)
end

function PlayerUpperBodyUtils:OnManualOperateChoice(manualOperateType, id)
    self.headIKHandler:OnManualOperateChoice(manualOperateType, id)
end

function PlayerUpperBodyUtils:OnPlaybackStarts()
    self.headIKHandler:OnPlaybackStarts()
end

function PlayerUpperBodyUtils:OnPlaybackEnds()
    self.headIKHandler:OnPlaybackEnds()
end

function PlayerUpperBodyUtils:OnShootBallEnds(ballShoot)
    self.upperBodyLayerHandler:OnShootBallEnds(ballShoot)
    self.headIKHandler:OnShootBallEnds()
end

function PlayerUpperBodyUtils:OnMatchEvent(matchKeyFrame, previousEventType)
    if matchKeyFrame.matchEvent == MatchEventType.PenaltyShootOutKick then
        self.inPenaltyShootOut = true
    end
end

return PlayerUpperBodyUtils

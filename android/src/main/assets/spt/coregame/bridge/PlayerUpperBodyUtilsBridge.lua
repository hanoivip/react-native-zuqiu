local PlayerUpperBodyUtils = require("coregame.actionlayer.PlayerUpperBodyUtils")

local upperBodyUtils = PlayerUpperBodyUtils.new()

function PlayerUpperBodyUtilsBridge_Start()
    upperBodyUtils:Start()
end

function PlayerUpperBodyUtilsBridge_Destroy()
    upperBodyUtils:Destroy()
end

function PlayerUpperBodyUtilsBridge_OnNewActionStart(playerId, action)
    upperBodyUtils:OnNewActionStart(playerId, action)
end

function PlayerUpperBodyUtilsBridge_OnFirstTouchBall(playerId, action)
    upperBodyUtils:OnFirstTouchBall(playerId, action)
end

function PlayerUpperBodyUtilsBridge_OnLastTouchBall(playerId, action)
    upperBodyUtils:OnLastTouchBall(playerId, action)
end

function PlayerUpperBodyUtilsBridge_OnAthleteSkill(skill)
    upperBodyUtils:OnAthleteSkill(skill)
end

function PlayerUpperBodyUtilsBridge_OnManualOperateStart(id, manualOperateAction)
    upperBodyUtils:OnManualOperateStart(id, manualOperateAction)
end

function PlayerUpperBodyUtilsBridge_OnManualOperateChoice(manualOperateType, id)
    upperBodyUtils:OnManualOperateChoice(manualOperateType, id)
end
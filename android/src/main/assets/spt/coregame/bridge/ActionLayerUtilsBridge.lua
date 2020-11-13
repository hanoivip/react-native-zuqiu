local ActionLayerUtils = require("coregame.actionlayer.ActionLayerUtils")
local DeadBallTimeManager = require("coregame.actionlayer.DeadBallTimeManager")
local PlaybackManager = require("coregame.actionlayer.PlaybackManager")

local deadBallTimeManager = DeadBallTimeManager.new()
local playbackManager = PlaybackManager.new()

function ActionLayerUtilsBridge_Start()
    deadBallTimeManager:Start()
    playbackManager:Start()
end

function ActionLayerUtilsBridge_Destroy()
    deadBallTimeManager:Destroy()
    playbackManager:Destroy()
end

function ActionLayerUtilsBridge_OnMatchEvent(matchKeyFrame, previousEventType)
    deadBallTimeManager:OnMatchEvent(matchKeyFrame, previousEventType)
    ___upperBodyUtil:OnMatchEvent(matchKeyFrame, previousEventType)
end

function ActionLayerUtilsBridge_OnNormalPlayOn(matchKeyFrame, previousEventType)
    deadBallTimeManager:OnNormalPlayOn(matchKeyFrame, previousEventType)
end

function ActionLayerUtilsBridge_OnWithBallActionStart(id, action)
    deadBallTimeManager:OnWithBallActionStart(id, action)
end

function ActionLayerUtilsBridge_InitBallAction(ballAction)
    ActionLayerUtils.InitBallAction(ballAction)
end

function ActionLayerUtilsBridge_DecideInterDribblePassType(currentLastTouchBallPos, nextFirstTouchBallPos)
    return ActionLayerUtils.DecideInterDribblePassType(currentLastTouchBallPos, nextFirstTouchBallPos)
end

function ActionLayerUtilsBridge_OnPostShoot(postShootAction)
    deadBallTimeManager:OnPostShoot(postShootAction)
end

function ActionLayerUtilsBridge_OnDeadBallTimeEnd()
    deadBallTimeManager:OnDeadBallTimeEnd()
end

function ActionLayerUtilsBridge_OnOneDeadBallTimeSceneStarts()
    deadBallTimeManager:OnOneDeadBallTimeSceneStart()
end

function ActionLayerUtilsBridge_OnOneDeadBallTimeSceneEnd()
    deadBallTimeManager:OnOneDeadBallTimeSceneEnd()
end

function ActionLayerUtilsBridge_OnTouchShootComplete(shooter, shootPath, shootAction)
    ___demoManager:OnTouchShootComplete(shooter, shootPath, shootAction)
end

function ActionLayerUtilsBridge_OnAutoShoot(shooter, shootPath, shootAction)
    ___demoManager:OnAutoShoot(shooter, shootPath, shootAction)
end

function ActionLayerUtilsBridge_OnDemoMatchManualActionStarts(id, action)
    ___demoManager:OnManualActionStarts(id, action)
end

function ActionLayerUtilsBridge_OnDemoMatchManualOperate(manualOperateType, id)
    ___demoManager:OnManualOperate(manualOperateType, id)
end

function ActionLayerUtilsBridge_OnSaveBounceFreeFly(gkPosition, saveAction, ballPosition)
    ActionLayerUtils.OnSaveBounceFreeFly(gkPosition, saveAction, ballPosition)
end

function ActionLayerUtilsBridge_OnShootBallEnds(ballShoot, ballPosition, lastBallPosition)
    ActionLayerUtils.OnShootBallEnds(ballShoot, ballPosition, lastBallPosition)
end

function ActionLayerUtilsBridge_InitPlaybackClip(startTime, startMatchEvent, lastPass, shootStartTime)
    playbackManager:InitPlaybackClip(startTime, startMatchEvent, lastPass, shootStartTime)
end

function ActionLayerUtilsBridge_OnLastPassInPlayback()
    playbackManager:OnLastPassInPlayback()
end

function ActionLayerUtilsBridge_OnPlaybackEnds()
    playbackManager:OnPlaybackEnds()
end

function ActionLayerUtilsBridge_OnPlaybackClipEnds()
    playbackManager:OnPlaybackClipEnds()
end

function ActionLayerUtilsBridge_OnFreeFlyBallBounceOnGround(ball)
    ActionLayerUtils.OnFreeFlyBallBounceOnGround(ball)
end

function ActionLayerUtilsBridge_OnFreeFlyBallHitCollider(ball, collider)
    ActionLayerUtils.OnFreeFlyBallHitCollider(ball, collider)
end

--用于测试死球场景
function ActionLayerUtilsBridge_TestDeadBallTimeScene(sceneType, index, positionX, positionZ)
    deadBallTimeManager:TestDeadBallTimeScene(sceneType, index, positionX, positionZ)
end
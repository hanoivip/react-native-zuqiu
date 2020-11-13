function MatchUIDataBridge_OnMatchStart()
    ___matchUI:onMatchStart()
end

function MatchUIDataBridge_OnPlayerNameChangeMsg(athleteId)
    ___matchUI:onPlayerNameChangeMsg(athleteId)
end

function MatchUIDataBridge_OnShootBallFlyEnd(shootResult)
    ___matchUI:onShootBallFlyEnd(shootResult)
end

function MatchUIDataBridge_OnPlayerActionStart(id, athleteId, athleteActionType, successProbability, action, actionName)
    ___matchUI:onPlayerActionStart(id, athleteId, athleteActionType, successProbability, action, actionName)
end

function MatchUIDataBridge_OnCoachSkillCast(playerCoachSkillId, opponentCoachSkillId)
    ___matchUI:onCoachSkillCast(playerCoachSkillId, opponentCoachSkillId)
end

function MatchUIDataBridge_OnAthleteEffect(effect)
    ___matchUI:onAthleteEffect(effect)
end

function MatchUIDataBridge_OnAthleteSkill(skill)
    ___matchUI:onAthleteSkill(skill)
    PlayerUpperBodyUtilsBridge_OnAthleteSkill(skill)
end

function MatchUIDataBridge_OnAthleteBuff(buff)
    ___matchUI:onAthleteBuff(buff)
end

function MatchUIDataBridge_OnShootStart(onfieldId, athleteId, action, athleteObject)
    ___matchUI:onShootStart(onfieldId, athleteId, action, athleteObject)
end

function MatchUIDataBridge_OnPostShoot(shootAction, postShootAction)
    ___matchUI:onPostShoot(shootAction, postShootAction)
end

function MatchUIDataBridge_OnShootBallFlyStart(athleteId, athleteObject)
    ___matchUI:onShootBallFlyStart(athleteId, athleteObject)
end

function MatchUIDataBridge_OnManualOperateStart(onfieldId, athleteId, action, manualOperateAthleteObject)
    ___matchUI:onManualOperateStart(onfieldId, athleteId, action, manualOperateAthleteObject)
end

function MatchUIDataBridge_OnManualOperateDisableUnselectedButtons()
    ___matchUI:onManualOperateDisableUnselectedButtons()
end

function MatchUIDataBridge_OnManualOperateEnd()
    ___matchUI:onManualOperateEnd()
end

function MatchUIDataBridge_OnShowMatchTips()
    ___matchUI:onShowMatchTips()
end

function MatchUIDataBridge_OnHideMatchTips()
    ___matchUI:onHideMatchTips()
end

function MatchUIDataBridge_OnTouchShootActivated(callback)
    ___matchUI:onTouchShootActivated(callback)
end

function MatchUIDataBridge_OnTouchShootDeactivated()
    ___matchUI:onTouchShootDeactivated()
end

function MatchUIDataBridge_OnManualOperateActivated(callback)
    ___matchUI:onManualOperateActivated(callback)
end

function MatchUIDataBridge_OnManualOperateDeactivated()
    ___matchUI:onManualOperateDeactivated()
end

function MatchUIDataBridge_OnDisablePreMatch()
    ___matchUI:onDisablePreMatch()
end

function MatchUIDataBridge_OnEnablePreMatch()
    ___matchUI:onEnablePreMatch()
end

function MatchUIDataBridge_OnDeployedEvent()
    ___matchUI:onDeployed()
end

function MatchUIDataBridge_OnDebugInfo(debugInfo)
    ___matchUI:onDebugInfo(debugInfo)
end

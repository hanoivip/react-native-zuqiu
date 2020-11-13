local EnumType = require("coregame.EnumType")
local ActionType = EnumType.ActionType
local ShootResult = EnumType.ShootResult
local ActionLayerUtils = require("coregame.actionlayer.ActionLayerUtils")

local UpperBodyLayerHandler = class()
local EmptyAction = {
        actionName = 'Empty',
        transitionPercent = 0.96
    }

local UpperBodyAction = {
    CallForBall = {
        ['left'] = {
            [1] = {
                actionName = 'G_A01_1',
                transitionPercent = 0.92
            },
            [2] = {
                actionName = 'G_A02_1',
                transitionPercent = 0.90
            }
        },
        ['right'] = {
            [1] = {
                actionName = 'G_A01',
                transitionPercent = 0.92
            },
            [2] = {
                actionName = 'G_A02',
                transitionPercent = 0.90
            }
        }
    },
    ChaseDefense = {
        ['left'] = {
            [1] = {
                actionName = 'G_K01_1',
                transitionPercent = 0.86
            },
            [2] = {
                actionName = 'G_K10',
                transitionPercent = 0.86
            }
        },
        ['right'] = {
            [1] = {
                actionName = 'G_K01',
                transitionPercent = 0.86
            },
            [2] = {
                actionName = 'G_K10_1',
                transitionPercent = 0.86
            }
        }
    },
    AntiDefense = {
        ['left'] = {
            [1] = {
                actionName = 'G_K04_1',
                transitionPercent = 0.83
            },
            [2] = {
                actionName = 'G_K08_1',
                transitionPercent = 0.86
            },
            [3] = {
                actionName = 'G_K09_1',
                transitionPercent = 0.86
            }
        },
        ['right'] = {
            [1] = {
                actionName = 'G_K04',
                transitionPercent = 0.83
            },
            [2] = {
                actionName = 'G_K08',
                transitionPercent = 0.86
            },
            [3] = {
                actionName = 'G_K09',
                transitionPercent = 0.86
            }
        }
    },
    MarkDefense = {
        [1] = {
            actionName = 'G_K05',
            transitionPercent = 0.86
        }
    },
    GoalCheerShooter = {
        [1] = {
            actionName = 'G_Z03',
            transitionPercent = 0.96
        },
        [2] = {
            actionName = 'G_Z04',
            transitionPercent = 0.96
        },
        [3] = {
            actionName = 'G_Z05',
            transitionPercent = 0.96
        },
        [4] = {
            actionName = 'G_Z06',
            transitionPercent = 0.96
        },
        [5] = {
            actionName = 'G_Z07',
            transitionPercent = 0.96
        },
        [6] = { -- not a typo
            actionName = 'G_Z04',
            transitionPercent = 0.96
        },
        [7] = { -- not a typo
            actionName = 'G_Z06',
            transitionPercent = 0.96
        },
    },
    GoalCheerNonShooter = {
        [1] = {
            actionName = 'G_Z01',
            transitionPercent = 0.96
        },
        [2] = {
            actionName = 'G_Z03',
            transitionPercent = 0.96
        },
        [3] = {
            actionName = 'G_Z04',
            transitionPercent = 0.96
        },
        [4] = {
            actionName = 'G_Z06',
            transitionPercent = 0.96
        },
        [5] = {
            actionName = 'G_Z07',
            transitionPercent = 0.96
        },
        [6] = EmptyAction,
        [7] = EmptyAction,
        [8] = EmptyAction,
        [9] = EmptyAction,
        [10] = EmptyAction
    },
    GoalLost = {
        [1] = {
            actionName = 'G_Z09',
            transitionPercent = 0.96
        },
        [2] = {
            actionName = 'G_Z10',
            transitionPercent = 0.96
        },
        [3] = {
            actionName = 'G_Z11',
            transitionPercent = 0.96
        },
        [4] = {
            actionName = 'G_Z12',
            transitionPercent = 0.96
        },
        [5] = {
            actionName = 'G_Z13',
            transitionPercent = 0.96
        },
    },
    StealDefense = {
        ['left'] = {
            [1] = {
                actionName = 'G_K08_1',
                transitionPercent = 0.86
            },
        },
        ['right'] = {
            [1] = {
                actionName = 'G_K08',
                transitionPercent = 0.86
            },
        }
    },
}

local ChaseDefenseRange = 4
local MarkDefenseRange = 2

local function addUpperBodyAction(playerId, model)
    GameHubWrap.AddUpperBodyLayerAction(playerId, model)
end

function UpperBodyLayerHandler:Start()
    self.currentAction = {}
    for i = 0, 21 do
        self.currentAction[i] = 0
    end
    self.currentActionType = {}
    for i = 0, 21 do
        self.currentActionType[i] = ActionType.None
    end
end

function UpperBodyLayerHandler:Destroy()
    self.currentAction = nil
    self.currentActionType = nil
end

function UpperBodyLayerHandler:OnNewActionStart(playerId, action)
    self.currentAction[playerId] = action.nameHash
    self.currentActionType[playerId] = action.athleteAction.athleteActionType
    if action.isStartOnNormalPlayOn then
        self.stealPlayer = nil
    end
    if self.stealPlayer == playerId then
        if action.athleteAction.athleteActionType == ActionType.Dribble then
            self:DoAntiDefenseAfterSteal(self.stealPlayer)
        end
        self.stealPlayer = nil
    end
    if action.isWithBallAction == true then
        if action.athleteAction.athleteActionType == ActionType.Pass then
            GameHubWrap.StopUpperBodyLayerAction(playerId)
            self:DoCallForBall(action.athleteAction.passAction.targetAthlete, playerId)
        elseif action.athleteAction.athleteActionType == ActionType.Shoot
            or action.athleteAction.athleteActionType == ActionType.Catch then
            GameHubWrap.StopUpperBodyLayerAction(playerId)
        end
    else
        if ___upperBodyUtil:IsOfDefenseTeam(playerId) == true
            and self:IsPotentialDefenseTarget(___upperBodyUtil.ballHandler) == true -- offensiver is potential denfense target
            and GameHubWrap.IsDoingUpperBodyAction(playerId) == false then
            self:TryDoDefense(playerId, ___upperBodyUtil.ballHandler)
        end
    end
end

function UpperBodyLayerHandler:OnFirstTouchBall(playerId, action)
    if self:IsPotentialDefenseTarget(playerId) == true
        and GameHubWrap.IsDoingUpperBodyAction(playerId) == false then
        self:TryInvokeDefense(playerId)
    end
end

function UpperBodyLayerHandler:OnLastTouchBall(playerId, action)
    if action.athleteAction.athleteActionType == ActionType.Steal then
        self.stealPlayer = playerId
    end
    if self:IsPotentialDefenseTarget(playerId) == true
        and GameHubWrap.IsDoingUpperBodyAction(playerId) == false then
        self:TryInvokeDefense(playerId)
    end
end

function UpperBodyLayerHandler:OnAthleteSkill(skill)
    if skill.SkillId == "A02" then --小动作
        local defender = skill.OnfieldId
        local offensiver = ___upperBodyUtil.ballHandler
        local defenseForward = GameHubWrap.GetPlayerForward(defender)
        local forward = Vector2Lua(defenseForward.x, defenseForward.z)

        local defensePos = GameHubWrap.GetPlayerPosition(defender)
        local offensePos = GameHubWrap.GetPlayerPosition(offensiver)
        local offset = Vector2Lua(offensePos.x - defensePos.x, offensePos.z - defensePos.z)

        local angle = Vector2Lua.SAngle(forward, offset)

        if angle > -90 and angle < 90 then
            if angle >= 0 then -- offensiver is on the right side of defender
                addUpperBodyAction(defender, ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.ChaseDefense['right']))
                if self:IsPotentialDefenseTarget(___upperBodyUtil.ballHandler) == true then
                    self:DoAntiDefense(offensiver, true)
                end
            else
                addUpperBodyAction(defender, ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.ChaseDefense['left']))
                if self:IsPotentialDefenseTarget(___upperBodyUtil.ballHandler) == true then
                    self:DoAntiDefense(offensiver, false)
                end
            end
        elseif angle > -45 and angle < 45 then
            addUpperBodyAction(defender, ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.MarkDefense))
            if self:IsPotentialDefenseTarget(___upperBodyUtil.ballHandler) == true then
                if angle >= 0 then
                    self:DoAntiDefense(offensiver, false)
                else
                    self:DoAntiDefense(offensiver, true)
                end
            end
        end
    end
end

function UpperBodyLayerHandler:IsPotentialDefenseTarget(playerId)
    return self.currentActionType[playerId] == ActionType.Dribble
        or self.currentActionType[playerId] == ActionType.Catch
        or self.currentActionType[playerId] == ActionType.Shoot
end

function UpperBodyLayerHandler:IsSuitableForAntiDefense(playerId)
    return self.currentActionType[playerId] == ActionType.Dribble
end

function UpperBodyLayerHandler:TryInvokeDefense(offensiver)
    local isAround, defender = ActionLayerUtils.IsAroundRivals(offensiver, ChaseDefenseRange)
    if GameHubWrap.IsDoingUpperBodyAction(defender) == false then
        self:TryDoDefense(defender, offensiver)
    end
end

function UpperBodyLayerHandler:TryDoDefense(defender, offensiver)
    local defensePos = GameHubWrap.GetPlayerPosition(defender)
    local offensePos = GameHubWrap.GetPlayerPosition(offensiver)
    local distance = ActionLayerUtils.Vector3SqrDistanceOnXZ(defensePos, offensePos)
    if distance < ChaseDefenseRange then -- defender and offensiver are close enough
        local defenseForward = GameHubWrap.GetPlayerForward(defender)
        local forward = Vector2Lua(defenseForward.x, defenseForward.z)
        local offset = Vector2Lua(offensePos.x - defensePos.x, offensePos.z - defensePos.z)
        local angle = Vector2Lua.SAngle(forward, offset)
        if angle > -90 and angle < 90 and ActionLayerUtils.IsRunningForward(self.currentAction[defender]) == true then
            if angle >= 0 then -- offensiver is on the right side of defender
                addUpperBodyAction(defender, ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.ChaseDefense['right']))
                self:DoAntiDefense(offensiver, true)
            else
                addUpperBodyAction(defender, ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.ChaseDefense['left']))
                self:DoAntiDefense(offensiver, false)
            end
        elseif angle > -45 and angle < 45 and distance < MarkDefenseRange then
            if ActionLayerUtils.IsRunningLeftward(self.currentAction[defender]) == true
                or ActionLayerUtils.IsRunningRightward(self.currentAction[defender]) == true then
                addUpperBodyAction(defender, ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.MarkDefense))
                if angle >= 0 then
                    self:DoAntiDefense(offensiver, false)
                else
                    self:DoAntiDefense(offensiver, true)
                end
            end
        end
    end
end

function UpperBodyLayerHandler:DoAntiDefense(offensiver, defenderOnLeft)
    if self:IsSuitableForAntiDefense(offensiver) == true then
        GameHubWrap.ResetBlendTreeHandler(offensiver)
        if defenderOnLeft == true then
            addUpperBodyAction(offensiver, ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.AntiDefense['left']))
        else
            addUpperBodyAction(offensiver, ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.AntiDefense['right']))
        end
    end
end

function UpperBodyLayerHandler:DoAntiDefenseAfterSteal(playerId)
    if ___upperBodyUtil.preBallHandler then
        local defensePos = GameHubWrap.GetPlayerPosition(___upperBodyUtil.preBallHandler)
        local offensePos = GameHubWrap.GetPlayerPosition(playerId)
        local offenseForward = GameHubWrap.GetPlayerForward(playerId)
        local forward = Vector2Lua(offenseForward.x, offenseForward.z)
        local offset = Vector2Lua(defensePos.x - offensePos.x, defensePos.z - offensePos.z)
        if Vector2Lua.Cross(forward, offset) > 0 then
            addUpperBodyAction(playerId, ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.StealDefense['left']))
        else
            addUpperBodyAction(playerId, ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.StealDefense['right']))
        end
    end
end

function UpperBodyLayerHandler:DoCallForBall(catcher, passer)
    if ActionLayerUtils.IsRunningForward(self.currentAction[catcher]) == true then
        GameHubWrap.ResetBlendTreeHandler(catcher)

        local catcherPos = GameHubWrap.GetPlayerPosition(catcher)
        local passerPos = GameHubWrap.GetPlayerPosition(passer)
        local offset = Vector2Lua(passerPos.x - catcherPos.x, passerPos.z - catcherPos.z)

        local catcherForward = GameHubWrap.GetPlayerForward(catcher)
        local forward = Vector2Lua(catcherForward.x, catcherForward.z)

        if math.sign(Vector2Lua.Cross(forward, offset)) >= 0 then
            addUpperBodyAction(catcher, ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.CallForBall['left']))
        else
            addUpperBodyAction(catcher, ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.CallForBall['right']))
        end
    end
end

function UpperBodyLayerHandler:OnShootBallEnds(ballShoot)
    if ballShoot.shootResult == ShootResult.Goal and not ___upperBodyUtil.inPenaltyShootOut then
        for i = 0, 21 do
            GameHubWrap.ResetBlendTreeHandler(i)
            GameHubWrap.StopUpperBodyLayerAction(i)
            local upperBodyAction = nil
            if not ActionLayerUtils.IsRival(ballShoot.shooterId, i) then
                if ballShoot.shooterId == i then
                    upperBodyAction = ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.GoalCheerShooter)
                elseif ballShoot.endPoint.z * GameHubWrap.GetPlayerPosition(i).z > 0 then
                    upperBodyAction = ActionLayerUtils.RandomChooseOneFromTable(UpperBodyAction.GoalCheerNonShooter)
                end
            end
            if upperBodyAction and upperBodyAction.actionName ~= 'Empty' then
                addUpperBodyAction(i, upperBodyAction)
            end
        end
    end
end

return UpperBodyLayerHandler
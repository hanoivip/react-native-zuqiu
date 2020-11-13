local TrainGk = class(unity.base)

local ActionConfig = require("training.ActionConfig")
local TrainConst = require("training.TrainConst")

local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time
local AvatarIKGoal = UnityEngine.AvatarIKGoal
local WaitForSeconds = UnityEngine.WaitForSeconds

function TrainGk:ctor()
    self.animator = self.___ex.animator

    self.isGoal = true
    self.startPrepare = false
    self.startMove = false
    self.startSave = false
    self.startCatch = false
    self.ikActive = false
    self.moveWeight = 0

    self.prepareAction = ActionConfig.GetOneAction("GK_PREPARE_MOTION")
    self.moveAction = self.prepareAction

    self:InitIKMap()
end

function TrainGk:InitData(trainData)
    self.trainData = trainData
end

function TrainGk:InitIKMap()
    local IKMap = {
        ["E_C001"] = AvatarIKGoal.RightHand,
        ["E_C003"] = AvatarIKGoal.RightFoot,
        ["E_C004"] = AvatarIKGoal.LeftHand,
        ["E_C004_2"] = AvatarIKGoal.RightHand,
        ["E_C004_1"] = AvatarIKGoal.RightHand,
        ["E_C004_3"] = AvatarIKGoal.LeftHand,
        ["E_C007"] = AvatarIKGoal.LeftHand,
        ["E_C007_1"] = AvatarIKGoal.RightHand,
        ["E_C006_1"] = AvatarIKGoal.RightFoot,
        ["E_C006_3"] = AvatarIKGoal.LeftFoot,
        ["E_C010"] = AvatarIKGoal.RightHand,
        ["E_C010_1"] = AvatarIKGoal.LeftHand,
        ["E_C009"] = AvatarIKGoal.RightHand,
        ["E_C009_1"] = AvatarIKGoal.LeftHand,
    }
    self.ikDict = IKMap

    self.candidateList = {}
    for k, v in pairs(IKMap) do
        table.insert(self.candidateList, k)
    end
end

function TrainGk:start()

end

function TrainGk:PlayAnimationDelay(name, delayTime)
    self:coroutine(function()
        coroutine.yield(WaitForSeconds(delayTime))
        self.animator:Play(name)
    end)
end

function TrainGk:update()
    if self.startPrepare then
        self.animator:Play(self.prepareAction)
        self:LoopPlay(self.prepareAction)
    elseif self.startMove then
        self.animator:Play(self.moveAction)
        self:LoopPlay(self.moveAction)
        self.transform.position = Vector3.Lerp(self.movePosition, self.savePosition, (Time.time - self.moveStartTime) / self.saveStartTime)
    elseif self.startSave then
        self.animator:Play(self.saveAction.name)
        self.startSave = false
    elseif self.startCatch then
        self.animator:Play(self.saveAction.name)
        self.startCatch = false
        self.startCatchStartTime = Time.time
    end
end

function TrainGk:lateUpdate()
    if self.startSave then
        self.animator:Play(self.saveAction.name)
        self.startSave = false
    end
end

function TrainGk:OnAnimatorIK()
    local ikDict = self.ikDict
    if self.ikActive then
        if saveAction ~= nil and ikDict[saveAction.name] then
            self.animator:SetIKPositionWeight(ikDict[saveAction.name], self.moveWeight)
            self.animator:SetIKPosition(ikDict[saveAction.name], self.ballTarget)
        else
            self.animator:SetIKPositionWeight(AvatarIKGoal.LeftHand, self.moveWeight)
            self.animator:SetIKPositionWeight(AvatarIKGoal.RightHand, self.moveWeight)
            self.animator:SetIKPosition(AvatarIKGoal.LeftHand, self.ballTarget)
            self.animator:SetIKPosition(AvatarIKGoal.RightHand, self.ballTarget)
        end
        self.moveWeight = Mathf.Lerp(self.moveWeight, 1.0, Time.deltaTime * 5)  --Lua assist checked flag
    else
        if saveAction ~= nil and ikDict[saveAction.name] then
            self.animator:SetIKPositionWeight(ikDict[saveAction.name], self.moveWeight)
            self.animator:SetIKPosition(ikDict[saveAction.name], self.ballTarget)
        else
            self.animator:SetIKPositionWeight(AvatarIKGoal.LeftHand, self.moveWeight)
            self.animator:SetIKPositionWeight(AvatarIKGoal.RightHand, self.moveWeight)
            self.animator:SetIKPosition(AvatarIKGoal.LeftHand, self.ballTarget)
            self.animator:SetIKPosition(AvatarIKGoal.RightHand, self.ballTarget)
        end
        self.moveWeight = Mathf.Lerp(self.moveWeight, 0, Time.deltaTime * 10)  --Lua assist checked flag
    end    
end

function TrainGk:LoopPlay(action)

end

function TrainGk:OnGoalKeeperSave(position, duration)
    self:StartMoveForCore(position, duration, false)
end

function TrainGk:StartMoveForCore(position, duration)
    -- 先随机去一个
    local action = self.candidateList[math.random(1, #self.candidateList)]
    -- local action = "E_C001" --chooseSaveMotion(position, duration, catched)
    local saveActionTable = {
        name = action,
        possessBall = false,
        firstTouchBallOffset = Vector3.zero,
        firstTouchBallTime = 0,
    }

    local tmp = position - self.transform.rotation * saveActionTable.firstTouchBallOffset
    local savePos = Vector3(tmp.x, 0, tmp.z)
    local goalRate = self:GetGoalRate(position)
    self:StartMove(self.transform.position, savePos, saveActionTable, duration - saveActionTable.firstTouchBallTime, position, goalRate)
end

function TrainGk:GetGoalRate(position)
    local maxDis = self.trainData:GetMaxGoalDistance()
    local minDis = 0
    local dis = Vector3.Distance(position, Vector3(50, 1, 0))
    local maxPercent = self.trainData:GetTrainExInfo("shoot_max_save_rate")
    local minPercent = self.trainData:GetTrainExInfo("shoot_min_save_rate")
    local ret = minPercent + (maxPercent - minPercent) * (dis - minDis) / (maxDis - minDis)
    return math.floor(ret)
end

function TrainGk:InGoalArea(target)
    if target.y > 0 and target.y < TrainConst.GOAL_CROSSBAR_HEIGHT and target.z > -TrainConst.GOAL_POST_DISTANCE_HALF and target.z < TrainConst.GOAL_POST_DISTANCE_HALF then
        return true
    end

    return false
end

function TrainGk:AdjustTarget(target, save)
    local targetRet = target
    local saveRet = save

    if targetRet.y >= TrainConst.GOAL_CROSSBAR_HEIGHT then
        targetRet.y = 2
    end
    if targetRet.z <= -TrainConst.GOAL_POST_DISTANCE_HALF then
        targetRet.z = -3.5
        saveRet.z = -3
    end
    if targetRet.z >= TrainConst.GOAL_POST_DISTANCE_HALF then
        targetRet.z = 3.5
        saveRet.z = 3
    end

    return targetRet, saveRet
end

function TrainGk:AdjustSavePosition(move, save)
    local saveRet = save
    saveRet = saveRet - Vector3.Lerp(Vector3.zero, save - move, 0.5)
    return saveRet
end

function TrainGk:StartMove(move, save, action, timePoint, target, rate)
    if tonumber(rate) > -1 then
        local tmp = math.random(0, 99)
        if tmp < tonumber(rate) then
            self.isGoal = true
        else
            self.isGoal = false
        end
    end

    if not self:InGoalArea(target) then
        target, save = self:AdjustTarget(target, save)
    end
    if self.isGoal then
        save = self:AdjustSavePosition(move, save)
    end

    if type(self.setGoal) == "function" then
        self.setGoal(self.isGoal)
    end
    -- var trainManager = TrainManager.GetInstance()  --Lua assist checked flag
    -- if (trainManager != null) {
    --     trainManager.isGoal = isGoal
    -- }
    self.startPrepare = true
    self.prepareTime = Time.time
    if timePoint < 0 then
        timePoint = 0
    end
    self.saveStartTime = timePoint
    self.saveAction = action

    if Vector3.Distance(move, save) < 1 then
        self.moveAction = ActionConfig.GetOneAction("GK_MOVE_TINY_MOTION")
    elseif timePoint < 0.5 then
        if self.isGoal then
            -- saveAction = new PlayerAction(ActionConfig.GetOneAction(ActionConfig.GK_FAIL_LEFT_MOTION)) 
            self.saveAction = {
                name = ActionConfig.GetOneAction("GK_FAIL_LEFT_MOTION"),
                possessBall = false,
                firstTouchBallOffset = Vector3.zero,
                firstTouchBallTime = 0,            
            }
            save = move
        end
        if Vector3.Dot(self.transform.right, save - move) > 0 then
            self.moveAction = ActionConfig.GetOneAction("GK_MOVE_RIGHT_MOTION")
        else
            self.moveAction = ActionConfig.GetOneAction("GK_MOVE_LEFT_MOTION")
        end
    end
    self.movePosition = move
    self.savePosition = save
    self.ballTarget = target

    clr.coroutine(function()
        coroutine.yield(WaitForSeconds(timePoint * 0.3))
        self.startPrepare = false
        self.startMove = true
        self.moveStartTime = Time.time
        self.saveStartTime = self.saveStartTime - self.moveStartTime - self.prepareTime
    end)
    clr.coroutine(function()
        coroutine.yield(WaitForSeconds(timePoint))
        self.startMove = false

        self.startSave = true
        if self.isGoal == false then
            clr.coroutine(function()
                coroutine.yield(WaitForSeconds(self.saveAction.firstTouchBallTime * 0.6))
                self.ikActive = true
                self.moveWeight = 0
            end)
            clr.coroutine(function()
                coroutine.yield(WaitForSeconds(self.saveAction.firstTouchBallTime))
                self.ikActive = false
            end)
        end
    end)
end

return TrainGk

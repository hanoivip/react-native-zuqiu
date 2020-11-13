local TrainMenuCtrl = class()

local TrainType = require("training.TrainType")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")

local CoreResultCtrl = require("ui.controllers.training.CoreResultCtrl")

local CustomEvent = require("ui.common.CustomEvent")

local trainMenuMap = {
    [TrainType.SHOOT] = "Assets/CapstonesRes/Game/UI/Scene/Training/ShootTraining.prefab",
    [TrainType.GK] = "Assets/CapstonesRes/Game/UI/Scene/Training/SaveTraining.prefab",
    [TrainType.DRIBBLE] = "Assets/CapstonesRes/Game/UI/Scene/Training/DribbleTraining.prefab",
    [TrainType.DEFEND] = "Assets/CapstonesRes/Game/UI/Scene/Training/StealTraining.prefab"
}

function TrainMenuCtrl:ctor(trainMenuTrans, trainType)
    self.trainMenuTrans = trainMenuTrans
    self.trainType = trainType
    if trainType == TrainType.DRIBBLE then
        local trainMenuObj, dialogcomp = res.ShowDialog(trainMenuMap[trainType], "overlay", false, false)
        self.trainMenuView = dialogcomp.contentcomp
    else
        local trainMenuObj, spt = res.Instantiate(trainMenuMap[trainType])
        trainMenuObj.transform:SetParent(trainMenuTrans.transform, false)
        self.trainMenuView = spt
    end

    self.playerCardsMapModel = PlayerCardsMapModel.new()
end

function TrainMenuCtrl:InitView(defendResult, trainType, life, score)
    -- self.trainMenuView:InitView(defendResult, trainType, life, score)
    self.trainMenuView:SetScore(score)
    self.trainMenuView:SetChance(life)    
end

function TrainMenuCtrl:ReplaceHead(playerObject)
end

function TrainMenuCtrl:InitDistancePanel(distance)
    self.trainMenuView:SetDistance(math.floor(distance))
end

function TrainMenuCtrl:InitScorePanel(score)
    self.trainMenuView:SetScore(score)
end

function TrainMenuCtrl:InitChancePanel(life)
    self.trainMenuView:SetChance(life)
end

function TrainMenuCtrl:InitGoalPanel(score)
    self.trainMenuView:InitGoalPanel(score)
end

function TrainMenuCtrl:InitMissPanel()
    self.trainMenuView:InitMissPanel()
end

function TrainMenuCtrl:InitGameOverPanel(gameID, pcid, score)
    self.trainMenuView:InitGameOverPanel()

    -- 发送小游戏完成请求
    clr.coroutine(function()
        local respone = req.littleGamePlay(gameID, pcid, score)
        if api.success(respone) then
            local data = respone.val
            CustomEvent.Training()
            luaevt.trig("HoolaiBISendCounterCoregame", 5, gameID, true)
            self.playerCardsMapModel:ResetCardData(data.cardInfo.pcid, data.cardInfo)

            -- 进入结算页面
            local coreResultCtrl = CoreResultCtrl.new(data.maxTimes, data.times, self.trainMenuTrans.transform)
            coreResultCtrl:InitView(PlayerCardModel.new(data.cardInfo.pcid), data.reward, data.score)
            -- 关闭自己的页面
            if type(self.trainMenuView.closeDialog) == "function" then
                self.trainMenuView.closeDialog()
            end
        end
    end)
end

return TrainMenuCtrl

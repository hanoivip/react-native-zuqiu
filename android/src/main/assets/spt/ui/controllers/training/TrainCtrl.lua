local BaseCtrl = require("ui.controllers.BaseCtrl")
local TrainType = require("training.TrainType")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local MenuBarCtrl = require("ui.controllers.common.MenuBarCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")

local TrainModel = require("ui.models.training.TrainModel")

local TrainCtrl = class(BaseCtrl, "TrainCtrl")

TrainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Training/Training.prefab"

function TrainCtrl:Init()
    self.view:RegOnInfoBarDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self.view:PlayLeaveAnimation()
        end)
        self.view:RegOnLeave(function()
            res.PopScene()
        end)
    end)

    self.view.clickShoot = function()
        self:ChoosePlayer(TrainType.SHOOT, "101")
    end
    self.view.clickSave = function()
        self:ChoosePlayer(TrainType.GK, "401")
    end
    self.view.clickDribble = function()
        self:ChoosePlayer(TrainType.DRIBBLE, "201")
    end
    self.view.clickDefend = function()
        self:ChoosePlayer(TrainType.DEFEND, "301")
    end
    self.view.clickTheory = function()
        self:ChoosePlayer(TrainType.BRAIN, "501")
    end
    self.view.clickRank = function()
        self:ClickRank()
    end

    self.menuBarCtrl = MenuBarCtrl.new(self.view.menuBarDynParent, self)
end

function TrainCtrl:AheadRequest()
    local response = req.littleGameInfo()
    if api.success(response) then
        local data = response.val
        self.trainModel = TrainModel.new()
        self.trainModel:InitWithProtocol(data)
    end
end

function TrainCtrl:Refresh()
    TrainCtrl.super.Refresh(self)
    self:InitView()
end

function TrainCtrl:InitView()
    self.view:InitView(self.trainModel)
end

function TrainCtrl:ClickRank()
    res.PushScene("ui.controllers.training.rank.TrainRankCtrl", self.trainModel:GetQuestionOpenState())
end

function TrainCtrl:ChoosePlayer(trainType, gameID)
    if gameID == "501" then -- 脑力训练次数与其他训练不共用
        if self.trainModel:GetQuestionRemainTimes() <= 0 then
            return
        end
    elseif self.trainModel:GetRemainingTimes() <= 0 then
        DialogManager.ShowToast(lang.trans("training_tips1"))
        return
    end
    local remainingTimes = self.trainModel:GetRemainingTimes()
    local questionRemainTimes = self.trainModel:GetQuestionRemainTimes()
    local residualTime = gameID ~= "501" and remainingTimes or questionRemainTimes
    res.PushDialog("ui.controllers.training.TrainListCtrl", trainType, gameID, self, residualTime)
end

return TrainCtrl

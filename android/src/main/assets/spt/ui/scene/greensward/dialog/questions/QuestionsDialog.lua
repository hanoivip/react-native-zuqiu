local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local QuestionsDialog = class(unity.base)

function QuestionsDialog:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.unlockTxt = self.___ex.unlockTxt
    self.startBtn = self.___ex.startBtn
    self.consumeCountTxt = self.___ex.consumeCountTxt
    self.moraleGo = self.___ex.moraleGo
    self.fightGo = self.___ex.fightGo
    self.closeBtnSpt = self.___ex.closeBtnSpt
    self.rewardTrans = self.___ex.rewardTrans
--------End_Auto_Generate----------
end

function QuestionsDialog:start()
	DialogAnimation.Appear(self.transform)
    self.closeBtnSpt:regOnButtonClick(function()
        self:Close()
    end)
    self.startBtn:regOnButtonClick(function()
        self:OnStartClick()
    end)
end

function QuestionsDialog:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function QuestionsDialog:OnStartClick()
    if self.onStartClick then
        self.onStartClick()
    end
end

function QuestionsDialog:InitView(eventModel)
    self.eventModel = eventModel
    self.titleTxt.text = eventModel:GetEventName()
    local blockPoint = eventModel:GetBlockPoint()
    self.unlockTxt.text = lang.trans("unlock_terrain_condition", blockPoint)
    self:SetConsumeBtn()
    self:InitRewardArea()
end

function QuestionsDialog:InitRewardArea()
    local rewardData = self.eventModel:GetRewardData()
    res.ClearChildren(self.rewardTrans)
    for i, v in ipairs(rewardData) do
        local rewardParams = {
            parentObj = self.rewardTrans,
            rewardData = v.contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
end

function QuestionsDialog:SetConsumeBtn()
    local moraleState = self.eventModel:ConsumeByMorale()
    local powerState = self.eventModel:ConsumeByPower()
    local count = 0
    local color = self.consumeCountTxt.color
    if moraleState then
        local starSymbol = 0
        count, starSymbol = self.eventModel:GetConsumeMorale()
        local r, g, b = self.eventModel:GetConvertColor(starSymbol)
        color = ColorConversionHelper.ConversionColor(r, g, b)
    elseif powerState then
        count = self.eventModel:GetConsumeFight()
    end
    GameObjectHelper.FastSetActive(self.fightGo, powerState)
    GameObjectHelper.FastSetActive(self.moraleGo, moraleState)
    self.consumeCountTxt.text = "x" .. count
    self.consumeCountTxt.color = color
end

return QuestionsDialog

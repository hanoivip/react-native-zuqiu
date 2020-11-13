local UnityEngine = clr.UnityEngine
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TreasureDialog = class(unity.base)

-- 奖励显示的最大个数
local Max_Line = 4

function TreasureDialog:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.unlockTxt = self.___ex.unlockTxt
    self.startBtn = self.___ex.startBtn
    self.consumeCountTxt = self.___ex.consumeCountTxt
    self.moraleGo = self.___ex.moraleGo
    self.fightGo = self.___ex.fightGo
    self.rewardTrans = self.___ex.rewardTrans
    self.closeBtnSpt = self.___ex.closeBtnSpt
--------End_Auto_Generate----------
    self.scrollRect = self.___ex.scrollRect
end

function TreasureDialog:start()
    DialogAnimation.Appear(self.transform)
    self.closeBtnSpt:regOnButtonClick(function()
        self:Close()
    end)
    self.startBtn:regOnButtonClick(function()
        self:OnStartClick()
    end)
end

function TreasureDialog:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function TreasureDialog:OnStartClick()
    if self.onStartClick then
        self.onStartClick()
    end
end

function TreasureDialog:InitView(eventModel)
    self.eventModel = eventModel
    self.titleTxt.text = eventModel:GetEventName()
    local blockPoint = eventModel:GetBlockPoint()
    self.unlockTxt.text = lang.trans("unlock_terrain_condition", blockPoint)
    self:SetConsumeBtn()
    self:InitRewardArea()
end

function TreasureDialog:SetConsumeBtn()
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

function TreasureDialog:InitRewardArea()
    local rewardData = self.eventModel:GetRewardData()
    res.ClearChildren(self.rewardTrans)
    for i, v in ipairs(rewardData) do
        local rewardParams = {
            parentObj = self.rewardTrans,
            rewardData = v.contents,
            isShowName = true,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end

    -- 对奖励个数进行适配
    if self.rewardTrans.childCount > Max_Line then
        self:coroutine(function()
            unity.waitForNextEndOfFrame()
            unity.waitForNextEndOfFrame()
            self.scrollRect.horizontalNormalizedPosition = 0
            self.scrollRect.enabled = true
        end)
    else
        self.scrollRect.enabled = false
    end
end

return TreasureDialog

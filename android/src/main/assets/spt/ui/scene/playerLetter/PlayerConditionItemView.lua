local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Image = UnityEngine.UI.Image
local AssetFinder = require("ui.common.AssetFinder")
local Card = require("data.Card")
local CardQuality = require("data.CardQuality")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local PlayerConditionItemView = class(unity.base)

function PlayerConditionItemView:ctor()
    -- 头像框
    self.avatarBox = self.___ex.avatarBox
    -- 完成标志
    self.doneIcon = self.___ex.doneIcon
    self.maskBtn = self.___ex.maskBtn
    -- 条件数据
    self.conditionData = nil
    -- 卡牌模型
    self.playerCardModel = nil
    -- 是否拥有该卡牌
    self.isOwnCard = nil
end

function PlayerConditionItemView:InitView(conditionData)
    self.conditionData = conditionData
    local playerCardsMapModel = PlayerCardsMapModel.new()
    self.isOwnCard = playerCardsMapModel:IsExistCardID(conditionData.id)
    self.playerCardModel = StaticCardModel.new(conditionData.id)
    local pcId = playerCardsMapModel:GetPcidByCid(conditionData.id)
    self.isOwnCard = pcId
    self:BuildPage()
    self:BindAll()
end

function PlayerConditionItemView:BindAll()
    self.maskBtn:regOnButtonClick(function ()
        EventSystem.SendEvent("PlayerLetterDetail.ShowCardDetail", self.conditionData.id)
        EventSystem.SendEvent("ActivityPlayerLetterDetail.ShowCardDetail", self.conditionData.id)
    end)
end

function PlayerConditionItemView:BuildPage()
    if self.conditionData.isFinished then
        self.doneIcon:SetActive(true)
    else
        self.doneIcon:SetActive(false)
    end

    local rewardParams = {
        parentObj = self.avatarBox,
        rewardData = {card = {{id = self.conditionData.id}}},
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
    }

    if self.isOwnCard then
        local playerCardMode = PlayerCardModel.new(self.isOwnCard)
        rewardParams.cardLv = playerCardMode:GetLevel()
    end

    RewardDataCtrl.new(rewardParams)

    if not self.isOwnCard then
        local imgComps = clr.table(self.gameObject:GetComponentsInChildren(Image))
        for i, v in ipairs(imgComps) do
            v.color = Color(v.color.r * 0.6, v.color.g * 0.6, v.color.b * 0.6, v.color.a)
        end
    end
end

function PlayerConditionItemView:SetActivityPlayerLetterOwnState(isOwnCardState)
    if isOwnCardState == -1 then
        local imgComps = clr.table(self.gameObject:GetComponentsInChildren(Image))
        for i, v in ipairs(imgComps) do
            v.color = Color(v.color.r * 0.6, v.color.g * 0.6, v.color.b * 0.6, v.color.a)
        end
    end
end

return PlayerConditionItemView

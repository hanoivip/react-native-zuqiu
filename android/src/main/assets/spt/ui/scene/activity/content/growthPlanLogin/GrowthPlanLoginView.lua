local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local CardIndexModel = require("ui.models.cardIndex.CardIndexModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local MenuType = require("ui.controllers.playerList.MenuType")
local CardOpenFromType = require("ui.controllers.cardDetail.CardOpenFromType")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local GrowthPlanLoginView = class(ActivityParentView)

function GrowthPlanLoginView:ctor()
    self.staticCardArea = self.___ex.staticCardArea
    self.rewardScrollView = self.___ex.rewardScrollView
    self.buyButton = self.___ex.buyButton
    self.btnBuy = self.___ex.btnBuy
    self.content = self.___ex.content
    self.currencyIcon = self.___ex.currencyIcon
    self.needCountText = self.___ex.needCountText
    self.btnSeventhCollectSpt = self.___ex.btnSeventhCollectSpt
    self.btnSeventhCollectButton = self.___ex.btnSeventhCollectButton
    self.seventhCollectedObj = self.___ex.seventhCollectedObj
    self.seventhBtnText = self.___ex.seventhBtnText
    self.residualTimeText = self.___ex.residualTimeText
    self.beforeBuyObj = self.___ex.beforeBuyObj
    self.afterBuyObj = self.___ex.afterBuyObj
    self.seventhEffect = self.___ex.seventhEffect
end

function GrowthPlanLoginView:start()
    self.buyButton:regOnButtonClick(function()
        if self.clickBuyBtn then
            self.clickBuyBtn()
        end
    end)

    self.btnSeventhCollectSpt:regOnButtonClick(function()
        if self.clickSeventhBtn then
            self.clickSeventhBtn(self.isEnable)
        end
    end)
end

function GrowthPlanLoginView:InitView(activityModel)
    self.activityModel = activityModel
    self:InitRewardScrollArea()
    self:InitSeventhRewardArea()
    self:InitBuyButtonView()
    self:InitSeventhBtnState()
end

function GrowthPlanLoginView:InitBuyButtonView()
    local buyType = self.activityModel:GetPayType()
    local needCount = self.activityModel:GetBuyPrice()
    self.currencyIcon.overrideSprite = res.LoadRes(CurrencyImagePath[buyType])
    self.needCountText.text = tostring(needCount)
    local isBuy = self.activityModel:GetIsBuy()
    self.btnBuy.interactable = not isBuy
    GameObjectHelper.FastSetActive(self.beforeBuyObj, not isBuy)
    GameObjectHelper.FastSetActive(self.afterBuyObj, isBuy)
end

function GrowthPlanLoginView:InitSeventhBtnState()
    local data = self.activityModel:GetSeventhRewardData()
    if not data or not next(data) then return end

    local isCollected = data.status == 1
    local isInteractable = data.status == 0
    self.isEnable = isInteractable
    self.btnSeventhCollectButton.interactable = isInteractable
    GameObjectHelper.FastSetActive(self.seventhEffect, isInteractable)
    GameObjectHelper.FastSetActive(self.seventhCollectedObj, isCollected)
    GameObjectHelper.FastSetActive(self.btnSeventhCollectSpt.gameObject, not isCollected)
    if isInteractable then
        self.seventhBtnText.text = lang.transstr("mail_collectRewards")
        self.seventhBtnText.gameObject:GetComponent("GradientText").enabled = true
    else
        self.seventhBtnText.text = lang.transstr("time_limit_growthPlan_desc4")
        self.seventhBtnText.gameObject:GetComponent("GradientText").enabled = false
    end
end

function GrowthPlanLoginView:InitRewardScrollArea()
    local dataList = self.activityModel:GetRewardList()
    local rewardList = self:DataListPretreatment(dataList)
    self.rewardScrollView:InitView(rewardList, self.activityModel)
end

function GrowthPlanLoginView:InitSeventhRewardArea()
    self.cardResourceCache = CardResourceCache.new()
    self.cardIndexModel = CardIndexModel.new()
    local cardID = self.activityModel:GetRewardCardID()
    if not cardID or cardID == "" then return end
    local cardModel = self.cardIndexModel:GetCardModel(cardID)
    self:CreateOneCardHere(cardModel)

    self:InitSeventhScrollRect()
end

function GrowthPlanLoginView:InitSeventhScrollRect()
    local data = self.activityModel:GetSeventhRewardData()
    if not data or not next(data) then return end
    self.model = data
    res.ClearChildren(self.content)

    local rewardParams = {
        parentObj = self.content,
        rewardData = self.model.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowCardPieceBeforeItem = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function GrowthPlanLoginView:CreateOneCardHere(cardModel)
    local scaleFactor = 1
    local scaleVector = Vector3Lua(scaleFactor, scaleFactor, 1)
    local obj = self:CreateOnePrefab(scaleVector, cardModel)

    obj.transform:SetParent(self.staticCardArea, false)
    obj.transform.localPosition = Vector3(0, 0, 0)
end

function GrowthPlanLoginView:CreateOnePrefab(scaleValueVector, prefabData)
    local obj = Object.Instantiate(self:GetPlayerRes())
    obj.transform.localScale = self:ConvertVector3(scaleValueVector)
    obj.transform.pivot = Vector2(0.5, 0.5)
    obj.transform.anchorMin = Vector2(0.5, 0.5)
    obj.transform.anchorMax = Vector2(0.5, 0.5)

    return self:ResetOnePrefab(obj, prefabData)
end

function GrowthPlanLoginView:ResetOnePrefab(obj, prefabData)
    local spt = res.GetLuaScript(obj)
    local itemData = prefabData
    spt:InitView(itemData, MenuType.LIST, self.cardIndexModel, self.cardResourceCache, self)
    itemData:InitEquipsAndSkills()
    spt:SetCardTip(false)
    spt:SetNameBg(false)
    GameObjectHelper.FastSetActive(spt.message, false)
    spt.clickCard = function() self:OnCardClick(itemData:GetCid()) end

    return obj
end

function GrowthPlanLoginView:OnCardClick(cid)
    local cardList = {}
    table.insert(cardList, cid)
    local currentModel = CardBuilder.GetBaseCardModel(cid)
    currentModel:SetIsPasterPokedex(true)
    currentModel:SetOpenFromPageType(CardOpenFromType.HANDBOOK)
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        local CardDetailMainCtrl = res.PushSceneImmediate("ui.controllers.cardDetail.CardDetailMainCtrl", cardList, 1, currentModel)
    end)
end

function GrowthPlanLoginView:GetCardRes()
    if not self.cardRes then 
        self.cardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    end
    return self.cardRes
end

function GrowthPlanLoginView:GetPlayerRes()
    if not self.playerRes then 
        self.playerRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Player.prefab")
    end
    return self.playerRes
end

function GrowthPlanLoginView:DataListPretreatment(rewardList)
    for k, v in pairs(rewardList) do
        local count = 0
        for key, value in pairs(v.contents) do
            if type(value) == "table" then
                for kk, vv in pairs(value) do
                    count = count + 1
                end
            else
                count = count + 1
            end
        end
        v.contentsCount = count
    end

    return rewardList
end

function GrowthPlanLoginView:ConvertVector3(vector)
    return Vector3(vector.x, vector.y, vector.z)
end

function GrowthPlanLoginView:onDestroy()
end

return GrowthPlanLoginView
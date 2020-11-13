local DialogManager = require("ui.control.manager.DialogManager")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerRecycleView = class(unity.base, "PlayerRecycleView")

function PlayerRecycleView:ctor()
    self.cardParentTrans = self.___ex.cardParentTrans
    self.labelArea = self.___ex.labelArea
    self.moneyBtn = self.___ex.moneyBtn
    self.diamondBtn = self.___ex.diamondBtn
    self.bkdBtn = self.___ex.bkdBtn
    self.recycleBtn = self.___ex.recycleBtn
    self.toggleSelectTrans = self.___ex.toggleSelectTrans
    self.itemTitle = self.___ex.itemTitle
    self.contentParent = self.___ex.contentParent
    self.moneyPrice = self.___ex.moneyPrice
    self.diamondPrice = self.___ex.diamondPrice
    self.bkdPrice = self.___ex.bkdPrice
    self.infobarView = self.___ex.infobarView
    self.availableBtn = self.___ex.availableBtn
    self.notAvailableBtn = self.___ex.notAvailableBtn
    self.helpBtn = self.___ex.helpBtn
    self.close = self.___ex.close
    self.moneyGo = self.___ex.moneyGo
    self.diamondGo = self.___ex.diamondGo
    self.bkdGo = self.___ex.bkdGo
end
function PlayerRecycleView:start()
    self.close:regOnButtonClick(function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
    self.moneyBtn:regOnButtonClick(function()
        self:OnToggleClick(self.moneyBtn.transform, "m")
    end)
    self.diamondBtn:regOnButtonClick(function()
        self:OnToggleClick(self.diamondBtn.transform, "d")
    end)
    self.bkdBtn:regOnButtonClick(function()
        self:OnToggleClick(self.bkdBtn.transform, "bkd")
    end)
    self.recycleBtn:regOnButtonClick(function()
        self:OnRecycleClick()
    end)
    self.helpBtn:regOnButtonClick(function()
        self:OnHelpClick()
    end)
	DialogAnimation.Appear(self.transform)
end

function PlayerRecycleView:InitView(playerRecycleModel)
    self.playerRecycleModel = playerRecycleModel
    local cardModel = playerRecycleModel:GetCarModel()
    self:InitCardArea(cardModel)
    self:InitLableArea()
    self:InitToggleArea()
end

function PlayerRecycleView:InitCardArea(cardModel)
    if not self.cardView then
        local cardObject, cardSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        cardObject.transform:SetParent(self.cardParentTrans, false)
        self.cardView = cardSpt
        self.cardView:IsShowName(false)
    end
    self.cardView:InitView(cardModel)
end

function PlayerRecycleView:InitLableArea()
    local lableContent = self.playerRecycleModel:GetLableContent()
    local defaultTag = self.playerRecycleModel:GetDefaultTag()
    local onLableClickFunc = function(tag, lableSpt, lableData)
        if lableData.isOpen then
            local cost = self.playerRecycleModel:GetBKDCost(tag)
            if type(cost) == "number" and cost > 0 then
                self.playerRecycleModel:SetCurrentTag(tag)
                self.playerRecycleModel:SetCurrentLableData(lableData)
                local costType = self.playerRecycleModel:GetCurrentCostType()
                self:ChangeLabelSelectTag(tag)
                self:InitToggleArea()
                self:RefreshItemArea()
            else
                DialogManager.ShowToastByLang("recycle_none_tips")
            end
        else
            DialogManager.ShowToastByLang("commingSoon")
        end
    end
    self.labelArea:InitView(lableContent, onLableClickFunc, defaultTag)
end

function PlayerRecycleView:ChangeLabelSelectTag(tag)
    self.labelArea:ChangeSelectTag(tag)
end

function PlayerRecycleView:InitToggleArea()
    local tag = self.playerRecycleModel:GetCurrentTag()
    local m, d, bkd = self.playerRecycleModel:GetPrice(tag)
    local currencyType = CurrencyType.Money
    local currencyTrans = self.moneyBtn.transform
    if bkd > 0 then
        currencyType = CurrencyType.BlackDiamond
        currencyTrans = self.bkdBtn.transform
    end
    if d > 0 then
        currencyType = CurrencyType.Diamond
        currencyTrans = self.diamondBtn.transform
    end
    if m > 0 then
        currencyType = CurrencyType.Money
        currencyTrans = self.moneyBtn.transform
    end
    self:OnToggleClick(currencyTrans, currencyType)
    self.moneyPrice.text = " X".. string.formatIntWithTenThousands(m)
    self.diamondPrice.text = " X".. d
    self.bkdPrice.text = " X".. bkd
    GameObjectHelper.FastSetActive(self.moneyGo, m > 0)
    GameObjectHelper.FastSetActive(self.diamondGo, d > 0)
    GameObjectHelper.FastSetActive(self.bkdGo, bkd > 0)
end

function PlayerRecycleView:OnToggleClick(parentTrans, costType)
    self.costType = costType
    self.toggleSelectTrans:SetParent(parentTrans, false)
    self.playerRecycleModel:SetCurrentCostType(costType)
    self:RefreshItemArea()
    local nowTag = self.playerRecycleModel:GetCurrentTag()
    local nowCost = self.playerRecycleModel:GetNowCost(nowTag, costType) or 0
    GameObjectHelper.FastSetActive(self.availableBtn, nowCost >= 0)
    GameObjectHelper.FastSetActive(self.notAvailableBtn, nowCost < 0)
end

function PlayerRecycleView:RefreshItemArea()
    local lableData = self.playerRecycleModel:GetCurrentLableData()
    local costType = self.playerRecycleModel:GetCurrentCostType()
    local tag = lableData.tag
    local itemData = self.playerRecycleModel:GetRecycleItemContent(tag, costType)
    self.itemTitle.text = lang.trans(lableData.labelName)
    res.ClearChildren(self.contentParent)
    if itemData then
        local rewardParams = {
            parentObj = self.contentParent,
            rewardData = itemData,
            isShowName = true,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = false,
        }
        RewardDataCtrl.new(rewardParams)
    end
end

function PlayerRecycleView:OnRecycleClick()
    if type(self.clickRecycle) == "function" then
        self.clickRecycle()
    end
end

function PlayerRecycleView:OnHelpClick()
    if type(self.clickHelp) == "function" then
        self.clickHelp()
    end
end

function PlayerRecycleView:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

return PlayerRecycleView
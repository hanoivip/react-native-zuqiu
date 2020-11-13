local ItemModel = require("ui.models.ItemModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local InfoBarCtrl = require("ui.controllers.common.AssistCoachGachaInfoBarCtrl")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local AssistCoachGachaModel = require("ui.models.coach.assistCoachGacha.AssistCoachGachaModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local ItemsMapModel = require("ui.models.ItemsMapModel")

local AssistCoachGachaCtrl = class(BaseCtrl, "AssistCoachGachaCtrl")

AssistCoachGachaCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachGacha/AssistantCoachGacha.prefab"

local DefaultTabIndex = 1

function AssistCoachGachaCtrl:AheadRequest()
    local response = req.getAssistantCoachGacha()
    if api.success(response) then
        local data = response.val
        if not self.assistCoachGachaModel then
            self.assistCoachGachaModel = AssistCoachGachaModel.new()
        end
        if type(data) == "table" and next(data) then
            self.assistCoachGachaModel:InitWithProtocol(data)
        end
    end
end

function AssistCoachGachaCtrl:ctor()
    AssistCoachGachaCtrl.super.ctor(self)
end

function AssistCoachGachaCtrl:Init()
    AssistCoachGachaCtrl.super.Init(self)
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self.assistCoachGachaModel)
    end)

    self.view.onOneBtnClick = function() self:OnClickOneBtn() end
    self.view.onTenBtnClick = function() self:OnClickTenBtn() end
    self.view.onExchangeBtnClick = function() self:OnClickExchangeBtn() end
    self.view.onArrowRightBtnClick = function() self:OnClickArrowRightBtn() end
    self.view.onArrowLeftBtnClick = function() self:OnClickArrowLeftBtn() end
    self.playerInfoModel = PlayerInfoModel.new()
    self.itemsMapModel = ItemsMapModel.new()
end

function AssistCoachGachaCtrl:Refresh(tabIndex)
    AssistCoachGachaCtrl.super.Refresh(self)
    if not self.assistCoachGachaModel then
        self.assistCoachGachaModel = AssistCoachGachaModel.new()
    end
    self.view:InitView(self.assistCoachGachaModel)
    self:ChangeTabIndex(tabIndex)
    GuideManager.Show(self)
end

function AssistCoachGachaCtrl:OnClickOneBtn()
    local gachaId = self.assistCoachGachaModel:GetCurrentGachaId()
    local consumeType = self.assistCoachGachaModel:GetCachaOneConsumeType(gachaId)

    local costCount = 1
    local costName = ""
    if consumeType == self.assistCoachGachaModel.Item_Gacha then
        local id = self.assistCoachGachaModel:GetCachaOneItemId(gachaId)
        local itemModel = ItemModel.new(id)
        costName = itemModel:GetName()
    else
        costCount = self.assistCoachGachaModel:GetCachaOnePrice(gachaId)
        costName = lang.transstr("diamond")  -- 钻石
    end

    local title = lang.transstr("coach_gacha_month_one") -- 单次搜寻
    local msg = lang.transstr("coach_gacha_consume_tip", costName, costCount, title) -- 确认消耗xx xxx进行单次搜寻
    DialogManager.ShowConfirmPop(title, msg, function()
        if self.consumeType == self.assistCoachGachaModel.Item_Gacha then
            self:Buy(1, gachaId, consumeType)
        else
            CostDiamondHelper.CostDiamond(costCount, self.view, function() self:Buy(1, gachaId, consumeType) end)
        end
    end)
end

function AssistCoachGachaCtrl:OnClickTenBtn()
    local gachaId = self.assistCoachGachaModel:GetCurrentGachaId()
    local consumeType = self.assistCoachGachaModel:GetCachaTenConsumeType(gachaId)

    local costCount = 1
    local costName = ""
    if consumeType == self.assistCoachGachaModel.Item_Gacha then
        local id = self.assistCoachGachaModel:GetCachaTenItemId(gachaId)
        local itemModel = ItemModel.new(id)
        costName = itemModel:GetName()
    else
        costCount = self.assistCoachGachaModel:GetCachaTenDiscountPrice(gachaId)
        costName = lang.transstr("diamond")  -- 钻石
    end

    local title = lang.transstr("coach_gacha_month_ten") -- 十次搜寻
    local msg = lang.transstr("coach_gacha_consume_tip", costName, costCount, title) -- 确认消耗xx xxx进行十次搜寻
    DialogManager.ShowConfirmPop(title, msg, function()
        if self.consumeType == self.assistCoachGachaModel.Item_Gacha then
            self:Buy(10, gachaId, consumeType)
        else
            CostDiamondHelper.CostDiamond(costCount, self.view, function() self:Buy(10, gachaId, consumeType) end)
        end
    end)
end

function AssistCoachGachaCtrl:OnClickExchangeBtn()
    local gachaId = self.assistCoachGachaModel:GetCurrentGachaId()
    local luckyPointReward = self.assistCoachGachaModel:GetCachaLuckyPointReward(gachaId)
    local luckyPoint = self.assistCoachGachaModel:GetLuckyPoint()
    local isLackLuckyPoint = luckyPoint < luckyPointReward

    local giftContent = self.assistCoachGachaModel:GetGiftContent(gachaId)
    res.PushDialog("ui.controllers.coach.assistCoachGacha.CoachGachaOptionRewardCtrl", giftContent, gachaId, isLackLuckyPoint)
end

function AssistCoachGachaCtrl:ExchangeGift(gachaId, giftId)
    self.view:coroutine(function()
        local respone = req.exchangeAssistantCoachGift(gachaId, giftId)
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) then
                CongratulationsPageCtrl.new(data.contents)
                self:OnExchangeGift(gachaId, data)
            end
        end
    end)
end

function AssistCoachGachaCtrl:OnExchangeGift(gachaId, data)
    local cost = data.cost
    if cost.type == "aclp" then
        self.assistCoachGachaModel:SetLuckyPoint(cost.curr_num)
    end
    self.assistCoachGachaModel:SetCachaMonthExchangeTimes(data.monthExchangeTimes)
    local scrollPos = self.view.tabListScroll:GetScrollNormalizedPosition()
    self.view:InitView(self.assistCoachGachaModel, scrollPos)
    self:ChangeTabIndex(gachaId)
end

function AssistCoachGachaCtrl:OnClickArrowRightBtn()
    local gachaId = self.assistCoachGachaModel:GetCurrentGachaId()
    local nextGachaId = self.assistCoachGachaModel:GetNextGachaId(gachaId)
    if nextGachaId then
        self:ChangeTabIndex(nextGachaId)
        self.assistCoachGachaModel:SetCurrentGachaId(nextGachaId)
        local scrollPos = self.view.tabListScroll:GetScrollNormalizedPosition()
        self.view:InitView(self.assistCoachGachaModel, scrollPos)
        local scrollIndex = self.assistCoachGachaModel:GetScrollIndexByGachaId(nextGachaId)
        self.view.tabListScroll:scrollToCellEx(scrollIndex)
    end
end

function AssistCoachGachaCtrl:OnClickArrowLeftBtn()
    local gachaId = self.assistCoachGachaModel:GetCurrentGachaId()
    local preGachaId = self.assistCoachGachaModel:GetPreGachaId(gachaId)
    if preGachaId then
        self:ChangeTabIndex(preGachaId)
        self.assistCoachGachaModel:SetCurrentGachaId(preGachaId)
        local scrollPos = self.view.tabListScroll:GetScrollNormalizedPosition()
        self.view:InitView(self.assistCoachGachaModel, scrollPos)
        local scrollIndex = self.assistCoachGachaModel:GetScrollIndexByGachaId(preGachaId)
        self.view.tabListScroll:scrollToCellEx(scrollIndex)
    end
end

function AssistCoachGachaCtrl:Buy(times, gachaId, consumeType)
    self.view:coroutine(function()
        local respone = req.buyAssistantCoachGift(gachaId, times, consumeType)
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) then
                self:ShowReward(data.contents, gachaId)
                self:OnBuyRefresh(data, gachaId)
            end
        end
    end)
end

function AssistCoachGachaCtrl:OnBuyRefresh(data, gachaId)
    self.assistCoachGachaModel:SetLuckyPoint(data.luckyPoint or data.lickyPoint)
    self.assistCoachGachaModel:SetMonthBuyTimes(data.monthBuyTimes)
    self.playerInfoModel:CostDetail(data.cost)
    self.itemsMapModel:UpdateFromReward(data.cost)
    local scrollPos = self.view.tabListScroll:GetScrollNormalizedPosition()
    self.view:InitView(self.assistCoachGachaModel, scrollPos)
    self:ChangeTabIndex(gachaId)
end

-- 抽卡一个物品和多个物品的展示不一样
function AssistCoachGachaCtrl:ShowReward(reward, gachaId)
    if type(reward) == "table" then
        if #reward > 1 then
            res.PushDialog("ui.controllers.coach.assistCoachGacha.CoachGachaRewardCtrl", reward, gachaId, self.assistCoachGachaModel)
        else
            CongratulationsPageCtrl.new(reward[1].contents)
        end
    end
end

function AssistCoachGachaCtrl:ChangeTabIndex(tabIndex)
    local scrollIndex = self.assistCoachGachaModel:GetScrollIndexByGachaId(tabIndex)
    self.view:ChageArrowState(scrollIndex)
    tabIndex = tabIndex or DefaultTabIndex
    EventSystem.SendEvent("CoachGachaTabItemView_SetSelectStateByIndex", tabIndex)
end

function AssistCoachGachaCtrl:GetStatusData()
end

function AssistCoachGachaCtrl:OnEnterScene()
    self:RegEvent()
    self.view:OnEnterScene()
end

function AssistCoachGachaCtrl:OnExitScene()
    self:UnRegEvent()
    self.view:OnExitScene()
end

function AssistCoachGachaCtrl:RegEvent()
    EventSystem.AddEvent("AssistCoachGachaCtrl_OnTabCkick", self, self.OnTabCkick)
    EventSystem.AddEvent("AssistCoachGachaCtrl_GachaTimeOut", self, self.GachaTimeOut)
    EventSystem.AddEvent("AssistCoachGachaCtrl_OnExchangeGift", self, self.OnExchangeGift)
    EventSystem.AddEvent("AssistCoachGachaCtrl_OnBuyRefresh", self, self.OnBuyRefresh)
    EventSystem.AddEvent("CongratulationsPageClosed", self, self.OnRewardClosed)
    
end

function AssistCoachGachaCtrl:UnRegEvent()
    EventSystem.RemoveEvent("AssistCoachGachaCtrl_OnTabCkick", self, self.OnTabCkick)
    EventSystem.RemoveEvent("AssistCoachGachaCtrl_GachaTimeOut", self, self.GachaTimeOut)
    EventSystem.RemoveEvent("AssistCoachGachaCtrl_OnExchangeGift", self, self.OnExchangeGift)
    EventSystem.RemoveEvent("AssistCoachGachaCtrl_OnBuyRefresh", self, self.OnBuyRefresh)
    EventSystem.RemoveEvent("CongratulationsPageClosed", self, self.OnRewardClosed)
end

function AssistCoachGachaCtrl:OnTabCkick(gachaData)
    local gachaId = gachaData.gachaId
    self.assistCoachGachaModel:SetCurrentGachaId(gachaId)
    local scrollPos = self.view.tabListScroll:GetScrollNormalizedPosition()
    self.view:InitView(self.assistCoachGachaModel, scrollPos)
    local scrollIndex = self.assistCoachGachaModel:GetScrollIndexByGachaId(gachaId)
    self.view:ChageArrowState(scrollIndex)
end

function AssistCoachGachaCtrl:GachaTimeOut()
    self.view:coroutine(function()
        local respone = req.getAssistantCoachGacha()
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) then
                local gachaId = self.assistCoachGachaModel:GetCurrentGachaId()
                if type(data) == "table" and next(data) then
                    self.assistCoachGachaModel:InitWithProtocol(data)
                end
                local scrollPos = self.view.tabListScroll:GetScrollNormalizedPosition()
                self.view:InitView(self.assistCoachGachaModel, scrollPos)
                self:ChangeTabIndex(gachaId)
            end
        end
    end)
end

-- 根据抽卡结果选择是否进行引导
function AssistCoachGachaCtrl:OnRewardClosed(rewardData)
    if rewardData.cti then
        GuideManager.InitCurModule("assistantcoach2")
        GuideManager.Show(self)
    end
end

return AssistCoachGachaCtrl

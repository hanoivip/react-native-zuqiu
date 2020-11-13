local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local EventSystem = require("EventSystem")

local FanShopBroadView = class(ActivityParentView)

function FanShopBroadView:ctor()
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.timeTxt = self.___ex.timeTxt
    self.recycleBtn = self.___ex.recycleBtn
    self.fanCoinCount = self.___ex.fanCoinCount
    self.residualTimer = nil
    self:RegBtn()
    self:OnCreateItem()
end

function FanShopBroadView:RegBtn()
    self.recycleBtn:regOnButtonClick(function()
        self:OnClickRecycle()
    end)
end

function FanShopBroadView:InitView(fanShopModel)
    self.fanShopModel = fanShopModel
    local startTime = self.fanShopModel:GetBeginTime()
    local endTime = self.fanShopModel:GetEndTime()
    startTime = string.convertSecondToMonth(startTime)
    endTime = string.convertSecondToMonth(endTime)
    self.timeTxt.text = lang.trans("cumulative_pay_time", startTime, endTime)
    self:RefreshFanCoin()
    self.activityDes.text = self.fanShopModel:GetActivityDesc()
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        self.fanCoinCount.gameObject:SetActive(false)
        unity.waitForNextEndOfFrame()
        self.fanCoinCount.gameObject:SetActive(true)
    end)
end

function FanShopBroadView:RefreshFanCoin()
    self.fanCoinCount.text = "x" .. self.fanShopModel:GetCoinCount()
end

function FanShopBroadView:RefreshContent()
    self.scrollView.itemDatas = self.fanShopModel:GetGiftBoxInfo()
    self.scrollView:refresh()
end

function FanShopBroadView:OnCreateItem()
    self.scrollView:regOnCreateItem(function(scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/FanShop/FanShopItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        spt.onClickBuy = function(itemData, num, buyCallBack) self:OnClickBuy(itemData, num, buyCallBack) end
        scrollSelf:resetItem(spt, index)
        return obj, spt
    end)
    self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
        local itemData = self.scrollView.itemDatas[index]
        spt:InitView(itemData)
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function FanShopBroadView:OnClickBuy(itemData, num, buyCallBack)
    if self.onClickBuy then
        self.onClickBuy(itemData, num, buyCallBack)
    end
end

function FanShopBroadView:OnClickRecycle()
    if self.onClickRecycle then
        self.onClickRecycle()
    end
end

function FanShopBroadView:OnEnterScene()
    FanShopBroadView.super.OnEnterScene(self)
    EventSystem.AddEvent("RefreshFanCoin", self, self.RefreshFanCoin)
end

function FanShopBroadView:OnExitScene()
    FanShopBroadView.super.OnExitScene(self)
    EventSystem.RemoveEvent("RefreshFanCoin", self, self.RefreshFanCoin)
end


function FanShopBroadView:onDestroy()
end

return FanShopBroadView

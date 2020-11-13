local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local NewYearExchangeCtrl = class(ActivityContentBaseCtrl)

function NewYearExchangeCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)

    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.exchangeItemDetailMultiRefresh = function(thisLua, val, successCallBack) self:ExchangeItemDetailMultiRefresh(val, successCallBack) end
end

function NewYearExchangeCtrl:RefreshData(successCallBack)
    self:MyAheadRequest(successCallBack)
end

function NewYearExchangeCtrl:MyAheadRequest(successCallBack)
    clr.coroutine(function()
        local response = req.activityWorldBossExchangeInfo(self.activityModel:GetID())
        if api.success(response) then
            self.activityModel:InitResponseData(response.val)
            self.view:InitView(self.activityModel)
            self:CreateItemList()
            self.view:OnEnterScene()
            if type(successCallBack) == "function"  then
                successCallBack()
            end
        end
    end)
end

function NewYearExchangeCtrl:OnRefresh()
end

function NewYearExchangeCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/NewYearExchangeItem.prefab")
        return obj, spt
    end
    local exchangeContents = self.activityModel:GetContents()
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local itemData = self.view.scrollView.itemDatas[index]
        spt.onRewardBtnClick = function(exchangeId, count) self:OnRewardBtnClick(exchangeId, count) end
        spt:InitView(itemData, exchangeContents)
        self.view.scrollView:updateItemIndex(spt, index)
    end
    self:RefreshScrollView()
end

function NewYearExchangeCtrl:OnRewardBtnClick(exchangeId, count)
    if self.isReq then
        return
    end
    self.isReq = true
    clr.coroutine(function()
        local response = req.activityWorldBossExchange(exchangeId, count)
        if api.success(response) then
            self:ExchangeItemDetailMultiRefresh(response.val.gift, function() self.isReq = false end)
        end
    end)
end

function NewYearExchangeCtrl:ExchangeItemDetailMultiRefresh(gift, successCallBack)
    self.normalPos = self.view.scrollView:getScrollNormalizedPos()
    CongratulationsPageCtrl.new(gift)
    --刷页面
    self:RefreshData(successCallBack)
end

function NewYearExchangeCtrl:RefreshView(exchangeId)
    self.activityModel:OnExchanged(exchangeId)
    self.view:InitView(self.activityModel)
    self:CreateItemList()
end

function NewYearExchangeCtrl:RefreshScrollView()
    self.view.scrollView:clearData()
    local mId = self.activityModel:GetID()
    local contentCount = self.activityModel:GetContents()
    for k,v in pairs(self.activityModel:GetExchangeList()) do
        if tonumber(v.id) == tonumber(mId) then
            v.itemHasCount = contentCount.item
            table.insert(self.view.scrollView.itemDatas, v)
        end
    end

    table.sort(self.view.scrollView.itemDatas, function (a,b)
        return a.exchangeId < b.exchangeId
    end)
    self.view.scrollView:refresh(nil, self.normalPos)
end

function NewYearExchangeCtrl:OnEnterScene()
    self:RefreshData()
    self.view:OnEnterScene()
end

function NewYearExchangeCtrl:OnExitScene()
    self.view:OnExitScene()
end

return NewYearExchangeCtrl


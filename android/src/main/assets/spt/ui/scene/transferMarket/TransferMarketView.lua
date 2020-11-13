local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local EventSystem = require("EventSystem")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local TransferMarketModel = require("ui.models.transferMarket.TransferMarketModel")
local Timer = require('ui.common.Timer')

local TransferMarketView = class(unity.base)

function TransferMarketView:ctor()
    self.btnRefresh = self.___ex.btnRefresh
    self.btnPlayerSet = self.___ex.btnPlayerSet
    self.playerArea = self.___ex.playerArea
    self.freeRefreshText = self.___ex.freeRefreshText
    self.paidRefreshText = self.___ex.paidRefreshText
    self.freeRefreshTimesTips = self.___ex.freeRefreshTimesTips
    self.paidRefreshTimesTips = self.___ex.paidRefreshTimesTips
    self.freeRefreshTimesText = self.___ex.freeRefreshTimesText
    self.paidRefreshTimesText = self.___ex.paidRefreshTimesText
    self.refreshDiamondValue = self.___ex.refreshDiamondValue
    self.infoBarDynParent = self.___ex.infoBar
    self.animator = self.___ex.animator
    self.paidRefreshTimer = nil
end

function TransferMarketView:start()
    self.btnRefresh:regOnButtonClick(function()
        if self.onRefresh then
            self.onRefresh()
        end
    end)
    self.btnPlayerSet:regOnButtonClick(function()
        if self.onPlayerSet then
            self.onPlayerSet()
        end
    end)
    self:PlayAccessAnimation()
end

function TransferMarketView:InitView(transferMarketModel)
    self.transferMarketModel = transferMarketModel
    self:ShowPaidRefreshTime()
end

function TransferMarketView:ShowPaidRefreshTime()
    self.freeRefreshRemainCount = self.transferMarketModel:GetFreeRefreshRemainCount()
    self:UpdateRefreshComponent()
    if self.freeRefreshRemainCount < 3 then
        local refreshRecoverTime = self.transferMarketModel:GetRefreshRecoverTime()
        if refreshRecoverTime > 0 and self.paidRefreshTimer == nil then
            self.paidRefreshTimer = Timer.new(refreshRecoverTime, function(remainTime)
                if remainTime > 0 then
                    self:UpdatePaidRefreshTimes(remainTime)
                else
                    if self.paidRefreshTimer ~= nil then
                        self.paidRefreshTimer:Destroy()
                        self.paidRefreshTimer = nil
                    end
                    clr.coroutine(function()
                        local respone = req.transferInfo()
                        if api.success(respone) then
                            local data = respone.val
                            self.transferMarketModel:SetFreeRefreshRemainCount(data.info.cnt)
                            self.transferMarketModel:SetRefreshRecoverTime(data.info.recoverTime)
                            self:ShowPaidRefreshTime()
                        end
                    end)
                end
            end)
        end
    end
end

function TransferMarketView:UpdateRefreshComponent()
    if self.freeRefreshRemainCount <= 0 then
        self.freeRefreshText:SetActive(false)
        self.paidRefreshText:SetActive(true)
        self.refreshDiamondValue.text = lang.trans("transferMarket_refreshDiamondCost", self.transferMarketModel:GetRefreshDiamondCost())
    else
        self.freeRefreshText:SetActive(true)
        self.paidRefreshText:SetActive(false)
    end
    if self.freeRefreshRemainCount < 3 then
        self.freeRefreshTimesTips:SetActive(true)
        self.paidRefreshTimesTips:SetActive(true)
    else
        self.freeRefreshTimesTips:SetActive(true)
        self.paidRefreshTimesTips:SetActive(false)
    end
    self.freeRefreshTimesText.text = lang.trans("transferMarket_freeRefreshTimes", self.freeRefreshRemainCount, 3)
end

function TransferMarketView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function TransferMarketView:ClearPlayerObject()
    local count = self.playerArea.childCount
    for i = 0, count - 1 do
        Object.Destroy(self.playerArea:GetChild(i).gameObject)
    end
end

function TransferMarketView:AddPlayerObject(playerObject)
    playerObject.transform:SetParent(self.playerArea, false)
end

function TransferMarketView:UpdatePaidRefreshTimes(refreshRecoverTime)
    local leftTime = string.formatTimeClock(refreshRecoverTime, 3600, ":")
    self.paidRefreshTimesText.text = lang.trans("transferMarket_paidRefreshTimesTips_2", leftTime)
end

function TransferMarketView:EventUpdateCacheData()
    if self.updateCacheDataCallBack then
        self.updateCacheDataCallBack()
    end
end

function TransferMarketView:OnAccess()
    GuideManager.InitCurModule("transfermarket")
    GuideManager.Show()
end

function TransferMarketView:RegOnLeave(func)
    self.onLeaveCallBack = func
end

function TransferMarketView:OnLeave()
    if type(self.onLeaveCallBack) == "function" then
        self.onLeaveCallBack()
    end
end

function TransferMarketView:PlayAccessAnimation()
    self.animator:Play("TransferMarketAccess")
end

function TransferMarketView:PlayLeaveAnimation()
    self.animator:Play("TransferMarketLeave")
end

function TransferMarketView:RefreshTransferMarketModel()
    clr.coroutine(function()
        local respone = req.transferInfo()
        if api.success(respone) then
            local data = respone.val
            local transferMarketModel = TransferMarketModel.new()
            transferMarketModel:InitWithProtocol(data)
        end
    end)
end

function TransferMarketView:EnterScene()
    EventSystem.AddEvent("TransferMarketModel_UpdateCacheData", self, self.EventUpdateCacheData)
    EventSystem.AddEvent("TransferMarketModel_RefreshTransferMarketModel", self, self.RefreshTransferMarketModel)
end

function TransferMarketView:ExitScene()
    EventSystem.RemoveEvent("TransferMarketModel_UpdateCacheData", self, self.EventUpdateCacheData)
    EventSystem.RemoveEvent("TransferMarketModel_RefreshTransferMarketModel", self, self.RefreshTransferMarketModel)
end

function TransferMarketView:onDestroy()
    if self.paidRefreshTimer ~= nil then
        self.paidRefreshTimer:Destroy()
        self.paidRefreshTimer = nil
    end
end

return TransferMarketView

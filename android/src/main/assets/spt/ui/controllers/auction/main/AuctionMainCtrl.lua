local BaseCtrl = require("ui.controllers.BaseCtrl")
local AuctionMainModel = require("ui.models.auction.main.AuctionMainModel")
local AuctionMainConstants = require("ui.models.auction.main.AuctionMainConstants")
-- local AuctionTimingTaskCtrl = require("ui.controllers.auction.common.AuctionTimingTaskCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local AuctionMainCtrl = class(BaseCtrl, "AuctionMainCtrl")

AuctionMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Auction/Main/Prefabs/AuctionMain.prefab"

function AuctionMainCtrl:AheadRequest(statusData)
    if self.view then
        self.view:ShowDisplayArea(false)
    end
end

function AuctionMainCtrl:ctor()
    AuctionMainCtrl.super.ctor(self)
    self.isUpdating = false
end

function AuctionMainCtrl:Init()
    self.view.onClickBtnBack = function() self:OnClickBtnBack() end
    self.view.onClickBtnIntro = function() self:OnClickBtnIntro() end
    self.view.onScrollItemClick = function(scrollIndex, menuTag) self:OnScrollItemClick(scrollIndex, menuTag) end
    self.view.timingRefresh = function(quiet) self:TimingRefresh(quiet) end
    self.view.receiveReward = function(id, subID, scrollIndex) self:ReceiveReward(id, subID, scrollIndex) end
    self:InitBtnGroup()
end

function AuctionMainCtrl:InitBtnGroup()
    -- 竞拍大厅
    self.view:RegOnMenuGroup(AuctionMainConstants.AuctionHall, function()
        self:SwitchMenu(AuctionMainConstants.AuctionHall)
    end)

    -- 历史记录
    self.view:RegOnMenuGroup(AuctionMainConstants.History, function()
        self:SwitchMenu(AuctionMainConstants.History)
    end)
end

function AuctionMainCtrl:Refresh(statusData)
    AuctionMainCtrl.super.Refresh(self)
    if self.model then
        if statusData then
            self.model:SetStatusData(statusData)
        end
        self:SwitchMenu(self.model:GetCurrBtnGroup())
    else
        self:SwitchMenu(AuctionMainConstants.AuctionHall)
    end
end

function AuctionMainCtrl:GetStatusData()
    return self.model:GetStatusData()
end

function AuctionMainCtrl:OnEnterScene()
    self.view:EnterScene()
end

function AuctionMainCtrl:OnExitScene()
    self.view:ExitScene()
end

function AuctionMainCtrl:OnClickBtnIntro()
    res.PushDialog("ui.controllers.auction.intro.AuctionIntroCtrl")
end

function AuctionMainCtrl:OnClickBtnBack()
    res.PopScene()
end

function AuctionMainCtrl:SwitchMenu(tag, quiet)
    if self.model then
        self.model:StopTiming()
    end

    if not tag then tag = AuctionMainConstants.AuctionHall end
    if tag == AuctionMainConstants.AuctionHall then
        self:SwitchToAuctionHall(quiet)
    elseif tag == AuctionMainConstants.History then
        self:SwitchToHistory(quiet)
    end
end

function AuctionMainCtrl:SwitchToAuctionHall(quiet)
    if not self.isUpdating then
        self.isUpdating = true
        self.view:coroutine(function()
            local response = req.auctionInfo(nil, nil, quiet)
            if api.success(response) then
                local data = response.val
                if not self.model then
                    self.model = AuctionMainModel.new()
                end
                self.model:InitWithProtocol(data, AuctionMainConstants.AuctionHall)
                self.model:SetCurrBtnGroup(AuctionMainConstants.AuctionHall)
                self.model:SetTimingInterval(AuctionMainConstants.AuctionMain_PassiveRefreshDuration)
                self.model:ResetTimingCounter()
                self.view:ShowDisplayArea(true)
                self.view:InitView(self.model)
                self.isUpdating = false
                self.model:StartTiming()
            else
                self.isUpdating = false
            end
        end)
    end
end

function AuctionMainCtrl:SwitchToHistory(quiet)
    if not self.isUpdating then
        self.isUpdating = true
        self.view:coroutine(function()
            local response = req.auctionHistory(nil, nil, quiet)
            if api.success(response) then
                local data = response.val
                if not self.model then
                    self.model = AuctionMainModel.new()
                end
                self.model:InitWithProtocol(data, AuctionMainConstants.History)
                self.model:SetCurrBtnGroup(AuctionMainConstants.History)
                self.model:SetTimingInterval(AuctionMainConstants.AuctionMain_PassiveRefreshDuration)
                self.model:ResetTimingCounter()
                self.view:ShowDisplayArea(true)
                self.view:InitView(self.model)
                self.isUpdating = false
                self.model:StartTiming()
            else
                self.isUpdating = false
            end
        end)
    end
end

function AuctionMainCtrl:OnScrollItemClick(scrollIndex, menuTag)
    local auctionData = nil
    if menuTag == AuctionMainConstants.AuctionHall then
        auctionData = self.model:GetAuctionHallData()[scrollIndex]
    elseif menuTag == AuctionMainConstants.History then
        auctionData = self.model:GetMyHistoryData()[scrollIndex]
    end
    local statusData = {}
    statusData.id = auctionData.id
    statusData.subId = auctionData.subId
    statusData.myBidePrice = nil
    res.PushScene("ui.controllers.auction.hall.AuctionHallCtrl", statusData)
end

function AuctionMainCtrl:TimingRefresh(quiet)
    local currBtnTag = nil
    if self.model then
        currBtnTag = self.model:GetCurrBtnGroup()
    end
    self:SwitchMenu(currBtnTag, quiet)
end

function AuctionMainCtrl:ReceiveReward(id, subID, scrollIndex)
    if not self.isUpdating then
        self.isUpdating = true
        self.view:coroutine(function()
            local response = req.auctionReceive(id, subID)
            if api.success(response) then
                local data = response.val
                CongratulationsPageCtrl.new(data.contents)
                self.model:UpdateAfterReceive(scrollIndex)
                self.view:InitView(self.model)
                self.isUpdating = false
            else
                self.isUpdating = false
            end
        end)
    end
end

return AuctionMainCtrl
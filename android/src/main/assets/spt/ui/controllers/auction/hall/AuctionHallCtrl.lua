local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local AuctionHallModel = require("ui.models.auction.hall.AuctionHallModel")
local AuctionMainConstants = require("ui.models.auction.main.AuctionMainConstants")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local AuctionHallCtrl = class(BaseCtrl, "AuctionHallCtrl")

AuctionHallCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Auction/Hall/Prefabs/AuctionHall.prefab"

function AuctionHallCtrl:AheadRequest(statusData)
    if self.view then
        self.view:ShowDisplayArea(false)
    end

    local id = statusData.id
    local subID = statusData.subId
    local response = req.auctionDetail(id, subID, 1, nil, nil, false)
    if api.success(response) then
        local data = response.val
        if not self.model then
            self.model = AuctionHallModel.new()
        end
        self.model:InitWithProtocol(data)
        self.model:SetStatusData(statusData)
        self.model:StopTiming()
        if self.model:GetCurrStep() == AuctionMainConstants.AuctionStep.STEP_4 and self.model:CanBid() then
            -- 第四阶段的5名玩家，3秒刷新
            self.model:SetTimingInterval(AuctionMainConstants.AuctionHall_PassiveRefreshDuration_core)
        else
            self.model:SetTimingInterval(AuctionMainConstants.AuctionHall_PassiveRefreshDuration)
        end
        self.model:ResetTimingCounter()
        self.model:StartTiming()
    end
end

function AuctionHallCtrl:ctor()
    AuctionHallCtrl.super.ctor(self)

    self.infoBarCtrl = nil
end

function AuctionHallCtrl:Init(statusData)
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self, false, false)
    end)

    self.view.onClickBtnRefresh = function() self:OnClickBtnRefresh() end
    self.view.onClickBtnRank = function() self:OnClickBtnRank() end
    self.view.onClickBtnAdd = function () self:OnClickBtnAdd() end
    self.view.onClickBtnMinus = function() self:OnClickBtnMinus() end
    self.view.onClickBtnHammer = function() self:OnClickBtnHammer() end
    self.view.timingRefresh = function(quiet, isFirst) self:TimingRefresh(quiet, isFirst) end
end

function AuctionHallCtrl:Refresh(statusData)
    AuctionHallCtrl.super.Refresh(self)
    if not self.model then
        self.model = AuctionHallModel.new()
    end
    self.model:SetStatusData(statusData)
    self.view:ShowDisplayArea(true)
    self.view:InitView(self.model)
end

function AuctionHallCtrl:GetStatusData()
    return self.model:GetStatusData()
end

function AuctionHallCtrl:OnEnterScene()
    self.view:EnterScene()
end

function AuctionHallCtrl:OnExitScene()
    self.view:ExitScene()
end

function AuctionHallCtrl:OnClickBtnRefresh()
    if self.model:GetIsUpdating() then
        return
    end

    self:TimingRefresh(false, 1)
end

function AuctionHallCtrl:OnClickBtnRank()
    res.PushDialog("ui.controllers.auction.rank.AuctionRankCtrl", self.model:GetPeriod(), self.model:GetSubID())
end

function AuctionHallCtrl:OnClickBtnAdd()
    if self.model:GetIsUpdating() then
        DialogManager.ShowToastByLang("auction_hall_updating")
        return
    end

    local newMyPrice = self.model:GetMyBidPrice() + self.model:GetSingleBidPrice()
    local highBidPrice = self.model:GetHighBidPrice()
    if newMyPrice > highBidPrice then
        newMyPrice = highBidPrice
        DialogManager.ShowToastByLang("auction_hall_high_bid_price")
    end
    self.model:SetMyBidPrice(newMyPrice)
    self.view:UpdateMyBidPirce()
end

function AuctionHallCtrl:OnClickBtnMinus()
    if self.model:GetIsUpdating() then
        DialogManager.ShowToastByLang("auction_hall_updating")
        return
    end

    local newMyPrice = self.model:GetMyBidPrice() - self.model:GetSingleBidPrice()
    local lowBidPrice = self.model:GetLowBidPrice()
    if newMyPrice < lowBidPrice then
        newMyPrice = lowBidPrice
        DialogManager.ShowToastByLang("auction_hall_low_bid_price")
    end
    self.model:SetMyBidPrice(newMyPrice)
    self.view:UpdateMyBidPirce()
end

function AuctionHallCtrl:OnClickBtnHammer()
    if not self.model:CanBid() then -- 检查是否有竞拍资格
        DialogManager.ShowToastByLang("auction_hall_can_not_bid")
        return
    end

    if self.model:GetIsUpdating() then
        DialogManager.ShowToastByLang("auction_hall_updating")
        return
    end
    local playerInfoModel = PlayerInfoModel.new()

    local myWholeBidPrice = self.model:GetWholeBidMoney()
    if playerInfoModel:GetMoney() < myWholeBidPrice then
        DialogManager.ShowToastByLang("goldCoinNotEnough") -- 欧元不足
        return
    end

    local bidDiamondPrice = self.model:GetBidDiamondPrice()
    if playerInfoModel:GetDiamond() < bidDiamondPrice then
        DialogManager.ShowToastByLang("diamondNotEnough") -- 钻石不足
        return
    end

    local id = self.model:GetPeriod()
    local subID = self.model:GetSubID()
    local myBidPrice = self.model:GetMyBidPrice()
    self.view:coroutine(function()
        self.model:SetIsUpdating(true)
        local response = req.auctionBid(id, subID, myBidPrice)
        if api.success(response) then
            local data = response.val
            self.model:UpdateAfterBid(data)
            self.view:UpdateAfterBid(self.model)
            playerInfoModel:SetMoney(playerInfoModel:GetMoney() - data.cost.m)
            playerInfoModel:ReduceDiamond(data.cost.d)
            self.view.hammerAnimator:SetBool("isHit", true)
            self.model:SetIsUpdating(false)
        else
            self.model:SetIsUpdating(false)
        end
    end)
end

function AuctionHallCtrl:TimingRefresh(quiet, isFirst)
    local statusData = self.model:GetStatusData()
    local id = statusData.id
    local subID = statusData.subId
    if self.model:GetIsUpdating() then
        return
    end
    self.view:coroutine(function()
        self.model:SetIsUpdating(true)
        self.model:StopTiming()
        local response = req.auctionDetail(id, subID, isFirst, nil, nil, quiet)
        if api.success(response) then
            local data = response.val
            if not self.model then
                self.model = AuctionHallModel.new()
            end
            self.model:InitWithProtocol(data)
            self.model:SetStatusData(statusData)
            if self.model:GetCurrStep() == AuctionMainConstants.AuctionStep.STEP_4 and self.model:CanBid() then
                -- 第四阶段的5名玩家，3秒刷新
                self.model:SetTimingInterval(AuctionMainConstants.AuctionHall_PassiveRefreshDuration_core)
            else
                self.model:SetTimingInterval(AuctionMainConstants.AuctionHall_PassiveRefreshDuration)
            end
            self.view:InitView(self.model)
            self.model:SetIsUpdating(false)
            self.model:ResetTimingCounter()
            self.model:StartTiming()
        else
            if quiet then
                DialogManager.ShowToast(tostring(response.val)) -- 弹出服务器返回的失败提示
            end
            self.model:SetIsUpdating(false)
            self.model:ResetTimingCounter()
            self.model:StartTiming()
        end
    end)
end

return AuctionHallCtrl
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local AuctionMainConstants = require("ui.models.auction.main.AuctionMainConstants")
-- 实例化各类物品所需
local ItemModel = require("ui.models.ItemModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local EquipModel = require("ui.models.EquipModel")

local AuctionHallView = class(unity.base, "AuctionHallView")

local itemPrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Auction/Main/Prefabs/AuctionMainItem.prefab"

function AuctionHallView:ctor()
    self.mainView = self.___ex.mainView
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.txtItemName = self.___ex.txtItemName
    self.itemsContainer = self.___ex.itemsContainer
    self.btnRefresh = self.___ex.btnRefresh
    self.scrollView = self.___ex.scrollView
    self.inAuction = self.___ex.inAuction
    self.final = self.___ex.final
    self.txtStage = self.___ex.txtStage
    self.btnRank = self.___ex.btnRank
    self.txtCountdown = self.___ex.txtCountdown
    self.txtDesc1 = self.___ex.txtDesc1
    self.txtCurrPirce = self.___ex.txtCurrPirce
    self.btnMinus = self.___ex.btnMinus
    self.btnAdd = self.___ex.btnAdd
    self.txtAddPrice = self.___ex.txtAddPrice
    self.txtDiamond = self.___ex.txtDiamond
    self.txtFinalPrice = self.___ex.txtFinalPrice
    self.txtFinalTimes = self.___ex.txtFinalTimes
    self.txtFinalPlayer = self.___ex.txtFinalPlayer
    self.btnHammer = self.___ex.btnHammer
    self.itemsAnimator = self.___ex.itemsAnimator
    self.hammerAnimator = self.___ex.hammerAnimator
    self.txtMoney = self.___ex.txtMoney

    self.remainTimeCounter = nil
    self.isForceUpdate = false
    self.isInAuction = false
    self.bidBtnCooldownCounter = 0 -- 玩家竞拍冷却计时器
    self.refreshBtnCooldownCounter = 0 -- 刷新按钮冷却计时器
    self.timingRefresh = nil
end

function AuctionHallView:start()
    GameObjectHelper.FastSetActive(self.inAuction.gameObject, false)
    GameObjectHelper.FastSetActive(self.final.gameObject, false)
    self:RegBtnEvent()
end

function AuctionHallView:update()
    if self.remainTimeCounter and self.isInAuction then
        if self.remainTimeCounter <= 0 then
            -- 倒计时为零，进入下一阶段，静默网络请求
            if not self.isForceUpdate then
                EventSystem.SendEvent("AuctionHall_ForceRequrestUpdateItem", true, 1)
                self.isForceUpdate = true
                self.remainTimeCounter = nil
            end
        else
            self.remainTimeCounter = self.remainTimeCounter - Time.deltaTime
            self:UpdateCountdown()
        end
    end

    -- 定时刷新
    if self.model and self.model:IsTiming() then
        if self.model:GetTimingCounter() < Time.deltaTime then
            self:TimingRefresh(true, 0)
            self.model:ResetTimingCounter()
        else
            self.model:UpdateTimingCounter(Time.deltaTime)
        end
    end

    if self.bidBtnCooldownCounter >= 0 then
        self.bidBtnCooldownCounter = self.bidBtnCooldownCounter - Time.deltaTime
    end

    if self.refreshBtnCooldownCounter >= 0 then
        self.refreshBtnCooldownCounter = self.refreshBtnCooldownCounter - Time.deltaTime
    end
end

function AuctionHallView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function AuctionHallView:InitView(auctionHallModel)
    self.model = auctionHallModel
    self.isInAuction = self.model:IsInAuction()
    self:InitItemArea()
    GameObjectHelper.FastSetActive(self.btnRefresh.gameObject, self.isInAuction)
    self.scrollView:InitView(self.model:GetRecordList())
    self:InitRightArea()
end

function AuctionHallView:UpdateAfterBid()
    self.scrollView:InitView(self.model:GetRecordList())
    self:UpdateCurrMaxPrice()
    self:UpdateMyBidPirce()
    -- 第四阶段直接刷新界面时间至1分钟
    local step = self.model:GetCurrStep()
    if step == AuctionMainConstants.AuctionStep.STEP_4 and self.remainTimeCounter <= AuctionMainConstants.Auction_Step4_Core_Time then
        self.remainTimeCounter = AuctionMainConstants.Auction_Step4_Core_Time
    end
end

function AuctionHallView:InitItemArea()
    local itemType = self.model:GetAuctionItemType()
    local id = self.model:GetAuctionItemID()
    local name = ""
    if itemType == "item" then
        name = ItemModel.new(id):GetName()
    elseif itemType == "card" then
        name = StaticCardModel.new(id):GetName()
    elseif itemType == "paster" then
        local pasterModel = CardPasterModel.new()
        pasterModel:InitWithStatic(id)
        name = pasterModel:GetName()
    elseif itemType == "cardPiece" then
        local pieceModel = CardPieceModel.new()
        pieceModel:InitWithStatic(id)
        name = pieceModel:GetName()
    elseif itemType == "pasterPiece" then
        local pieceModel = CardPasterPieceModel.new()
        pieceModel:InitWithStatic(id)
        name = pieceModel:GetName()
    elseif itemType == "eqs" then
        name = EquipModel.new(id):GetName()
    end
    self.txtItemName.text = lang.trans("auction_hall_item_name", name, self.model:GetAuctionItemCount())

    res.ClearChildren(self.itemsContainer.transform)
    local rewardParams = {
        parentObj = self.itemsContainer,
        rewardData = self.model:GetAuctionItem(),
        isShowName = false,
        isReceive = false,
        isShowSymbol = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        hideCount = true,
    }
    if itemType == "card" then
        rewardParams.rewardData.card[1].num = 0
    end
    RewardDataCtrl.new(rewardParams)

    self.itemsAnimator:SetBool("isInAuction", self.isInAuction)
end

function AuctionHallView:InitRightArea()
    GameObjectHelper.FastSetActive(self.inAuction.gameObject, self.isInAuction)
    GameObjectHelper.FastSetActive(self.final.gameObject, not self.isInAuction)
    GameObjectHelper.FastSetActive(self.btnRank.gameObject, true)

    self.isForceUpdate = false
    self.remainTimeCounter = self.model:GetRemainTime()
    local step = self.model:GetCurrStep()
    if step == AuctionMainConstants.AuctionStep.NOT_START then-- 未开启
    elseif step == AuctionMainConstants.AuctionStep.STEP_1 then-- 第一阶段
        self.txtStage.text = lang.trans("auction_hall_step_1")
        self.txtDesc1.text = lang.trans("auction_hall_step_1_desc")
        -- 隐藏排行榜按钮
        GameObjectHelper.FastSetActive(self.btnRank.gameObject, false)
    elseif step == AuctionMainConstants.AuctionStep.STEP_2 then-- 第二阶段
        self.txtStage.text = lang.trans("auction_hall_step_2")
        self.txtDesc1.text = lang.trans("auction_hall_step_2_desc")
    elseif step == AuctionMainConstants.AuctionStep.STEP_3 then-- 第三阶段
        self.txtStage.text = lang.trans("auction_hall_step_3")
        self.txtDesc1.text = lang.trans("auction_hall_step_3_desc")
    elseif step == AuctionMainConstants.AuctionStep.STEP_4 then-- 第四阶段
        self.txtStage.text = lang.trans("auction_hall_step_4")
        if self.remainTimeCounter >= AuctionMainConstants.Auction_Step4_Core_Time then
            self.txtDesc1.text = lang.trans("auction_hall_step_4_desc_1")
        else
            self.txtDesc1.text = lang.trans("auction_hall_step_4_desc_2")
        end
    elseif step == AuctionMainConstants.AuctionStep.FINISH then-- 第五阶段，显示中标者和价格
        local topPlayer = self.model:GetTheTopPlayer()
        self.txtFinalPrice.text = string.formatNumWithUnit(topPlayer.money or 0)
        self.txtFinalTimes.text = lang.trans("auction_hall_times", tostring(self.model:GetBidCount()))
        if topPlayer.serverName or topPlayer.name then
            self.txtFinalPlayer.text = lang.trans("auction_hall_final_player", topPlayer.serverName or "", topPlayer.name or "")
        else
            self.txtFinalPlayer.text = lang.trans("auction_main_none")
        end
    end

    self:UpdateCurrMaxPrice()
    self.txtAddPrice.text = tostring(self.model:GetMyBidPrice())
    self.txtDiamond.text = "X" .. tostring(self.model:GetBidDiamondPrice())
    self.txtMoney.text = lang.trans("auction_hall_money_whole", string.formatNumWithUnit(self.model:GetLastMyBidMoney()), string.formatNumWithUnit(self.model:GetWholeBidMoney()))
end

function AuctionHallView:UpdateCountdown()
    local step = self.model:GetCurrStep()
    local remainTimeStr = string.convertSecondToTime(self.remainTimeCounter)
    if step == AuctionMainConstants.AuctionStep.NOT_START then-- 未开启
    elseif step == AuctionMainConstants.AuctionStep.STEP_1 then-- 第一阶段
        self.txtCountdown.text = lang.trans("auction_hall_countdown", remainTimeStr)
    elseif step == AuctionMainConstants.AuctionStep.STEP_2 then-- 第二阶段
        self.txtCountdown.text = lang.trans("auction_hall_countdown", remainTimeStr)
    elseif step == AuctionMainConstants.AuctionStep.STEP_3 then-- 第三阶段
        self.txtCountdown.text = lang.trans("auction_hall_countdown", remainTimeStr)
    elseif step == AuctionMainConstants.AuctionStep.STEP_4 then-- 第四阶段
        self.txtCountdown.text = lang.trans("auction_hall_countdown", remainTimeStr)
        if self.remainTimeCounter >= AuctionMainConstants.Auction_Step4_Core_Time then
            self.txtDesc1.text = lang.trans("auction_hall_step_4_desc_1")
        else
            self.txtDesc1.text = lang.trans("auction_hall_step_4_desc_2")
        end
    elseif step == AuctionMainConstants.AuctionStep.FINISH then-- 第五阶段，显示中标者和价格
    end
end

function AuctionHallView:UpdateMyBidPirce()
    self.txtAddPrice.text = tostring(self.model:GetMyBidPrice())
    self.txtMoney.text = lang.trans("auction_hall_money_whole", string.formatNumWithUnit(self.model:GetLastMyBidMoney()), string.formatNumWithUnit(self.model:GetWholeBidMoney()))
end

function AuctionHallView:UpdateCurrMaxPrice()
    local isFirstPlayer = table.nums(self.model:GetRecordList()) == 0
    local currPriceStr = string.formatNumWithUnit(self.model:GetCurrPrice())
    if isFirstPlayer then
        self.txtCurrPirce.text = lang.trans("auction_hall_initial_price", currPriceStr)
    else
        self.txtCurrPirce.text = lang.trans("auction_hall_curr_price", currPriceStr)
    end
end

function AuctionHallView:RegBtnEvent()
    self.btnRefresh:regOnButtonClick(function()
        self:OnClickBtnRefresh()
    end)

    self.btnRank:regOnButtonClick(function()
        self:OnClickBtnRank()
    end)

    self.btnAdd:regOnButtonClick(function()
        self:OnClickBtnAdd()
    end)

    self.btnMinus:regOnButtonClick(function()
        self:OnClickBtnMinus()
    end)

    self.btnHammer:regOnButtonClick(function()
        self:OnClickBtnHammer()
    end)
end

function AuctionHallView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.mainView.gameObject, isShow)
end

function AuctionHallView:EnterScene()
    EventSystem.AddEvent("AuctionHall_ForceRequrestUpdateItem", self, self.TimingRefresh)
end

function AuctionHallView:ExitScene()
    EventSystem.RemoveEvent("AuctionHall_ForceRequrestUpdateItem", self, self.TimingRefresh)
end

function AuctionHallView:OnClickBtnRefresh()
    if self.refreshBtnCooldownCounter >= 0 then
        return
    end

    if self.onClickBtnRefresh then
        self.refreshBtnCooldownCounter = tonumber(AuctionMainConstants.refreshCooldown)
        self.onClickBtnRefresh()
    end
end

function AuctionHallView:OnClickBtnRank()
    if self.onClickBtnRank then
        self.onClickBtnRank()
    end
end

function AuctionHallView:OnClickBtnAdd()
    if self.onClickBtnAdd then
        self.onClickBtnAdd()
    end
end

function AuctionHallView:OnClickBtnMinus()
    if self.onClickBtnMinus then
        self.onClickBtnMinus()
    end
end

function AuctionHallView:OnClickBtnHammer()
    if self.bidBtnCooldownCounter >= 0 then
        return
    end
    if self.onClickBtnHammer then
        self.bidBtnCooldownCounter = tonumber(AuctionMainConstants.BidCooldown)
        self.onClickBtnHammer()
    end
end

function AuctionHallView:FinishHit()
    self.hammerAnimator:SetBool("isHit", false)
end

function AuctionHallView:TimingRefresh(quiet, isFirst)
    if self.timingRefresh then
        self.timingRefresh(quiet, isFirst)
    end
end

return AuctionHallView
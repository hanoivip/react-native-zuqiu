local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Time = UnityEngine.Time
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AuctionMainConstants = require("ui.models.auction.main.AuctionMainConstants")

local AuctionMainView = class(unity.base, "AuctionMainView")

function AuctionMainView:ctor()
    self.btnBack = self.___ex.btnBack
    self.btnIntro = self.___ex.btnIntro
    self.mainView = self.___ex.mainView
    self.btnGroup = self.___ex.btnGroup
    self.txtHint = self.___ex.txtHint
    self.imgClosed = self.___ex.imgClosed
    self.scrollViewHalls = self.___ex.scrollViewHalls
    self.scrollViewHistory = self.___ex.scrollViewHistory

    self.isOpen = nil
    self.onClickBtnBack = nil
    self.onClickBtnIntro = nil
    self.onScrollItemClick = nil
    self.timingRefresh = nil
    self.receiveReward = nil
end

function AuctionMainView:start()
    self:RegBtnEvent()
end

function AuctionMainView:update()
    if self.model and self.model:IsTiming() then
        if self.model:GetTimingCounter() < Time.deltaTime then
            self:TimingRefresh(true)
            self.model:ResetTimingCounter()
        else
            self.model:UpdateTimingCounter(Time.deltaTime)
        end
    end
end

function AuctionMainView:InitView(auctionMainModel)
    self.model = auctionMainModel
    self.isOpen = self.model:IsOpen()
    self:InitHandsomeMan()

    GameObjectHelper.FastSetActive(self.scrollViewHalls.gameObject, false)
    GameObjectHelper.FastSetActive(self.scrollViewHistory.gameObject, false)
    GameObjectHelper.FastSetActive(self.imgClosed.gameObject, false)

    local currMenu = self.model:GetCurrBtnGroup()
    if currMenu == AuctionMainConstants.AuctionHall then
        self:InitAuctionHall()
    elseif currMenu == AuctionMainConstants.History then
        self:InitHistory()
    end
end

function AuctionMainView:RegBtnEvent()
    self.btnBack:regOnButtonClick(function()
        self:OnClickBtnBack()
    end)

    self.btnIntro:regOnButtonClick(function()
        self:OnClickBtnIntro()
    end)
end

function AuctionMainView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.mainView.gameObject, isShow)
end

function AuctionMainView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.btnGroup:BindMenuItem(tag, func)
    end
end

function AuctionMainView:InitHandsomeMan()
    if self.isOpen then
        self.txtHint.text = lang.trans("auction_main_handsome_3")
    else
        local nextStartTime = self.model:GetNextStartTime()
        if nextStartTime == AuctionMainConstants.AuctionMain_NoPreNotice then -- 未来24小时没有拍卖
            self.txtHint.text = lang.trans("auction_main_handsome_1")
        else
            self.txtHint.text = lang.trans("auction_main_handsome_2", string.formatTimestampAllWithWord(nextStartTime))
        end
    end
end

function AuctionMainView:InitAuctionHall()
    GameObjectHelper.FastSetActive(self.scrollViewHalls.gameObject, true)
    if not self.isOpen then
        GameObjectHelper.FastSetActive(self.imgClosed.gameObject, true)
    end
    self.btnGroup:selectMenuItem(AuctionMainConstants.AuctionHall)
    self.scrollViewHalls:InitView(self.model:GetAuctionHallData())
end

function AuctionMainView:InitHistory()
    GameObjectHelper.FastSetActive(self.scrollViewHistory.gameObject, true)
    GameObjectHelper.FastSetActive(self.imgClosed.gameObject, false)
    self.btnGroup:selectMenuItem(AuctionMainConstants.History)
    self.scrollViewHistory:InitView(self.model:GetMyHistoryData())
end

function AuctionMainView:OnClickBtnBack()
    if self.onClickBtnBack then
        self.onClickBtnBack()
    end
end

function AuctionMainView:OnClickBtnIntro()
    if self.onClickBtnIntro then
        self.onClickBtnIntro()
    end
end

function AuctionMainView:EnterScene()
    EventSystem.AddEvent("AuctionMain_OnScrollItemClick", self, self.OnScrollItemClick)
    EventSystem.AddEvent("AuctionMain_ForceRequrestUpdateItem", self, self.TimingRefresh)
    EventSystem.AddEvent("AuctionMain_Receive", self, self.ReceiveReward)
end

function AuctionMainView:ExitScene()
    EventSystem.RemoveEvent("AuctionMain_OnScrollItemClick", self, self.OnScrollItemClick)
    EventSystem.RemoveEvent("AuctionMain_ForceRequrestUpdateItem", self, self.TimingRefresh)
    EventSystem.RemoveEvent("AuctionMain_Receive", self, self.ReceiveReward)
end

function AuctionMainView:OnScrollItemClick(scrollIndex, menuTag)
    if self.onScrollItemClick then
        self.onScrollItemClick(scrollIndex, menuTag)
    end
end

function AuctionMainView:TimingRefresh(quiet)
    if self.timingRefresh then
        self.timingRefresh(quiet)
    end
end

function AuctionMainView:ReceiveReward(id, subID, scrollIndex)
    if self.receiveReward then
        self.receiveReward(id, subID, scrollIndex)
    end
end

return AuctionMainView
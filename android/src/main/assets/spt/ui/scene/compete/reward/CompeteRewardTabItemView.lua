local LuaButton = require("ui.control.button.LuaButton")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local EventSystem = require("EventSystem")
local CompeteRewardTabItemView = class(LuaButton, "CompeteRewardTabItemView")

function CompeteRewardTabItemView:ctor()
    CompeteRewardTabItemView.super.ctor(self)

    self.selected = self.___ex.selected
    self.furled = self.___ex.furled
    self.unfurled = self.___ex.unfurled
    self.giftName = self.___ex.giftName
    self.time = self.___ex.time
    self.timeRemained = self.___ex.timeRemained
    self.descShort = self.___ex.descShort
    self.descLong = self.___ex.descLong
    self.rewardContentScrollView = self.___ex.rewardContentScrollView

    self.isSelect = false
    self.isRead = false
    self.mainTitle = self.___ex.mainTitle
    self.descTitle = self.___ex.descTitle
    self.textOrGift = self.___ex.textOrGift
    self.showGift = self.___ex.showGift
    self.tipsForMail = self.___ex.tipsForMail
    self.mailContent = self.___ex.mailContent
    self.contentScrollShort = self.___ex.contentScrollShort
    self.contentScrollLong = self.___ex.contentScrollLong
    self.isPureTextMail = false

    self.competeRewardMailModel = nil
    self:BindBtnCollectOrNot(false)
end

function CompeteRewardTabItemView:start()
    EventSystem.AddEvent("CompeteRewardMailModel_SetMailRead", self, self.EventSetMailRead)
end

function CompeteRewardTabItemView:ClickCollect()
    clr.coroutine(function()
        local respone = req.worldTournamentRewardCollectOneMail(self.competeRewardMailModel:GetMailID())
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) then
                self.isRead = true
                self:InitEnvelopeState(self.isRead)
                self.competeRewardMailModel:SetMailCollected(data)
                local popCongratulationsPage = function()
                    local isTextMail = self.competeRewardMailModel:IsTextMail()
                    if not isTextMail then 
                        CongratulationsPageCtrl.new(data.contents, self.competeRewardMailModel:IsJumpToiOSStore())
                    end
                end
                self:Close(popCongratulationsPage)
            end
        end
    end)
end

function CompeteRewardTabItemView:Close(popCongratulationsPage)
    popCongratulationsPage()
end

function CompeteRewardTabItemView:InitView(competeRewardMailModel)
    self.btnCollect = nil
    self.mailReceived = nil
    self.btnCollectObj = nil
    self.isRead = false
    self.competeRewardMailModel = competeRewardMailModel
    if self.competeRewardMailModel:IsRead() then
       self.isRead = true
    else
        self.isRead = false
    end
    self:InitEnvelopeState(self.isRead)
    self:ChangeBtnState(false, false)
    self:InitButtonState()

    self:ClearScrollItemData()
    self:FillEnvelopeTextAreas()
end

function CompeteRewardTabItemView:ClearScrollItemData()
    self.giftName.text = ""
    self.time.text = ""
    self.timeRemained.text = ""
end

function CompeteRewardTabItemView:FillEnvelopeTextAreas()
    local title = self.competeRewardMailModel:GetTitle() or ""
    self.giftName.text = title
    self.time.text = tostring(self.competeRewardMailModel:GetTime())
    self.timeRemained.text = lang.transstr("compete_reward_timeRemianed", tostring(self.competeRewardMailModel:GetRestTime()))
end

function CompeteRewardTabItemView:FillContentTextAreas(showFlag)
    self.mainTitle.text = lang.transstr("directors_letter")
    self.descTitle.text = self.competeRewardMailModel:GetTitle()
    self["desc"..(showFlag and "Long" or "Short")].text = self.competeRewardMailModel:GetDesc()
end

function CompeteRewardTabItemView:SetSelect(isSelect)
    self.isSelect = isSelect
    local mailID = self.competeRewardMailModel:GetMailID()
    local isShowRewardContent = false
    local readOrReceive = "have_received"
    if self.isSelect then
        GameObjectHelper.FastSetActive(self.tipsForMail, false)
        GameObjectHelper.FastSetActive(self.mailContent, true)
        self:BindBtnCollectOrNot(true)
        cache.setSelectedMailID(tostring(mailID))
        if not self.competeRewardMailModel:HasContent() then  --- 是否包含礼包
            self.isPureTextMail = true
            if not self.competeRewardMailModel:IsRead() then
                self:ClickCollect()        
            end
            self.isRead = true
            self:ChangeBtnState(false, false)
            readOrReceive = "compete_reward_haveRead"
            isShowRewardContent = false
        else
            self.isPureTextMail = false
            if self.competeRewardMailModel:IsRead() then
                self:ChangeBtnState(true, false)
            else
                self:ChangeBtnState(false, true)
            end
            isShowRewardContent = true
        end
        GameObjectHelper.FastSetActive(self.rewardContentScrollView.gameObject, isShowRewardContent)
        if isShowRewardContent then
            self.rewardContentScrollView:InitView(self.competeRewardMailModel)
        end
        self.textOrGift.text = lang.transstr(readOrReceive)
        self:ShowPureTextMail(self.isPureTextMail)
    else
        self:BindBtnCollectOrNot(false)
    end
    if self.competeRewardMailModel:IsRead() then
       self.isRead = true
    else
        self.isRead = false
    end
    self:InitEnvelopeState(self.isRead)
    GameObjectHelper.FastSetActive(self.selected, isSelect)
end

function CompeteRewardTabItemView:BindBtnCollectOrNot(isBind)
    if isBind then
        self.btnCollect = self.___ex.btnCollect
        self.mailReceived = self.___ex.received
        self.btnCollectObj = self.___ex.btnCollectObj
        if self.btnCollect then
            self.btnCollect:regOnButtonClick(function()
                self:ClickCollect()
                self.isRead = true
            end)
        end
    else
        self.btnCollect = nil
        self.mailReceived = nil
        self.btnCollectObj = nil
    end
end

function CompeteRewardTabItemView:ShowPureTextMail(showFlag)
    if showFlag then
        GameObjectHelper.FastSetActive(self.contentScrollLong, true)
        GameObjectHelper.FastSetActive(self.contentScrollShort, false)
        GameObjectHelper.FastSetActive(self.showGift, false)
    else
        GameObjectHelper.FastSetActive(self.contentScrollLong, false)
        GameObjectHelper.FastSetActive(self.contentScrollShort, true)
        GameObjectHelper.FastSetActive(self.showGift, true)
    end
    self:FillContentTextAreas(showFlag)
end

function CompeteRewardTabItemView:GetIsRead()
    return self.isRead
end

function CompeteRewardTabItemView:ChangeBtnState(isReceived, isBtnCollect)
    GameObjectHelper.FastSetActive(self.mailReceived, isReceived)
    GameObjectHelper.FastSetActive(self.btnCollectObj, isBtnCollect)
end

function CompeteRewardTabItemView:InitEnvelopeState(isUnfurled)
    GameObjectHelper.FastSetActive(self.unfurled, isUnfurled)
    GameObjectHelper.FastSetActive(self.furled, not isUnfurled)
end

function CompeteRewardTabItemView:InitButtonState()
    self:unselectBtn()
    self:onPointEventHandle(true)
end

function CompeteRewardTabItemView:InitCollectButton(isRead)
    if tonumber(self.competeRewardMailModel:getMailIconType()) == 0 then
        self:ChangeBtnState(false, false)
    else
        self:ChangeBtnState(true, false)
    end
end

function CompeteRewardTabItemView:SetMailRead(isRead)
    self:InitCollectButton(isRead)
end

function CompeteRewardTabItemView:EventSetMailRead(mailID)
    if self.competeRewardMailModel:GetMailID() == mailID then 
        self:SetMailRead(self.competeRewardMailModel:IsRead())
    end
end 

function CompeteRewardTabItemView:onDestroy()
    EventSystem.RemoveEvent("CompeteRewardMailModel_SetMailRead", self, self.EventSetMailRead)
end

return CompeteRewardTabItemView
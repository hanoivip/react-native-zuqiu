local Timer = require("ui.common.Timer")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local PlayerLetterConstants = require("ui.scene.playerLetter.PlayerLetterConstants")

local TimeLimitLeaugeLetterView = class(ActivityParentView, "TimeLimitLeaugeLetterView")

function TimeLimitLeaugeLetterView:ctor()
    self.txtActivityTime = self.___ex.txtActivityTime
    self.txtCondition = self.___ex.txtCondition
    self.imgProgress = self.___ex.imgProgress
    self.scrollView = self.___ex.scrollView
    self.cardContainer = self.___ex.cardContainer
    self.txtCardName = self.___ex.txtCardName
    self.btnBigCard = self.___ex.btnBigCard
    self.btnReceive = self.___ex.btnReceive
    self.buttonReceive = self.___ex.buttonReceive
    self.txtReceive = self.___ex.txtReceive
end

function TimeLimitLeaugeLetterView:InitView(timeLimitedLeaugeLetterModel)
    self.model = timeLimitedLeaugeLetterModel

    self:InitTimeView()
    local cardModel = self.model:GetBigCardModel()
    self:InitProgressView(cardModel)
    self:InitBigCardView(cardModel)

    local scrollData = self.model:GetScrollData()
    self:InitScrollView(scrollData)

    self:InitReceiveBtn()
end

function TimeLimitLeaugeLetterView:InitTimeView()
    local startTime = self.model:GetBeginTime()
    local endTime = self.model:GetEndTime()
    self.txtActivityTime.text = lang.trans("cumulative_pay_time", string.formatTimestampNoYear(startTime), string.formatTimestampNoYear(endTime))
end

function TimeLimitLeaugeLetterView:InitProgressView(cardModel)
    self.txtCondition.text = lang.trans("timelimit_league_letter_condition_content", cardModel:GetName())
    self.imgProgress.fillAmount = self.model:GetProgress()
end

function TimeLimitLeaugeLetterView:InitScrollView(scrollData)
    self.scrollView:InitView(scrollData)
end

function TimeLimitLeaugeLetterView:InitBigCardView(cardModel)
    local cardObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    self.bigCardView = cardObject:GetComponent(clr.CapsUnityLuaBehav)
    cardObject.transform:SetParent(self.cardContainer.transform, false)
    self.bigCardView:InitView(cardModel)
    self.bigCardView:IsShowName(false)
    self.txtCardName.text = cardModel:GetName()

    self.btnBigCard:regOnButtonClick(function ()
        if self.onClickBigCard then
            self.onClickBigCard(cardModel:GetCid())
        end
    end)
end

function TimeLimitLeaugeLetterView:InitReceiveBtn()
    local status = self.model:GetStatus()
    if status == PlayerLetterConstants.LetterState.UNFINISHED then -- 未完成
        self.buttonReceive.interactable = false
        self.txtReceive.text = lang.trans("unfinished")
    elseif status == PlayerLetterConstants.LetterState.NOT_AWARD then -- 可领取
        self.buttonReceive.interactable = true
        self.btnReceive:regOnButtonClick(function ()
            if self.onBtnReceive then
                self.onBtnReceive()
            end
        end)
        self.txtReceive.text = lang.trans("receive")
    elseif status == PlayerLetterConstants.LetterState.HAVE_AWARD then -- 已领取
        self.buttonReceive.interactable = false
        self.txtReceive.text = lang.trans("have_received")
    else
        self.buttonReceive.interactable = false
        self.txtReceive.text = lang.trans("receive")
    end
end

function TimeLimitLeaugeLetterView:UpdateAfterReceive()
    self:InitReceiveBtn()
end

return TimeLimitLeaugeLetterView
local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local TweenExtensions = Tweening.TweenExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MailBarView = class(unity.base)

function MailBarView:ctor()
    self.icon = self.___ex.icon
    self.titleBar = self.___ex.titleBar
    self.title = self.___ex.title
    self.time = self.___ex.time
    self.btnArea = self.___ex.btnArea
    self.collectButton = self.___ex.collectButton
    self.collectButtonScripts = self.___ex.collectButtonScripts
    self.collectButtonText = self.___ex.collectButtonText
    self.mailBarIcon = self.___ex.mailBarIcon
    self.mailRestTime = self.___ex.mailRestTime
    self.rewardContent = self.___ex.rewardContent
    self.recieved = self.___ex.recieved
    self.read = self.___ex.read

    self.marquee = self.___ex.marquee
    self.marqueeStartPos = self.___ex.marqueeStartPos
    self.marqueeRectTrans = self.___ex.marqueeRectTrans
    self.marqueeFrame = self.___ex.marqueeFrame
end

function MailBarView:start()
    self.btnArea:regOnButtonClick(function()
        if self.clickMail then
            self.clickMail()
        end
    end)

    self.collectButton:regOnButtonClick(function()
        if self.clickCollect then
            self.clickCollect()
        end
    end)

    EventSystem.AddEvent("MailDetailModel_SetMailRead", self, self.EventSetMailRead)
end

function MailBarView:InitView(mailDetailModel)
    self.mailDetailModel = mailDetailModel
    self.title.text = mailDetailModel:GetTitle()
    self.time.text = mailDetailModel:GetTime()
    local isRead = mailDetailModel:IsRead()
    self:InitCollectButton(isRead)
    local iconType = mailDetailModel:getMailIconType()
    -- 文本图片没有暂时用通用图片替代
    iconType = (iconType > 0) and 1 or iconType
    self.mailBarIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Mail/Image/mailGiftIcon".. tostring(iconType) ..".png")
    local rewardContentTransform = self.rewardContent.transform
    self.rewardContent:InitView(mailDetailModel:GetRewardContent(), rewardContentTransform)

    self:UpdateMarquee()
    self:SetMailContentState(mailDetailModel)
end

function MailBarView:SetMailContentState(mailDetailModel)
    local isTextMail = mailDetailModel:IsTextMail()
    local titlePosY = isTextMail and -20 or -5
    self.titleBar.anchoredPosition = Vector2(self.titleBar.anchoredPosition.x, titlePosY)
    GameObjectHelper.FastSetActive(self.marqueeFrame.gameObject, not isTextMail)
end

local marqueeAreaWidth = 220
function MailBarView:UpdateMarquee()
    if self.tweener then 
        TweenExtensions.Restart(self.tweener)
        self.marqueeRectTrans.anchoredPosition = Vector2(0, 0)
    end
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        local marqueeWidth = self.marquee.sizeDelta.x
        if marqueeWidth > marqueeAreaWidth then
            local marqueeScrollSpeed = 80
            self.marqueeRectTrans.position = self.marqueeStartPos.position
            local time = (self.marqueeFrame.rect.width + marqueeWidth) / marqueeScrollSpeed
            self.tweener = ShortcutExtensions.DOAnchorPosX(self.marqueeRectTrans, - marqueeWidth, time)
            TweenSettingsExtensions.SetEase(self.tweener, Ease.Linear)
            TweenSettingsExtensions.SetLoops(self.tweener, -1)
        end
    end)
end

function MailBarView:InitCollectButton(isRead)
    local isTextMail = self.mailDetailModel:IsTextMail()
    if not isRead then 
        self.collectButtonText.text = lang.trans("check_formation") 
    end

    self.collectButton:onPointEventHandle(not isRead)
    GameObjectHelper.FastSetActive(self.collectButton.gameObject, not isRead)
    GameObjectHelper.FastSetActive(self.recieved, isRead and not isTextMail)
    GameObjectHelper.FastSetActive(self.read, isRead and isTextMail)
end

function MailBarView:SetMailRead(isRead)
    self:InitCollectButton(isRead)
end

function MailBarView:EventSetMailRead(mailID)
    if self.mailDetailModel:GetMailID() == mailID then 
        self:SetMailRead(self.mailDetailModel:IsRead())
    end
end

function MailBarView:onDestroy()
    EventSystem.RemoveEvent("MailDetailModel_SetMailRead", self, self.EventSetMailRead)
end

return MailBarView

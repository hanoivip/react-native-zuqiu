local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Vector2 = UnityEngine.Vector2
local MailDetailView = class(unity.base)
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

function MailDetailView:ctor()
    self.title = self.___ex.title
    self.time = self.___ex.time
    self.desc = self.___ex.desc
    self.scrollArea = self.___ex.scrollArea
    self.btnCollect = self.___ex.btnCollect
    self.touchMask = self.___ex.touchMask
    self.haveCollected = self.___ex.haveCollected
    self.haveRead = self.___ex.haveRead
    self.content = self.___ex.content
    self.rewardBoard = self.___ex.rewardBoard
    self.textBoard = self.___ex.textBoard
    self.contentRect = self.___ex.contentRect
    self.buttonText = self.___ex.buttonText
end

function MailDetailView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.touchMask:regOnButtonClick(function()
        self:Close()
    end)
    self.btnCollect:regOnButtonClick(function()
        if self.clickCollect then
            self.clickCollect()
        end
    end)
end

function MailDetailView:Close(popCongratulationsPage)
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
            self.closeDialog()
            if type(popCongratulationsPage) == "function" then
                popCongratulationsPage()
            end
        end)
    end
end

local TextRectHeight = 400
local RewardRectHeight = 260
function MailDetailView:InitView(mailDetailModel)
    self.mailDetailModel = mailDetailModel
    self.title.text = mailDetailModel:GetTitle()
    local mailRestTime = tostring(mailDetailModel:GetRestTime())
    self.time.text = lang.trans("mail_restTime", mailRestTime)
    self.desc.inline.text = mailDetailModel:GetDesc()
    local isTextMail = mailDetailModel:IsTextMail()
    self.buttonText.text = isTextMail and lang.trans("email_read") or lang.trans("receive")
    if not mailDetailModel:IsRead() then
        GameObjectHelper.FastSetActive(self.btnCollect.gameObject, true)
        GameObjectHelper.FastSetActive(self.haveCollected, false)
        GameObjectHelper.FastSetActive(self.haveRead, false)
    else
        GameObjectHelper.FastSetActive(self.haveRead, isTextMail)
        GameObjectHelper.FastSetActive(self.haveCollected, not isTextMail)
        GameObjectHelper.FastSetActive(self.btnCollect.gameObject, false)
    end
    local fixHeight = isTextMail and TextRectHeight or RewardRectHeight
    self.contentRect.sizeDelta = Vector2(self.contentRect.sizeDelta.x, fixHeight)
    GameObjectHelper.FastSetActive(self.rewardBoard.gameObject, not isTextMail)
    GameObjectHelper.FastSetActive(self.textBoard.gameObject, isTextMail)
    if mailDetailModel:HasContent() then
        local rewardParams = {
            parentObj = self.scrollArea,
            rewardData = mailDetailModel:GetRewardContent(),
            isShowName = true,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = false,
            itemParams = {
                 nameColor = Color.black,
                 nameShadowColor = Color.white,
            },
        }
        RewardDataCtrl.new(rewardParams)
    end

    if not isTextMail and self.scrollArea.transform.childCount <= 0 then
        self.btnCollect.gameObject:SetActive(false)
    end
end

function MailDetailView:SetAttachment(attachment)
    attachment.transform:SetParent(self.scrollArea.transform, false)
end

return MailDetailView

local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GUILD_MEMBERTYPE = require("ui.controllers.guild.GUILD_MEMBERTYPE")
local AssetFinder = require("ui.common.AssetFinder")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Tweening = clr.DG.Tweening
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local CapsUnityLuaBehavEnable = clr.CapsUnityLuaBehavEnable

local GuildHomeView = class(unity.base)

function GuildHomeView:ctor()
    self.contribute = self.___ex.contribute
    self.member = self.___ex.member
    self.applyType = self.___ex.applyType
    self.level = self.___ex.level
    self.nameTxt = self.___ex.name
    self.serverName = self.___ex.serverName
    self.logo = self.___ex.logo
    self.btnLog = self.___ex.btnLog
    self.btnRank = self.___ex.btnRank
    self.btnChat = self.___ex.btnChat
    self.notice = self.___ex.notice
    self.memberScrollerView = self.___ex.memberScrollerView
    self.requestScrollerView = self.___ex.requestScrollerView
    self.btnGuildSetting = self.___ex.btnGuildSetting
    self.btnRequest = self.___ex.btnRequest
    self.btnArrow = self.___ex.btnArrow
    self.btnSetting = self.___ex.btnSetting
    self.bottomTitle = self.___ex.bottomTitle
    self.infoBarDynParent = self.___ex.infoBar
    self.panel = self.___ex.panel
    self.btnQuit = self.___ex.btnQuit
    self.btnSign = self.___ex.btnSign
    self.logoAnimator = self.___ex.logoAnimator
    self.animator = self.___ex.animator
    self.btnChallenge = self.___ex.btnChallenge
    self.signInRedPoint = self.___ex.signInRedPoint
    self.chatRedPoint = self.___ex.chatRedPoint
    self.btnWar = self.___ex.btnWar
    self.warEffect = self.___ex.warEffect
    self.warGlow = self.___ex.warGlow
    self.challengeRedPoint = self.___ex.challengeRedPoint
    self.warRedPoint = self.___ex.warRedPoint
    self.powerTxt = self.___ex.powerTxt
    self.requestRedPoint = self.___ex.requestRedPoint
    self.voteBtn = self.___ex.voteBtn
    self.donationRedPoint = self.___ex.donationRedPoint
end

function GuildHomeView:start()
    self.btnLog:regOnButtonClick(function()
        if type(self.onBtnLogClick) == "function" then
            self.onBtnLogClick()
        end 
    end)
    self.btnRank:regOnButtonClick(function()
        if type(self.onBtnRankClick) == "function" then
            self.onBtnRankClick()
        end  
    end)
    self.btnChat:regOnButtonClick(function()
        if type(self.onBtnChatClick) == "function" then
            self.onBtnChatClick()
        end  
    end)
    self.btnGuildSetting:regOnButtonClick(function()
        if type(self.onBtnGuildSettingClick) == "function" then
            self.onBtnGuildSettingClick()
        end  
    end)
    self.btnRequest:regOnButtonClick(function()
        if type(self.onBtnRequestClick) == "function" then
            self.onBtnRequestClick()
        end  
    end)
    self.btnSetting:regOnButtonClick(function()
        if type(self.onBtnSettingClick) == "function" then
            self.onBtnSettingClick()
        end
    end)
    self.btnArrow:regOnButtonClick(function()
        if type(self.onBtnArrowClick) == "function" then
            self.onBtnArrowClick()
        end
    end)
    self.btnQuit:regOnButtonClick(function()
        if type(self.onBtnQuitClick) == "function" then
            self.onBtnQuitClick()
        end
    end)
    self.btnSign:regOnButtonClick(function()
        if type(self.onBtnSignInClick) == "function" then
            self.onBtnSignInClick()
        end
    end)
    self.btnChallenge:regOnButtonClick(function()
        if type(self.onBtnChallengeClick) == "function" then
            self.onBtnChallengeClick()
        end
    end)
    self.btnWar:regOnButtonClick(function()
        if type(self.onBtnWarClick) == "function" then
            self.onBtnWarClick()
        end
    end)
    self.voteBtn:regOnButtonClick(function()
        if type(self.onBtnVoteClick) == "function" then
            self.onBtnVoteClick()
        end
    end)
    self.gameObject:AddComponent(CapsUnityLuaBehavEnable)end

local distance = 400
function GuildHomeView:MoveUpThePanel()
    local tweener = ShortcutExtensions.DOAnchorPosY(self.panel, distance, 0.5)
    TweenSettingsExtensions.SetEase(tweener, Ease.InOutQuad)
end

function GuildHomeView:MoveDownThePanel()
    local tweener = ShortcutExtensions.DOAnchorPosY(self.panel, 0, 0.5)
    TweenSettingsExtensions.SetEase(tweener, Ease.InOutQuad)
end

function GuildHomeView:SetArrowUpState()
    self.btnArrow.gameObject.transform.localScale = Vector3(1, 1, 1)
end

function GuildHomeView:SetArrowDownState()
    self.btnArrow.gameObject.transform.localScale = Vector3(1, -1, 1)
end

function GuildHomeView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function GuildHomeView:SetBtnSettingScale(ismanager)
    if ismanager == true then
        self.btnSetting.gameObject.transform.localScale = Vector3(1, 1, 1)
    else
        self.btnSetting.gameObject.transform.localScale = Vector3(1.3, 1.3, 1)
    end
end

function GuildHomeView:SetButtonsState(state)
    GameObjectHelper.FastSetActive(self.btnChat.gameObject, state)
    GameObjectHelper.FastSetActive(self.btnLog.gameObject, state)
    GameObjectHelper.FastSetActive(self.btnRank.gameObject, state)
    GameObjectHelper.FastSetActive(self.btnSign.gameObject, state)
    GameObjectHelper.FastSetActive(self.voteBtn.gameObject, state)
end

function GuildHomeView:SetWarEffectState(state)
    GameObjectHelper.FastSetActive(self.warEffect, state)
    GameObjectHelper.FastSetActive(self.warGlow, state)
end

function GuildHomeView:InitInfoView(data, ctrl)
    self.ctrl = ctrl
    self.animator.enabled = true
    self.nameTxt.text = data.name
    self.serverName.text = data.serverName
    self.contribute.text = tostring(data.cumulativeTotal)
    self.member.text = data.memberNum .. "/40"
    self.level.text = tostring(data.minPlayerLvl)
    self.notice.text = data.msg
    self.powerTxt.text = string.formatIntWithTenThousands(data.power)
    self.logo.overrideSprite = AssetFinder.GetGuildIcon("GuildLogo" .. data.eid)
    if tonumber(data.requestAcceptType) == 1 then
        self.applyType.text = lang.transstr("guild_reqAuto2")
    else
        self.applyType.text = lang.transstr("guild_reqAuto1")
    end
    self:IsShowSignInRedPoint()
    self:IsShowDonationRedPoint()
    self:IsShowChatRedPoint()
    self:IsShowChallengeRedPoint()
    self:IsShowWarRedPoint()
    self:IsShowRequestRedPoint()
end

function GuildHomeView:InitButtonState(myselfType)
    if myselfType ~= GUILD_MEMBERTYPE.MEMBER then
        GameObjectHelper.FastSetActive(self.btnRequest.gameObject, true)
        GameObjectHelper.FastSetActive(self.btnSetting.gameObject, true)

        if myselfType == GUILD_MEMBERTYPE.ELDER then
            GameObjectHelper.FastSetActive(self.btnGuildSetting.gameObject, false)
        else
            GameObjectHelper.FastSetActive(self.btnGuildSetting.gameObject, true)
        end
    else
        GameObjectHelper.FastSetActive(self.btnSetting.gameObject, false)
        GameObjectHelper.FastSetActive(self.btnRequest.gameObject, false)
        GameObjectHelper.FastSetActive(self.btnGuildSetting.gameObject, false)
    end
end

function GuildHomeView:IsShowSignInRedPoint()
    local signIn = ReqEventModel.GetInfo("guildSign")
    GameObjectHelper.FastSetActive(self.signInRedPoint, tonumber(signIn) > 0)
end

function GuildHomeView:IsShowDonationRedPoint()
    local guildDonation = ReqEventModel.GetInfo("guildDonation")
    GameObjectHelper.FastSetActive(self.donationRedPoint, tonumber(guildDonation) > 0)
end

function GuildHomeView:IsShowChatRedPoint()
    local guildMsg = ReqEventModel.GetInfo("msgGuild")
    GameObjectHelper.FastSetActive(self.chatRedPoint, tonumber(guildMsg) > 0)
end

function GuildHomeView:IsShowChallengeRedPoint()
    local guildChlg = ReqEventModel.GetInfo("guildChlg")
    GameObjectHelper.FastSetActive(self.challengeRedPoint, tonumber(guildChlg) > 0)
end

function GuildHomeView:IsShowWarRedPoint()
    local guildWar = ReqEventModel.GetInfo("guildWar")
    GameObjectHelper.FastSetActive(self.warRedPoint, tonumber(guildWar) > 0)
end

function GuildHomeView:IsShowRequestRedPoint()
    local guildRequest = ReqEventModel.GetInfo("guildRequest")
    GameObjectHelper.FastSetActive(self.requestRedPoint, tonumber(guildRequest) > 0)
end

function GuildHomeView:InitMemberView(model)
    self.memberScrollerView:InitView(model)
end

function GuildHomeView:onAnimationLeave()
    self.animator.enabled = false
    self.logoAnimator:Play("GuildHomeLogo")
end

function GuildHomeView:onDisable()
    if self.ctrl then
        self.ctrl:OnExitScene()
    end
end

return GuildHomeView

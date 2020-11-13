local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssistantCoachConstants = require("ui.models.coach.assistantSystem.AssistantCoachConstants")
local AssetFinder = require("ui.common.AssetFinder")

-- 助理教练头像view
local AssistantCoachPortraitView = class(unity.base, "AssistantCoachPortraitView")

function AssistantCoachPortraitView:ctor()
    self.imgIconBg = self.___ex.imgIconBg
    self.imgIcon = self.___ex.imgIcon
    self.imgLineL = self.___ex.imgLineL
    self.imgLineR = self.___ex.imgLineR
    self.sptStar = self.___ex.sptStar
    self.btnClick = self.___ex.btnClick
    self.txtName = self.___ex.txtName
    self.imgBg = self.___ex.imgBg
    self.bgLvl = self.___ex.bgLvl
    self.txtLvl = self.___ex.txtLvl

    self.acModel = nil -- 助理教练model
    self.hasAC = false -- 是否有助教Model数据
end

function AssistantCoachPortraitView:start()
end

-- 默认都显示
function AssistantCoachPortraitView:InitView(assistantCoachModel, isShowBg, isShowPortrait, isShowStar, isShowLvl, isShowName)
    self.acModel = assistantCoachModel
    self.hasAC = tobool(self.acModel ~= nil)

    self:DisplayBg(isShowBg)
    self:DisplayPortrait(isShowPortrait)
    self:DisplayStars(isShowStar)
    self:DisplayLvl(isShowLvl)
    self:DisplayName(isShowName)
end

function AssistantCoachPortraitView:DisplayBg(isShow)
    if isShow == nil then isShow = true end
    GameObjectHelper.FastSetActive(self.imgBg.gameObject, isShow)
end

function AssistantCoachPortraitView:DisplayPortrait(isShow)
    if isShow == nil then isShow = true end
    GameObjectHelper.FastSetActive(self.imgIconBg.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.imgIcon.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.imgLineL.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.imgLineR.gameObject, isShow)
    if self.hasAC then
        self.imgIconBg.overrideSprite = AssetFinder.GetAssistantCoachIconBg(self.acModel:GetIconBg())
        self.imgIcon.overrideSprite = AssetFinder.GetAssistantCoachIcon(self.acModel:GetIcon())
    else
        self.imgIconBg.overrideSprite = AssetFinder.GetAssistantCoachIconBg()
        self.imgIcon.overrideSprite = AssetFinder.GetAssistantCoachIcon()
    end
end

function AssistantCoachPortraitView:DisplayStars(isShow)
    if isShow == nil then isShow = true end
    GameObjectHelper.FastSetActive(self.sptStar.gameObject, isShow)
    if self.hasAC then
        self.sptStar:InitView(tonumber(self.acModel:GetQuality()))
    else
        self.sptStar:InitView(0)
    end
end

function AssistantCoachPortraitView:DisplayLvl(isShow)
    if isShow == nil then isShow = true end
    GameObjectHelper.FastSetActive(self.bgLvl.gameObject, isShow)
    if self.hasAC then
        self.txtLvl.text = lang.trans("friends_manager_item_level", tostring(self.acModel:GetLvl()) .. "/" .. tostring(self.acModel:GetMaxLvl()))
    else
        self.txtLvl.text = ""
    end
end

function AssistantCoachPortraitView:DisplayName(isShow)
    if isShow == nil then isShow = true end
    GameObjectHelper.FastSetActive(self.txtName.gameObject, isShow)
    if self.hasAC then
        self.txtName.text = self.acModel:GetName()
    else
        self.txtName.text = ""
    end
end

function AssistantCoachPortraitView:RegOnPortraitClick(func)
    self.btnClick:regOnButtonClick(function()
        EventSystem.SendEvent("AssistantCoachPortrait_OnPortraitClick")
        if func then
            func()
        end
    end)
end

function AssistantCoachPortraitView:GetCoachCredentialLevelName(credentialLevel)
    for k,v in pairs(CoachBaseLevel) do
        if v.coachCredentialLevel == credentialLevel then
            return v.coachName
        end
    end
end

return AssistantCoachPortraitView

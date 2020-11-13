local GameObjectHelper = require("ui.common.GameObjectHelper")
local CoachBaseLevel = require("data.CoachBaseLevel")
local CoachMainModel = require("ui.models.coach.CoachMainModel")

local AssetFinder = require("ui.common.AssetFinder")

local CoachPortraitView = class(unity.base, "CoachPortraitView")

local CredentialColor = {
    "<color=#FFFFE7FF>",
    "<color=#FBE7B1FF>",
    "<color=#FBFBFBFF>",
    "<color=#FFFFC3FF>",
    "<color=#FFFFFFFF>",
    "<color=#EED75CFF>",
    "<color=#FBF597FF>",
    "<color=#FFFFBEFF>",
}

function CoachPortraitView:ctor()
    self.imgIcon = self.___ex.imgIcon
    self.objStars = self.___ex.objStars
    self.imgGreyStars = self.___ex.imgGreyStars
    self.imgStars = self.___ex.imgStars
    self.btnClick = self.___ex.btnClick
    self.txtName = self.___ex.txtName
end

function CoachPortraitView:start()
    self:RegBtnEvent()
end

-- @para credentialLevel 教练的阶级，决定使用何种头像
-- @para starLevel 教练阶级下的等级，决定点亮几颗星星
-- @para isShowStars 是否显示星星
function CoachPortraitView:InitView(credentialLevel, starLevel, isShowStars)
    if credentialLevel == nil then credentialLevel = 1 end
    if starLevel == nil then starLevel = 1 end
    if isShowStars == nil then isShowStars = false end

    GameObjectHelper.FastSetActive(self.objStars.gameObject, isShowStars)
    self.imgIcon.overrideSprite = AssetFinder.GetCoachIcon(credentialLevel)
    if isShowStars then
        self:DisplayStars(starLevel)
    end
    local color = CredentialColor[tonumber(credentialLevel)] or "<color=#FFFFFFFF>"
    local credentialLevelName = self:GetCoachCredentialLevelName(credentialLevel)
    self.txtName.text = color .. credentialLevelName .. "</color>"
end

function CoachPortraitView:DisplayStars(starLevel)
    local count = tonumber(starLevel)

    for i = 1, count do
        GameObjectHelper.FastSetActive(self.imgStars[tostring(i)].gameObject, true)
    end

    local coachMainModel = CoachMainModel.new()
    local coachStarMaxLevel = coachMainModel:GetCoachStarMaxLevel()

    if count < 5 then
        for i = count + 1, coachStarMaxLevel do
            GameObjectHelper.FastSetActive(self.imgStars[tostring(i)].gameObject, false)
        end
    end
end

function CoachPortraitView:RegBtnEvent()
end

function CoachPortraitView:RegOnPortraitClick(func)
    self.btnClick:regOnButtonClick(function()
        EventSystem.SendEvent("CoachPortrait_OnPortraitClick")
        if func then
            func()
        end
    end)
end

function CoachPortraitView:GetCoachCredentialLevelName(credentialLevel)
    for k,v in pairs(CoachBaseLevel) do
        if v.coachCredentialLevel == credentialLevel then
            return v.coachName
        end
    end
end

return CoachPortraitView

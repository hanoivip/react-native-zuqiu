local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CoachBaseLevel = require("data.CoachBaseLevel")
local CoachMainModel = require("ui.models.coach.CoachMainModel")
local CoachHelper = require("ui.scene.coach.common.CoachHelper")

local CoachEntryView = class(unity.base, "CoachPortraitView")

function CoachEntryView:ctor()
    self.qualityImg = self.___ex.qualityImg
    self.coachNameTxt = self.___ex.coachNameTxt
    self.coachNameGradient = self.___ex.coachNameGradient
    self.imgStars = self.___ex.imgStars
end

-- @para credentialLevel 教练的阶级，决定使用何种数字背景
-- @para starLevel 教练阶级下的等级，决定点亮几颗星星
function CoachEntryView:InitView(credentialLevel, starLevel)
    if credentialLevel == nil then credentialLevel = 1 end
    if starLevel == nil then starLevel = 1 end

    local nameGradientColor = CoachHelper.CoachNameColor[tostring(credentialLevel)]
    self.coachNameGradient:ResetPointColors(table.nums(nameGradientColor))
    for i, v in ipairs(nameGradientColor) do
        self.coachNameGradient:AddPointColors(v.percent, v.color)
    end
    self.qualityImg.overrideSprite = AssetFinder.GetCoachEntryQuality(credentialLevel)
    local credentialLevelName = self:GetCoachCredentialLevelName(credentialLevel)
    self:DisplayStars(starLevel)
    self.coachNameTxt.text = credentialLevelName
end

function CoachEntryView:DisplayStars(starLevel)
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

function CoachEntryView:GetCoachCredentialLevelName(credentialLevel)
    for k,v in pairs(CoachBaseLevel) do
        if v.coachCredentialLevel == credentialLevel then
            return v.coachName
        end
    end
end

return CoachEntryView

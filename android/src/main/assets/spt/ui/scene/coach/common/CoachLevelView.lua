local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CoachMainModel = require("ui.models.coach.CoachMainModel")

local CoachLevelView = class(unity.base, "CoachPortraitView")

function CoachLevelView:ctor()
    self.imgIcon = self.___ex.imgIcon
    self.imgStars = self.___ex.imgStars
    self.btnClick = self.___ex.btnClick
end

function CoachLevelView:start()
    self:RegBtnEvent()
end

-- @para credentialLevel 教练的阶级，决定使用何种数字背景
-- @para starLevel 教练阶级下的等级，决定点亮几颗星星
function CoachLevelView:InitView(credentialLevel, starLevel)
    if credentialLevel == nil then credentialLevel = 1 end
    if starLevel == nil then starLevel = 1 end

    self.imgIcon.overrideSprite = AssetFinder.GetCoachNum(credentialLevel)
    self:DisplayStars(starLevel)
end

function CoachLevelView:DisplayStars(starLevel)
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

function CoachLevelView:RegBtnEvent()
end

function CoachLevelView:RegOnPortraitClick(func)
    self.btnClick:regOnButtonClick(function()
        EventSystem.SendEvent("CoachPortrait_OnPortraitClick")
        if func then
            func()
        end
    end)
end

return CoachLevelView

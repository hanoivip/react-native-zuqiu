local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CoachTalentRoundItemView = class(unity.base, "CoachTalentRoundItemView")

function CoachTalentRoundItemView:ctor()
    self.imgIcon = self.___ex.imgIcon
    self.txtName = self.___ex.txtName
    self.txtIndex = self.___ex.txtIndex
end

function CoachTalentRoundItemView:start()
    self:RegBtnEvent()
end

function CoachTalentRoundItemView:InitView(data)
    self.data = data
    self.imgIcon.overrideSprite = AssetFinder.GetCoachTalentRound(data.roundPicIndex)
    self.txtName.text = tostring(data.roundName)
    self.txtIndex.text = tostring(data.roundId) .. "/" .. tostring(data.roundNum)
end

function CoachTalentRoundItemView:RegBtnEvent()
    -- self.btnIntro:regOnButtonClick(function()
    --     if self.onBtnIntroClick then
    --         self.onBtnIntroClick()
    --     end
    -- end)
end

return CoachTalentRoundItemView

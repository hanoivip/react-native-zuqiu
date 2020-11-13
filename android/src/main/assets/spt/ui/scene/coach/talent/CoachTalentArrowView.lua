local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
 
local CoachTalentArrowView = class(unity.base, "CoachTalentArrowView")

function CoachTalentArrowView:ctor()
    self.rct = self.___ex.rct
    self.img = self.___ex.img
end

function CoachTalentArrowView:start()
end

function CoachTalentArrowView:InitView(pos, length)
    local height = self.rct.sizeDelta.y
    self.rct.anchoredPosition = Vector2(pos.x, pos.y + height / 2)
    self.rct.sizeDelta = Vector2(length, height)
end

function CoachTalentArrowView:SetState(isNodeLocked, canNodeUnlock)
    if isNodeLocked then
        if canUnlock then
            self.img.color = Color(1, 1, 1, 1)
        else
            self.img.color = Color(0, 1, 1, 1)
        end
    else
        self.img.color = Color(1, 1, 1, 1)
    end
end

function CoachTalentArrowView:ResetState()
    self.img.color = Color(1, 1, 1, 1)
end

return CoachTalentArrowView

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Quaternion = UnityEngine.Quaternion
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CoachTalentLineView = class(unity.base, "CoachTalentLineView")

CoachTalentLineView.LineType = {
    vertical = "vertical",
    horizontal = "horizontal",
}

function CoachTalentLineView:ctor()
    self.rct = self.___ex.rct
    self.img = self.___ex.img
end

function CoachTalentLineView:start()
end

function CoachTalentLineView:InitView(pos, length, lineType)
    local width = self.rct.sizeDelta.x
    if lineType == self.LineType.horizontal then
        self.rct.anchoredPosition = Vector2(pos.x, pos.y - width / 2)
        self.rct.localRotation = Quaternion.Euler(Vector3(0, 0, 90))
    else -- 默认竖直
        self.rct.anchoredPosition = Vector2(pos.x, pos.y)
        self.rct.localRotation = Quaternion.Euler(Vector3.zero)
    end
    self.rct.sizeDelta = Vector2(width, length)
end

function CoachTalentLineView:SetState(isNodeLocked, canNodeUnlock)
    if isNodeLocked then
        self.img.color = Color(0, 1, 1, 1)
    else
        self.img.color = Color(1, 1, 1, 1)
    end
end

function CoachTalentLineView:ResetState()
    self.img.color = Color(1, 1, 1, 1)
end

return CoachTalentLineView

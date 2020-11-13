local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Screen = UnityEngine.Screen

local GuideToMatchView = class(unity.base)

function GuideToMatchView:ctor()
    self.guideArea = self.___ex.guideArea
end

function GuideToMatchView:InitView()
    local distanceMoveUp = 0
    if Screen.width / Screen.height < 1.4 then
        distanceMoveUp = 50
    end
    self.guideArea.anchoredPosition = Vector2(self.guideArea.localPosition.x, self.guideArea.localPosition.y + distanceMoveUp)
end

return GuideToMatchView
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local ToCareerRaceView = class(unity.base)
    
function ToCareerRaceView:ctor()
    EventSystem.SendEvent("GuideManager.RaceGuideActive")
    self.hole = self.___ex.hole
    self.attentionArea = self.___ex.attentionArea
    self.handParent = self.___ex.handParent
end

function ToCareerRaceView:InitView()
    local guideCareerRaceFlag = cache.getGuideCareerRaceFlag()
    if guideCareerRaceFlag and guideCareerRaceFlag.isChangeCoordinate then
        self.hole.anchoredPosition = Vector2(6, 181)
        self.attentionArea.anchoredPosition = Vector2(-2, 177)
        self.handParent.anchoredPosition = Vector2(160, 250)        
    end
end

return ToCareerRaceView
local PlayTipsContentItemView = class(unity.base)

function PlayTipsContentItemView:ctor()
--------Start_Auto_Generate--------
    self.floorTxt = self.___ex.floorTxt
    self.completeScoreTxt = self.___ex.completeScoreTxt
    self.areaScoreTxt = self.___ex.areaScoreTxt
--------End_Auto_Generate----------
end

function PlayTipsContentItemView:InitView(floorData)
    self.floorTxt.text = tostring(floorData.floorID)
    self.completeScoreTxt.text = tostring(floorData.stagePoint)
    self.areaScoreTxt.text = tostring(floorData.blockPoint)
end

return PlayTipsContentItemView

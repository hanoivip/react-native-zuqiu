local TrophyInfoBoardView = class(unity.base)

function TrophyInfoBoardView:ctor()
    self.trophyName = self.___ex.trophyName
    self.description = self.___ex.description
    self.finishTime = self.___ex.finishTime
end

function TrophyInfoBoardView:InitView(honorPalaceItemModel)
    self.trophyName.text = honorPalaceItemModel:GetName()
    self.description.text = honorPalaceItemModel:GetDesc()
    self.finishTime.text = honorPalaceItemModel:GetTime()
end

return TrophyInfoBoardView
local FormationKeyPlayerInfoBoardView = class(unity.base)

function FormationKeyPlayerInfoBoardView:ctor()
    self.keyPlayerTypeName = self.___ex.keyPlayerTypeName
    self.keyPlayerName = self.___ex.keyPlayerName
    self.skillAttr = self.___ex.skillAttr
    self.normalAttr = self.___ex.normalAttr
end

function FormationKeyPlayerInfoBoardView:InitView(data)
    self.keyPlayerTypeName.text = data.keyPlayerTypeName
    self.keyPlayerName.text = data.keyPlayerName
    self.skillAttr.text = data.skillAttr
    self.normalAttr.text = data.normalAttr
end

return FormationKeyPlayerInfoBoardView
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")

local GreenswardStarLibItemView = class(unity.base, "GreenswardStarLibItemView")

function GreenswardStarLibItemView:ctor()
    self.imgIcon = self.___ex.imgIcon
    self.txtName = self.___ex.txtName
    self.txtDesc = self.___ex.txtDesc
end

function GreenswardStarLibItemView:start()
end

function GreenswardStarLibItemView:InitView(greenswardStarModel)
    self.model = greenswardStarModel
    self.imgIcon.overrideSprite = AssetFinder.GetGreenswardStarIcon(self.model:GetIconIndex())
    self.txtName.text = tostring(self.model:GetName())
    self.txtDesc.text = tostring(self.model:GetDesc())
end

function GreenswardStarLibItemView:RefreshView()
end

return GreenswardStarLibItemView

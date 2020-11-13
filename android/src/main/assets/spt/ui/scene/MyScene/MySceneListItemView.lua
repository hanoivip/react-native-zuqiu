local GameObjectHelper = require("ui.common.GameObjectHelper")
local MySceneListItemView = class(unity.base)

function MySceneListItemView:ctor()
    self.selectbg = self.___ex.selectbg
    self.select = self.___ex.select
    self.select1 = self.___ex.select1
    self.text = self.___ex.text
    self.image = self.___ex.image
    self.btn = self.___ex.btn
end

function MySceneListItemView:start()
    self.btn:regOnButtonClick(function ()
        self:OnButtonClick()
    end)
end

function MySceneListItemView:InitView(mySceneItemModel)
    self.text.text = mySceneItemModel:GetName()
    self.image.overrideSprite = mySceneItemModel:GetIcon()
    self.image:SetNativeSize()
end

function MySceneListItemView:OnButtonClick()
end

function MySceneListItemView:OnSelect(bActive)
    GameObjectHelper.FastSetActive(self.selectbg.gameObject, not bActive)
    GameObjectHelper.FastSetActive(self.select.gameObject, bActive)
    GameObjectHelper.FastSetActive(self.select1.gameObject, bActive)
end

return MySceneListItemView
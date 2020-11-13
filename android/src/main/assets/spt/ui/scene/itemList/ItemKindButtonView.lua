local LuaButton = require("ui.control.button.LuaButton")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ItemListConstants = require("ui.models.itemList.ItemListConstants")

local ItemKindButtonView = class(LuaButton)

function ItemKindButtonView:ctor()
    ItemKindButtonView.super.ctor(self)
    self.down = self.___ex.down
    self.up = self.___ex.up
    self.upText = self.___ex.upText
    self.pressText = self.___ex.pressText
end

function ItemKindButtonView:start()
    self:regOnButtonClick(function()
        self:OnBtnClick()
    end)
end

function ItemKindButtonView:InitView(id, name, state)
    self.id = id
    self.state = state
    self.upText.text = lang.trans(name)
    self.pressText.text = lang.trans(name)
    self:ChangeButtonState()
end

function ItemKindButtonView:GetState()
    return self.state
end

function ItemKindButtonView:SetState(state)
    self.state = state
    self:ChangeButtonState()
end

function ItemKindButtonView:SetButtonState(selectMap, isSelect)
    for k, v in pairs(selectMap) do
        GameObjectHelper.FastSetActive(v, isSelect)
    end
end

function ItemKindButtonView:ChangeButtonState()
    local isSelect = (self.state == ItemListConstants.KindState.SELECTED)
    self:SetButtonState(self.down, isSelect)
    self:SetButtonState(self.up, not isSelect)
end

function ItemKindButtonView:OnBtnClick()
    if self.state == ItemListConstants.KindState.UNSELECTED then
        self.state = ItemListConstants.KindState.SELECTED
    else
        self.state = ItemListConstants.KindState.UNSELECTED
    end
    self:ChangeButtonState()
end

return ItemKindButtonView
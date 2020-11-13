local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")

local CardMemorySelectSortButtonView = class(LuaButton, "CardMemorySelectSortButtonView")

function CardMemorySelectSortButtonView:ctor()
    CardMemorySelectSortButtonView.super.ctor(self)
    self.objArrow = self.___ex.objArrow
    self.arrowUp = self.___ex.arrowUp
    self.arrowDown = self.___ex.arrowDown
    self.rctTxt = self.___ex.rctTxt
end

function CardMemorySelectSortButtonView:ShowSortOrder(isShow)
    GameObjectHelper.FastSetActive(self.objArrow.gameObject, isShow)
    local oldPos = self.rctTxt.anchoredPosition
    local x = isShow and -8 or 0
    self.rctTxt.anchoredPosition = Vector2(x, oldPos.y)
end

function CardMemorySelectSortButtonView:SetSortOrder(sortOrder)
    self.arrowUp.interactable = sortOrder
    self.arrowDown.interactable = not sortOrder
end

return CardMemorySelectSortButtonView

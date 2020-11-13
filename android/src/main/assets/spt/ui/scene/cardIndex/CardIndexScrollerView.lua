local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local CardIndexScrollerView = class(LuaScrollRectExSameSize)

function CardIndexScrollerView:ctor()
    self.scrollRect = self.___ex.scrollRect
    self.cardIndexViewModel = nil
    self.super.ctor(self)
end

function CardIndexScrollerView:InitView(cardIndexViewModel)
    self.cardIndexViewModel = cardIndexViewModel
    self.itemDatas = self.cardIndexViewModel:GetCardListByFilter()

    self:refresh(self.itemDatas, self.cardIndexViewModel:GetScrollNormalizedPosition())
end

function CardIndexScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/CardIndex/CardIndexPlayer.prefab"
    local obj, spt = res.Instantiate(prefab)
    spt:InitView(self.itemDatas[index], self.cardIndexViewModel)
    return obj
end

function CardIndexScrollerView:resetItem(spt, index)
    spt:InitView(self.itemDatas[index], self.cardIndexViewModel)
    spt:BuildPage()
end

function CardIndexScrollerView:GetScrollNormalizedPosition()
    return self:getScrollNormalizedPos()
end

return CardIndexScrollerView
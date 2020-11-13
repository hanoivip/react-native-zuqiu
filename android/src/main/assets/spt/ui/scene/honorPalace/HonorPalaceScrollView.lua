local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local HonorPalaceScrollView = class(LuaScrollRectExSameSize)

function HonorPalaceScrollView:ctor()
    HonorPalaceScrollView.super.ctor(self)
end

function HonorPalaceScrollView:start()

end

function HonorPalaceScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/HonorPalace/HonorPalaceScrollBar.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function HonorPalaceScrollView:resetItem(spt, index)
    local honorPalaceItemModel = self.data[index]
    spt:InitView(honorPalaceItemModel)
    spt.clickReceive = function() self:clickRecieveTrophy(honorPalaceItemModel.ID) end
    self:updateItemIndex(spt, index)
end

function HonorPalaceScrollView:InitView(data)
    self.data = data
    self:calcCellCount()
    self:refresh(self.data)
end

function HonorPalaceScrollView:clickRecieveTrophy(trophyId)
    if self.clickReceive then
        self.clickReceive(trophyId)
    end
end

return HonorPalaceScrollView
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local PasterScrollView = class(LuaScrollRectExSameSize)

function PasterScrollView:ctor()
    PasterScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.pasterMap = {}
    self.selectPasterIndex = nil
end

function PasterScrollView:GetPasterCardRes()
    if not self.pasterCardRes then 
        self.pasterCardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/PasterCard.prefab")
    end
    return self.pasterCardRes
end

function PasterScrollView:GetPasterRes()
    if not self.pasterRes then 
        self.pasterRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/Paster.prefab")
    end
    return self.pasterRes
end

function PasterScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetPasterCardRes())
    local spt = res.GetLuaScript(obj)
    spt.clickCardPaster = function(index, cardPasterModel) self:OnClickCardPaster(index, cardPasterModel) end
    self:resetItem(spt, index)
    return obj
end

function PasterScrollView:resetItem(spt, index)
    local cardPasterModel = self.itemDatas[index]
    local pasterRes = self:GetPasterRes()
    spt:InitView(cardPasterModel, self.cardResourceCache, pasterRes)
    self:updateItemIndex(spt, index)
end

function PasterScrollView:updateItemIndex(spt, index)
    spt:UpdateItemIndex(index)
    self.pasterMap[tostring(index)] = spt
end

function PasterScrollView:OnClickCardPaster(index, cardPasterModel)
    if self.clickCardPaster then 
        self.clickCardPaster(cardPasterModel)
    end
end

function PasterScrollView:InitView(pasterListSortModel, cardResourceCache)
    self.cardResourceCache = cardResourceCache
    self:refresh(pasterListSortModel)
end

return PasterScrollView

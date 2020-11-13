local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local PasterAvailableScrollView = class(LuaScrollRectExSameSize)

function PasterAvailableScrollView:ctor()
    PasterAvailableScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
end

function PasterAvailableScrollView:GetPasterNodeRes()
    if not self.pasterNodeRes then 
        self.pasterNodeRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/PasterAvailableNode.prefab")
    end
    return self.pasterNodeRes
end

function PasterAvailableScrollView:GetPasterRes()
    if not self.pasterRes then 
        self.pasterRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/Paster.prefab")
    end
    return self.pasterRes
end

function PasterAvailableScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetPasterNodeRes())
    local spt = res.GetLuaScript(obj)
    spt.clickUse = function(index, cardPasterModel) self:OnClickUse(index, cardPasterModel) end
    self:resetItem(spt, index)
    return obj
end

function PasterAvailableScrollView:resetItem(spt, index)
    local cardPasterModel = self.itemDatas[index]
    local pasterRes = self:GetPasterRes()
    spt:InitView(cardPasterModel, pasterRes)
    self:updateItemIndex(spt, index)
end

function PasterAvailableScrollView:updateItemIndex(spt, index)
    spt:UpdateItemIndex(index)
end

function PasterAvailableScrollView:destroyItem(index)
end

function PasterAvailableScrollView:OnClickUse(index, cardPasterModel)
    if self.clickUse then 
        self.clickUse(cardPasterModel)
    end
end

function PasterAvailableScrollView:SortPasterList(pasterAvailableModel)
    table.sort(pasterAvailableModel, function(aModel, bModel)
        if aModel:GetPasterType() == bModel:GetPasterType() then
            return aModel:GetPasterQuality() > bModel:GetPasterQuality()
        else
            return aModel:GetPasterType() > bModel:GetPasterType()
        end
    end)
end

function PasterAvailableScrollView:InitView(cardModel)
    local pasterAvailable = cardModel:GetPasterAvailableModel()
    self:SortPasterList(pasterAvailable)
    self:refresh(pasterAvailable)
end

return PasterAvailableScrollView

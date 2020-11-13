local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local PasterUpgradeScrollView = class(LuaScrollRectExSameSize)

function PasterUpgradeScrollView:ctor()
    PasterUpgradeScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.pasterMap = {}
    self.selectPasterIndex = nil
end

function PasterUpgradeScrollView:GetUpgradePasterCardRes()
    if not self.upgradePasterCardRes then 
        self.upgradePasterCardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PasterUpgrade/PasterUpgradeItem.prefab")
    end
    return self.upgradePasterCardRes
end

function PasterUpgradeScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetUpgradePasterCardRes())
    local spt = res.GetLuaScript(obj)
    spt.clickCardPaster = function(index, cardPasterModel) self:OnClickCardPaster(index, cardPasterModel) end
    self:resetItem(spt, index)
    return obj
end

function PasterUpgradeScrollView:resetItem(spt, index)
    local cardPasterModel = self.itemDatas[index]
    spt:InitView(cardPasterModel, self.cardResourceCache, self.selectedMap)
    self:updateItemIndex(spt, index)
end

function PasterUpgradeScrollView:updateItemIndex(spt, index)
    spt:UpdateItemIndex(index)
    self.pasterMap[tostring(index)] = spt
end

function PasterUpgradeScrollView:OnClickCardPaster(index, cardPasterModel)
    if self.clickCardPaster then 
        self.clickCardPaster(cardPasterModel)
    end
end

function PasterUpgradeScrollView:InitView(pasterListSortModel, cardResourceCache, selectedMap)
    self.cardResourceCache = cardResourceCache
    self.selectedMap = selectedMap
    self:refresh(pasterListSortModel)
end

return PasterUpgradeScrollView

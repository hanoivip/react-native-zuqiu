local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local EventSystem = require("EventSystem")
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local PasterListScrollView = class(LuaScrollRectExSameSize)

function PasterListScrollView:ctor()
    self.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.pasterMap = {}
    self.sptTable = {}

    local selectedPasterModel = {}
    self.selectedPasterModel = {}       --cache returns a referrence
    for k, v in pairs(selectedPasterModel) do
        self.selectedPasterModel[k] = v
    end
end

function PasterListScrollView:GetPasterCardRes()
    if not self.pasterCardRes then 
        self.pasterCardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Activties/PasterSplit/PasterListNode.prefab")
    end
    return self.pasterCardRes
end

function PasterListScrollView:GetPasterRes()
    if not self.pasterRes then 
        self.pasterRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/Paster.prefab")
    end
    return self.pasterRes
end

function PasterListScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetPasterCardRes())
    local spt = res.GetLuaScript(obj)
    spt.clickUse = function(index, cardPasterModel) self:OnClickCardPaster(index, cardPasterModel) end
    self:resetItem(spt, index)
    return obj
end

function PasterListScrollView:resetItem(spt, index)
    local cardPasterModel = self.itemDatas[index]
    if not self.sptTable[index] then self.sptTable[index] = spt end 
    local pasterRes = self:GetPasterRes()
    spt:InitView(cardPasterModel, pasterRes)
    self:updateItemIndex(spt, index)
end

function PasterListScrollView:updateItemIndex(spt, index)
    spt:UpdateItemIndex(index)
end

function PasterListScrollView:destroyItem(index)
end

function PasterListScrollView:OnClickCardPaster(index, cardPasterModel)
    self.selectedPasterModel.cardPasterModel = cardPasterModel
    local ptid = self.selectedPasterModel.cardPasterModel:GetId()
    self.selectedPasterModel.selectedPtid = ptid
    self.selectedPasterModel.cardResourceCache = self.cardResourceCache
    EventSystem.SendEvent("PasterSplit_ChangeView", true, self.selectedPasterModel)
    self.parentView:Close()
end

function PasterListScrollView:InitView(parentView, pasterSplitableModelList, cardResourceCache)
    self.parentView = parentView
    self.cardResourceCache = cardResourceCache
    self:refresh(pasterSplitableModelList)
end

return PasterListScrollView

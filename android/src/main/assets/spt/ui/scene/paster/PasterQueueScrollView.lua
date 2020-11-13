local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CardOpenFromType = require("ui.controllers.cardDetail.CardOpenFromType")

local PasterQueueScrollView = class(LuaScrollRectExSameSize)

function PasterQueueScrollView:ctor()
    PasterQueueScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.pasterMap = {}
    self.selectPasterIndex = nil
    self.bSupporter = false
end

function PasterQueueScrollView:GetPasterBarRes()
    if not self.pasterBarRes then 
        self.pasterBarRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/PasterBar.prefab")
    end
    return self.pasterBarRes
end

function PasterQueueScrollView:GetPasterRes()
    if not self.pasterRes then 
        self.pasterRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/Paster.prefab")
    end
    return self.pasterRes
end

function PasterQueueScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetPasterBarRes())
    local spt = res.GetLuaScript(obj)
    spt.clickAppend = function() self:OnClickAppend() end
    spt.clickUse = function(cardAppendPasterModel) self:OnClickUse(cardAppendPasterModel) end
    spt.clickCardPaster = function(cardAppendPasterModel) self:OnClickCardPaster(cardAppendPasterModel) end
    spt.clickSkill = function(index, cardAppendPasterModel) self:OnClickSkill(index, cardAppendPasterModel) end
    spt.bSupporter = self.bSupporter
    self:resetItem(spt, index)
    return obj
end

function PasterQueueScrollView:resetItem(spt, index)
    local cardAppendPasterModel = self.itemDatas[index]
    local pasterRes = self:GetPasterRes()
    spt:InitView(cardAppendPasterModel, pasterRes)
    self:updateItemIndex(spt, index)
end

function PasterQueueScrollView:updateItemIndex(spt, index)
    spt:UpdateItemIndex(index)
    self.pasterMap[tostring(index)] = spt
end

function PasterQueueScrollView:destroyItem(index)
end

function PasterQueueScrollView:OnClickAppend()
    if self.clickAppend then 
        self.clickAppend()
    end
end

function PasterQueueScrollView:OnClickUse(cardAppendPasterModel)
    if self.clickUse then 
        self.clickUse(cardAppendPasterModel)
    end
end

function PasterQueueScrollView:OnClickCardPaster(cardAppendPasterModel)
    if self.clickCardPaster then 
        self.clickCardPaster(cardAppendPasterModel)
    end
end

function PasterQueueScrollView:OnClickSkill(index, cardAppendPasterModel)
    if self.clickSkill then 
        self.clickSkill(cardAppendPasterModel)
    end
end

function PasterQueueScrollView:UpdateSkillLevelUp(selectCardAppendPasterModel)
    local selectPasterId = selectCardAppendPasterModel:GetId()
    local newPasterModel = self.cardModel:GetPasterAppointModel(selectPasterId)
    for pasterIndex, v in ipairs(self.itemDatas) do
        if not v.isAppend then
            if tostring(v:GetId()) == tostring(selectPasterId) then
                self.itemDatas[pasterIndex] = newPasterModel
                self.pasterMap[tostring(pasterIndex)]:UpdateSkillLevelUp(newPasterModel)
                break
            end
        end
    end
end

function PasterQueueScrollView:InitView(pasterQueueModel, bSupporter)
    self.cardModel = pasterQueueModel:GetCardModel()
    self.bSupporter = bSupporter or false
    local pasterModelList = pasterQueueModel:GetPasterModelList()
    self:refresh(pasterModelList)
end

return PasterQueueScrollView

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CardTrainingMedalSelectScrollView = class(LuaScrollRectExSameSize)

function CardTrainingMedalSelectScrollView:ctor()
    CardTrainingMedalSelectScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.medalItemMap = {}
    self.selectMedalIndex = nil
end

function CardTrainingMedalSelectScrollView:GetMedalRes()
    if not self.itemRes then 
        self.itemRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalItem.prefab")
    end
    return self.itemRes
end

function CardTrainingMedalSelectScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetMedalRes())
    local spt = res.GetLuaScript(obj)
    self:resetItem(spt, index)
    return obj
end

function CardTrainingMedalSelectScrollView:resetItem(spt, index)
    local medalModel = self.itemDatas[index]
    spt:InitView(medalModel, index, self.selectMedalIndex)
    spt.clickMedal = function() self:OnClickMedal(index, medalModel) end
    self:UpdateItemIndex(spt, index)
end

function CardTrainingMedalSelectScrollView:UpdateItemIndex(spt, index)
    spt:UpdateItemIndex(index)
    self.medalItemMap[tostring(index)] = spt
end

function CardTrainingMedalSelectScrollView:OnClickMedal(index, medalModel)
    if self.selectMedalIndex == index then 
        return 
    end
    local preMedalItem = self.medalItemMap[tostring(self.selectMedalIndex)]
    if preMedalItem then 
        preMedalItem:IsSelect(false)
    end
    local currentMedalItem = self.medalItemMap[tostring(index)]
    if currentMedalItem then 
        currentMedalItem:IsSelect(true)
    end
    self.selectMedalIndex = index
    if self.clickMedal then 
        self.clickMedal(medalModel)
    end
end

function CardTrainingMedalSelectScrollView:InitView(pos, medalSelectModel, cardTrainingMedalModel)
    local medalArray = cardTrainingMedalModel:GetMedalList()
    self:refresh(medalArray)
end

function CardTrainingMedalSelectScrollView:OnDestroy()
    self.itemRes = nil
end

return CardTrainingMedalSelectScrollView

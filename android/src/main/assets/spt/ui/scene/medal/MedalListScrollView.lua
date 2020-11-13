local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local MedalListScrollView = class(LuaScrollRectExSameSize)

function MedalListScrollView:ctor()
    MedalListScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.medalItemMap = {}
    self.selectMedalIndex = nil
end

function MedalListScrollView:GetMedalRes()
    if not self.itemRes then 
        self.itemRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalItem.prefab")
    end
    return self.itemRes
end

function MedalListScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetMedalRes())
    local spt = res.GetLuaScript(obj)
    self:resetItem(spt, index)
    return obj
end

function MedalListScrollView:resetItem(spt, index)
    local medalModel = self.itemDatas[index]
    spt:InitView(medalModel, index, self.selectMedalIndex)
    spt.clickMedal = function(medalModel, index) self:OnClickMedal(medalModel, index) end
    self:updateItemIndex(spt, index)
end

function MedalListScrollView:updateItemIndex(spt, index)
    spt:UpdateItemIndex(index)
    self.medalItemMap[tostring(index)] = spt
end

function MedalListScrollView:OnClickMedal(medalModel, index)
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

function MedalListScrollView:InitView(medalListModel)
    self.medalListModel = medalListModel
    local medalArray = self.medalListModel:GetAllMedalMap()
    self:SearchSort(medalArray)
end

function MedalListScrollView:SearchSort(medalArray)
    self:refresh(medalArray)
    local index, nextModel = next(medalArray)
    if self.selectMedalIndex then
        -- 取消之前的选择
        local preMedalItem = self.medalItemMap[tostring(self.selectMedalIndex)]
        if preMedalItem then 
            preMedalItem:IsSelect(false)
        end
    end
    self.selectMedalIndex = nil
    if nextModel then 
        self:OnClickMedal(nextModel, index)
    end
end

function MedalListScrollView:ResetMedal(pmid)
    local model = self.medalListModel:GetSingleMedalModel(pmid)
    local index
    for i, v in ipairs(self.itemDatas) do
        if tostring(v:GetPmid()) == tostring(pmid) then 
            index = i
            self.itemDatas[i] = model
            break
        end
    end
    local medalView = self.medalItemMap[tostring(index)]
    if medalView then
        medalView:InitView(model, index)
        self.selectMedalIndex = nil
        self:OnClickMedal(model, index)
    end
end

function MedalListScrollView:RemoveMedal(pmid)
    local index
    for i, v in ipairs(self.itemDatas) do
        if tostring(v:GetPmid()) == tostring(pmid) then
            index = i
            break
        end
    end
    self:removeItem(index)
end

function MedalListScrollView:destroyItem(index)
    self.selectMedalIndex = nil
    if index > table.nums(self.itemDatas) then 
        index = 1
    end
    local nextMedalModel = self.itemDatas[index]
    self:OnClickMedal(nextMedalModel, index)
end

function MedalListScrollView:OnDestroy()
    self.itemRes = nil
end

return MedalListScrollView

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local MedalEquipScrollView = class(LuaScrollRectExSameSize)

function MedalEquipScrollView:ctor()
    MedalEquipScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.medalItemMap = {}
    self.selectMedalIndex = nil
end

function MedalEquipScrollView:GetMedalRes()
    if not self.itemRes then
        self.itemRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalItem.prefab")
    end
    return self.itemRes
end

function MedalEquipScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetMedalRes())
    local spt = res.GetLuaScript(obj)
    self:resetItem(spt, index)
    return obj
end

function MedalEquipScrollView:resetItem(spt, index)
    local medalModel = self.itemDatas[index]
    spt:InitView(medalModel, index, self.selectMedalIndex)
    spt.clickMedal = function() self:OnClickMedal(index, medalModel) end
    self:UpdateItemIndex(spt, index)
end

function MedalEquipScrollView:UpdateItemIndex(spt, index)
    spt:UpdateItemIndex(index)
    self.medalItemMap[tostring(index)] = spt
end

function MedalEquipScrollView:OnClickMedal(index, medalModel)
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

function MedalEquipScrollView:InitView(pos, medalSelectModel, playerMedalsMapModel)
    local medalArray = playerMedalsMapModel:GetSameTypeMedalMap(pos)
    self:refresh(medalArray)
end

function MedalEquipScrollView:OnDestroy()
    self.itemRes = nil
end

return MedalEquipScrollView

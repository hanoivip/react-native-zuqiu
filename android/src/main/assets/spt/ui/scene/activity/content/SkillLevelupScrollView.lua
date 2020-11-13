local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local SkillLevelupScrollView = class(LuaScrollRectExSameSize)

function SkillLevelupScrollView:ctor()
    SkillLevelupScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.itemMap = {}
end

function SkillLevelupScrollView:GetSkillBarRes()
    if not self.skillBarRes then 
        self.skillBarRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Activties/Skill/SkillBar.prefab")
    end
    return self.skillBarRes
end

function SkillLevelupScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetSkillBarRes())
    local spt = res.GetLuaScript(obj)
    spt.onRewardBtnClick = function(subID) self:OnRewardBtnClick(subID) end
    self:resetItem(spt, index)
    return obj
end

function SkillLevelupScrollView:resetItem(spt, index)
    local data = self.data[index]
    spt:InitView(data, self.cScroll, self.scrollRect)
    self:updateItemIndex(spt, index)
    self.itemMap[tostring(data.subID)] = spt
end

function SkillLevelupScrollView:InitView(skillLevelupModel)
    self.skillLevelupModel = skillLevelupModel
    self.data = self.skillLevelupModel:GetRewardData()
    self:refresh(self.data)
end

function SkillLevelupScrollView:OnRewardBtnClick(subID)
    if self.onRewardBtnClick then
        self.onRewardBtnClick(subID)
    end
end

function SkillLevelupScrollView:SkillLevelupChange(activityListId)
    local itemListData = self.skillLevelupModel:GetItemListData(activityListId)
    self.itemMap[tostring(activityListId)]:InitRewardState(itemListData.status, itemListData.value, itemListData.condition)
end

function SkillLevelupScrollView:OnEnterScene()
    EventSystem.AddEvent("SkillLevelupChange", self, self.SkillLevelupChange)
end

function SkillLevelupScrollView:OnExitScene()
    EventSystem.RemoveEvent("SkillLevelupChange", self, self.SkillLevelupChange)
end

return SkillLevelupScrollView

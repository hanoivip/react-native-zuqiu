local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GrowthPlanLoginScrollView = class(LuaScrollRectExSameSize)

function GrowthPlanLoginScrollView:ctor()
    GrowthPlanLoginScrollView.super.ctor(self)

    self.scrollRect = self.___ex.scrollRect
end

function GrowthPlanLoginScrollView:start()
end

function GrowthPlanLoginScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/GrowthPlanLogin/RewardItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GrowthPlanLoginScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    data.dateNum = data.condition or index
    spt:InitView(data, self.scrollRect, self.activityModel)  
    self:updateItemIndex(spt, index)
end

function GrowthPlanLoginScrollView:InitView(rewardList, activityModel)
    self.activityModel = activityModel
    self:refresh(rewardList)
end

return GrowthPlanLoginScrollView

local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local GrowthPlanScrollView = class(LuaScrollRectExSameSize)

function GrowthPlanScrollView:ctor()
    self.super.ctor(self)
    self.parentScrollRect = self.___ex.parentScrollRect
end

function GrowthPlanScrollView:start()
end

function GrowthPlanScrollView:InitView(growthPlanModel)
    self.activityModel = growthPlanModel
    self.itemDatas = self.activityModel:GetRewardDataList()
    self:refresh()
end

function GrowthPlanScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/GrowthPlan/GrowthPlanScrollItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GrowthPlanScrollView:resetItem(spt, index)
    spt:InitView(self.activityModel, index, self.parentScrollRect)

    spt.onRewardBtnClick = function()
        spt:coroutine(function()
            local response = req.activityFirstPay(self.activityModel:GetActivityType(),
                self.activityModel:GetRewardSubIdByIndex(index))
            if api.success(response) then
                local data = response.val
                if data.contents then
                    CongratulationsPageCtrl.new(data.contents)
                    spt:InitRewardButtonState(spt.collectStatus.collected)
                    self.activityModel:SetRewardStatusByIndex(index, spt.collectStatus.collected)
                    local selectedTabTag = self.activityModel:GetSelectedTabTag()
                    local hasRewardCollectable = self.activityModel:HasRewardCollectable(selectedTabTag)
                    EventSystem.SendEvent("TabItem_RefreshRedPoint", selectedTabTag, hasRewardCollectable)
                end
            end
        end)
    end
end

return GrowthPlanScrollView

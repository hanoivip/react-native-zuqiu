local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local ChainGrowthPlanScrollView = class(LuaScrollRectExSameSize)

function ChainGrowthPlanScrollView:ctor()
    self.super.ctor(self)
    self.parentScrollRect = self.___ex.parentScrollRect
end

function ChainGrowthPlanScrollView:start()
end

function ChainGrowthPlanScrollView:InitView(growthPlanModel)
    self.activityModel = growthPlanModel
    self.itemDatas = self.activityModel:GetRewardDataList()
    self:refresh()
end

function ChainGrowthPlanScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/ChainGrowthPlan/ChainGrowthPlanScrollItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function ChainGrowthPlanScrollView:resetItem(spt, index)
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

return ChainGrowthPlanScrollView

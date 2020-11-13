local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local GrowthPlanScrollView = class(LuaScrollRectExSameSize)

function GrowthPlanScrollView:ctor()
    self.super.ctor(self)
    self.parentScrollRect = self.___ex.parentScrollRect
    self.itemView = {}
end

function GrowthPlanScrollView:start()
end

function GrowthPlanScrollView:InitView(growthPlanModel)
    self.growthPlanModel = growthPlanModel
    self.itemDatas = growthPlanModel:GetRewardData()
    self:refresh()
end

function GrowthPlanScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/GrowthPlanItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    table.insert(self.itemView, spt)
    
    spt:InitView(self.growthPlanModel, index, self.parentScrollRect)
    spt:InitRewardButtonState(self.growthPlanModel:GetRewardStatusByIndex(index))
    spt.onRewardBtnClick = function()
        clr.coroutine(function()
            local response = req.activityFirstPay(self.growthPlanModel:GetActivityType(),
                self.growthPlanModel:GetRewardSubIdByIndex(index))
            if api.success(response) then
                local data = response.val
                if data.contents then
                    CongratulationsPageCtrl.new(data.contents)
                    spt:InitRewardButtonState(1)
                    self.growthPlanModel:SetRewardStatusByIndex(index, 1)
                end
            end
        end)
    end

    return obj
end

function GrowthPlanScrollView:resetItem(spt, index)
    spt:InitView(self.growthPlanModel, index, self.parentScrollRect)
    spt:InitRewardButtonState(self.growthPlanModel:GetRewardStatusByIndex(index))
    spt.onRewardBtnClick = function()
        clr.coroutine(function()
            local response = req.activityFirstPay(self.growthPlanModel:GetActivityType(),
                self.growthPlanModel:GetRewardSubIdByIndex(index))
            if api.success(response) then
                local data = response.val
                if data.contents then
                    CongratulationsPageCtrl.new(data.contents)
                    spt:InitRewardButtonState(1)
                    self.growthPlanModel:SetRewardStatusByIndex(index, 1)
                end
            end
        end)
    end
end

return GrowthPlanScrollView

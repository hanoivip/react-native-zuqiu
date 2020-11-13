local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local ActivitySerialPayScrollView = class(LuaScrollRectExSameSize)

function ActivitySerialPayScrollView:ctor()
    self.super.ctor(self)
    self.parentScrollRect = self.___ex.parentScrollRect
    self.itemView = {}
end

function ActivitySerialPayScrollView:start()
end

-- 消费钻石事件回调
function ActivitySerialPayScrollView:RefreshItemContent()
    for i, v in ipairs(self.itemView) do
        v:RefreshTextContentAndButtonState()
    end
end

function ActivitySerialPayScrollView:InitView(cumulativeConsumeModel)
    self.cumulativeConsumeModel = cumulativeConsumeModel
    self.itemDatas = cumulativeConsumeModel:GetRewardData()
    self:refresh()
end

function ActivitySerialPayScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/SerialPayItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    table.insert(self.itemView, spt)
    
    spt:InitView(self.cumulativeConsumeModel, index, self.parentScrollRect)
    spt:InitRewardButtonState(self.cumulativeConsumeModel:GetRewardStatusByIndex(index))
    spt.onRewardBtnClick = function ()
        clr.coroutine(function ()
            local response = req.activityCumulativePay(self.cumulativeConsumeModel:GetActivityType(),
                self.cumulativeConsumeModel:GetRewardSubIdByIndex(index))
            if api.success(response) then
                local data = response.val
                if data.contents ~= nil then 
                    CongratulationsPageCtrl.new(data.contents)
                    spt:InitRewardButtonState(1)
                end
            end
            self.cumulativeConsumeModel:SetRewardStatusByIndex(index, 1)
        end)
    end

    return obj
end

function ActivitySerialPayScrollView:resetItem(spt, index)

    spt:InitView(self.cumulativeConsumeModel, index, self.parentScrollRect)

    spt:InitRewardButtonState(self.cumulativeConsumeModel:GetRewardStatusByIndex(index))

    spt.onRewardBtnClick = function ()
        clr.coroutine(function ()
            local response = req.activityCumulativePay(self.cumulativeConsumeModel:GetActivityType(),
                self.cumulativeConsumeModel:GetRewardSubIdByIndex(index))
            if api.success(response) then
                local data = response.val
                if data.contents ~= nil then 
                    CongratulationsPageCtrl.new(data.contents)
                    spt:InitRewardButtonState(1)
                end
            end
        end)
        self.cumulativeConsumeModel:SetRewardStatusByIndex(index, 1)
    end
end

return ActivitySerialPayScrollView
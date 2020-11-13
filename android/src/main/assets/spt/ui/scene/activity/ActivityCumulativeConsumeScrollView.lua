local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local ActivityCumulativeConsumeScrollView = class(LuaScrollRectExSameSize)

function ActivityCumulativeConsumeScrollView:ctor()
    self.super.ctor(self)
    self.parentScrollRect = self.___ex.parentScrollRect
    self.itemView = {}
end

function ActivityCumulativeConsumeScrollView:start()
end

-- 消费钻石事件回调
function ActivityCumulativeConsumeScrollView:RefreshItemContent()
    for i, v in ipairs(self.itemView) do
        v:RefreshTextContentAndButtonState()
    end
end

function ActivityCumulativeConsumeScrollView:InitView(cumulativeConsumeModel)
    self.cumulativeConsumeModel = cumulativeConsumeModel
    self.itemDatas = cumulativeConsumeModel:GetRewardData()
    self:refresh()
end

function ActivityCumulativeConsumeScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/CumulativeConsumeItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    table.insert(self.itemView, spt)
    
    spt:InitView(self.cumulativeConsumeModel, index, self.parentScrollRect)
    spt:InitRewardButtonState(self.cumulativeConsumeModel:GetRewardStatusByIndex(index))
    spt.onRewardBtnClick = function ()
        clr.coroutine(function ()
            local response = req.activityCumulativeConsume(self.cumulativeConsumeModel:GetActivityType(),
                self.cumulativeConsumeModel:GetRewardSubIdByIndex(index))
            if api.success(response) then
                local data = response.val
                CongratulationsPageCtrl.new(data.contents)
                spt:InitRewardButtonState(1)
            end
            self.cumulativeConsumeModel:SetRewardStatusByIndex(index, 1)
        end)
    end

    return obj
end

function ActivityCumulativeConsumeScrollView:resetItem(spt, index)

    spt:InitView(self.cumulativeConsumeModel, index, self.parentScrollRect)

    spt:InitRewardButtonState(self.cumulativeConsumeModel:GetRewardStatusByIndex(index))

    spt.onRewardBtnClick = function ()
        clr.coroutine(function ()
            local response = req.activityCumulativeConsume(self.cumulativeConsumeModel:GetActivityType(),
                self.cumulativeConsumeModel:GetRewardSubIdByIndex(index))
            if api.success(response) then
                local data = response.val
                CongratulationsPageCtrl.new(data.contents)
                spt:InitRewardButtonState(1)
            end
        end)
        self.cumulativeConsumeModel:SetRewardStatusByIndex(index, 1)
    end
end

return ActivityCumulativeConsumeScrollView
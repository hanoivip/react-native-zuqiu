local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local ActivityOBTCumulativeConsumeScrollView = class(LuaScrollRectExSameSize)

function ActivityOBTCumulativeConsumeScrollView:ctor()
    self.super.ctor(self)
    self.parentScrollRect = self.___ex.parentScrollRect
    self.itemView = {}
end

function ActivityOBTCumulativeConsumeScrollView:start()
end

-- 消费钻石事件回调
function ActivityOBTCumulativeConsumeScrollView:RefreshItemContent()
    for i, v in ipairs(self.itemView) do
        v:RefreshTextContentAndButtonState()
    end
end

function ActivityOBTCumulativeConsumeScrollView:InitView(obtCumulativeConsumeModel)
    self.obtCumulativeConsumeModel = obtCumulativeConsumeModel
    self.itemDatas = obtCumulativeConsumeModel:GetRewardData()
    self:refresh()
end

function ActivityOBTCumulativeConsumeScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/OBTCumulativeConsumeItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    table.insert(self.itemView, spt)
    
    spt:InitView(self.obtCumulativeConsumeModel, index, self.parentScrollRect)
    spt:InitRewardButtonState(self.obtCumulativeConsumeModel:GetRewardStatusByIndex(index))
    spt.onRewardBtnClick = function ()
        clr.coroutine(function ()
            local response = req.activityCumulativeConsume(self.obtCumulativeConsumeModel:GetActivityType(),
                self.obtCumulativeConsumeModel:GetRewardSubIdByIndex(index))
            if api.success(response) then
                local data = response.val
                CongratulationsPageCtrl.new(data.contents)
                spt:InitRewardButtonState(1)
            end
            self.obtCumulativeConsumeModel:SetRewardStatusByIndex(index, 1)
        end)
    end

    return obj
end

function ActivityOBTCumulativeConsumeScrollView:resetItem(spt, index)

    spt:InitView(self.obtCumulativeConsumeModel, index, self.parentScrollRect)

    spt:InitRewardButtonState(self.obtCumulativeConsumeModel:GetRewardStatusByIndex(index))

    spt.onRewardBtnClick = function ()
        clr.coroutine(function ()
            local response = req.activityCumulativeConsume(self.obtCumulativeConsumeModel:GetActivityType(),
                self.obtCumulativeConsumeModel:GetRewardSubIdByIndex(index))
            if api.success(response) then
                local data = response.val
                if data.contents ~= nil then 
                    CongratulationsPageCtrl.new(data.contents)
                    spt:InitRewardButtonState(1)
                end
            end
        end)
        self.obtCumulativeConsumeModel:SetRewardStatusByIndex(index, 1)
    end
end

return ActivityOBTCumulativeConsumeScrollView
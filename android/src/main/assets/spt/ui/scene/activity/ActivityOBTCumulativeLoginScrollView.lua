local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local ActivityOBTCumulativeLoginScrollView = class(LuaScrollRectExSameSize)

function ActivityOBTCumulativeLoginScrollView:ctor()
    self.super.ctor(self)
    self.parentScrollRect = self.___ex.parentScrollRect
    self.itemView = {}
end

function ActivityOBTCumulativeLoginScrollView:start()
end

-- 消费钻石事件回调
function ActivityOBTCumulativeLoginScrollView:RefreshItemContent()
    for i, v in ipairs(self.itemView) do
        v:RefreshTextContentAndButtonState()
    end
end

function ActivityOBTCumulativeLoginScrollView:InitView(obtCumulativeLoginModel)
    self.obtCumulativeLoginModel = obtCumulativeLoginModel
    self.itemDatas = obtCumulativeLoginModel:GetRewardData()
    self:refresh()
end

function ActivityOBTCumulativeLoginScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/OBTCumulativeLoginItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    table.insert(self.itemView, spt)
    
    spt:InitView(self.obtCumulativeLoginModel, index, self.parentScrollRect)
    spt:InitRewardButtonState(self.obtCumulativeLoginModel:GetRewardStatusByIndex(index))
    spt.onRewardBtnClick = function ()
        clr.coroutine(function ()
            local response = req.activityCumulativePay(self.obtCumulativeLoginModel:GetActivityType(),
                self.obtCumulativeLoginModel:GetRewardSubIdByIndex(index))
            if api.success(response) then
                local data = response.val
                CongratulationsPageCtrl.new(data.contents)
                spt:InitRewardButtonState(1)
            end
            self.obtCumulativeLoginModel:SetRewardStatusByIndex(index, 1)
        end)
    end

    return obj
end

function ActivityOBTCumulativeLoginScrollView:resetItem(spt, index)

    spt:InitView(self.obtCumulativeLoginModel, index, self.parentScrollRect)

    spt:InitRewardButtonState(self.obtCumulativeLoginModel:GetRewardStatusByIndex(index))

    spt.onRewardBtnClick = function ()
        clr.coroutine(function ()
            local response = req.activityCumulativePay(self.obtCumulativeLoginModel:GetActivityType(),
                self.obtCumulativeLoginModel:GetRewardSubIdByIndex(index))
            if api.success(response) then
                local data = response.val
                if data.contents ~= nil then
                    CongratulationsPageCtrl.new(data.contents)
                    spt:InitRewardButtonState(1)
                end
            end
        end)
        self.obtCumulativeLoginModel:SetRewardStatusByIndex(index, 1)
    end
end

return ActivityOBTCumulativeLoginScrollView
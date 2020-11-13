local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local ActivityOBTSerialConsumeScrollView = class(LuaScrollRectExSameSize)

function ActivityOBTSerialConsumeScrollView:ctor()
    self.super.ctor(self)
    self.parentScrollRect = self.___ex.parentScrollRect
    self.itemView = {}
end

function ActivityOBTSerialConsumeScrollView:start()
end

-- 消费钻石事件回调
function ActivityOBTSerialConsumeScrollView:RefreshItemContent()
    for i, v in ipairs(self.itemView) do
        v:RefreshTextContentAndButtonState()
    end
end

function ActivityOBTSerialConsumeScrollView:InitView(obtSerialConsumeModel)
    self.obtSerialConsumeModel = obtSerialConsumeModel
    self.itemDatas = obtSerialConsumeModel:GetRewardData()
    self:refresh()
end

function ActivityOBTSerialConsumeScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/OBTSerialConsumeItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    table.insert(self.itemView, spt)
    
    spt:InitView(self.obtSerialConsumeModel, index, self.parentScrollRect)
    spt:InitRewardButtonState(self.obtSerialConsumeModel:GetRewardStatusByIndex(index))
    spt.onRewardBtnClick = function ()
        clr.coroutine(function ()
            local response = req.activityCumulativePay(self.obtSerialConsumeModel:GetActivityType(),
                self.obtSerialConsumeModel:GetRewardSubIdByIndex(index))
            if api.success(response) then
                local data = response.val
                if data.contents ~= nil then 
                    CongratulationsPageCtrl.new(data.contents)
                    spt:InitRewardButtonState(1)
                end
            end
            self.obtSerialConsumeModel:SetRewardStatusByIndex(index, 1)
        end)
    end

    return obj
end

function ActivityOBTSerialConsumeScrollView:resetItem(spt, index)

    spt:InitView(self.obtSerialConsumeModel, index, self.parentScrollRect)

    spt:InitRewardButtonState(self.obtSerialConsumeModel:GetRewardStatusByIndex(index))

    spt.onRewardBtnClick = function ()
        clr.coroutine(function ()
            local response = req.activityCumulativePay(self.obtSerialConsumeModel:GetActivityType(),
                self.obtSerialConsumeModel:GetRewardSubIdByIndex(index))
            if api.success(response) then
                local data = response.val
                if data.contents ~= nil then 
                    CongratulationsPageCtrl.new(data.contents)
                    spt:InitRewardButtonState(1)
                end
            end
        end)
        self.obtSerialConsumeModel:SetRewardStatusByIndex(index, 1)
    end
end

return ActivityOBTSerialConsumeScrollView
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local MultiSerialPayScrollView = class(LuaScrollRectExSameSize)

function MultiSerialPayScrollView:ctor()
    self.super.ctor(self)
    self.parentScrollRect = self.___ex.parentScrollRect
    self.itemView = {}
end

function MultiSerialPayScrollView:start()
end

function MultiSerialPayScrollView:InitView(cumulativeConsumeModel)
    self.cumulativeConsumeModel = cumulativeConsumeModel
    self.itemDatas = cumulativeConsumeModel:GetRewardData()
    self:refresh()
end

function MultiSerialPayScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/MultiSerialPay/MultiSerialPayItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function MultiSerialPayScrollView:resetItem(spt, index)
    spt:InitView(self.itemDatas[index], self.parentScrollRect)
    spt.onRewardBtnClick = function ()
        clr.coroutine(function ()
            local response = req.activityCumulativePay(self.cumulativeConsumeModel:GetActivityType(),
                self.itemDatas[index].subID)
            if api.success(response) then
                local data = response.val
                if data.contents ~= nil then
                    CongratulationsPageCtrl.new(data.contents)
                    local playerInfoModel = PlayerInfoModel.new()
                    -- 重新和服务器交互，刷新活动数据
                    playerInfoModel:SetDiamond(playerInfoModel:GetDiamond())
                end
            end
        end)
    end
end

return MultiSerialPayScrollView
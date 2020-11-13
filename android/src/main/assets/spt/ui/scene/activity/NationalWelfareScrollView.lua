local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local NationalWelfareScrollView = class(LuaScrollRectExSameSize)

function NationalWelfareScrollView:ctor()
    self.super.ctor(self)
    self.parentScrollRect = self.___ex.parentScrollRect
end

function NationalWelfareScrollView:start()
end

function NationalWelfareScrollView:InitView(nationalWelfareModel, rewardType)
    self.nationalWelfareModel = nationalWelfareModel
    self.rewardType = rewardType
    self.itemDatas = nationalWelfareModel:GetRewardData(self.rewardType)
    self:refresh()
end

function NationalWelfareScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/NationalWelfareItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    spt:InitView(self.nationalWelfareModel, self.rewardType, index, self.parentScrollRect)
    spt:InitRewardButtonState(self.nationalWelfareModel:GetRewardStatusByIndex(index))
    spt.onRewardBtnClick = function() self:OnRewardBtnClick(spt, index) end
    return obj
end

function NationalWelfareScrollView:resetItem(spt, index)
    spt:InitView(self.nationalWelfareModel, self.rewardType, index, self.parentScrollRect)
    spt:InitRewardButtonState(self.nationalWelfareModel:GetRewardStatusByIndex(index))
    spt.onRewardBtnClick = function() self:OnRewardBtnClick(spt, index) end
end

-- 领取奖励
function NationalWelfareScrollView:OnRewardBtnClick(spt, index)
    clr.coroutine(function ()
        local response = req.activityCumulativePay(self.nationalWelfareModel:GetActivityType(), self.nationalWelfareModel:GetRewardSubIdByIndex(index))
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
            spt:InitRewardButtonState(1)
            self.nationalWelfareModel:SetRewardStatusByIndex(index, 1)
        end
    end)
end

return NationalWelfareScrollView
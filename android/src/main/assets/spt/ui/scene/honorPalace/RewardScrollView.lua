local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local HonorPalaceModel = require("ui.models.honorPalace.HonorPalaceModel")

local RewardScrollView = class(LuaScrollRectExSameSize)

function RewardScrollView:ctor()
    RewardScrollView.super.ctor(self)
    self.parentScrollRect = self.___ex.parentScrollRect
end

function RewardScrollView:start()
end

function RewardScrollView:GetScrollNormalizedPosition()
    return self:getScrollNormalizedPos()
end

function RewardScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/HonorPalace/RewardItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    spt.onClickReceiveBtn = function ()
        clr.coroutine(function()
            local data = self.data[spt.afterRefreshIndex]
            local response = req.receiveReward(data.level)
            if api.success(response) then
                local data = response.val
                CongratulationsPageCtrl.new(data.gift)
                EventSystem.SendEvent("Refresh_Honor_View")
            end
        end)
    end
    self:resetItem(spt, index)
    return obj
end

function RewardScrollView:resetItem(spt, index)
    local data = self.data[index]
    spt:InitView(data)
    spt.childScrollContentDragSpt.scrollRectInParent = self.parentScrollRect
    spt.afterRefreshIndex = index
    self:updateItemIndex(spt, index)
end

function RewardScrollView:InitView(data, scrollPos)
    self.data = data
    self:refresh(self.data, scrollPos)
end

return RewardScrollView
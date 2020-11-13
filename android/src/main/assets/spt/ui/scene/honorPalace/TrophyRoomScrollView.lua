local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local TrophyRoomCtrl = require("ui.controllers.honorPalace.TrophyRoomCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local HonorPalaceItemModel = require("ui.models.honorPalace.HonorPalaceItemModel")

local TrophyRoomScrollView = class(LuaScrollRectExSameSize)

function TrophyRoomScrollView:ctor()
    TrophyRoomScrollView.super.ctor(self)
end

function TrophyRoomScrollView:start()
end

function TrophyRoomScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/HonorPalace/TrophyRoomItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function TrophyRoomScrollView:resetItem(spt, index)
    local data = self.data[index]
    spt.onClickRoomItem = function ()
        local showTrohpyTable = cache.getHonorShowData()
        local isShow = false
        for k, v in pairs(showTrohpyTable) do
            if tonumber(data.ID) == tonumber(v) then
                isShow = true
            end
        end

        local changePos = cache.getHonorChangePos()
        if not changePos then
            return
        end

        if isShow then
            DialogManager.ShowToast(lang.trans("honor_palace_tip_1"))
            return
        end

        local honorPalaceItemModel = HonorPalaceItemModel.new(data)
        local name = honorPalaceItemModel:GetName()
        DialogManager.ShowConfirmPop(lang.trans("pd_honor_btn"), lang.trans("honor_palace_tip", name), function ()
            TrophyRoomCtrl.UseTrophy(data.ID, changePos, function ()
                self:refresh(self.data)
            end)
        end)
    end
    spt:InitView(data)
    self:updateItemIndex(spt, index)
end

function TrophyRoomScrollView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

return TrophyRoomScrollView
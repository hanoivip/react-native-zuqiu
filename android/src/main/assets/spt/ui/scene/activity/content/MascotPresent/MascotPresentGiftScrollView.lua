local MascotPresentGiftBoxItemModel = require("ui.models.activity.mascotPresent.MascotPresentGiftBoxItemModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local MascotPresentGiftScrollView = class(LuaScrollRectExSameSize)

function MascotPresentGiftScrollView:ctor()
    MascotPresentGiftScrollView.super.ctor(self)
end

function MascotPresentGiftScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/MascotPresent/MascotPresentGiftBoxItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function MascotPresentGiftScrollView:resetItem(spt, index)
    local itemModel = MascotPresentGiftBoxItemModel.new(self.data[index])
    self.itemSpts[index] = spt
    spt:InitView(itemModel, self.showType)
    spt.clickCollectProgressReward = function()
        self:OnClickCollect(index)  
    end
end

function MascotPresentGiftScrollView:InitView(mascotPresentModel, showType)
    self.activityModel = mascotPresentModel
    self.itemSpts = {}
    self.showType = showType

    local view3ShowType = 3
    local giftList = {}
    if tonumber(showType) == view3ShowType then
        giftList = self.activityModel:GetOrderedOwnedGiftBoxList()
    else
        giftList = self.activityModel:GetMascotPresentGiftBoxList()
    end
    for k, v in pairs(giftList) do
        v.index = k
    end

    self.data = giftList
    self:refresh(giftList)
end

function MascotPresentGiftScrollView:OnClickCollect(index)
    local count = self.activityModel:GetClickProgressItemCount()
    local isRewardCollected = self.activityModel:IsProgressRewardCollectedByCount(count)
    if isRewardCollected then
        DialogManager.ShowToast(lang.transstr("mascotPresent_desc27"))
        return
    end

    local title = lang.trans("tips")
    local content = lang.transstr("mascotPresent_desc26", tostring(index))
    DialogManager.ShowConfirmPop(title, content, function ()
        self:coroutine(function()
            local period = self.activityModel:GetActivityPeriod()           
            local respone = req.mascotPresentCollectProgressReward(period, count, index - 1)    --服务器顺序从0开始
            if api.success(respone) then
                local data = respone.val
                if type(data) == "table" and next(data) then
                    self.activityModel:SetProgressGiftDataCollectedByIndex(index, count)
                    self:resetItem(self.itemSpts[index], index)
                    EventSystem.SendEvent("ActivityProgressItem_UpdateState")

                    CongratulationsPageCtrl.new(data.contents, false)
                end
            end
        end)        
    end)
end

return MascotPresentGiftScrollView
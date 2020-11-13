local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CommonConstants = require("ui.models.activity.mascotPresent.CommonConstants")
local MascotPresentGiftCtrl = class(BaseCtrl, "MascotPresentGiftCtrl")

MascotPresentGiftCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

MascotPresentGiftCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/MascotPresent/MascotPresentGift.prefab"

function MascotPresentGiftCtrl:ctor()
    self.showType = nil
end

function MascotPresentGiftCtrl:Init(mascotPresentModel, collectable_preview)
    self.view.refreshCtrlModel = function(mascotPresentModel) self:RefreshCtrlModel(mascotPresentModel) end
    self.view.clickToView3 = function() self:OnClickToView3() end
end

function MascotPresentGiftCtrl:Refresh(mascotPresentModel, collectable_preview)
    self.activityModel = mascotPresentModel
    if collectable_preview then
        self.showType = CommonConstants.COLLECTABLE_PREVIEW
    elseif self.activityModel:IsMascotPresentGiftBoxCollect() then
        self.showType = CommonConstants.COLLECTABLE
    else
        self.showType = CommonConstants.PREVIEW
    end

    self.view:InitView(self.activityModel, self.showType)
end

function MascotPresentGiftCtrl:RefreshView(mascotPresentModel, collectable_preview)
    self:Refresh(mascotPresentModel, collectable_preview)
end

function MascotPresentGiftCtrl:GetStatusData()
    return self.activityModel
end

function MascotPresentGiftCtrl:RefreshCtrlModel(mascotPresentModel)
    self.activityModel = mascotPresentModel
end

function MascotPresentGiftCtrl:OnClickToView3()
    local period = self.activityModel:GetActivityPeriod()
    local count = self.activityModel:GetClickProgressItemCount()

    self.view:coroutine(function()
        local response = req.mascotPresentStaticGiftBox(period, count, nil, nil, true)
        if api.success(response) then
            local data = response.val
            if type(data) == "table" and next(data) then
                self.activityModel:InitOrderedOwnedGiftBoxData(data)
                self.showType = nil
                self:RefreshView(self.activityModel, CommonConstants.COLLECTABLE_PREVIEW)
            else
                dump("server data error!!!")
            end
        end
    end)
end

function MascotPresentGiftCtrl:OnEnterScene()
end

return MascotPresentGiftCtrl
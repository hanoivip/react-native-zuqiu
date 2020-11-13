local BaseCtrl = require("ui.controllers.BaseCtrl")
local RestaurantDialogCtrl = class(BaseCtrl, "RestaurantDialogCtrl")

RestaurantDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/RestaurantDialog.prefab"

function RestaurantDialogCtrl:AheadRequest(eventModel)
    local row, col = eventModel:GetRow(), eventModel:GetCol()
    local response = req.greenswardAdventureViewCell(row, col)
    if api.success(response) then
        local data = response.val
        eventModel:InitWithProtocolReward(data)
    end
end

function RestaurantDialogCtrl:Init(eventModel)
    self.eventModel = eventModel
    self.view:InitView(eventModel)
    self.view.onStartClick = function() self:StartClick() end
end

function RestaurantDialogCtrl:StartClick()
    local notEnough = self.eventModel:ConsumeNotEnough()
    if not notEnough then
        self.view:coroutine(function()
            local row = self.eventModel:GetRow()
            local col = self.eventModel:GetCol()
            local response = req.greenswardAdventureTrigger(row, col)
            if api.success(response) then
                local data = response.val
                local base = data.base or {}
                local ret = data.ret or {}
                local map = ret.map or {}
                local buildModel = self.eventModel:GetBuildModel()
                self.view.closeDialog()
                self:ShowReward(ret.cellResult)
                buildModel:RefreshEventData(map)
                buildModel:RefreshBaseInfo(base)
                self.eventModel:HandleEvent(data)
            end
        end)
    end
end

function RestaurantDialogCtrl:ShowReward(cellResult)
    local rewardContent = cellResult.contents
    local cost = cellResult.cost
    local rcPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/RewardCurrencyDialog.prefab"
    local dialog, dialogcomp = res.ShowDialog(rcPath, "camera", true, true)
    local spt = dialogcomp.contentcomp
    local title = lang.trans("tips")
    local isPlus, tip, contents
    if cost then
        isPlus = false
        contents = cost
        tip = lang.trans("adventure_restaurant_debuff")
    else
        isPlus = true
        contents = rewardContent
        tip = lang.trans("adventure_restaurant_thanks")
    end
    spt:InitView(title, tip, isPlus, contents)
end

return RestaurantDialogCtrl

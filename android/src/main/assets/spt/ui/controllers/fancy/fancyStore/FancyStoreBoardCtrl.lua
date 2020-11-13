local FancyStoreModel = require("ui.models.fancy.fancyStore.FancyStoreModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local FancyStoreBoardCtrl = class(BaseCtrl)

FancyStoreBoardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyStore/FancyStoreBoard.prefab"

function FancyStoreBoardCtrl:AheadRequest()
    local response = req.fancyCardMallInfo()
    if api.success(response) then
        local data = response.val
        local fancyStoreModel = FancyStoreModel.new()
        fancyStoreModel:Init(data)
        self.model = fancyStoreModel
        self.view:InitView(self.model)
    end
end

function FancyStoreBoardCtrl:Refresh()
end

return FancyStoreBoardCtrl
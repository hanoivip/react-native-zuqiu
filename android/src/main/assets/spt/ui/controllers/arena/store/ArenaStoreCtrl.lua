local BaseCtrl = require("ui.controllers.BaseCtrl")
local ArenaStoreModel = require("ui.models.arena.store.ArenaStoreModel")
local ArenaInfoBarCtrl = require("ui.controllers.common.ArenaInfoBarCtrl")
local ArenaStoreCtrl = class(BaseCtrl, "ArenaStoreCtrl")

ArenaStoreCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/ArenaStore.prefab"

function ArenaStoreCtrl:Init()
    self.view:InitView(ArenaStoreModel.new())
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = ArenaInfoBarCtrl.new(child, self)
    end)
end

return ArenaStoreCtrl
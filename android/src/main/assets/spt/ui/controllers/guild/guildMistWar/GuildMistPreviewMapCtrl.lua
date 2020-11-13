local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildMistPreviewMapCtrl = class(BaseCtrl, "GuildMistPreviewMapCtrl")

GuildMistPreviewMapCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistPreviewMap.prefab"

function GuildMistPreviewMapCtrl:Refresh()
    self.view:InitView()
end

return GuildMistPreviewMapCtrl

local BaseCtrl = require("ui.controllers.BaseCtrl")
local CardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")

local DreamLeagueCardCtrl = class(BaseCtrl)

DreamLeagueCardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamLeagueCard.prefab"

function DreamLeagueCardCtrl:InitView(model) 
    self.model = model
    self.view:Init(self.model)
end 

return DreamLeagueCardCtrl

local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local CardMedalModel = class(PlayerMedalModel, "CardMedalModel")

function CardMedalModel:ctor(pmid)
    CardMedalModel.super.ctor(self, pmid)
end

return CardMedalModel

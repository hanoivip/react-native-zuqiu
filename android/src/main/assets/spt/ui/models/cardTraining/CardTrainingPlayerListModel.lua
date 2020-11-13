
local PlayerListModel = require("ui.models.playerList.PlayerListModel")

local CardTrainingPlayerListModel = class(PlayerListModel, "CardTrainingMainModel")

function CardTrainingPlayerListModel:ctor()
    CardTrainingPlayerListModel.super.ctor(self)
end

function CardTrainingPlayerListModel:ToggleSelectCard(pcid)
    local oldState = self.selectdCardList[tostring(pcid)]
    self.selectdCardList = {}
    self.selectdCardList[tostring(pcid)] = not oldState

    EventSystem.SendEvent("PlayerListModel_ToggleSelectCard", pcid, self.selectdCardList[tostring(pcid)])
end



return CardTrainingPlayerListModel
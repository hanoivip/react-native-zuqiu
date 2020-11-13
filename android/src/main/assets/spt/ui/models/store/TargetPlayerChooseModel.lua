local PlayerListModel = require("ui.models.playerList.PlayerListModel")
local TargetPlayerChooseModel = class(PlayerListModel, "TargetPlayerChooseModel")

function TargetPlayerChooseModel:ctor(cardModelList)
    self:SetCardList(cardModelList)
    TargetPlayerChooseModel.super.ctor(self)
end

function TargetPlayerChooseModel:GetCardList()
    return self.cardList
end

function TargetPlayerChooseModel:SetCardList(cardModelList)
    self.cardList = {}
    for i, cardModel in ipairs(cardModelList) do
        local pcid = cardModel:GetPcid()
        table.insert(self.cardList, pcid)
    end
end

return TargetPlayerChooseModel

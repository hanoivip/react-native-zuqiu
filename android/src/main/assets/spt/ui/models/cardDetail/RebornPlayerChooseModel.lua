local EventSystem = require ("EventSystem")

local RebornPlayerChooseModel = class()

function RebornPlayerChooseModel:ctor()
    self.choosePcid = nil
end
    
function RebornPlayerChooseModel:SetChooseCard(pcid)
    assert(pcid)
    self.choosePcid = pcid

    EventSystem.SendEvent("RebornPlayerChooseModel_SetChooseCard", self.choosePcid)
end

function RebornPlayerChooseModel:GetChooseCardPcid()
    return self.choosePcid
end

function RebornPlayerChooseModel:ConfirmChooseCard()
    if self.choosePcid then
        EventSystem.SendEvent("RebornPlayerChooseModel_ConfirmChooseCard", self.choosePcid)
    end
end

return RebornPlayerChooseModel

local CardBuilder = require("ui.common.card.CardBuilder")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local GreenswardDetailCtrl = class(PlayerDetailCtrl)

function GreenswardDetailCtrl.ShowPlayerDetailView(reqPlayerDetailFunc, pid, sid, hideFunBtn, showIndex, friendManagerModel, specialEventsMatchId, arenaType)
    if type(reqPlayerDetailFunc) == "function" then
        clr.coroutine(function()
            local respone = reqPlayerDetailFunc()
            if api.success(respone) then
                local data = respone.val
                res.PushDialog("ui.controllers.playerDetail.GreenswardDetailCtrl", data, pid, sid, hideFunBtn, showIndex, friendManagerModel, specialEventsMatchId, arenaType)
            end
        end)
    end
end

-- 点击球员
function GreenswardDetailCtrl:OnCardClick(pcId)
    local cids = self.playerDetailModel:GetChemicalCids()
    local otherPlayerTeamsModel = self.playerDetailModel:GetOtherPlayerTeamsModel()
    local playerCardModelsMap = self.playerDetailModel:GetOtherPlayerCardsMapModel()
    local opRevise = self.playerDetailModel:GetPlayerOpRevise()
    local currentModel = CardBuilder.GetGreenswardCardModel(pcId, cids, playerCardModelsMap, otherPlayerTeamsModel, opRevise)
    local pcidList = {}
    local tempIndex = 1
    local mIndex = nil
    for k,v in pairs(otherPlayerTeamsModel:GetInitPlayersData()) do
        table.insert(pcidList, v)
        if tostring(v) == tostring(pcId) then
            mIndex = tempIndex
        end
        tempIndex = tempIndex + 1
    end
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", mIndex and pcidList or {pcId}, mIndex and mIndex or 1, currentModel)
end

return GreenswardDetailCtrl
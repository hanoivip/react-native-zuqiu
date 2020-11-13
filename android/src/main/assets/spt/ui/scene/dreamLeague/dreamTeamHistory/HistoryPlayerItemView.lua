local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local DreamTeamHistoryView = class(unity.base)

function DreamTeamHistoryView:ctor()
    self.score = self.___ex.score
    self.cardParent = self.___ex.cardParent
    self.detailBtn = self.___ex.detailBtn
end

function DreamTeamHistoryView:InitView(playerData, matchTag, clickCallBack)
    self.score.text = lang.trans("dream_player_score", playerData.score)
    self.detailBtn:regOnButtonClick(function()
        if clickCallBack then
            clickCallBack(matchTag, playerData.dcid)
        end
    end)
    local cardPrefabPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamLeagueCard.prefab"
    local obj, spt = res.Instantiate(cardPrefabPath)
    local dreamLeagueCardModel = DreamLeagueCardModel.new(playerData.dcid)
    spt:InitView(dreamLeagueCardModel)
    obj.transform:SetParent(self.cardParent, false)
end

return DreamTeamHistoryView

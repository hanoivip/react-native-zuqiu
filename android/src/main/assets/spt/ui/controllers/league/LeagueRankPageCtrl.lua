local LeagueInfoModel = require("ui.models.league.LeagueInfoModel")

local LeagueRankPageCtrl = class()

function LeagueRankPageCtrl:ctor(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self:Init()
end

function LeagueRankPageCtrl:Init()
    clr.coroutine(function()
        local response = req.leaguRank()
        if api.success(response) then
            local data = response.val
            if not self.leagueInfoModel then
                self.leagueInfoModel = LeagueInfoModel.new()
            end
            self.leagueInfoModel:InitWithRankProtocol(data)
            local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/League/LeagueRank.prefab", "camera", true, true)
            dialogcomp.contentcomp:InitView(self.leagueInfoModel)
        end
    end)
end

return LeagueRankPageCtrl
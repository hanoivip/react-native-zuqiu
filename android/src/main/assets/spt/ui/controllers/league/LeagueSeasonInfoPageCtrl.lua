local LeagueInfoModel = require("ui.models.league.LeagueInfoModel")

local LeagueSeasonInfoPageCtrl = class()

function LeagueSeasonInfoPageCtrl:ctor(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self:Init()
end

function LeagueSeasonInfoPageCtrl:Init()
    clr.coroutine(function()
        local response = req.leagueSeasonInfo()
        if api.success(response) then
            local data = response.val
            if not self.leagueInfoModel then
                self.leagueInfoModel = LeagueInfoModel.new()
            end
            self.leagueInfoModel:InitWithSeasonInfoProtocol(data)
            local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/League/LeagueSeasonInfo.prefab", "camera", true, true)
            dialogcomp.contentcomp:InitView(self.leagueInfoModel)
        end
    end)
end

return LeagueSeasonInfoPageCtrl
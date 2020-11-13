local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local FormationConstants = require("ui.scene.formation.FormationConstants")

local SpecialEventsPlayerTeamsModel = class(PlayerTeamsModel, "SpecialEventsPlayerTeamsModel")

function SpecialEventsPlayerTeamsModel:ctor()
    SpecialEventsPlayerTeamsModel.super.ctor(self)
end

function SpecialEventsPlayerTeamsModel:InitWithProtocol(data, matchId)
    SpecialEventsPlayerTeamsModel.super.InitWithProtocol(self, data)
    self.matchId = matchId
end

function SpecialEventsPlayerTeamsModel:Init(data)
    if data ~= nil then
        self.data = clone(data)
        if not next(self.data) then
            self:SetNowTeamId(0)
            self.data.teams = {}
            self.nowFormationId = 11
        end
        self:SetNowTeamData(self:GetNowTeamId())
        self:SetSelectedType(self:GetSelectedType())
    end
end

function SpecialEventsPlayerTeamsModel:SaveData(data)
end

function SpecialEventsPlayerTeamsModel:GetCardModelWithPcid(pcid)
    local playerCardModel = SpecialEventsPlayerTeamsModel.super.GetCardModelWithPcid(self, pcid)
    playerCardModel:CheckIsMatchForSpecialEvents(self.matchId)

    return playerCardModel
end

function SpecialEventsPlayerTeamsModel:GetWaitPlayersDataByOuterData(initPlayersData, replacePlayersData, sortType)
    local base = SpecialEventsPlayerTeamsModel.super.GetWaitPlayersDataByOuterData
    local waitPlayersNoRepeatList, waitPlayersRepeatList = base(self, initPlayersData, replacePlayersData, sortType)
    table.sort(
        waitPlayersNoRepeatList,
        function(p1, p2)
            return SpecialEventsPlayerTeamsModel.SortByIsSuit(p1, p2, sortType)
        end
    )
    table.sort(
        waitPlayersRepeatList,
        function(p1, p2)
            return SpecialEventsPlayerTeamsModel.SortByIsSuit(p1, p2, sortType)
        end
    )
    return waitPlayersNoRepeatList, waitPlayersRepeatList
end

function SpecialEventsPlayerTeamsModel.SortByIsSuit(p1, p2, sortType)
    if p1:IsSuitForSpecialEvent() == p2:IsSuitForSpecialEvent() then
        if sortType == FormationConstants.SortType.POWER then
            return PlayerTeamsModel.SortCardOrderByPower(p1, p2)
        elseif sortType == FormationConstants.SortType.QUALITY then
            return PlayerTeamsModel.SortCardOrderByQuality(p1, p2)
        elseif sortType == FormationConstants.SortType.GET_TIME then
            return PlayerTeamsModel.SortCardOrderByGetTime(p1, p2)
        elseif sortType == FormationConstants.SortType.NAME then
            return PlayerTeamsModel.SortCardOrderByName(p1, p2)
        end
    else
        return p1:IsSuitForSpecialEvent()
    end
end

return SpecialEventsPlayerTeamsModel

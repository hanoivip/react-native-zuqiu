local FormationCacheDataModel = require("ui.models.formation.FormationCacheDataModel")

local SpecialEventsFormationCacheDataModel = class(FormationCacheDataModel, "SpecialEventsFormationCacheDataModel")

function SpecialEventsFormationCacheDataModel:ctor(playerTeamsModel, matchId)
    SpecialEventsFormationCacheDataModel.super.ctor(self, playerTeamsModel)
    self.specialEventsMatchId = matchId
end


-- 获取候补球员数据，是经过筛选的数据
function SpecialEventsFormationCacheDataModel:GetWaitPlayerCacheData(sortType)
    local waitPlayersNoRepeatList, waitPlayersRepeatList = self.playerTeamsModel:GetWaitPlayersDataByOuterData(self.initPlayerCacheData, self.replacePlayerCacheData, sortType)
    if table.nums(self.waitPlayerFilterPosData) ~= 0 then
        local filterWaitPlayersNoRepeatList = {}
        local filterWaitPlayersRepeatList = {}
        for _, playerCardModel in ipairs(waitPlayersNoRepeatList) do
            local posList = playerCardModel:GetPosition()
            for _, posLetter in ipairs(posList) do
                if self:CheckWaitPlayerPosIsMatch(posLetter) then
                    table.insert(filterWaitPlayersNoRepeatList, playerCardModel)
                    break
                end
            end
        end

        for _, playerCardModel in ipairs(waitPlayersRepeatList) do
            local posList = playerCardModel:GetPosition()
            for _, posLetter in ipairs(posList) do
                if self:CheckWaitPlayerPosIsMatch(posLetter) then
                    table.insert(filterWaitPlayersRepeatList, playerCardModel)
                    break
                end
            end
        end
        return filterWaitPlayersNoRepeatList, filterWaitPlayersRepeatList
    else
        return waitPlayersNoRepeatList, waitPlayersRepeatList
    end
end

return SpecialEventsFormationCacheDataModel

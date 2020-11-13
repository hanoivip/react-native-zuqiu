local Nation = require("data.Nation")
local DreamLeagueListModel = require("ui.models.dreamLeague.DreamLeagueListModel")
local PlayerDreamCardsMapModel = require("ui.models.dreamLeague.PlayerDreamCardsMapModel")

local Model = require("ui.models.Model")
local DreamBagModel = class(Model, "DreamBagModel")

function DreamBagModel:ctor(dcids, isSelectMode, posIndex, allNations)
    self.dreamLeagueListModel = DreamLeagueListModel.new(dcids, allNations, posIndex)
    self.isSelectMode = isSelectMode
    self.posIndex = posIndex
end

-- 这里做位置筛选
function DreamBagModel:GetSearchScrollData()
    self.nationSearchDatas = self.dreamLeagueListModel:GetStaticNationMember(posIndex)
    return self.nationSearchDatas
end

function DreamBagModel:GetAllDcids()
    local playerDreamCardsMapModel = PlayerDreamCardsMapModel.new()
    local allDcids = playerDreamCardsMapModel:GetCardList()
    return allDcids
end

function DreamBagModel:GetOwnerNum()
    if self.dreamLeagueListModel.lightDcids then
        return tostring(#self.dreamLeagueListModel.lightDcids)
    else
        local playerDreamCardsMapModel = PlayerDreamCardsMapModel.new()
        local cardDcidList = playerDreamCardsMapModel:GetCardList()
        return tostring(#cardDcidList)
    end
end

function DreamBagModel:GetLightNum()
    local allCards = self.dreamLeagueListModel:GetAllCards()
    local num = 0
    for nationName, nation in pairs(allCards) do
        for teamName, player in pairs(nation) do
            num = num + table.nums(player)
        end
    end
    return tostring(num)
end

function DreamBagModel:GetSelectModeState()
    return self.isSelectMode
end

function DreamBagModel:GetPosIndex()
    return self.posIndex
end

function DreamBagModel:GetDreamLeagueListModel()
    return self.dreamLeagueListModel
end

return DreamBagModel

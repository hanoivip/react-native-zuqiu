local Nation = require("data.Nation")
local DreamLeagueCardBaseModel = require("ui.models.dreamLeague.DreamLeagueCardBaseModel")
local PlayerDreamCardsMapModel = require("ui.models.dreamLeague.PlayerDreamCardsMapModel")
local Model = require("ui.models.Model")
local TeamPageModel = class(Model, "TeamPageModel")

function TeamPageModel:ctor(teamPageIndex, dreamLeagueListModel, isSelectMode, posIndex)
    self.teamPageIndex = teamPageIndex
    self.isSelectMode = isSelectMode
    self.posIndex = posIndex
    self.dreamLeagueListModel = dreamLeagueListModel
end

function TeamPageModel:GetScrollData()
    local data = self.dreamLeagueListModel:GetTeamPageData(self.teamPageIndex)
    local dreamModels = {}
    for k,v in pairs(data.teamMember) do
        local playerName = k
        local dreamId = k .. "1"
        local dreamCardModel = DreamLeagueCardBaseModel.new(dreamId)
        local mainPosition = dreamCardModel:GetPositionType()
        local positionName = dreamCardModel:GetMainPosition()
        if not dreamModels[mainPosition] then
            dreamModels[mainPosition] = {}
        end
        dreamModels[mainPosition].mainPosition = positionName
        dreamModels[mainPosition].model = dreamCardModel
        dreamModels[mainPosition].listModel = self.dreamLeagueListModel
        if not dreamModels[mainPosition].player then
            dreamModels[mainPosition].player = {}
        end
        dreamModels[mainPosition].player[playerName] = v
    end
    local temp = {}
    for k,v in pairs(dreamModels) do
        table.insert(temp, v)
    end
    self.data = temp
    if self.posIndex then
        self.data = {dreamModels[self.posIndex]}
        return self.data
    end
    return temp
end

function TeamPageModel:GetAllDcids()
    local allDcids = {}
    for i, v in ipairs(self.data) do
        for playerName, qualitys in pairs(v.player) do
            if type(qualitys) == "table" then
                for i = 1, 4 do
                    if qualitys[i] and type(qualitys[i]) == "table" then
                        for dcid, value in pairs(qualitys[i]) do
                            table.insert(allDcids, value)
                        end
                    end
                end
            end
        end
    end
    return allDcids
end

function TeamPageModel:GetDreamLeagueListModel()
    return self.dreamLeagueListModel
end

function TeamPageModel:GetTeamCode()
    return self.teamPageIndex.teamName
end

function TeamPageModel:GetTeamName()
    local teamName = self.teamPageIndex.teamName
    return Nation[teamName].nation
end

function TeamPageModel:GetOwnerAndLightNum()
    local ownerNum = 0
    local lightNum = 0
    for index, position in ipairs(self.data) do
        for playerName, dcids in pairs(position.player) do
            if type(dcids) == "table" then
                lightNum = lightNum + 1
                for i = 1, 4 do
                    if dcids[i] then
                        for k, v in pairs(dcids[i]) do
                            ownerNum = ownerNum + 1
                        end
                    end
                end
            end
        end
    end
    return tostring(ownerNum), tostring(lightNum)
end

function TeamPageModel:GetTeamPageIndex()
    return self.teamPageIndex
end

function TeamPageModel:GetSelectModeState()
    return self.isSelectMode
end

return TeamPageModel

local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local PlayerDreamCardsMapModel = require("ui.models.dreamLeague.PlayerDreamCardsMapModel")
local Nation = require("data.Nation")
local DreamLeagueCard = require("data.DreamLeagueCard")
local Model = require("ui.models.Model")

local DreamLeagueListModel = class(Model, "DreamLeagueListModel")

-- posIndex代表根据位置筛选
function DreamLeagueListModel:ctor(dcids, allNations, posIndex)
    self.allNations = allNations
    self.posIndex = posIndex
    self:Init(dcids)
end

function DreamLeagueListModel:Init(dcids)
    self.allList = {}
    self.nationMap = {}
    self.playerMap = {}
    self.isNewMap = {}
    if dcids then
        self.lightDcids = dcids
    end
    self.playerDreamCardsMapModel = PlayerDreamCardsMapModel.new()
    self.nationTeamMember = self:InitStaticPlayer()
    local list = dcids or self.playerDreamCardsMapModel:GetCardList()
    for k,v in pairs(list) do
        self:AddCard(v)
    end
end

function DreamLeagueListModel:AddCard(dcid)
    dcid = tostring(dcid)
    local cardModel = DreamLeagueCardModel.new(dcid)
    local nation = cardModel:GetNation()
    local team = cardModel:GetTeam()
    local nameId = cardModel:GetNameId()
    local quality = cardModel:GetQuality()
    local isNew = cardModel:IsNew()
    local firstLetter = string.upper(Nation[nation].firstLetter)
    if not self.allList[nation] then
        self.allList[nation] = {}
    end
    if not self.allList[nation][team] then
        self.allList[nation][team] = {}
    end
    if not self.allList[nation][team][nameId] then
        self.allList[nation][team][nameId] = {}
    end
    if not self.allList[nation][team][nameId][quality] then
        self.allList[nation][team][nameId][quality] = {}
    end
    self.allList[nation][team][nameId][quality][dcid] = dcid
    self.nationTeamMember[firstLetter].nations[nation][team].teamMember[nameId] = self.allList[nation][team][nameId]
    if isNew then
        if not self.isNewMap.nations then
            self.isNewMap.nations = {}
        end
        if not self.isNewMap.teams then
            self.isNewMap.teams = {} 
        end
        if not self.isNewMap.players then
            self.isNewMap.players = {}
        end
        if not self.isNewMap.dcids then
            self.isNewMap.dcids = {}
        end
        self.isNewMap.nations[nation] = true
        self.isNewMap.teams[team] = true
        self.isNewMap.players[nameId] = true
        self.isNewMap.dcids[dcid] = true
    end
end

-- 获取所有卡牌
function DreamLeagueListModel:GetAllCards()
    return self.allList
end

-- 获取某个国家的卡牌
function DreamLeagueListModel:GetCardsByNation(nation)
    return self.nationMap[nation]
end

-- 获取某个球员的卡牌
function DreamLeagueListModel:GetCardsByName(nameId)
    return self.nameList[nameId]
end

-- 这个国家是否包含新获得球员
function DreamLeagueListModel:IsNationContainsNewPlayer(nation)
    return self.isNewMap.nations and self.isNewMap.nations[nation]
end

-- 这个队伍是否包含新获得球员
function DreamLeagueListModel:IsTeamContainsNewPlayer(team)
    return self.isNewMap.teams and self.isNewMap.teams[team]
end

-- 这个球员所有品质的卡牌是否包含新获得球员
function DreamLeagueListModel:IsAllQualityContainsNewPlayer(player)
    return self.isNewMap.players  and self.isNewMap.players[player]
end

-- 这个具体的球员是否是新球员
function DreamLeagueListModel:IsPlayersContainsNewPlayer(dcid)
    dcid = tostring(dcid)
    return self.isNewMap.dcids and self.isNewMap.dcids[dcid]
end

-- 清除某个球员是否是新球员的标记
function DreamLeagueListModel:ClearNewPlayerTag(dcid)
    dcid = tostring(dcid)
    local cardModel = DreamLeagueCardModel.new(dcid)

    local nation = cardModel:GetNation()
    if not nation then
        return
    end
    local team = cardModel:GetTeam()
    local nameId = cardModel:GetNameId()
    if self.isNewMap then
        if self.isNewMap.nations then
            self.isNewMap.nations[nation] = nil
        end
        if self.isNewMap.teams then
            self.isNewMap.teams[team] = nil
        end
        if self.isNewMap.players then
            self.isNewMap.players[nameId] = nil
        end
        if self.isNewMap.dcids then
            self.isNewMap.dcids[dcid] = nil
        end
    end
    self.playerDreamCardsMapModel:SetCardNewTag(dcid, nil)
end

function DreamLeagueListModel:DelCard(dcid)
    local cardModel = DreamLeagueCardModel.new(dcid)
    local nation = cardModel:GetNation()
    local team = cardModel:GetTeam()
    local nameId = cardModel:GetNameId()
    local quality = cardModel:GetQuality()
    local firstLetter = string.upper(Nation[nation].firstLetter)
    self.allList[nation][team][nameId][quality][dcid] = nil
    self.nationTeamMember[firstLetter].nations[nation][team].teamMember[nameId][quality][dcid] = nil
    self:ClearNewPlayerTag(dcid)
    self.playerDreamCardsMapModel:RemoveSingleCardData(dcid)
end

-- 国家页面的列表
function DreamLeagueListModel:GetStaticNationMember()
    local scrollData = {}
    for k,v in pairs(self.nationTeamMember) do
        table.insert(scrollData, v)
    end
    table.sort(scrollData, function(a, b) return a.firstLetter < b.firstLetter end)
    return scrollData
end

-- 球队页面的列表
function DreamLeagueListModel:GetTeamPageData(teamPageIndex)
    local scrollData = self:GetStaticNationMember()
    for k,v in pairs(scrollData) do
        if v.firstLetter == teamPageIndex.firstLetter then
            local nation = v.nations[teamPageIndex.nationName] and v.nations[teamPageIndex.nationName][teamPageIndex.teamName]
            if nation then
                return nation
            end
        end
    end
end

-- 球员页面的列表
function DreamLeagueListModel:GetPlayerPageData(playerPageIndex)
    local scrollData = self:GetStaticNationMember()
    for k,v in pairs(scrollData) do
        if v.firstLetter == playerPageIndex.firstLetter then
            local playerInfo = v.nations[playerPageIndex.nationName] and 
                            v.nations[playerPageIndex.nationName][playerPageIndex.teamName] and
                            v.nations[playerPageIndex.nationName][playerPageIndex.teamName].teamMember[playerPageIndex.playerName]
            if playerInfo then
                return playerInfo
            end
        end
    end
end

function DreamLeagueListModel:InitStaticPlayer()
    if self.lightDcids then
        return self:InitOwnerPlayer()
    else
        return self:InitAllStaticPlayer()
    end
end

function DreamLeagueListModel:InitOwnerPlayer()
    local allStaticPlayer = self:InitAllStaticPlayer()
    local nationsOwner = {}
    for k,v in ipairs(self.lightDcids) do
        local model = DreamLeagueCardModel.new(v)
        local dreamCardId = model:GetDreamCardId()
        local nation = model:GetNation()
        local team = model:GetTeam()
        local nameId = model:GetNameId()
        local posIndex = model:GetPostionType()
        local nationFirstLetter = Nation[nation].firstLetter
        if not nationsOwner[nationFirstLetter] then
            nationsOwner[nationFirstLetter] = {}
            nationsOwner[nationFirstLetter].firstLetter = nationFirstLetter
            nationsOwner[nationFirstLetter].nations = {}
        end
        if not nationsOwner[nationFirstLetter].nations[nation] then
            nationsOwner[nationFirstLetter].nations[nation] = {}
            nationsOwner[nationFirstLetter].nations[nation].nationName = nation
        end
        nationsOwner[nationFirstLetter].nations[nation] = allStaticPlayer[nationFirstLetter].nations[nation]
    end
    if self.allNations then
        for k,v in pairs(self.allNations) do
            local nationFirstLetter = Nation[k].firstLetter
            if not nationsOwner[nationFirstLetter] then
                nationsOwner[nationFirstLetter] = {}
                nationsOwner[nationFirstLetter].firstLetter = nationFirstLetter
                nationsOwner[nationFirstLetter].nations = {}
            end
            if not nationsOwner[nationFirstLetter].nations[k] then
                nationsOwner[nationFirstLetter].nations[k] = allStaticPlayer[nationFirstLetter].nations[k]
            end
        end
    end
    return nationsOwner
end

function DreamLeagueListModel:InitAllStaticPlayer()
    local nationsStatic = {}
    for k,v in pairs(DreamLeagueCard) do
        local dreamCardId = k
        local nation = v.nation
        local team = v.teamInfo
        local posIndex = v.positionType
        local nationFirstLetter = Nation[nation].firstLetter
        if not nationsStatic[nationFirstLetter] then
            nationsStatic[nationFirstLetter] = {}
            nationsStatic[nationFirstLetter].firstLetter = nationFirstLetter
            nationsStatic[nationFirstLetter].nations = {}
        end
        if not nationsStatic[nationFirstLetter].nations[nation] then
            nationsStatic[nationFirstLetter].nations[nation] = {}
            nationsStatic[nationFirstLetter].nations[nation].nationName = nation
        end
        if not nationsStatic[nationFirstLetter].nations[nation][team] then
            nationsStatic[nationFirstLetter].nations[nation][team] = {}
            nationsStatic[nationFirstLetter].nations[nation][team].teamName = team
            nationsStatic[nationFirstLetter].nations[nation][team].teamMember = {}
            nationsStatic[nationFirstLetter].nations[nation][team].teamPosIndex = {}
        end

        nationsStatic[nationFirstLetter].nations[nation][team].teamMember[v.nameId] = true
        nationsStatic[nationFirstLetter].nations[nation][team].teamPosIndex[v.nameId] = posIndex
        nationsStatic[nationFirstLetter].nations[nation][team].listModel = self
    end
    return nationsStatic
end

function DreamLeagueListModel:GetNationTitleList()
    local nationsData = {}
    for k, v in pairs(Nation) do
        if not self:IsContainLetter(nationsData, v.firstLetter) then
            table.insert(nationsData, v.firstLetter)
        end
    end
    table.sort(nationsData, function(a, b) return a < b end)
    return nationsData
end

function DreamLeagueListModel:IsContainLetter(nationsData, firstLetter)
  for _, value in pairs(nationsData) do
    if value == firstLetter then
      return true
    end
  end
  return false
end

return DreamLeagueListModel


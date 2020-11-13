local Model = require("ui.models.Model")
local OtherCardModel = require("ui.models.cardDetail.OtherCardModel")
local OtherPlayerCardsMapModel = require("ui.models.OtherPlayerCardsMapModel")
local OtherPlayerTeamsModel = require("ui.models.OtherPlayerTeamsModel")
local OtherLegendCardsMapModel = require("ui.models.legendRoad.OtherLegendCardsMapModel")
local OtherCoachMainModel = require("ui.models.coach.OtherCoachMainModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local OtherSceneModel = require("ui.models.myscene.OtherSceneModel")
local PlayerDetailModel = class(Model)

function PlayerDetailModel:ctor()
    PlayerDetailModel.super.ctor(self)
end

function PlayerDetailModel:InitWithProtocol(playerDetailData)
    if playerDetailData then
        self.cacheData = {}
        if playerDetailData.player then
            self.cacheData.player = playerDetailData.player
        end
        if playerDetailData then
            self.otherPlayerCardsMapModel = OtherPlayerCardsMapModel.new()
            self.otherPlayerCardsMapModel:InitWithProtocol(playerDetailData.card)

            self.otherPlayerTeamsModel = OtherPlayerTeamsModel.new(self.otherPlayerCardsMapModel)
            self.otherPlayerTeamsModel:InitWithProtocol(playerDetailData.team)

            if playerDetailData.legendRoad then
                self.cacheData.legendRoad = playerDetailData.legendRoad
                self.otherLegendCardsMapModel = OtherLegendCardsMapModel.new()
                self.otherLegendCardsMapModel:InitWithProtocol(self.cacheData.legendRoad)
                self.otherLegendCardsMapModel:BuildTeamLegendInfo(self:GetOtherPlayerTeamsModel())
            end
            self.otherSceneModel = OtherSceneModel.new()
            local scenario = playerDetailData.scenario
            if scenario then
                self.otherSceneModel:SetTeamCourtSelect(scenario.weather, scenario.grass, scenario.home)
            end
            if playerDetailData.coach then
                self.cacheData.coach = playerDetailData.coach
                self.otherCoachMainModel = OtherCoachMainModel.new(self.otherPlayerTeamsModel)
                self.otherCoachMainModel:InitWithProtocol(self.cacheData.coach)
            end
            local cids = self:GetChemicalCids()
            self.cacheData.playerCardModelsMap = {}
            for k, v in pairs(playerDetailData.card) do
                local otherPlayerCardModel = CardBuilder.GetOtherCardModel(k, cids, self.otherPlayerCardsMapModel, self.otherPlayerTeamsModel, self.otherLegendCardsMapModel, self.otherSceneModel, self.otherCoachMainModel)
                self.cacheData.playerCardModelsMap[tostring(k)] = otherPlayerCardModel
            end
        end
        if playerDetailData.cidChemical then
            self.cacheData.cidChemical = playerDetailData.cidChemical
        end
        -- 是否是好友
        self.cacheData.isFriend = playerDetailData.isFriend
        -- 好友人数
        self.cacheData.friendsCount = playerDetailData.friendsCount
        -- 公会数据
        if playerDetailData.guild then
            self.cacheData.guild = playerDetailData.guild
        end
        -- 联赛数据
        if playerDetailData.league then
            self.cacheData.league = playerDetailData.league
        end
        -- 天梯数据
        if playerDetailData.ladder then
            self.cacheData.ladder = playerDetailData.ladder
        end
        -- 竞技场数据
        if playerDetailData.arena then
            self.cacheData.arena = playerDetailData.arena
        end
        -- 冠军联赛服务器名称
        if playerDetailData.serverName then
            self.cacheData.serverName = playerDetailData.serverName
        end
        -- 冠军联赛区服id
        if playerDetailData.displayId then
            self.cacheData.displayId = playerDetailData.displayId
        end
        -- 额外系数
        if playerDetailData.opRevise then
            self.cacheData.opRevise = playerDetailData.opRevise
        end
    end
end

function PlayerDetailModel:SetHomeCourtState(byHomeCourt)
    self.otherPlayerTeamsModel:SetHomeCourtState(byHomeCourt)
end

function PlayerDetailModel:GetOtherSceneModel()
    return self.otherSceneModel
end

function PlayerDetailModel:GetOtherPlayerLegendCardModel()
    return self.otherLegendCardsMapModel
end

function PlayerDetailModel:GetOtherPlayerTeamsModel()
    return self.otherPlayerTeamsModel
end

function PlayerDetailModel:GetOtherPlayerCardsMapModel()
    return self.otherPlayerCardsMapModel
end

function PlayerDetailModel:GetChemicalCids()
    return self.cacheData.cidChemical
end

function PlayerDetailModel:GetPlayerName()
    return self.cacheData.player.name
end

function PlayerDetailModel:GetPlayerLevel()
    return self.cacheData.player.lvl
end

function PlayerDetailModel:GetPower()
    return self.cacheData.player.power
end

function PlayerDetailModel:GetTeamLogo()
    return self.cacheData.player.logo
end

function PlayerDetailModel:GetLastLoginTime()
    return self.cacheData.player.l_t
end

function PlayerDetailModel:GetPlayerHonorList()
    return self.cacheData.player.honor
end

function PlayerDetailModel:GetPlayerVIPLevel()
    return self.cacheData.player.vip.lvl
end

function PlayerDetailModel:GetPlayerCompeteSign()
    return self.cacheData.player.worldTournamentLevel
end

function PlayerDetailModel:GetUnionName()
end

function PlayerDetailModel:GetJonName()
end

function PlayerDetailModel:GetPlayerCardModel(pcid)
    return self.cacheData.playerCardModelsMap[tostring(pcid)]
end

function PlayerDetailModel:GetGuild()
    return self.cacheData.guild
end

function PlayerDetailModel:GetLeague()
    return self.cacheData.league
end

function PlayerDetailModel:GetLadder()
    return self.cacheData.ladder
end

function PlayerDetailModel:GetArena()
    return self.cacheData.arena
end

function PlayerDetailModel:GetCoach()
    return self.cacheData.coach or {}
end

function PlayerDetailModel:GetCoachMainModel()
    return self.otherCoachMainModel
end

function PlayerDetailModel:GetCoachLevel()
    local coach = self:GetCoach()
    return tonumber(coach.lvl)
end

-- 获得好友教练阵型
function PlayerDetailModel:GetCoachFormation()
    local coach = self:GetCoach()
    return coach.formation
end

-- 获得好友教练战术
function PlayerDetailModel:GetCoachTactics()
    local coach = self:GetCoach()
    return coach.tactics
end

-- 获得好友教练执教天赋
function PlayerDetailModel:GetCoachTalent()
    local coach = self:GetCoach()
    return coach.talent
end

-- 获得好友助理教练
function PlayerDetailModel:GetCoachAssistant()
    local coach = self:GetCoach()
    return coach.assistantCoach
end

function PlayerDetailModel:GetFriendNum()
    local friendsCount = self.cacheData.friendsCount or 0
    return tostring(friendsCount)
end

function PlayerDetailModel:GetFriendShipNum()
    return tostring(self.cacheData.player.fp)
end

function PlayerDetailModel:GetRegTime()
    return os.date("%Y/%m/%d", self.cacheData.player.c_t)
end

function PlayerDetailModel:GetExp()
    return self.cacheData.player.exp
end

function PlayerDetailModel:GetNeedExp()
    return self.cacheData.player.playerExp
end

function PlayerDetailModel:SetIndex(value)
    self.selfIndex = value
end

function PlayerDetailModel:GetIndex()
    return self.selfIndex
end

function PlayerDetailModel:isFriend()
    return self.cacheData.isFriend
end

function PlayerDetailModel:GetGuildID()
    return self.cacheData.guild and self.cacheData.guild.gid
end

function PlayerDetailModel:GetGuild()
    return self.cacheData.guild
end

function PlayerDetailModel:SetIsMe(isMe)
    self.cacheData.isMe = isMe
end

function PlayerDetailModel:GetIsMe()
    return self.cacheData.isMe
end

function PlayerDetailModel:GetServerName()
    return self.cacheData.serverName or ""
end

function PlayerDetailModel:GetDisplayId()
    return self.cacheData.displayId or ""
end

function PlayerDetailModel:GetServerDisplayId()
    return self.cacheData.displayId
end

function PlayerDetailModel:SetArenaType(arenaType)
    self.cacheData.arenaType = arenaType
end

function PlayerDetailModel:GetArenaType()
    return self.cacheData.arenaType
end

-- 额外战力加成系数
function PlayerDetailModel:GetPlayerOpRevise()
    return self.cacheData.opRevise
end

return PlayerDetailModel

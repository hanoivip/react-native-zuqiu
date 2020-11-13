local OtherCardModel = require("ui.models.cardDetail.OtherCardModel")
local OtherPlayerCardsMapModel = require("ui.models.OtherPlayerCardsMapModel")
local OtherPlayerTeamsModel = require("ui.models.OtherPlayerTeamsModel")
local OtherLegendCardsMapModel = require("ui.models.legendRoad.OtherLegendCardsMapModel")
local PlayerDetailModel = require("ui.models.playerDetail.PlayerDetailModel")
local PeakPlayerDetailModel = class(PlayerDetailModel, 'PeakPlayerDetailModel')

function PeakPlayerDetailModel:ctor()
    PeakPlayerDetailModel.super.ctor(self)
end

function PeakPlayerDetailModel:InitWithProtocol(playerDetailData)
    self.playerDetailData = playerDetailData
    if playerDetailData then
        self.cacheData = {}
        if playerDetailData.player then
            self.cacheData.player = playerDetailData.player
        end

        self.otherPlayerCardsMapModel = OtherPlayerCardsMapModel.new()
        self.otherPlayerCardsMapModel:InitWithProtocol(playerDetailData.peakTeamCards)

        --是否残阵标识
        self.cacheData.teamFlagList = {}
        if playerDetailData.peakTeam.teamFlag then
            for i, v in pairs(playerDetailData.peakTeam.teamFlag) do
                self.cacheData.teamFlagList[tostring(i)] = v
            end
        end

        --是否为隐藏阵容
        self.cacheData.teamShow = {}
        self.cacheData.teamOrder = {}
        if playerDetailData.peakTeam.teamOrder then
            for k, v in pairs(playerDetailData.peakTeam.teamOrder) do
                self.cacheData.teamOrder[tostring(v)] = k
            end
        end
        if playerDetailData.peakTeam.teamShow then
            for k, v in pairs(self.cacheData.teamOrder) do
                self.cacheData.teamShow[k] = playerDetailData.peakTeam.teamShow[v]
            end
        end

        if playerDetailData.cidChemical then
            self.cacheData.cidChemical = playerDetailData.cidChemical
        end
        --是否同服
        self.cacheData.isSameServer = playerDetailData.sameServer
        -- 是否是好友
        self.cacheData.isFriend = playerDetailData.isFriend or false
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
    end
end

function PeakPlayerDetailModel:InitTeamModelByIndex(index)
    if self.playerDetailData then
        --阵容战力相关
        self.cacheData.power = self.playerDetailData.peakTeam.teamInfo[tostring(index)].power or 0

        self.otherPlayerTeamsModel = OtherPlayerTeamsModel.new(self.otherPlayerCardsMapModel)
        self.otherPlayerTeamsModel:InitWithProtocol(self.playerDetailData.peakTeam.teamInfo[tostring(index)])

        if self.playerDetailData.legendRoad then
            self.cacheData.legendRoad = self.playerDetailData.legendRoad
            self.otherLegendCardsMapModel = OtherLegendCardsMapModel.new()
            self.otherLegendCardsMapModel:InitWithProtocol(self.cacheData.legendRoad)
            self.otherLegendCardsMapModel:BuildTeamLegendInfo(self:GetOtherPlayerTeamsModel())
        end

        self.cacheData.playerCardModelsMap = {}
        for k, v in pairs(self.playerDetailData.peakTeamCards) do
            local otherPlayerCardModel = OtherCardModel.new(k, self.otherPlayerCardsMapModel, self.otherPlayerTeamsModel, self.otherLegendCardsMapModel)
            self.cacheData.playerCardModelsMap[tostring(k)] = otherPlayerCardModel
        end     
    end
end

function PeakPlayerDetailModel:GetOtherPlayerTeamsModel()
    return self.otherPlayerTeamsModel
end

function PeakPlayerDetailModel:GetOtherPlayerCardsMapModel()
    return self.otherPlayerCardsMapModel
end

function PeakPlayerDetailModel:GetChemicalCids()
    return self.cacheData.cidChemical
end

function PeakPlayerDetailModel:GetPlayerName()
    return self.cacheData.player.name
end

function PeakPlayerDetailModel:GetPlayerLevel()
    return self.cacheData.player.lvl
end

function PeakPlayerDetailModel:GetPower()
    return self.cacheData.power
end

function PeakPlayerDetailModel:GetTeamLogo()
    return self.cacheData.player.logo
end

function PeakPlayerDetailModel:GetLastLoginTime()
    return self.cacheData.player.l_t
end

function PeakPlayerDetailModel:GetPlayerHonorList()
    return self.cacheData.player.honor
end

function PeakPlayerDetailModel:GetPlayerVIPLevel()
    return self.cacheData.player.vip.lvl
end

function PeakPlayerDetailModel:GetPlayerCompeteSign()
    return self.cacheData.player.worldTournamentLevel
end

function PeakPlayerDetailModel:GetUnionName()
end

function PeakPlayerDetailModel:GetJonName()
end

function PeakPlayerDetailModel:GetPlayerCardModel(pcid)
    return self.cacheData.playerCardModelsMap[tostring(pcid)]
end

function PeakPlayerDetailModel:GetGuild()
    return self.cacheData.guild
end

function PeakPlayerDetailModel:GetLeague()
    return self.cacheData.league
end

function PeakPlayerDetailModel:GetLadder()
    return self.cacheData.ladder
end

function PeakPlayerDetailModel:GetArena()
    return self.cacheData.arena
end

function PeakPlayerDetailModel:GetFriendNum()
    local friendsCount = self.cacheData.friendsCount or 0
    return tostring(friendsCount)
end

function PeakPlayerDetailModel:GetFriendShipNum()
    return tostring(self.cacheData.player.fp)
end

function PeakPlayerDetailModel:GetRegTime()
    return os.date("%Y/%m/%d", self.cacheData.player.c_t)
end

function PeakPlayerDetailModel:GetExp()
    return self.cacheData.player.exp
end

function PeakPlayerDetailModel:GetNeedExp()
    return self.cacheData.player.playerExp
end

function PeakPlayerDetailModel:SetIndex(value)
    self.selfIndex = value
end

function PeakPlayerDetailModel:GetIndex()
    return self.selfIndex
end

function PeakPlayerDetailModel:isFriend()
    return self.cacheData.isFriend
end

function PeakPlayerDetailModel:GetGuildID()
    return self.cacheData.guild and self.cacheData.guild.gid
end

function PeakPlayerDetailModel:GetGuild()
    return self.cacheData.guild
end

function PeakPlayerDetailModel:SetIsMe(isMe)
    self.cacheData.isMe = isMe
end

function PeakPlayerDetailModel:GetIsMe()
    return self.cacheData.isMe
end

function PeakPlayerDetailModel:GetServerName()
    return self.cacheData.serverName or ""
end

function PeakPlayerDetailModel:GetDisplayId()
    return self.cacheData.displayId or ""
end

function PeakPlayerDetailModel:SetArenaType(arenaType)
    self.cacheData.arenaType = arenaType
end

function PeakPlayerDetailModel:GetArenaType()
    return self.cacheData.arenaType
end

function PeakPlayerDetailModel:GetIsSameServer()
    return self.cacheData.isSameServer
end

function PeakPlayerDetailModel:GetTeamFlagByIndex(index)
    return self.cacheData.teamFlagList[tostring(index)]
end

function PeakPlayerDetailModel:GetTeamShowByIndex(index)
    return self.cacheData.teamShow[tostring(index)]
end

function PeakPlayerDetailModel:SetTeamName(name)
    self.cacheData.teamName = name
end

function PeakPlayerDetailModel:GetTeamName()
    return self.cacheData.teamName
end

return PeakPlayerDetailModel
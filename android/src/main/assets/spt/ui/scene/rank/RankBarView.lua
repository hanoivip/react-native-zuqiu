local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local RankTabType = require("ui.scene.rank.RankTabType")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local AssetFinder = require("ui.common.AssetFinder")

local RankBarView = class(unity.base)

function RankBarView:ctor()
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.teamLogoObj = self.___ex.teamLogoObj
    self.guildObj = self.___ex.guildObj
    self.playerObj = self.___ex.playerObj
    self.teamLogo = self.___ex.teamLogo
    self.teamName = self.___ex.teamName
    self.teamServer = self.___ex.teamServer
    self.guildLogo = self.___ex.guildLogo
    self.guildName = self.___ex.guildName
    self.playerLogo = self.___ex.playerLogo
    self.playerName = self.___ex.playerName
    self.playerServer = self.___ex.playerServer
    self.desc = self.___ex.desc
    self.power = self.___ex.power
    self.btnView = self.___ex.btnView
    self.guildNameTip = self.___ex.guildNameTip
    self.powerTip = self.___ex.powerTip
    -- 争霸赛标识
    self.competeSign = self.___ex.competeSign
    self.rctPlayerName = self.___ex.rctPlayerName
end

function RankBarView:start()
    self.btnView:regOnButtonClick(function()
        if self.onView then
            self.onView(self.pid, self.sid, self.pcid, self.gid, self.cid)
        end
    end)
end

function RankBarView:InitView(rankData, rankModel)
    self.pid = rankData.pid
    self.sid = rankData.sid
    self.pcid = rankData.pcid
    self.gid = rankData.gid
    self.cid = rankData.cid
    self.teamName.text = rankData.name
    self.playerName.text = rankData.name
    self.teamServer.text = rankData.serverName
    self.playerServer.text = rankData.serverName
    self.normalRank.text = tostring(rankData.rank)
    local power = rankData.power or "" 
    self.power.text = tostring(power)

    self:InitTeamLogo(rankData.logo)
    self:InitRankShowState(rankData.rank)
    self:InitDesc(rankData, rankModel)
    self:InitCompeteSign(rankData)
end

function RankBarView:InitTeamLogo(logoData)
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, logoData)
end

function RankBarView:InitGuild(guildData, textComponet)
    if guildData then 
        textComponet.text = guildData.name
    else
        textComponet.text = lang.trans("no_guild")
    end 
end

function RankBarView:InitDesc(rankData, rankModel)
    local selectKey = rankModel:GetSelectKey()
    local showGuild = false
    self.guildNameTip.text = lang.trans("guild")
    self.powerTip.text = lang.trans("fightPower")
    if selectKey == RankTabType.GuildPower.key then 
        self.guildNameTip.text = lang.trans("guild_serverName")
        self.desc.text = rankData.serverName
        showGuild = true
        local guildPath = "Assets/CapstonesRes/Game/UI/Common/Images/GuildIcon/GuildLogo" .. tostring(rankData.eid) .. ".png"
        self.guildLogo.overrideSprite = res.LoadRes(guildPath)
        self:InitGuild(rankData, self.guildName)
    elseif selectKey == RankTabType.PlayerF.key or selectKey == RankTabType.PlayerM.key or selectKey == RankTabType.PlayerD.key or selectKey == RankTabType.PlayerG.key then 
        if not self.playerScript then 
            local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/PlayerAvatarBox.prefab")
            obj.transform:SetParent(self.playerLogo.transform, false)
            self.playerScript = spt
        end  
        self.playerScript:InitView(rankData.cid)  
        self:InitGuild(rankData.guild, self.desc)
    elseif selectKey == RankTabType.Pokedex.key then 
        self.powerTip.text = lang.trans("pokedex_num")
        self.power.text = tostring(rankData.album)
        self:InitGuild(rankData.guild, self.desc)
    elseif selectKey == RankTabType.HeroHall.key then
        self.powerTip.text = lang.trans("hero_hall_main_total_score_1")
        self.power.text = tostring(rankData.score)
        self:InitGuild(rankData.guild, self.desc)
    else
        self:InitGuild(rankData.guild, self.desc)
    end
    local showTeam = selectKey == RankTabType.TeamPower.key or selectKey == RankTabType.Pokedex.key or selectKey == RankTabType.HeroHall.key
    GameObjectHelper.FastSetActive(self.teamLogoObj.gameObject, showTeam)
    GameObjectHelper.FastSetActive(self.guildObj.gameObject, showGuild)
    GameObjectHelper.FastSetActive(self.playerObj.gameObject, not showTeam and not showGuild)
end

function RankBarView:InitRankShowState(rank)
    GameObjectHelper.FastSetActive(self.firstRank, rank == 1)
    GameObjectHelper.FastSetActive(self.secondRank, rank == 2)
    GameObjectHelper.FastSetActive(self.thirdRank, rank == 3)
    GameObjectHelper.FastSetActive(self.normalRank.gameObject, rank >= 4)
end

function RankBarView:InitCompeteSign(data)
    local worldTournamentLevel = data.worldTournamentLevel
    local posx = 170
    if worldTournamentLevel ~= nil then
        local signData = CompeteSignConvert[tostring(worldTournamentLevel)]
        if signData then
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, true)
            self.competeSign.overrideSprite = AssetFinder.GetCompeteSign(signData.path)
            posx = 203
        else
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
        end
    else
        GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
    end
    self.rctPlayerName.anchoredPosition = Vector2(posx, self.rctPlayerName.anchoredPosition.y)
end

return RankBarView
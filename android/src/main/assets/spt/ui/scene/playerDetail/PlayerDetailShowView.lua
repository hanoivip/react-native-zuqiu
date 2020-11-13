local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local ArenaModel = require("ui.models.arena.ArenaModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local TimeFormater = require("ui.controllers.friends.TimeFormater")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local PlayerLevel = require("data.PlayerLevel")

local PlayerInfoModel = require("ui.models.PlayerInfoModel")
-- 玩家详情显示
local PlayerDetailShowView = class(unity.base)

function PlayerDetailShowView:ctor()
    self.teamLogo = self.___ex.teamLogo
    self.teamName = self.___ex.teamName
    self.teamLv = self.___ex.teamLv
    self.vipLv = self.___ex.vipLv
    self.lvProgressBar = self.___ex.lvProgressBar
    self.lvProgressTxt = self.___ex.lvProgressTxt
    self.friendNumTxt = self.___ex.friendNumTxt
    self.friendNum = self.___ex.friendNum
    self.friendshipTxt = self.___ex.friendshipTxt
    self.friendshipNum = self.___ex.friendshipNum
    self.regTimeTxt = self.___ex.regTimeTxt
    self.regTime = self.___ex.regTime
    self.lastLoginTxt = self.___ex.lastLoginTxt
    self.lastLoginTime = self.___ex.lastLoginTime
    self.leagueTxt = self.___ex.leagueTxt
    self.leagueRank = self.___ex.leagueRank
    self.leagueLv = self.___ex.leagueLv
    self.leagueTotalRank = self.___ex.leagueTotalRank
    self.ladderTxt = self.___ex.ladderTxt
    self.ladderNum = self.___ex.ladderNum
    self.ladderCurRank = self.___ex.ladderCurRank
    self.cupTxt = self.___ex.cupTxt
    self.silverLua = self.___ex.silverLua
    self.goldLua = self.___ex.goldLua
    self.blackGoldLua = self.___ex.blackGoldLua
    self.platinaLua = self.___ex.platinaLua
    self.anniversaryLua = self.___ex.anniversaryLua
    self.arenaPeakLua = self.___ex.arenaPeakLua
    self.redLua = self.___ex.redLua
    self.teamServer = self.___ex.teamServer
    self.serverInfoBG = self.___ex.serverInfoBG
    self.serverInfo = self.___ex.serverInfo
    self.roleIDBG = self.___ex.roleIDBG
    self.roleID = self.___ex.roleID
    self.competeSign = self.___ex.competeSign
    self.competeEffectArea = self.___ex.competeEffectArea
    self.competeEffect = self.___ex.competeEffect
    self.vipRect = self.___ex.vipRect
end

function PlayerDetailShowView:InitView(detailModel)
    self.playerDetailModel = detailModel

    self.friendNumTxt.text = lang.transstr("pd_friend_num")
    self.friendshipTxt.text = lang.transstr("pd_friend_point")
    self.regTimeTxt.text = lang.transstr("pd_creat_time")
    self.lastLoginTxt.text = lang.transstr("pd_last_time")
    self.leagueTxt.text = lang.transstr("pd_league_txt")
    self.ladderTxt.text = lang.transstr("pd_ladder_txt")
    
    self.cupTxt.text = lang.transstr("pd_champions_league")

    self.teamName.text = self.playerDetailModel:GetPlayerName()
    self.teamServer.text = self.playerDetailModel:GetServerName()
    self.teamLv.text = "Lv" .. tostring(self.playerDetailModel:GetPlayerLevel())
    local vipLevel = self.playerDetailModel:GetPlayerVIPLevel()
    self.vipLv.text = tostring(vipLevel)
    local vipRectPosX = vipLevel > 9 and 200 or 210
    self.vipRect.anchoredPosition = Vector2(vipRectPosX, 0)
    local currentExp = self.playerDetailModel:GetExp()
    local needExp = self.playerDetailModel:GetNeedExp()
    local maxLevel = not PlayerLevel[tostring(self.playerDetailModel:GetPlayerLevel() + 1)]
    self.lvProgressBar.value = maxLevel and 1 or currentExp / needExp
    self.lvProgressTxt.text = maxLevel and "Max" or tostring(currentExp) .. "/" .. tostring(needExp)
    self.friendshipNum.text = self.playerDetailModel:GetFriendShipNum()
    self.friendNum.text = self.playerDetailModel:GetFriendNum()
    self.regTime.text = tostring(self.playerDetailModel:GetRegTime())
    self.lastLoginTime.text = TimeFormater.formatLoginTime(self.playerDetailModel:GetLastLoginTime())

    if self.playerDetailModel:GetIsMe() then
        local channel = cache.getChannel()
        if channel == "hoolai" then
            local uid = cache.getUid()
            self.serverInfoBG.gameObject:SetActive(true)
            self.roleIDBG.gameObject:SetActive(true)
            self.serverInfo.text = tostring(self.playerDetailModel:GetServerDisplayId())
            self.roleID.text = tostring(uid)
        else
            local playerInfoModel = PlayerInfoModel.new()
            self.serverInfoBG.gameObject:SetActive(true)
            self.roleIDBG.gameObject:SetActive(true)
            self.serverInfo.text = tostring(playerInfoModel:GetSID())
            self.roleID.text = tostring(playerInfoModel:GetID())
        end
    else
        self.serverInfoBG.gameObject:SetActive(false)
        self.roleIDBG.gameObject:SetActive(false)
    end

    local league = self.playerDetailModel:GetLeague()
    if league.base and league.base.diff then
        self.leagueLv.text = lang.transstr("pd_league_lv_txt") .. tostring(league.base.diff)
    else
        self.leagueLv.text = lang.transstr("pd_league_lv_txt") .."--"
    end
    if league.pos then
        self.leagueRank.text = lang.transstr("pd_league_rank") .. tostring(league.pos)
    else
        self.leagueRank.text = lang.transstr("pd_league_rank") .. "--"
    end
    if league.totalPos then
        self.leagueTotalRank.text = lang.transstr("pd_league_total_rank") .. tostring(league.totalPos)
    else
        self.leagueTotalRank.text = lang.transstr("pd_league_total_rank") .. "--"
    end
    local ladder = self.playerDetailModel:GetLadder()
    if ladder.season then
        self.ladderNum.text = lang.transstr("pd_ladder_season", ladder.season)
    else
        self.ladderNum.text = lang.transstr("pd_ladder_season", "--")
    end
    if ladder.rank then
        self.ladderCurRank.text = lang.transstr("pd_ladder_rank") .. ladder.rank
    else
        self.ladderCurRank.text = lang.transstr("pd_ladder_rank") .. "--"
    end

    local arena = self.playerDetailModel:GetArena()
    local arenaModel = ArenaModel.new()
    self.silverLua.mainTxt.text = lang.transstr("silver_arena")
    self.goldLua.mainTxt.text = lang.transstr("gold_arena")
    self.blackGoldLua.mainTxt.text = lang.transstr("black_arena")
    self.platinaLua.mainTxt.text = lang.transstr("platinum_arena")
    self.redLua.mainTxt.text = lang.transstr("red_arena")
    self.anniversaryLua.mainTxt.text = lang.transstr("yellow_arena")
    self.arenaPeakLua.mainTxt.text = lang.transstr("blue_arena")
    if arena.silver then
        self.silverLua:InitView(arenaModel, arena.silver.h_score)
    else
        self.silverLua:InitView(nil, 0)
    end
    if arena.gold then
        self.goldLua:InitView(arenaModel, arena.gold.h_score)
    else
        self.goldLua:InitView(nil, 0)
    end
    if arena.black then
        self.blackGoldLua:InitView(arenaModel, arena.black.h_score)
    else
        self.blackGoldLua:InitView(nil, 0)
    end
    if arena.platinum then
        self.platinaLua:InitView(arenaModel, arena.platinum.h_score)
    else
        self.platinaLua:InitView(nil, 0)
    end
    if arena.red then
        self.redLua:InitView(arenaModel, arena.red.h_score)
    else
        self.redLua:InitView(nil, 0)
    end
    if arena.anniversary then
        self.anniversaryLua:InitView(arenaModel, arena.anniversary.h_score)
    else
        self.anniversaryLua:InitView(nil, 0)
    end
    if arena.arenaPeak then
        self.arenaPeakLua:InitView(arenaModel, arena.arenaPeak.h_score)
    else
        self.arenaPeakLua:InitView(nil, 0)
    end
    if luaevt.trig("__SGP__VERSION__") or luaevt.trig("__UK__VERSION__") or luaevt.trig("__VN__VERSION__") then
        GameObjectHelper.FastSetActive(self.redLua.transform.gameObject, false)
        GameObjectHelper.FastSetActive(self.anniversaryLua.transform.gameObject, false)
        GameObjectHelper.FastSetActive(self.arenaPeakLua.transform.gameObject, false)
    end

    self:ShowTeamLogo()

    local teamNamePosX = -131.6
    local teamLvPosX = -206.4
    local competeSign = self.playerDetailModel:GetPlayerCompeteSign()
    local hasCompeteSign = false
    if competeSign then
        local signData = CompeteSignConvert[tostring(competeSign)]
        if signData then
            self.competeSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Images/" .. signData.path .. ".png")
            teamNamePosX = -80
            teamLvPosX = -155.9
            hasCompeteSign = true
            local effect = signData.effect
            if effect and not self.competeEffect then
                local prefab = "Assets/CapstonesRes/Game/UI/Scene/PlayerDetail/Effect/" .. effect .. ".prefab"
                local obj, spt = res.Instantiate(prefab)
                obj.transform:SetParent(self.competeEffectArea, false)
                self.competeEffect = obj
            end
        end
    end
    local teamNameRect = self.teamName.transform
    local teamLvlRect = self.teamLv.transform
    teamNameRect.anchoredPosition = Vector2(teamNamePosX, teamNameRect.anchoredPosition.y)
    teamLvlRect.anchoredPosition = Vector2(teamLvPosX, teamLvlRect.anchoredPosition.y)
    GameObjectHelper.FastSetActive(self.competeSign.gameObject, hasCompeteSign)
end

-- teamlogo的显示
function PlayerDetailShowView:ShowTeamLogo()
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, self.playerDetailModel:GetTeamLogo())
end

return PlayerDetailShowView

local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Object = UnityEngine.Object
local ArenaModel = require("ui.models.arena.ArenaModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local TimeFormater = require("ui.controllers.friends.TimeFormater")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")

-- 玩家详情显示
local PeakPlayerDetailShowView = class(unity.base)

function PeakPlayerDetailShowView:ctor()
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
    self.silverTxt = self.___ex.silverTxt
    self.goldTxt = self.___ex.goldTxt
    self.blackGoldTxt = self.___ex.blackGoldTxt
    self.platinaTxt = self.___ex.platinaTxt
    self.silverLua = self.___ex.silverLua
    self.goldLua = self.___ex.goldLua
    self.blackGoldLua = self.___ex.blackGoldLua
    self.platinaLua = self.___ex.platinaLua
    self.teamServer = self.___ex.teamServer
    self.competeSign = self.___ex.competeSign
    self.competeEffectArea = self.___ex.competeEffectArea
    self.competeEffect = self.___ex.competeEffect
    self.vipRect = self.___ex.vipRect
end

function PeakPlayerDetailShowView:InitView(detailModel)
    self.playerDetailModel = detailModel

    self.friendNumTxt.text = lang.transstr("pd_friend_num")
    self.friendshipTxt.text = lang.transstr("pd_friend_point")
    self.regTimeTxt.text = lang.transstr("pd_creat_time")
    self.lastLoginTxt.text = lang.transstr("pd_last_time")
    self.leagueTxt.text = lang.transstr("pd_league_txt")
    self.ladderTxt.text = lang.transstr("pd_ladder_txt")
    
    self.cupTxt.text = lang.transstr("pd_champions_league")
    self.silverTxt.text = lang.transstr("silver_arena") .. ":"
    self.goldTxt.text = lang.transstr("gold_arena") .. ":"
    self.blackGoldTxt.text = lang.transstr("black_arena") .. ":"
    self.platinaTxt.text = lang.transstr("platinum_arena") .. ":"

    self.teamName.text = self.playerDetailModel:GetPlayerName()
    self.teamServer.text = format("(%s)", self.playerDetailModel:GetServerName())
    self.teamLv.text = "Lv" .. tostring(self.playerDetailModel:GetPlayerLevel())
    local vipLevel = self.playerDetailModel:GetPlayerVIPLevel()
    self.vipLv.text = tostring(vipLevel)
    local vipRectPosX = vipLevel > 9 and 200 or 210
    self.vipRect.anchoredPosition = Vector2(vipRectPosX, 0)
    local currentExp = self.playerDetailModel:GetExp()
    local needExp = self.playerDetailModel:GetNeedExp()
    self.lvProgressBar.value = currentExp / needExp
    self.lvProgressTxt.text = tostring(currentExp) .. "/" .. tostring(needExp)
    self.friendshipNum.text = self.playerDetailModel:GetFriendShipNum()
    self.friendNum.text = self.playerDetailModel:GetFriendNum()
    self.regTime.text = tostring(self.playerDetailModel:GetRegTime())
    self.lastLoginTime.text = TimeFormater.formatLoginTime(self.playerDetailModel:GetLastLoginTime())

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
function PeakPlayerDetailShowView:ShowTeamLogo()
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, self.playerDetailModel:GetTeamLogo())
end

return PeakPlayerDetailShowView
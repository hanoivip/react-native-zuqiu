local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds

local LeagueConstants = require("ui.scene.league.LeagueConstants")
local UISoundManager = require("ui.control.manager.UISoundManager")
local LeagueBgmPlayer = require("ui.scene.league.LeagueBgmPlayer")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CustomEvent = require("ui.common.CustomEvent")
local CommonConstants = require("ui.common.CommonConstants")

local LeagueSeasonRewardPageView = class(unity.base)

function LeagueSeasonRewardPageView:ctor()
    -- 王冠
    self.rankImage = self.___ex.rankImage
    -- 排名
    self.rank = self.___ex.rank
    -- 欧元数量
    self.moneyNum = self.___ex.moneyNum
    -- 射手球队名称
    self.shootTeamName = self.___ex.shootTeamName
    -- 射手球员名称
    self.shootName = self.___ex.shootName
    -- 进球数
    self.goalNum = self.___ex.goalNum
    -- 射手球员头像框
    self.shootAvatarBox = self.___ex.shootAvatarBox
    -- 助攻球队名称
    self.assistTeamName = self.___ex.assistTeamName
    -- 助攻球员名称
    self.assistName = self.___ex.assistName
    -- 助攻数
    self.assistNum = self.___ex.assistNum
    -- 助攻球员头像框
    self.assistAvatarBox = self.___ex.assistAvatarBox
    -- 领取奖励按钮
    self.rewardBtn = self.___ex.rewardBtn
    -- 其他排名图标
    self.otherRankIcon = self.___ex.otherRankIcon
    -- 联赛等级
    self.leagueLevel = self.___ex.leagueLevel
    -- 动画管理器
    self.animator = self.___ex.animator
    -- 奖励数据
    self.rewardData = nil
    -- 当前排名
    self.nowRank = nil
    -- 射手数据
    self.shooterData = nil
    -- 助攻手数据
    self.assisterData = nil
end

function LeagueSeasonRewardPageView:InitView(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self.rewardData = self.leagueInfoModel:GetSeasonReward()
    self.nowRank = self.rewardData.pos + 1
    self.shooterData = self.leagueInfoModel:GetSeasonRewardBestShooterData()
    self.assisterData = self.leagueInfoModel:GetSeasonRewardBestAssisterData()
    
    self:BuildPage()
end

function LeagueSeasonRewardPageView:start()
    LeagueBgmPlayer.StartPlayBgm()
    UISoundManager.play("League/LeagueSeasonResult", 1)
    self:BindAll()
end

function LeagueSeasonRewardPageView:BindAll()
    -- 领取奖励按钮
    self.rewardBtn:regOnButtonClick(function ()
        self:PlayMoveOutAnim()
    end)
end

function LeagueSeasonRewardPageView:BuildPage()
    self.leagueLevel.text = lang.trans("league_seasonRewardTitle", tostring(self.leagueInfoModel:GetLeagueLevel()))
    if self.nowRank <= 3 then
        local rankImagePath = "Assets/CapstonesRes/Game/UI/Scene/League/Images/Trophy" .. tostring(self.nowRank) ..".png"
        self.rankImage.overrideSprite = res.LoadRes(rankImagePath)
        self.rank.text = lang.trans("league_seasonRankNum" .. self.nowRank)
    else
        self.rank.text = lang.trans("league_rank", self.nowRank)
    end
    GameObjectHelper.FastSetActive(self.rankImage.gameObject, self.nowRank <= 3)
    GameObjectHelper.FastSetActive(self.otherRankIcon, self.nowRank > 3)
    self.moneyNum.text = string.formatNumWithUnit(self.rewardData.contents.m)
    if self.shooterData ~= nil then
        self.goalNum.text = lang.trans("league_goalNum", self.shooterData.goal)
        self.shootName.text = self.shooterData.name
        self.shootTeamName.text = self.shooterData.teamName
        self:InstantiateAvatarBox(self.shootAvatarBox, self.shooterData.cid)
    else
        self.goalNum.text = ""
        self.shootName.text = ""
        self.shootTeamName.text = ""
    end
    if self.assisterData ~= nil then
        self.assistNum.text = lang.trans("league_assistNum", self.assisterData.goal)
        self.assistName.text = self.assisterData.name
        self.assistTeamName.text = self.assisterData.teamName
        self:InstantiateAvatarBox(self.assistAvatarBox, self.assisterData.cid)
    else
        self.assistNum.text = ""
        self.assistName.text = ""
        self.assistTeamName.text = ""
    end
end

function LeagueSeasonRewardPageView:InstantiateAvatarBox(parentTrans, cardId)
    local avatarBoxObj, avatarBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/PlayerAvatarBox.prefab")
    avatarBoxObj.transform:SetParent(parentTrans, false)
    avatarBoxView:InitView(cardId)
end

function LeagueSeasonRewardPageView:Destroy()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
    local rewardData = self.rewardData
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        CongratulationsPageCtrl.new(rewardData.contents)
        CustomEvent.GetMoney("1",tonumber(rewardData.contents.m))
        luaevt.trig("HoolaiBISendCounterRes", "inflow", 1, rewardData.contents.m)
    end)
end

function LeagueSeasonRewardPageView:PlayMoveOutAnim()
    self.animator:Play("MoveOut")
end

function LeagueSeasonRewardPageView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:Destroy()
    end
end

function LeagueSeasonRewardPageView:onDestroy()
    LeagueBgmPlayer.StopPlayBgm()
end

return LeagueSeasonRewardPageView

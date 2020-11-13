local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local UI = UnityEngine.UI
local Text = UI.Text

local LeagueConstants = require("ui.scene.league.LeagueConstants")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CommonConstants = require("ui.common.CommonConstants")

local LeagueSeasonInfoPageView = class(unity.base)

function LeagueSeasonInfoPageView:ctor()
    -- 队伍logo
    self.teamLogo = self.___ex.teamLogo
    -- 联赛等级文本
    self.leagueLevelText = self.___ex.leagueLevelText
    -- 队伍名称
    self.teamName = self.___ex.teamName
    -- 队伍名称
    self.teamName2 = self.___ex.teamName2
    -- 最佳射手
    self.bestShooter = self.___ex.bestShooter
    -- 最佳助攻
    self.bestAssister = self.___ex.bestAssister
    -- 赞助商名称
    self.sponsorName = self.___ex.sponsorName
    -- 赞助细则
    self.sponsorRules = self.___ex.sponsorRules
    -- 赞助费
    self.sponsorshipFee = self.___ex.sponsorshipFee
    -- 赛季收入
    self.seasonIncome = self.___ex.seasonIncome
    -- 排名
    self.rank = self.___ex.rank
    -- 排名第一时显示的对象
    self.rankFirst = self.___ex.rankFirst
    -- 排名第二时显示的对象
    self.rankSecond = self.___ex.rankSecond
    -- 排名第三时显示的对象
    self.rankThird = self.___ex.rankThird
    -- 排名奖励区域
    self.rewardArea = self.___ex.rewardArea
    -- 关闭按钮
    self.closeBtn = self.___ex.closeBtn
    -- 画布组
    self.canvasGroup = self.___ex.canvasGroup
    -- 最佳射手头像
    self.bestShooterAvatar = self.___ex.bestShooterAvatar
    -- 最佳助攻头像
    self.bestAssisterAvatar = self.___ex.bestAssisterAvatar
    -- 动画管理器
    self.animator = self.___ex.animator
    -- model
    self.leagueInfoModel = nil
    -- 联赛等级
    self.leagueLevel = nil
    -- 联赛排名奖励
    self.rankReward = nil
    -- 队伍积分数据
    self.teamScoreData = nil
    -- 最佳射手数据
    self.bestShooterData = nil
    -- 最佳助攻手数据
    self.bestAssisterData = nil
    -- 玩家信息模型
    self.playerInfoModel = nil
    -- 当前赞助商的数据
    self.nowSponsorData = nil
    -- 联赛基础信息
    self.baseInfo = nil
end

function LeagueSeasonInfoPageView:InitView(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self.playerInfoModel = PlayerInfoModel.new()
    self.leagueLevel = self.leagueInfoModel:GetLeagueLevel()
    self.rankReward = self.leagueInfoModel:GetRankReward()
    self.teamScoreData = self.leagueInfoModel:GetTeamScoreData(self.playerInfoModel:GetID())
    self.bestShooterData = self.leagueInfoModel:GetBestShooterData()
    self.bestAssisterData = self.leagueInfoModel:GetBestAssisterData()
    self.nowSponsorData = self.leagueInfoModel:GetNowSponsorData()
    self.baseInfo = self.leagueInfoModel:GetBaseInfo()
    self:InitRewardArea()
    
    self:BuildPage()
end

function LeagueSeasonInfoPageView:start()
    self:BindAll()
end

function LeagueSeasonInfoPageView:BindAll()
    -- 关闭按钮
    self.closeBtn:regOnButtonClick(function ()
        self:PlayMoveOutAnim()
    end)
end

--- 初始化奖励区域
function LeagueSeasonInfoPageView:InitRewardArea()
    local leagueRank = 0
    if self.teamScoreData then
        leagueRank = self.teamScoreData.pos + 1
    end
    for i = 1, LeagueConstants.TeamSum do
        local barScripts = self.rewardArea["bar" .. i]
        barScripts:InitView(i, self.rankReward[i], leagueRank)
    end
end

function LeagueSeasonInfoPageView:BuildPage()
    local teamLogoCtrl = TeamLogoCtrl.new(nil, self.teamLogo.transform)
    teamLogoCtrl:Init(self.playerInfoModel:GetTeamLogo())
    self.teamName.text = tostring(self.playerInfoModel:GetName())
    self.teamName2.text = self.teamName.text
    self.leagueLevelText.text = lang.trans("league_leagueLevel", self.leagueLevel)
    if self.bestShooterData and self.bestShooterData.name then
        self.bestShooter.text = tostring(self.leagueInfoModel:GetNameByID(self.bestShooterData.cid))
        self.bestShooterAvatar.sprite = AssetFinder.GetPlayerIcon(self.bestShooterData.cid)
        GameObjectHelper.FastSetActive(self.bestShooterAvatar.gameObject, true)
    else
        self.bestShooter.text = lang.trans("none")
        self.bestShooterAvatar.sprite = AssetFinder.GetPlayerIcon(-1)
    end
    if self.bestAssisterData and self.bestAssisterData.name then
        self.bestAssister.text = tostring(self.leagueInfoModel:GetNameByID(self.bestAssisterData.cid))
        self.bestAssisterAvatar.sprite = AssetFinder.GetPlayerIcon(self.bestAssisterData.cid)
        GameObjectHelper.FastSetActive(self.bestAssisterAvatar.gameObject, true)
    else
        self.bestAssister.text = lang.trans("none")
        self.bestAssisterAvatar.sprite = AssetFinder.GetPlayerIcon(-1)
    end
    self.sponsorName.text = tostring(self.nowSponsorData.sponsor)
    if self.nowSponsorData.type == LeagueConstants.SponsorType.PAY_IN_FULL then
        self.sponsorRules.text = lang.trans("league_oneTimeGetSponsorshipFees")
    else
        self.sponsorRules.text = lang.trans("league_everyWinAGameGetSponsorshipFees")
    end
    self.sponsorshipFee.text = string.formatNumWithUnit(self.nowSponsorData.reward)
    self.seasonIncome.text = string.formatNumWithUnit(self.baseInfo.seasonIncome)

    if self.teamScoreData then
        GameObjectHelper.FastSetActive(self.rankFirst, false)
        GameObjectHelper.FastSetActive(self.rankSecond, false)
        GameObjectHelper.FastSetActive(self.rankThird, false)
        GameObjectHelper.FastSetActive(self.rank.gameObject, false)

        local leagueRank = self.teamScoreData.pos + 1
        if leagueRank == 1 then
            GameObjectHelper.FastSetActive(self.rankFirst, true)
        elseif leagueRank == 2 then
            GameObjectHelper.FastSetActive(self.rankSecond, true)
        elseif leagueRank == 3 then
            GameObjectHelper.FastSetActive(self.rankThird, true)
        else
            GameObjectHelper.FastSetActive(self.rank.gameObject, true)
            self.rank.text = tostring(leagueRank)
        end
    else
        self.rank.text = "0" 
    end
end

function LeagueSeasonInfoPageView:Close()
    self:PlayMoveOutAnim()
end

function LeagueSeasonInfoPageView:PlayMoveOutAnim()
    self.animator:Play("MoveOut")
end

function LeagueSeasonInfoPageView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:Destroy()
    end
end

function LeagueSeasonInfoPageView:Destroy()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

return LeagueSeasonInfoPageView

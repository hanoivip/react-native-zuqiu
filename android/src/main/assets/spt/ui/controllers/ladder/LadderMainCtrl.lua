local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local LadderModel = require("ui.models.ladder.LadderModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local MenuBarCtrl = require("ui.controllers.common.MenuBarCtrl")
local MatchLoader = require("coregame.MatchLoader")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TechnologySettingConfig = require("ui.scene.court.technologyHall.TechnologySettingConfig")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local LadderDailyRewardDetailCtrl = require("ui.controllers.ladder.LadderDailyRewardDetailCtrl")
local BaseMenuBarModel = require("ui.models.menuBar.BaseMenuBarModel")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")

local LadderMainCtrl = class(BaseCtrl)
LadderMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderCanvas.prefab"

function LadderMainCtrl:Init()
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
    local menuBarModel = BaseMenuBarModel.new(BaseMenuBarModel.MenuState.Close, FormationConstants.TeamType.LADDER)
    self.menuBarCtrl = MenuBarCtrl.new(self.view.menuBarDynParent, self, nil, menuBarModel)
    self.opponentId = nil
end
function LadderMainCtrl:Refresh()
    LadderMainCtrl.super.Refresh(self)
    clr.coroutine(function()
        local respone = req.ladderInfo()
        if api.success(respone) then
            local data = respone.val
            self.ladderModel = LadderModel.new()
            self.ladderModel:InitWithProtocol(data)
            self:InitView()
        end
    end)
end

function LadderMainCtrl:GetStatusData()
end

function LadderMainCtrl:OnEnterScene()
    self.view:RegisterEvent()
    EventSystem.AddEvent("LadderShopMainCtrl.RefreshMyCurHonorPoint", self, self.RefreshMyCurHonorPoint)
end

function LadderMainCtrl:OnExitScene()
    self.view:UnRegisterEvent()
    EventSystem.RemoveEvent("LadderShopMainCtrl.RefreshMyCurHonorPoint", self, self.RefreshMyCurHonorPoint)
    self.view:StopHonorEffect()
end

function LadderMainCtrl:InitView()
    self.view.onRank = function() self:OnRank() end
    self.view.onShop = function() self:OnShop() end
    self.view.onSetHome = function() self:OnSetHome() end
    self.view.onRecord = function() self:OnRecord() end
    self.view.onReward = function() self:OnReward() end
    self.view.onReceive = function() self:OnReceive() end
    self.view.onChangeOpponents = function() self:OnChangeOpponents() end
    self.view.updateChallengeOpponents = function() self:UpdateChallengeOpponents() end
    self.view.onDailyRewardDetail = function() self:OnDailyRewardDetail() end
    self.view.onRuleHelp = function() self:OnRuleHelp() end
    self.view:InitView(self.ladderModel)
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            -- self.view:PlayLeaveAnimation()
            res.PopScene()
        end)
        --[[self.view:RegOnLeave(function()
            res.PopScene()
        end)]]
    end)
end

-- 排行榜
function LadderMainCtrl:OnRank()
    clr.coroutine(function()
        local respone = req.ladderRankList()
        if api.success(respone) then
            local data = respone.val
            if data.list then
                self.ladderModel:InitRankSeasonList(data.list)
            end
            if data.rank then
                self.ladderModel:InitCurRankDataList(data.rank)
            end
            if data.self then
                self.ladderModel:InitMyRealTimeRankInfo(data.self)
            end
            
            res.PushScene("ui.controllers.ladder.LadderRankMainCtrl", self.ladderModel)
        end
    end)
end

-- 商店
function LadderMainCtrl:OnShop()
    res.PushScene("ui.controllers.ladder.LadderShopMainCtrl", self.ladderModel)
end

-- 设置主场
function LadderMainCtrl:OnSetHome()
    local courtBuildModel = CourtBuildModel.new()
    if courtBuildModel.data and type(courtBuildModel.data) == "table" then
        res.PushDialog("ui.controllers.court.technologyHall.CourtDisplayCtrl", courtBuildModel, TechnologySettingConfig.Ladder)
    else
        clr.coroutine(function()
            local response = req.buildInfo()
            if api.success(response) then
                local data = response.val
                local courtBuildModel = CourtBuildModel.new()
                courtBuildModel:InitWithProtocol(data)
                res.PushDialog("ui.controllers.court.technologyHall.CourtDisplayCtrl", courtBuildModel, TechnologySettingConfig.Ladder)
            end
        end)
    end
end

-- 对战记录
function LadderMainCtrl:OnRecord()
    res.PushScene("ui.controllers.ladder.LadderMatchRecordMainCtrl", self.ladderModel)
end

-- 赛季奖励
function LadderMainCtrl:OnReward()
    res.PushScene("ui.controllers.ladder.LadderRewardMainCtrl", self.ladderModel)
end

-- 领取奖励
function LadderMainCtrl:OnReceive()
    clr.coroutine(function()
        local respone = req.ladderReward()
        if api.success(respone) then
            local data = respone.val
            self.ladderModel:SetTotalReceiveReward(data.rewardPoint)
            self.ladderModel:SetMyCurrentHonorPoint(data.contents.lp)
            self.view:PlayerHonorEffect()
        end
    end)
end

function LadderMainCtrl:UpdateChallengeOpponents()
    local challengeOpponents = self.ladderModel:GetChallengeOpponents()
    self.view:ClearChallengeOpponents()
    for index, info in ipairs(challengeOpponents) do
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderChallengeTeamBar.prefab")
        self.view:AddChallengeOpponent(obj)
        spt.onChallenge = function() self:OnChallenge(info.pid, info.sid) end
        spt.onView = function() self:OnView(info.pid, info.sid) end
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogo(), info.logo) end
        spt:InitView(info)
    end
end

-- 换一批对手
function LadderMainCtrl:OnChangeOpponents()
    clr.coroutine(function()
        local respone = req.ladderUpdateRival()
        if api.success(respone) then
            local data = respone.val
            self.ladderModel:SetChallengeOpponents(data.rivals)
        end
    end)
end

-- 挑战按钮回调
function LadderMainCtrl:OnChallenge(pcid)
    self.opponentId = pcid
    if self.ladderModel:IsRemainChallengeTimesUseUp() then
        self:BuyChallengeTimes()
    elseif self.ladderModel:IsCdDoing() then
        self:BuyCd()
    else
        self:Challenge()
    end
end

-- 查看玩家详情
function LadderMainCtrl:OnView(pid, sid)
    sid = sid or self.playerInfoModel:GetSID()
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

-- 挑战对手
function LadderMainCtrl:Challenge()
    clr.coroutine(function()
        local respone = req.ladderStart(self.opponentId)
        if api.success(respone) then
            local data = respone.val
            -- 更新花费
            if data.cost and data.cost.type == "d" then
                self.playerInfoModel:SetDiamond(data.cost.curr_num)
            end
            MatchLoader.startMatch(data.match)
        end
    end)
end

-- 询问是否购买CD
function LadderMainCtrl:BuyCd()
    local title = lang.trans("ladder_buyCdTitle")
    local msg = lang.trans("ladder_buyCdContent", 50)
    DialogManager.ShowConfirmPop(title, msg, function() self:OnBuyCdConfirm() end)
end

-- 确认购买CD
function LadderMainCtrl:OnBuyCdConfirm()
    clr.coroutine(function()
        local respone = req.ladderBuyCd()
        if api.success(respone) then
            local data = respone.val
            -- 更新花费
            if data.cost and data.cost.type == "d" then
                self.playerInfoModel:SetDiamond(data.cost.curr_num)
            end

            if data.cd then
                self.ladderModel:SetCd(data.cd)
            end

            self:Challenge()
        end
    end)
end

-- 询问是否购买挑战次数
function LadderMainCtrl:BuyChallengeTimes()
    local title = lang.trans("ladder_buyChallengeTimesTitle")
    local msg = lang.trans("ladder_buyChallengeTimesContent", 100)
    DialogManager.ShowConfirmPop(title, msg, function() self:OnBuyChallengeTimesConfirm() end)
end

-- 确认购买挑战次数
function LadderMainCtrl:OnBuyChallengeTimesConfirm()
    if self.ladderModel:IsCdDoing() then
        self:BuyCd()
    else
        self:Challenge()
    end
end

-- 设置队徽
function LadderMainCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

-- 打开每日奖励
function LadderMainCtrl:OnDailyRewardDetail()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderDailyRewardDetailBoard.prefab", "camera", true, true)
    local ladderDailyRewardDetailCtrl = LadderDailyRewardDetailCtrl.new(dialogcomp.contentcomp)
    ladderDailyRewardDetailCtrl:InitView(self.ladderModel)
end

-- 打开天梯规则
function LadderMainCtrl:OnRuleHelp()
    res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRuleBoard.prefab", "camera", true, true)
end

function LadderMainCtrl:RefreshMyCurHonorPoint()
    self.view:RefreshMyCurHonorPoint()
end

return LadderMainCtrl
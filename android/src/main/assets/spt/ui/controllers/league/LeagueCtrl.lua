local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local Object = UnityEngine.Object
local LeagueInfoModel = require("ui.models.league.LeagueInfoModel")
local MatchConstants = require("ui.scene.match.MatchConstants")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CustomEvent = require("ui.common.CustomEvent")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local LeagueBgmPlayer = require("ui.scene.league.LeagueBgmPlayer")
local DialogManager = require("ui.control.manager.DialogManager")
local NewYearOutPutPosType = require("ui.scene.activity.content.worldBossActivity.NewYearOutPutPosType")
local NewYearCongratulationsPageCtrl = require("ui.controllers.activity.content.worldBossActivity.NewYearCongratulationsPageCtrl")

local LeagueCtrl = class()

function LeagueCtrl:ctor()
    self.leagueInfoModel = nil
    self.settlementData = nil
    self:Init()
end

function LeagueCtrl:Init()
    self:RequestInitData()
end

function LeagueCtrl:RequestInitData(leagueMainPageCtrl, leagueInfoModel)
    clr.coroutine(function()
        local response = req.leagueIndex()
        if api.success(response) then
            local data = response.val
            if leagueInfoModel ~= nil then
                self.leagueInfoModel = leagueInfoModel
            else
                self.leagueInfoModel = LeagueInfoModel.new()
            end
            self.leagueInfoModel:InitWithIndexProtocol(data)
            self.leagueInfoModel:SetLeagueCtrl(self)

            -- 判断是否已签约赞助商
            local isSignedSponsor = self.leagueInfoModel:IsSignedSponsor()
            if isSignedSponsor then
                -- 判断是否需要获取最新的赛程列表
                local leagueLevel = self.leagueInfoModel:GetLeagueLevel()
                local scheduleLeagueLevel = self.leagueInfoModel:GetScheduleLeagueLevel()
                if leagueLevel ~= scheduleLeagueLevel then
                    self:RequestScheduleList(leagueMainPageCtrl)
                else
                    self:EnterMain(leagueMainPageCtrl)
                end
            else
                local leagueWelcomePageView = res.LoadSceneImmediate("Assets/CapstonesRes/Game/UI/Scene/League/LeagueWelcome.prefab")
                leagueWelcomePageView:InitView(self.leagueInfoModel)
                LeagueBgmPlayer.StartPlayBgm()
            end
        end
    end)
end

--- 进入主界面
function LeagueCtrl:EnterMain(leagueMainPageCtrl, isNewSeason)
    clr.coroutine(function()
        local response = req.leagueEnter()
        if api.success(response) then
            local data = response.val
            self.leagueInfoModel:InitWithEnterProtocol(data)
            if leagueMainPageCtrl == nil then
                if res.GetLastCtrlPath() == "ui.controllers.league.LeagueMainPageCtrl" then
                    res.RemoveLastSceneData()
                end
                res.PushSceneImmediate("ui.controllers.league.LeagueMainPageCtrl", self.leagueInfoModel, self, isNewSeason)
            else
                leagueMainPageCtrl:Refresh(self.leagueInfoModel, self)
            end
            self:CheckRewardSponsorshipFee()
            self:SettleMatchReward()
        end
    end)
end

--- 请求赛程列表
function LeagueCtrl:RequestScheduleList(leagueMainPageCtrl, isNewSeason)
    clr.coroutine(function()
        local response = req.leagueSchedule()
        if api.success(response) then
            local data = response.val
            self.leagueInfoModel:InitWithScheduleProtocol(data)
            self:EnterMain(leagueMainPageCtrl, isNewSeason)
        end
    end)
end

--- 检测是否奖励赞助费
function LeagueCtrl:CheckRewardSponsorshipFee()
    local fee = self.leagueInfoModel:GetRewardSponsorshipFee()
    if fee > 0 then
        local rewardData = {m = fee}
        CustomEvent.GetMoney("1", fee)
        luaevt.trig("HoolaiBISendCounterRes", "inflow", 2, fee)
        CongratulationsPageCtrl.new(rewardData)
    end
end

--- 结算比赛奖励
function LeagueCtrl:SettleMatchReward()
    local matchResultData = cache.getMatchResult()
    if matchResultData == nil then
        self:CheckSeasonIsFinished()
        return
    end

    self.settlementData = matchResultData.settlement
    -- 比赛的奖励是否已结算过
    if matchResultData.hasSettle == false and matchResultData.matchType == MatchConstants.MatchType.LEAGUE then
        matchResultData.hasSettle = true
        local playerTeamsModel = PlayerTeamsModel.new()
        local isMatchWin = self.settlementData.winGoals > 0
        CustomEvent.LeagueMatchEnd(self.leagueInfoModel:GetLeagueLevel(), isMatchWin, playerTeamsModel:GetTotalPower())

        -- 结算奖励
        local homeMoney = tonumber(self.settlementData.homeIncome) or 0
        local sponsorMoney = tonumber(self.settlementData.sponserMoney) or 0
        local totalMoney = 0
        if homeMoney > 0 then
            totalMoney = totalMoney + homeMoney
            luaevt.trig("HoolaiBISendCounterRes", "inflow", 3, homeMoney)
        end
        if sponsorMoney > 0 then
            totalMoney = totalMoney + sponsorMoney
            luaevt.trig("HoolaiBISendCounterRes", "inflow", 2, sponsorMoney)
        end

        local rewardUpdateCacheModel = RewardUpdateCacheModel.new()
        rewardUpdateCacheModel:UpdateCache({m = totalMoney})
        CustomEvent.GetMoney("1", tonumber(totalMoney))

        -- 更新赛程列表
        local baseInfo = self.leagueInfoModel:GetBaseInfo()
        self.leagueInfoModel:UpdateScheduleList(self.settlementData.currScheduleIndex + 1, self.settlementData.score)

        -- 排名是否提升，是否有主场收入、赞助费
        local leaguePreRanking = self.settlementData.leaguePreRanking or 0
        local leagueRanking = baseInfo.leagueRanking or 0
        local newRankNum = leagueRanking + 1
        local rankState = (leaguePreRanking > leagueRanking or leaguePreRanking == -1) and newRankNum ~= 0
        if rankState or (homeMoney > 0) or (sponsorMoney > 0) then
            local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/League/LeagueMatchReward.prefab", "camera", true, true)
            local script = dialogcomp.contentcomp
            script:InitView(self.leagueInfoModel, self.settlementData, function ()
                self:CheckIsShowPlayerReward()
            end)
        else
            self:CheckIsShowPlayerReward()
        end

        clr.coroutine(function ()
            coroutine.yield(WaitForSeconds(0.05))
            NewYearCongratulationsPageCtrl.new(self.settlementData, NewYearOutPutPosType.LEAGUE)
        end)
    else
        self:CheckSeasonIsFinished()
    end
end

--- 是否显示球员获得培养次数奖励
function LeagueCtrl:CheckIsShowPlayerReward()
    local playerRewardData = self.settlementData.freeAdvance
    if playerRewardData ~= nil and #playerRewardData > 0 then
        for i, rewardData in ipairs(playerRewardData) do
            local playerCardModel = SimpleCardModel.new(rewardData.pcid)
            playerCardModel:AddFreeAdvance(rewardData.freeAdvance)
        end

        local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/League/LeaguePlayerReward.prefab", "camera", true, true)
        local script = dialogcomp.contentcomp
        script:InitView(self.settlementData, function ()
            self:CheckSeasonIsFinished()
        end)
    else
        self:CheckSeasonIsFinished()
    end
end

--- 检测赛季是否已结束
function LeagueCtrl:CheckSeasonIsFinished()
    local isEnded = self.leagueInfoModel:GetSeasonIsCanAward()
    if isEnded then
        clr.coroutine(function()
            local response = req.leagueReward()
            if api.success(response) then
                local data = response.val
                self.leagueInfoModel:SetSeasonIsCanAwarded()
                local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/League/LeagueSeasonReward.prefab", "camera", false, true)
                local script = dialogcomp.contentcomp
                self.leagueInfoModel:InitWithSeasonRewardProtocol(data)
                script:InitView(self.leagueInfoModel)
            end
        end)
    end
end

return LeagueCtrl

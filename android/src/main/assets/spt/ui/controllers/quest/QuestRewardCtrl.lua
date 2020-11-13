local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds

local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")
local MatchConstants = require("ui.scene.match.MatchConstants")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local QuestPlotModel = require("ui.models.quest.questPlot.QuestPlotModel")
local QuestPlotManager = require("ui.controllers.quest.questPlot.QuestPlotManager")
local QuestConstants = require("ui.scene.quest.QuestConstants")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local NewYearOutPutPosType = require("ui.scene.activity.content.worldBossActivity.NewYearOutPutPosType")
local NewYearCongratulationsPageCtrl = require("ui.controllers.activity.content.worldBossActivity.NewYearCongratulationsPageCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

local QuestRewardCtrl = class()

function QuestRewardCtrl:ctor(questPageViewModel)
    self.settlementData = nil
    self.isPass = nil
    self.questPageViewModel = questPageViewModel
    self.questInfoModel = questPageViewModel:GetModel()
    self.matchStageId = nil
    self.matchStageIsCleared = nil
    self.playerInfoModel = PlayerInfoModel.new()
    self:Init()
end

function QuestRewardCtrl:Init()
    local matchResultData = cache.getMatchResult()
    if matchResultData == nil then
        return
    end

    -- 比赛的奖励是否已结算过
    if matchResultData.hasSettle == false and matchResultData.matchType == MatchConstants.MatchType.QUEST then
        self.settlementData = matchResultData.settlement
        self.isPass = tonumber(self.settlementData.star) > 0
        self:RegisterEvent()
        self:SettleReward()
        matchResultData.hasSettle = true
        self.matchStageId, self.matchStageIsCleared = self.questPageViewModel:GetMatchStageId()
        -- 比赛关卡现在是否通关
        if self.isPass then
            local isPlotTrigger = self:StartQuestPlot(function() self:ShowQuestRewardView() end)
            if not isPlotTrigger then
                self:ShowQuestRewardView()
            end
            if not self.matchStageIsCleared then
                clr.coroutine(function ()
                    coroutine.yield(WaitForSeconds(0.1))
                    EventSystem.SendEvent("Stage_SetPlayUnlockAnimPreState")
                end)
            end
        else
            self:RemoveEvent()
            self:ShowStagePage()
            -- 如果没有通关则继续引导开始比赛，直到通关
            if GuideManager.GuideIsOnGoing("main") then
                res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/PlayerGuide/GuideReQuestEnter1.prefab")
            end
            clr.coroutine(function ()
                coroutine.yield(WaitForSeconds(0.1))
                NewYearCongratulationsPageCtrl.new(self.settlementData, NewYearOutPutPosType.QUEST)
            end)
        end
    end
end

--- 注册事件
function QuestRewardCtrl:RegisterEvent()
    EventSystem.AddEvent("QuestReward.Destroy", self, self.OnQuestRewardViewDestroy)
    EventSystem.AddEvent("ChapterCleared.Destroy", self, self.OnChapterClearedViewDestroy)
    EventSystem.AddEvent("LevelUpAndFunctionNoticeEnd", self, self.OnLevelUpViewDestroy)

    GuideManager_IsReward = true
end

--- 移除事件
function QuestRewardCtrl:RemoveEvent()
    EventSystem.RemoveEvent("QuestReward.Destroy", self, self.OnQuestRewardViewDestroy)
    EventSystem.RemoveEvent("ChapterCleared.Destroy", self, self.OnChapterClearedViewDestroy)
    EventSystem.RemoveEvent("LevelUpAndFunctionNoticeEnd", self, self.OnLevelUpViewDestroy)

    GuideManager_IsReward = false
end

--- 显示关卡结算面板
function QuestRewardCtrl:ShowQuestRewardView()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Quest/QuestRewards.prefab", "camera", true, true)
    local script = dialogcomp.contentcomp
    local stageInfoModel = self.questInfoModel:GetStageInfoModelById(self.matchStageId)
    script:InitView(self.settlementData, stageInfoModel)

    NewYearCongratulationsPageCtrl.new(self.settlementData, NewYearOutPutPosType.QUEST)
end

--- 当关卡结算面板销毁时
function QuestRewardCtrl:OnQuestRewardViewDestroy()
    -- 比赛关卡之前是否已通关
    if not self.matchStageIsCleared then
        local matchChapterId = self.questInfoModel:GetChapterIdByStageId(self.matchStageId)
        local isChapterCleared = self.questInfoModel:CheckChapterClearedById(matchChapterId)
        -- 当章节通关时，弹出章节通关弹板
        if isChapterCleared then
            self:ShowChapterCleared(matchChapterId)
        else
            self:OnChapterClearedViewDestroy()
        end
    else
        self:ShowStagePage()
        self:OnChapterClearedViewDestroy()
    end
end

--- 当章节通关面板销毁时
function QuestRewardCtrl:OnChapterClearedViewDestroy()
    local isLevelUp = self.playerInfoModel:UnlockLevelUp()
    if not isLevelUp then
        self:OnLevelUpViewDestroy(true)
    end
end

--- 当升级面板销毁时
function QuestRewardCtrl:OnLevelUpViewDestroy(bNotLevelUp)
    self:RemoveEvent()
    if not self.matchStageIsCleared then
        EventSystem.SendEvent("Stage_PlayUnlockAnim", bNotLevelUp)
    else
        GuideManager.LevelGuide()
    end
end

--- 显示章节通关
function QuestRewardCtrl:ShowChapterCleared(matchChapterId)
    luaevt.trig("SDK_Report", "chapter_open", matchChapterId)
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Quest/ChapterCleared.prefab", "camera", true, true)
    local script = dialogcomp.contentcomp
    script:InitView(self.questInfoModel, matchChapterId)
end

-- 开启剧情
function QuestRewardCtrl:StartQuestPlot(completedCallBack)
    local isPlotTrigger = false
    local matchStageId, matchStageIsCleared = self.questPageViewModel:GetMatchStageId()
    local stageInfoModel = self.questInfoModel:GetStageInfoModelById(matchStageId)
    local stageId = stageInfoModel:GetStageId()
    local questPlotModel = QuestPlotModel.new(stageId, QuestConstants.QuestPlotShowPos.MATCH_STAGE_AFTER)
    local questPlotExisted = QuestPlotManager.CheckQuestPlotExisted(questPlotModel)
    if questPlotExisted then
        local plotShowPos = stageInfoModel:GetRead()
        if plotShowPos == QuestConstants.QuestPlotShowPos.MATCH_STAGE_FIRST or plotShowPos == QuestConstants.QuestPlotShowPos.MATCH_STAGE_BEFORE then
            clr.coroutine(function()
                local response = req.questReadStory(stageId, QuestConstants.QuestPlotShowPos.MATCH_STAGE_AFTER)
                if api.success(response) then
                    local data = response.val
                    stageInfoModel:SetRead(data.read)
                end
            end)
            QuestPlotManager.Show(questPlotModel, completedCallBack)
            isPlotTrigger = true
        end
    end
    return isPlotTrigger
end

function QuestRewardCtrl:ShowStagePage()
    local matchStageId, matchStageIsCleared = self.questPageViewModel:GetMatchStageId()
    local stageInfoModel = self.questInfoModel:GetStageInfoModelById(matchStageId)
    EventSystem.SendEvent("StagePage_InitView", stageInfoModel)
end

-- 结算奖励
function QuestRewardCtrl:SettleReward()
    self.playerInfoModel:LockLevelUp()
    self.playerInfoModel:SetStrength(self.settlementData.info.sp)
    if self.isPass == true then
        local rewardUpdateCacheModel = RewardUpdateCacheModel.new()
        rewardUpdateCacheModel:UpdateCache(self.settlementData.reward)
        if self.settlementData.reward.d and tonumber(self.settlementData.reward.d) > 0 then
            CustomEvent.GetDiamond("2", tonumber(self.settlementData.reward.d))
        end
        if self.settlementData.reward.m and tonumber(self.settlementData.reward.m) > 0 then
            CustomEvent.GetMoney("2", tonumber(self.settlementData.reward.m))
        end
    end
end

return QuestRewardCtrl
local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local EventSystems = UnityEngine.EventSystems
local EventSystem = require("EventSystem")
local TASK_TYPE = require("ui.controllers.rewards.TASK_TYPE")
local RewardListModel = require("ui.models.rewards.RewardListModel")
local RewardItemModel = require("ui.models.rewards.RewardItemModel")
local RewardTaskType = require("ui.scene.rewards.RewardTaskType")
local DialogManager = require("ui.control.manager.DialogManager")
local QuestInfoModel = require("ui.models.quest.QuestInfoModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local CardDetailModel = require("ui.models.cardDetail.CardDetailModel")
local CardDetailPageType = require("ui.scene.cardDetail.CardDetailPageType")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local UnlockModel = require("ui.models.common.UnlockModel")
local StartGameConstants = require("ui.scene.startGame.StartGameConstants")
local FriendsMenuType = require("ui.models.friends.MenuType")
local CardBuilder = require("ui.common.card.CardBuilder")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CustomEvent = require("ui.common.CustomEvent")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local RewardListCtrl = class(BaseCtrl, "Rewards")

RewardListCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Rewards/Rewards.prefab"

RewardListCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function RewardListCtrl:GetStatusData()
    return self.currentTaskType
end

function RewardListCtrl:AheadRequest()
    local respone = req.rewardInfo()
    if api.success(respone) then
        local data = respone.val
        self.rewardListModel = RewardListModel.new()
        self.rewardListModel:InitWithProtocol(data)
    end
end

function RewardListCtrl:Init()
    self.currentTaskType = TASK_TYPE.NEW
    self.view.clickTaskType = function(taskType)
        if taskType == self.currentTaskType then return end
        self.currentTaskType = taskType
        self:ShowRewardList(self.rewardListModel:GetToBeShownRewardModelList(taskType), self.currentTaskType)
    end

    self.view.rewardReceivedCallBack = function(rewardID)
        self:InitView(self.currentTaskType)
    end

    self.view.clickReward = function(rewardID)
        self:OnReceiveClick(rewardID)
    end
    
    self.view.onChargeToRewardCallback = function()
        self:RefreshRewardList(self.currentTaskType)
    end
end

function RewardListCtrl:RefreshRewardList(currentTaskType)
    clr.coroutine(function()
        self:AheadRequest()
        self:Refresh(currentTaskType)
    end)
end

function RewardListCtrl:Refresh(currentTaskType)
    self:InitView(currentTaskType)

    if self.rewardListModel:HasRewardCacheSp() then 
        CongratulationsPageCtrl.new({ sp = self.rewardListModel:GetRewardCacheSp()})
        self.rewardListModel:SetRewardCacheSp(0)
    end
end

-- 自动打开的是有红点的那个标签,没有新手任务又没有红点时默认选择主线界面
function RewardListCtrl:HandlePage(newbieBool, mainlineBool, dailyBool, currentTaskType, deaultTaskType)  
    if currentTaskType then 
        return currentTaskType
    elseif newbieBool then 
        return TASK_TYPE.NEW
    elseif dailyBool then
        return TASK_TYPE.DAILY
    elseif mainlineBool then
        return TASK_TYPE.MAIN
    elseif deaultTaskType then 
        return deaultTaskType
    end
    return self.currentTaskType
end

function RewardListCtrl:InitView(currentTaskType)    
    local newbieBool = self.rewardListModel:IsCanGetReward(TASK_TYPE.NEW)
    local mainlineBool = self.rewardListModel:IsCanGetReward(TASK_TYPE.MAIN)
    local dailyBool = self.rewardListModel:IsCanGetReward(TASK_TYPE.DAILY)
    local isShowNewTask = self.rewardListModel:IsShowNewTaskType()

    if isShowNewTask then 
        self.currentTaskType = self:HandlePage(newbieBool, mainlineBool, dailyBool, currentTaskType, TASK_TYPE.NEW) 
    else
        if currentTaskType == TASK_TYPE.NEW then 
            currentTaskType = nil
        end
        self.currentTaskType = self:HandlePage(false, mainlineBool, dailyBool, currentTaskType, TASK_TYPE.DAILY) 
    end
    self.view:RefreshTip(newbieBool, mainlineBool, dailyBool, isShowNewTask)
    self.view:InitView(self.currentTaskType, isShowNewTask)
    self.view:ControlScrollRect()
    self:ShowRewardList(self.rewardListModel:GetToBeShownRewardModelList(self.currentTaskType), self.currentTaskType)
end

function RewardListCtrl:ShowRewardList(rewardModelList, currentTaskType)
    self.view:RefreshView(rewardModelList, currentTaskType)
end

--具体的跳转逻辑如下：
--type=4 登录奖励，无跳转逻辑。
--type=10 通关奖励，跳转至最新进度生涯小关。
--type=11 强化球员奖励，跳转至相应的球员大卡页面。
--type=22 升级球员奖励，跳转至球员管理页面。
--type=23 新手任务，跳转到相应的功能页面。
--2301 生涯首页，2302球员来信首页，2303~2305阵容页面，2307~2309好友页面，2310转会市场页面，2311联赛首页，2312训练基地首页，2313球员管理，2314成就首页，2316~2317无
--2315 跳转到球员管理
function RewardListCtrl:OnReceiveClick(rewardID)
    local rewardItemModel = self.rewardListModel:GetRewardItemModel(rewardID)
    local remainDays = rewardItemModel:GetRemainDays() 
    if remainDays then -- 月卡特殊处理
        local state = rewardItemModel:GetState()
        if state ~= 0 then 
            if rewardItemModel:IsMonthCard() then
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
                return
            else
                res.PushScene("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.GiftBox)
                return
            end
        end
    elseif rewardItemModel:GetState() == -1 and rewardItemModel:IsJumpToAppointTask() then 
        if rewardItemModel:GetType() == RewardTaskType.Clearance then
            local id = rewardItemModel:GetCondition()
            local questInfoModel = QuestInfoModel.new()
            local isOpen = questInfoModel:CheckStageOpenedById(id)
            if isOpen then 
                res.PushScene("ui.controllers.quest.QuestPageCtrl", nil, id)
            else
                DialogManager.ShowToast(lang.trans("quest_stageNotOpened"))
            end
        elseif rewardItemModel:GetType() == RewardTaskType.StrengthenPlayer then
            local condition = rewardItemModel:GetCondition()
            local playerCondition = string.split(condition, "=")
            local cid = playerCondition[1]
            local playerCardsMapModel = PlayerCardsMapModel.new()
            local sameCardList = playerCardsMapModel:GetSameCardList(cid)
            if sameCardList and next(sameCardList) then 
                local pcid, value = next(sameCardList)
                local currentModel = CardBuilder.GetOwnCardModel(pcid)
                res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {pcid}, 1, currentModel)
            else
                DialogManager.ShowToast(lang.trans("not_need_player"))
            end
        elseif rewardItemModel:GetType() == RewardTaskType.LevelUpPlayer then
            res.PushScene("ui.controllers.playerList.PlayerListMainCtrl", nil, nil, nil, nil, true)
        elseif rewardItemModel:GetType() == RewardTaskType.Rookie then
            local playerInfoModel = PlayerInfoModel.new()
            local level = playerInfoModel:GetLevel()
            local unlockModel = UnlockModel.new(level)
            if rewardItemModel:GetRewardID() == 2301 then 
                res.PushScene("ui.controllers.quest.QuestPageCtrl", nil, nil, nil, true)
            elseif rewardItemModel:GetRewardID() == 2302 then 
                res.PushScene("ui.controllers.quest.QuestPageCtrl", nil, nil, nil, true)
            elseif rewardItemModel:GetRewardID() >= 2303 and rewardItemModel:GetRewardID() <= 2305 then
                local playerTeamsModel = require("ui.models.PlayerTeamsModel")
                res.PushScene("ui.controllers.formation.FormationPageCtrl", playerTeamsModel.new())
            elseif rewardItemModel:GetRewardID() >= 2307 and rewardItemModel:GetRewardID() <= 2309 then
                res.PushScene("ui.controllers.friends.FriendsMainCtrl", FriendsMenuType.MESSAGES)
            elseif rewardItemModel:GetRewardID() == 2310 then 
                if unlockModel:GetStateById(StartGameConstants.OtherFunctionConstants.TRANSFER.LIMIT_ID) then
                    res.PushScene("ui.controllers.transferMarket.TransferMarketCtrl", {})
                else
                    DialogManager.ShowToast(lang.trans("unlock_tips", clr.unwrap(lang.trans("transfer")), 5))
                end
            elseif rewardItemModel:GetRewardID() == 2311 then 
                if unlockModel:GetStateById(StartGameConstants.ViewConstants.LEAGUE.LIMIT_ID) then
                    require("ui.controllers.league.LeagueCtrl").new()
                else
                    DialogManager.ShowToast(lang.trans("unlock_tips", clr.unwrap(lang.trans("league")), 8))
                end
            elseif rewardItemModel:GetRewardID() == 2312 then 
                if unlockModel:GetStateById(StartGameConstants.ViewConstants.TRAIN.LIMIT_ID) then
                    res.PushScene("ui.controllers.training.TrainCtrl")
                else
                    DialogManager.ShowToast(lang.trans("unlock_tips", clr.unwrap(lang.trans("training")), 12))
                end
            elseif rewardItemModel:GetRewardID() == 2313 then 
                res.PushScene("ui.controllers.playerList.PlayerListMainCtrl", nil, nil, nil, nil, true)
            elseif rewardItemModel:GetRewardID() == 2315 then 
                self:SwitchToTrainPlayer()
            elseif rewardItemModel:GetRewardID() == 2314 then 
                res.PushScene("ui.controllers.honorPalace.HonorPalaceCtrl")
            else 
                DialogManager.ShowToast(lang.trans("not_jump"))
            end
        end
        return
    end
    if GuideManager.GuideIsOnGoing("main") then
        self.currentEventSystem = EventSystems.EventSystem.current
        self.currentEventSystem.enabled = false
    end
    clr.coroutine(function()
        local respone = req.rewardReceive(rewardID)
        if api.success(respone) then
            local data = respone.val
            if next(data) then
                self.rewardListModel:SetRewardReceiced(rewardID)
                if data.gift then
                    if data.gift.d and tonumber(data.gift.d) > 0 then
                        CustomEvent.GetDiamond("2", tonumber(data.gift.d))
                    end
                    if data.gift.m and tonumber(data.gift.m) > 0 then
                        CustomEvent.GetMoney("4", tonumber(data.gift.m))
                        luaevt.trig("HoolaiBISendCounterRes", "inflow", 5, data.gift.m)
                    end
                    CongratulationsPageCtrl.new(data.gift)
                end
                if GuideManager.GuideIsOnGoing("main") then
                    clr.coroutine(function()
                        unity.waitForNextEndOfFrame()
                        coroutine.yield(WaitForSeconds(0.1))
                        -- 领取奖励
                        --GuideManager.Show(self)
                        self.currentEventSystem.enabled = true
                    end)
                end
            end
        end
    end) 
end

function RewardListCtrl:SwitchToTrainPlayer()
    local playerCardsMapModel = PlayerCardsMapModel.new()
    local cardList = playerCardsMapModel:GetCardList()
    local hasPlayerTrainOpen = false
    local playerPcid, currentModel
    for i, pcid in ipairs(cardList) do
        local cardModel = CardBuilder.GetOwnCardModel(pcid)
        local isTrainOpen = cardModel:IsTrainOpen()
        if isTrainOpen then 
            hasPlayerTrainOpen = true
            playerPcid = pcid
            currentModel = cardModel
            break
        end
    end

    if hasPlayerTrainOpen then
        local cardDetailModel = CardDetailModel.new(currentModel)
        cardDetailModel:SetCurrentPage(CardDetailPageType.TrainPage)
        res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", { playerPcid }, 1, currentModel, cardDetailModel)
    else
        DialogManager.ShowToast(lang.trans("train_task_tip"))
    end
end

return RewardListCtrl

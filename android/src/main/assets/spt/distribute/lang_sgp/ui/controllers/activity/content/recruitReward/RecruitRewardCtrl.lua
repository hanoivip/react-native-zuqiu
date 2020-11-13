local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local Timer = require('ui.common.Timer')
local RewardByRankData = {} --修改
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3

local RecruitRewardCtrl = class()
-- 每个单独活动的ctrl基类
function RecruitRewardCtrl:ctor(activityType, activityId, activityRes, parentRect, activityModel)
    self.activityType = activityType
    self.activityId = activityId
    self.activityRes = activityRes
    self.parentRect = parentRect
    self.activityModel = activityModel
    local contentPrefabRes = activityRes:GetActivityContent(activityType, activityId)
    if contentPrefabRes then 
        self.contentPrefab = Object.Instantiate(contentPrefabRes)
        self.contentPrefab.transform:SetParent(parentRect, false)
    end

    if self.contentPrefab then
    	self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
        self.view.clickRefresh = function() self:OnRefrshClick() end
        self.view.clickReward = function() self:OnRewardClick() end
        self.view.clickRanking = function() self:OnRankingClick() end
        self.view.clickRule = function() self:OnRuleClick() end
        self.view.clickGoToStore = function() self:OnGoToStore() end
    else
        dump("error contentPrefab failure !!!")
    end

    self.residualTimer = nil
    self.beforeActEndTimer = nil
    self.refreshTimeInterval = 5
    self.coolDownInterval = self.refreshTimeInterval
    self.canRefresh = true
    self.isCountingDown = false
    self.isActivityActive = true

    self:InitWithProtocol()
end

function RecruitRewardCtrl:InitWithProtocol()
    self:AheadRequest()
    self.progressDataList = self.recruitRewardModel:GetProgressDataList()
    if not self.progressDataList or not next(self.progressDataList) then
        self:DoIfActDataNotFind()
    else
        self:CreateProgressRewardList()
    end

    local specialCardList = self.recruitRewardModel:GetSpecialGacha()
	if self.view then self.view:InitView(self.activityModel, specialCardList) end
    self:OnRankingClick()
    self:CreateRewardList()
    self:InitActTimeTip()
end

function RecruitRewardCtrl:DoIfActDataNotFind()
    self.view:coroutine(function()
        local tLGachaCountMaxId = self.recruitRewardModel:GetStaticTableMaxId()
        local staticTableName = self.recruitRewardModel:GetStaticTableName()
        local response = req.getNewDataByTableName(staticTableName, tLGachaCountMaxId)
        if api.success(response) then
            local staticTable = self.recruitRewardModel:GetStaticTableData()
            local newData = response.val.jsonUpdate[staticTableName]
            for id, v in pairs(newData) do
                staticTable[id] = v
            end
            self.progressDataList = self.recruitRewardModel:GetProgressDataList()
            self:CreateProgressRewardList()
        end
    end)
end

function RecruitRewardCtrl:AheadRequest()
    if not self.recruitRewardModel then
        self.recruitRewardModel = self.activityModel
        if not self.recruitRewardModel then dump("error: model is nil!!!!") end
        self.recruitRewardModel:InitWithProtocol()
    end
end

function RecruitRewardCtrl:OnGoToStore()
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        local storeCtrl = res.PushScene("ui.controllers.store.StoreCtrl", "gacha", nil, nil, nil, nil, nil, nil, nil, "RecruitRewardActivity")
        GuideManager.Show(storeCtrl)
    end)
end

function  RecruitRewardCtrl:OnRuleClick()
    res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Activties/RecruitReward/HelpBoard.prefab", "camera", true, true)
end

function RecruitRewardCtrl:OnRankingClick()
    self.view:SwitchRankingAndReward(true)
    self:ChangeButtonState(self.view.btnRanking, true)
    self:ChangeButtonState(self.view.btnReward, false)
    self:OnRefrshClick(true)
end

function RecruitRewardCtrl:OnRewardClick()
    self.view:SwitchRankingAndReward(false)
    self:ChangeButtonState(self.view.btnReward, true)
    self:ChangeButtonState(self.view.btnRanking, false)
end

function RecruitRewardCtrl:ChangeButtonState(objSpt, isSelect)
    objSpt:InitView(isSelect)
end

function RecruitRewardCtrl:InitActTimeTip(isCheck)
    local actTime = lang.transstr("recruitReward_activity_desc11")
    self.isActivityActive = self.recruitRewardModel:GetActivityState()
    if self.isActivityActive then
        GameObjectHelper.FastSetActive(self.view.btnGoToStore.gameObject, true)
        GameObjectHelper.FastSetActive(self.view.afterActEndTextObj, false)
        actTime = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.recruitRewardModel:GetStartTime()), 
                            string.convertSecondToMonth(self.recruitRewardModel:GetActivityEndTime()))
        self:CheckActivityEnd()
    else
        self:DoIfActivityEnd()
    end
    self.view.actTimeText.text = actTime
end

function RecruitRewardCtrl:DoIfActivityEnd()
    GameObjectHelper.FastSetActive(self.view.btnGoToStore.gameObject, false)
    GameObjectHelper.FastSetActive(self.view.afterActEndTextObj, true)
    self:CreateProgressRewardList()
end

function RecruitRewardCtrl:CheckActivityEnd()
    if not self.isActivityActive then return end

    local deltaTimeValue = cache.getServerDeltaTimeValue()
    local serverTimeNow = tonumber(os.time()) + tonumber(deltaTimeValue)
    local beforeEndInterval = tonumber(self.recruitRewardModel:GetActivityEndTime()) - serverTimeNow
    if beforeEndInterval <= 0 then
        self.isActivityActive = false
        self:InitActTimeTip()
        return
    end

    if self.beforeActEndTimer ~= nil then self.beforeActEndTimer:Destroy() end
    self.beforeActEndTimer = Timer.new(beforeEndInterval, function(time)
        if time <= 0 then
            self.isActivityActive = false
            self:InitActTimeTip()
        end
    end)
end

function RecruitRewardCtrl:OnRefrshClick(flag)
    if not self.isActivityActive then return end

    if self.canRefresh then
        self.canRefresh = false
        self:CreateRankingList()
        if not self.isCountingDown then
            if self.residualTimer ~= nil then
                self.residualTimer:Destroy()
            end
            self.residualTimer = Timer.new(self.refreshTimeInterval, function(time)
                if time > 0 then
                    self.isCountingDown = true
                    self.coolDownInterval = time
                else
                    self.canRefresh = true
                    self.isCountingDown = false
                end
            end)
        end
    else
        if not flag then
            DialogManager.ShowToast(lang.transstr("recruitReward_activity_desc5", math.ceil(self.coolDownInterval)))
        end
    end
end

function RecruitRewardCtrl:InitMyRankArea(rankingList)
    local playerInfo = cache.getPlayerInfo()
    local rank = lang.transstr("train_rankOut")
    for k, v in pairs(rankingList) do
        if string.find(v.p_s_id, playerInfo._id) then
            rank = k
            break
        end
    end
    self.view.myRank.text = tostring(rank)
    self.view.myScore.text = tostring(self.recruitRewardModel:GetMyScore())
end

function RecruitRewardCtrl:CreateRankingList()
    local currentPhase = self.recruitRewardModel:GetCurrentPhase()
    self.view:coroutine(function()
        local respone = req.recruitRewardRankingList(currentPhase)
        if api.success(respone) then
            local data = respone.val
            if data and type(data) == "table" then
                local rankingList = data
                self.view.rankingListScrollView:InitView(rankingList)
                self:InitMyRankArea(rankingList)
            end
        end
    end)
end

function RecruitRewardCtrl:CreateRewardList()
    self.rewardList = self.recruitRewardModel:GetRewardByRankList()
    self.view.rewardListScrollView:InitView(self.rewardList)
    self.view:SwitchRankingAndReward(true)
end

function RecruitRewardCtrl:CreateProgressRewardList()
    local prefabPath, scrollSptName = self:DetermineProgressItemArea()

    local rTimeRewardState = self.recruitRewardModel:GetRecruitTimeRewardState()
    self.view[scrollSptName].onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate(prefabPath)
        return obj, spt
    end
    self.view[scrollSptName].onScrollResetItem = function(spt, index)
        local recruitTime = tonumber(self.recruitRewardModel:GetRecruitTime())
        local data = self.view[scrollSptName].itemDatas[index]
        if self.isActivityActive then
            if tostring(rTimeRewardState[tostring(data.count)]) == "true" then
                data.status = -1
            elseif data.count <= tonumber(recruitTime) then
                data.status = 0
            else
                data.status = 1
            end
        else
            if data.count <= tonumber(recruitTime) then
                data.status = -1
            else
                data.status = 1
            end
        end
        spt:InitView(data)
        spt.onItemClick = function() self:ClickPregressItem() end

        GameObjectHelper.FastSetActive(spt.rBarBg, true)
        GameObjectHelper.FastSetActive(spt.rBar, true)
        local xScaleDelta = 0
        if recruitTime <= spt.progressNumber then
            xScaleDelta = 0
        elseif recruitTime < spt.nextProgressNumber then
            xScaleDelta = (recruitTime - spt.progressNumber) / (spt.nextProgressNumber - spt.progressNumber)
        else
            xScaleDelta = 1
        end
        if spt.nextProgressNumber == 0 then
            xScaleDelta = 0
            GameObjectHelper.FastSetActive(spt.rBarBg, false)
            GameObjectHelper.FastSetActive(spt.rBar, false)
        end
        spt.rBar.transform.localScale = Vector3(xScaleDelta, 1, 1)
        self.view[scrollSptName]:updateItemIndex(spt, index)
    end
    self:RefreshProgressItemList(scrollSptName)
end

function RecruitRewardCtrl:DetermineProgressItemArea()
    local prefab = ""
    local scrollSptName = nil
    if #self.progressDataList > 3 then
        prefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/RecruitReward/RecruitProgressItem.prefab"
        scrollSptName = "progressRewardSpt"
        GameObjectHelper.FastSetActive(self.view.progressItemArea, true)
        GameObjectHelper.FastSetActive(self.view.progressItemAreaL, false)
    else
        prefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/RecruitReward/RecruitProgressItemL.prefab"
        scrollSptName = "progressRewardLSpt"
        GameObjectHelper.FastSetActive(self.view.progressItemArea, false)
        GameObjectHelper.FastSetActive(self.view.progressItemAreaL, true)
    end
    return prefabPath, scrollSptName
end

function RecruitRewardCtrl:RefreshProgressItemList(scrollSptName)
    self.view[scrollSptName]:refresh(self.progressDataList)
end

function RecruitRewardCtrl:ClickPregressItem()
    res.PushDialog("ui.controllers.activity.content.recruitReward.RecruitProgressRewardCtrl", self.progressDataList, self.recruitRewardModel)
end

function RecruitRewardCtrl:ShowContent(isSelect)
    if self.contentPrefab then 
        GameObjectHelper.FastSetActive(self.contentPrefab, isSelect)
    end
end

function RecruitRewardCtrl:ResetCousume(func)
    -- 更新数据
    clr.coroutine(function()
        local response = req.activityList(nil, nil, true)
        if api.success(response) then
            local data = response.val
            local list = data and data.list
            ActivityListModel.new(ActivityRes.new()):RefreshData(list)
            if type(func) == "function" then
                func()
            end
        end
    end)
end

function RecruitRewardCtrl:OnRefresh()
end

function RecruitRewardCtrl:OnEnterScene()
    self:CheckActivityEnd()
end

function RecruitRewardCtrl:OnExitScene()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    if self.beforeActEndTimer ~= nil then self.beforeActEndTimer:Destroy() end
end

return RecruitRewardCtrl
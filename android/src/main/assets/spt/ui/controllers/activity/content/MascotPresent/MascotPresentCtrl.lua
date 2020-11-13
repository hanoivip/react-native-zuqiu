local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local Timer = require('ui.common.Timer')
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav
local CommonConstants = require("ui.models.activity.mascotPresent.CommonConstants")

local MascotPresentCtrl = class()
-- 每个单独活动的ctrl基类
function MascotPresentCtrl:ctor(activityType, activityId, activityRes, parentRect, activityModel)
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
        self.view = self.contentPrefab:GetComponent(CapsUnityLuaBehav)

        self.view.clickGuildReward = function() self:OnGuildReward() end
        self.view.clickMemberReward = function() self:OnMemberReward() end
        self.view.clickRankingReward = function() self:OnRankingReward() end
        self.view.clickContribute = function() self:OnContribute() end
        self.view.clickRule = function() self:OnRule() end
        self.view.refreshTaskRewardArea = function() self:RefreshTaskRewardArea() end
        self.view.refreshProgressRewardArea = function() self:RefreshProgressRewardArea() end
    else
        dump("error contentPrefab failure !!!")
    end

    self:InitWithProtocol()
end

function MascotPresentCtrl:InitWithProtocol()
    self:InitActivityTimeTip()

    local data = self.activityModel:GetActInfoDataFromListInfo()
    self.activityModel:InitActivityInfoData(data)

    self.view:InitView(self.activityModel)
    self.progressDataList = self.activityModel:GetProgressDataList()
    self:CreateProgressRewardList()

    EventSystem.SendEvent("MascotPresent_UpdateActivityModel", self.activityModel)
end

function  MascotPresentCtrl:OnRule()
    local actType = self.activityModel:GetActivityType() or "TimeLimitMascotPresent"
    local actIntroduceID = 1
    local introduceModel = SimpleIntroduceModel.new()
    introduceModel:InitModel(actIntroduceID, actType)
    introduceModel:SetBoardSize(783, 607)
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", introduceModel)
end

function MascotPresentCtrl:OnGuildReward()
    self:RefreshTaskScrollArea(CommonConstants.GUILD_REWARD_INDEX)
end

function MascotPresentCtrl:OnMemberReward()
    self:RefreshTaskScrollArea(CommonConstants.MEMBER_REWARD_INDEX)
end

function MascotPresentCtrl:OnRankingReward()
    self.view:coroutine(function()
        local period = self.activityModel:GetActivityPeriod()
        local response = req.mascotPresentGuildRankingList(period) 
        if api.success(response) then
            local data = response.val

            self.activityModel:InitGuildRankingData(data) 
            res.PushDialog("ui.controllers.activity.content.MascotPresent.GuildRankingRewardCtrl", self.activityModel)

            self.view:RefreshMyGuildRankText() --更新公会排行
            EventSystem.SendEvent("MascotPresent_RefreshGuildPointAndProgressGiftArea") --更新公会亲密度值和进度礼盒
        end
    end)
end

function MascotPresentCtrl:OnContribute()
    self.view:coroutine(function()
        local period = self.activityModel:GetActivityPeriod()
        local response = req.mascotPresentGuildMemberContribution(period) 
        if api.success(response) then
            local data = response.val
            if not data.rankList or not next(data.rankList) then
                DialogManager.ShowToast(lang.trans("guild_power_no_join_1"))
            else
                self.activityModel:InitGuildMemberContributeRankingData(data) 
                res.PushDialog("ui.controllers.activity.content.MascotPresent.GuildMemberContributeRankingCtrl", self.activityModel)
            end
        end
    end)
end

function MascotPresentCtrl:InitActivityTimeTip(isCheck)
    local residualTime = lang.transstr("mascotPresent_desc1")
    local isActivityActive = self.activityModel:GetActivityState()
    if isActivityActive then
        residualTime = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.activityModel:GetStartTime()), 
                            string.convertSecondToMonth(self.activityModel:GetActivityEndTime()))
        self:CheckActivityEnd()
    else
        self:DoIfActivityEnd()
    end
    self.view.residualTime.text = residualTime
end

function MascotPresentCtrl:DoIfActivityEnd()
    EventSystem.SendEvent("MascotPresent_RefreshTaskRewardArea")
end

function MascotPresentCtrl:CheckActivityEnd()
    local deltaTimeValue = cache.getServerDeltaTimeValue()
    local serverTimeNow = tonumber(os.time()) + tonumber(deltaTimeValue)
    local beforeEndInterval = tonumber(self.activityModel:GetActivityEndTime()) - serverTimeNow
    if beforeEndInterval <= 0 then
        self:InitActivityTimeTip()
        return
    end

    if self.beforeActEndTimer ~= nil then self.beforeActEndTimer:Destroy() end
    self.beforeActEndTimer = Timer.new(beforeEndInterval, function(time)
        if time <= 0 then
            self:InitActivityTimeTip()
        end
    end)
end

function MascotPresentCtrl:RefreshTaskRewardArea()
    self:RefreshTaskScrollArea(CommonConstants.GUILD_REWARD_INDEX, true)
end

function MascotPresentCtrl:RefreshProgressRewardArea()
    if self.activityModel:CheckIfMyGuildPointValueChange() then
        self.activityModel:RefreshMascotPresentGiftBoxStatus()
        self.progressDataList = self.activityModel:GetProgressDataList()  --refresh progress area
        self:CreateProgressRewardList() 
    end
end

function MascotPresentCtrl:RefreshTaskScrollArea(rewardIndex, DonnotChangeView)
    self.view:coroutine(function()
        local period = self.activityModel:GetActivityPeriod()
        local response = req.mascotPresentRefreshTask(period, nil, nil, true)
        if api.success(response) then
            local data = response.val
            if not data or not next(data) then
                dump("server error!!!")
            else
                self.activityModel:RefreshTaskRewardData(data)
                self.view:RefreshRedPoint()
                self.view:InitGuildRewardScroller()
                self.view:InitMemberRewardScroller()

                if not DonnotChangeView then
                    self.view:ShowGuildRewardArea(tonumber(rewardIndex) == tonumber(CommonConstants.GUILD_REWARD_INDEX))
                end
            end
        end
    end)
end

function MascotPresentCtrl:CreateProgressRewardList()
    local prefabPath, scrollSptName = self:SelectProgressItem()

    self.view[scrollSptName].onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate(prefabPath)
        return obj, spt
    end
    self.view[scrollSptName].onScrollResetItem = function(spt, index)
        local progressValue = tonumber(self.activityModel:GetCurrentProgressValue())
        local data = self.view[scrollSptName].itemDatas[index]
        
        spt:InitView(data)
        spt.onItemClick = function() self:ClickPregressItem(data.count) end

        GameObjectHelper.FastSetActive(spt.rBarBg, true)
        GameObjectHelper.FastSetActive(spt.rBar, true)
        local xScaleDelta = 0
        if progressValue <= spt.progressNumber then
            xScaleDelta = 0
        elseif progressValue < spt.nextProgressNumber then
            xScaleDelta = (progressValue - spt.progressNumber) / (spt.nextProgressNumber - spt.progressNumber)
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

function MascotPresentCtrl:SelectProgressItem()
    local prefabPath = ""
    local scrollSptName = nil

    local suffix = #self.progressDataList > 4 and "S" or ""
    suffix = #self.progressDataList == 4 and "" or suffix
    suffix = #self.progressDataList < 4 and "L" or suffix
    prefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/MascotPresent/MPProgressItem" .. suffix .. ".prefab"
    scrollSptName = "progressReward" .. suffix .. "Spt"
    GameObjectHelper.FastSetActive(self.view.progressItemArea, #self.progressDataList == 4)
    GameObjectHelper.FastSetActive(self.view.progressItemAreaL, #self.progressDataList < 4)
    GameObjectHelper.FastSetActive(self.view.progressItemAreaS, #self.progressDataList > 4)
    return prefabPath, scrollSptName
end

function MascotPresentCtrl:RefreshProgressItemList(scrollSptName)
    self.view[scrollSptName]:refresh(self.progressDataList)
end

function MascotPresentCtrl:ClickPregressItem(count)
    self.view:coroutine(function()
        local period = self.activityModel:GetActivityPeriod()
        local response = req.mascotPresentGiftBoxInfo(period, count, nil, nil, true) 
        if api.success(response) then
            local data = response.val
            if not data.score or not data.data or not next(data.data) then
                DialogManager.ShowToast(lang.trans("guild_power_no_join_1"))
            else
                self.activityModel:InitMascotPresentGiftBoxData(data, count)
                res.PushDialog("ui.controllers.activity.content.MascotPresent.MascotPresentGiftCtrl", self.activityModel)

                EventSystem.SendEvent("MascotPresent_RefreshGuildPointAndProgressGiftArea") 
            end
        end
    end)
end

function MascotPresentCtrl:ShowContent(isSelect)
    if self.contentPrefab then 
        GameObjectHelper.FastSetActive(self.contentPrefab, isSelect)
    end
end

function MascotPresentCtrl:OnRefresh()
end

function MascotPresentCtrl:OnEnterScene()
    EventSystem.SendEvent("MascotPresent_RefreshTaskRewardArea")
    self:CheckActivityEnd()
end

function MascotPresentCtrl:OnExitScene()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    if self.beforeActEndTimer ~= nil then
        self.beforeActEndTimer:Destroy()
    end
end

return MascotPresentCtrl

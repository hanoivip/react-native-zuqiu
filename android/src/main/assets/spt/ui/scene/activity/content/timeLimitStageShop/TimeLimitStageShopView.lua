local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local EventSystems = UnityEngine.EventSystems
local Timer = require("ui.common.Timer")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")

local TimeLimitStageShopView = class(ActivityParentView)

function TimeLimitStageShopView:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.timeTxt = self.___ex.timeTxt
    self.activityDesTxt = self.___ex.activityDesTxt
    self.helpBtn = self.___ex.helpBtn
    self.btnGroupSpt = self.___ex.btnGroupSpt
    self.tabContentTrans = self.___ex.tabContentTrans
    self.taskBtn = self.___ex.taskBtn
    self.cardCountTxt = self.___ex.cardCountTxt
    self.boxAreaAnim = self.___ex.boxAreaAnim
    self.remainTxt = self.___ex.remainTxt
    self.tips1Txt = self.___ex.tips1Txt
    self.tips2Txt = self.___ex.tips2Txt
    self.openOneBoxBtn = self.___ex.openOneBoxBtn
    self.openOneBoxTxt = self.___ex.openOneBoxTxt
    self.openOneBoxCountTxt = self.___ex.openOneBoxCountTxt
    self.openFiveBoxBtn = self.___ex.openFiveBoxBtn
    self.openFiveBoxTxt = self.___ex.openFiveBoxTxt
    self.openFiveBoxCountTxt = self.___ex.openFiveBoxCountTxt
    self.redPointGo = self.___ex.redPointGo
    self.timeLastTxt = self.___ex.timeLastTxt
--------End_Auto_Generate----------
    self.rewardItem = self.___ex.rewardItem
end

function TimeLimitStageShopView:start()
    self.helpBtn:regOnButtonClick(function()
        self:OnHelpBtnClick()
    end)
    self.taskBtn:regOnButtonClick(function()
        self:OnTaskBtnClick()
    end)
    self.openOneBoxBtn:regOnButtonClick(function()
        self:OpenOneBoxBtnClick()
    end)
    self.openFiveBoxBtn:regOnButtonClick(function()
        self:OpenFiveBoxBtnClick()
    end)
    self.currentEventSystem = EventSystems.EventSystem.current
end

function TimeLimitStageShopView:InitView(timeLimitLadderStoreModel)
    self.model = timeLimitLadderStoreModel
    self:InitTab()
    self:RefreshTimer()
    self:IsShowStageShopTaskRedPoint()
    local ticketCnt = self.model:GetTicketCnt()
    self:RefreshKey(ticketCnt)
end

function TimeLimitStageShopView:OnRefresh(timeLimitLadderStoreModel)
    self:IsShowStageShopTaskRedPoint()
end

function TimeLimitStageShopView:RefreshKey(keyCount)
    self.cardCountTxt.text = "x" .. keyCount
end

function TimeLimitStageShopView:InitTab()
    self.tabList = {}
    if not self.btnGroupSpt.menu then
        self.btnGroupSpt.menu = {}
    end
    local resPrefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitStageShop/TimeLimitStageShopTabItem.prefab")
    local storeData = self.model:GetStoreData()
    for i, v in ipairs(storeData) do
        if not self.btnGroupSpt.menu[i] then
            local obj = Object.Instantiate(resPrefab)
            obj.transform:SetParent(self.tabContentTrans, false)
            local objScript = obj:GetComponent("CapsUnityLuaBehav")
            self.tabList[i] = objScript
            self.btnGroupSpt.menu[i] = objScript
        end
        self.btnGroupSpt:BindMenuItem(i, function() self:OnTabClick(i) end)
        self.btnGroupSpt.menu[i]:InitView(v)
    end
    local defaultStoreType = self.model:GetDefaultStoreType()
    self.btnGroupSpt:selectMenuItem(defaultStoreType)
    self:OnTabClick(defaultStoreType)
end

function TimeLimitStageShopView:OnTabClick(tag)
    self.model:SetCurStoreType(tag)
    self:InitReward()

    local storeTicketCount = self.model:GetStoreTicketCount()
    local storeOpenTip = self.model:GetStoreOpenTip()
    local isOpen = self.model:GetStoreIsOpen(tag)
    local maxBuyCount = self.model:GetMaxBuyCount()

    if isOpen then
        self.tips1Txt.text = storeOpenTip
    else
        self.tips2Txt.text = storeOpenTip
    end

    if isOpen and maxBuyCount <= 0 then
        GameObjectHelper.FastSetActive(self.openOneBoxBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.openFiveBoxBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.tips1Txt.gameObject, false)
        GameObjectHelper.FastSetActive(self.tips2Txt.gameObject, true)
        self.tips2Txt.text = lang.trans("stage_shop_out_content")
    else
        self.openOneBoxCountTxt.text = "x" .. storeTicketCount
        self.openFiveBoxCountTxt.text = "x" .. storeTicketCount * maxBuyCount
        self.openOneBoxTxt.text = lang.trans("stage_shop_open", 1)
        self.openFiveBoxTxt.text = lang.trans("stage_shop_open", maxBuyCount)
        self.openFiveBoxCountTxt.text = "x" .. storeTicketCount * maxBuyCount
        GameObjectHelper.FastSetActive(self.openOneBoxBtn.gameObject, isOpen)
        GameObjectHelper.FastSetActive(self.openFiveBoxBtn.gameObject, isOpen)
        GameObjectHelper.FastSetActive(self.tips1Txt.gameObject, isOpen)
        GameObjectHelper.FastSetActive(self.tips2Txt.gameObject, not isOpen)
    end
end

function TimeLimitStageShopView:InitReward()
    local rewardData = self.model:GetRewardData()
    for i, v in ipairs(rewardData) do
        local index = tostring(i)
        local objScript = self.rewardItem[index]
        objScript:InitView(v)
    end
end

function TimeLimitStageShopView:AnimStart()
    self.currentEventSystem.enabled = false
    for i, v in pairs(self.rewardItem) do
        GameObjectHelper.FastSetActive(v.selectGo, true)
    end
    self.boxAreaAnim:Play("StageShopEnter")
end

function TimeLimitStageShopView:AnimReward(itemIds)
    self.boxAreaAnim:Play("Default")
    for i, v in pairs(self.rewardItem) do
        GameObjectHelper.FastSetActive(v.selectGo, false)
    end
    local idsKV = {}
    for i, v in ipairs(itemIds) do
        idsKV[v] = true
    end
    local rewardData = self.model:GetRewardData()
    for i, v in ipairs(rewardData) do
        local rewardID = v.rewardID
        if idsKV[rewardID] then
            local index = tostring(i)
            local objScript = self.rewardItem[index]
            GameObjectHelper.FastSetActive(objScript.selectGo, true)
            return
        end
    end
end

function TimeLimitStageShopView:AnimEnd()
    for i, v in pairs(self.rewardItem) do
        GameObjectHelper.FastSetActive(v.selectGo, false)
    end
end

-- 玩法说明
function TimeLimitStageShopView:OnHelpBtnClick()
    local simpleIntroduceModel = SimpleIntroduceModel.new()
    simpleIntroduceModel:InitModel(16, "TimeLimitStageShop")
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

-- 任务
function TimeLimitStageShopView:OnTaskBtnClick()
    if self.onTaskClick then
        self.onTaskClick()
    end
end

-- 买一次
function TimeLimitStageShopView:OpenOneBoxBtnClick()
    if self.onOpenOneBoxClick then
        self.onOpenOneBoxClick()
    end
end

-- 买五次
function TimeLimitStageShopView:OpenFiveBoxBtnClick()
    if self.onOpenFiveBoxClick then
        self.onOpenFiveBoxClick()
    end
end

-- 任务红点
function TimeLimitStageShopView:IsShowStageShopTaskRedPoint()
    local stageShopTask = ReqEventModel.GetInfo("stageShopTask")
    GameObjectHelper.FastSetActive(self.redPointGo, tonumber(stageShopTask) > 0)
end

function TimeLimitStageShopView:ResetTimer()
    if self.model:GetRemainTime() > 0 then
        self:RefreshTimer()
    else
        self:SetRunOutOfTimeView()
    end
end

function TimeLimitStageShopView:RefreshTimer()
    local lastTime = self.model:GetLastTime()
    self.timeLastTxt.text = lastTime
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    local remainTime = self.model:GetRemainTime()
    local timeTitleStr = lang.transstr("residual_time")
    self.residualTimer = Timer.new(remainTime, function(time)
        if time <= 1 then
            self:SetRunOutOfTimeView()
            return
        else
            self.timeTxt.text = timeTitleStr .. string.convertSecondToTime(time)
        end
    end)
end

function TimeLimitStageShopView:SetRunOutOfTimeView()
    self.timeTxt.text = lang.trans("visit_endInfo")
    if self.runOutOfTime then
        self.runOutOfTime()
    end
end

function TimeLimitStageShopView:OnEnterScene()
    TimeLimitStageShopView.super.OnEnterScene(self)
    EventSystem.AddEvent("ReqEventModel_stageShopTask", self, self.IsShowStageShopTaskRedPoint)
end

function TimeLimitStageShopView:OnExitScene()
    TimeLimitStageShopView.super.OnExitScene(self)
    EventSystem.RemoveEvent("ReqEventModel_stageShopTask", self, self.IsShowStageShopTaskRedPoint)
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return TimeLimitStageShopView

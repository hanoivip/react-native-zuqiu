local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Timer = require('ui.common.Timer')
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local EventSystem = require("EventSystem")
local PlayerTreasureView = class(ActivityParentView)


function PlayerTreasureView:ctor()
    self.boxAreaTrans = self.___ex.boxAreaTrans
    self.activityDesTxt = self.___ex.activityDesTxt
    self.residualTimeTxt = self.___ex.residualTimeTxt
    self.buyKeyBtn = self.___ex.buyKeyBtn
    self.nowKeyCountTxt = self.___ex.nowKeyCountTxt
    self.countContentTrans = self.___ex.countContentTrans
    self.nowCountTxt = self.___ex.nowCountTxt
    self.rewardContentTrans = self.___ex.rewardContentTrans
    self.helpBtn = self.___ex.helpBtn
    self.detailBtn = self.___ex.detailBtn
    self.refreshNextBtn = self.___ex.refreshNextBtn
    self.openTreasureTaskBtn = self.___ex.openTreasureTaskBtn
    self.refreshPriceTxt = self.___ex.refreshPriceTxt
    self.needOpenCountTxt = self.___ex.needOpenCountTxt
    self.openAllBoxBtn = self.___ex.openAllBoxBtn
    self.taskRedPointGo = self.___ex.taskRedPointGo
    self.tipsTxt = self.___ex.tipsTxt
    self.rewardScroll = self.___ex.rewardScroll
    self.residualTimer = nil
end

function PlayerTreasureView:start()
    self.buyKeyBtn:regOnButtonClick(function()
        self:OnBuyKeyClick()
    end)
    self.helpBtn:regOnButtonClick(function()
        self:OnHelpClick()
    end)
    self.detailBtn:regOnButtonClick(function()
        self:OnDetailClick()
    end)
    self.refreshNextBtn:regOnButtonClick(function()
        self:OnRefreshNextClick()
    end)
    self.openTreasureTaskBtn:regOnButtonClick(function()
        self:OnOpenTreasureTaskClick()
    end)
    self.openAllBoxBtn:regOnButtonClick(function()
        self:OnOpenAllBoxClick()
    end)
    EventSystem.AddEvent("BuyPlayerTreasureKey", self, self.RefreshKeyCount)
    EventSystem.AddEvent("BuyPlayerOpenBox", self, self.RefreshBuyCount)
    EventSystem.AddEvent("PlayerOpenCountBox", self, self.InitLeftArea)
    EventSystem.AddEvent("PlayerRefreshRedPointState", self, self.RefreshTaskRedPoint)
end

function PlayerTreasureView:InitView(activityModel, isRefresh)
    self.activityModel = activityModel
    self:InitLeftArea()
    self:InitMiddleArea(isRefresh)
    self:InitRightArea()
    self:InitUpArea()
    if self.isActivityEnd then
        self:ShowActivityEnd()
        return
    end
end

function PlayerTreasureView:InitLeftArea()
    local countList = self.activityModel:GetCountList()
    if not self.countViewList or #self.countViewList ~= #countList then
        res.ClearChildren(self.countContentTrans)
        self.countViewList = {}
        local countPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerTreasure/PlayerTreasureCountItem.prefab"
        for i,v in ipairs(countList) do
            local countObj, countSpt = res.Instantiate(countPath)
            countObj.transform:SetParent(self.countContentTrans, false)
            table.insert(self.countViewList, countSpt)
        end
    end
    for i,v in ipairs(self.countViewList) do
        v:InitView(countList[i], function() self:OnCountAreaClick() end)
    end
    self:RefreshBuyCount()
end

function PlayerTreasureView:InitMiddleArea(isRefresh)
    local maxBoxCount = self.activityModel:GetMaxBoxCount()
    if not self.boxViewList or #self.boxViewList ~= maxBoxCount then
        res.ClearChildren(self.boxAreaTrans)
        self.boxViewList = {}
        local boxPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerTreasure/PlayerTreasureBoxItem.prefab"
        for i = 1, maxBoxCount do
            local boxObj, boxSpt = res.Instantiate(boxPath)
            boxObj.transform:SetParent(self.boxAreaTrans, false)
            table.insert(self.boxViewList, boxSpt)
        end
    end
    if not isRefresh then
        for i,v in ipairs(self.boxViewList) do
            local state = self.activityModel:GetBoxState(i)
            v:InitView(i, state, self.clickBoxCallBack)
        end
    end
    local needOpenCount = self.activityModel:GetNeedOpenCount()
    self.needOpenCountTxt.text = "x" .. needOpenCount
    self.tipsTxt.text = lang.trans("player_treasure_key_tips", needOpenCount, 3)
    self:RefreshKeyCount()
    local taskRedPointState = self.activityModel:GetTaskRedPointState()
    self:RefreshTaskRedPoint(taskRedPointState)
end

function PlayerTreasureView:InitRightArea()
    local treasureList = self.activityModel:GetTreasureList()
    treasurePath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerTreasure/TreasureItem.prefab"
    res.ClearChildren(self.rewardContentTrans)
    for i,v in ipairs(treasureList) do
        local treasureObj, treasureSpt = res.Instantiate(treasurePath)
        treasureObj.transform:SetParent(self.rewardContentTrans, false)
        treasureSpt:InitView(v)
    end
    local refreshPrice = self.activityModel:GetRefreshPrice()
    self.refreshPriceTxt.text = "x" .. refreshPrice
end

function PlayerTreasureView:InitUpArea()
    local remainTime = self.activityModel:GetRemainTime()
    self:RefreshTime(remainTime)
end

function PlayerTreasureView:OnBuyKeyClick()
    if self.isActivityEnd then
        self:ShowActivityEnd()
        return
    end
    if self.clickbuyKey then
        self.clickbuyKey()
    end
end

function PlayerTreasureView:OnHelpClick()
    if self.clickHelp then
        self.clickHelp()
    end
end

function PlayerTreasureView:OnDetailClick()
    if self.clickDetail then
        self.clickDetail()
    end
end

function PlayerTreasureView:OnRefreshNextClick()
    if self.isActivityEnd then
        self:ShowActivityEnd()
        return
    end
    if self.clickRefreshNext then
        self.clickRefreshNext()
    end
end

function PlayerTreasureView:OnOpenTreasureTaskClick()
    if self.isActivityEnd then
        self:ShowActivityEnd()
        return
    end
    if self.clickOpenTreasureTask then
        self.clickOpenTreasureTask()
    end
end

function PlayerTreasureView:OnOpenAllBoxClick()
    if self.isActivityEnd then
        self:ShowActivityEnd()
        return
    end
    if self.clickOpenAllBox then
        self.clickOpenAllBox()
    end
end

function PlayerTreasureView:OnCountAreaClick()
    if self.isActivityEnd then
        self:ShowActivityEnd("player_treasure_end")
        return
    end
    res.PushDialog("ui.controllers.activity.content.playerTreasure.PlayerTreasureCountRewardCtrl", self.activityModel)
end

function PlayerTreasureView:RefreshKeyCount(count)
    if type(count) == "number" then
        self.activityModel:SetKeysCount(count)
    end
    local keyCount = self.activityModel:GetKeysCount()
    self.nowKeyCountTxt.text = tostring(keyCount)
end

function PlayerTreasureView:RefreshTaskRedPoint(taskRedPointState)
    self.activityModel:SetTaskRedPointState(taskRedPointState)
    GameObjectHelper.FastSetActive(self.taskRedPointGo, taskRedPointState)
end

function PlayerTreasureView:RefreshBuyCount()
    local nowCount = self.activityModel:GetBoxOpenCount()
    self.nowCountTxt.text = lang.trans("player_treasure_count", nowCount)
end

function PlayerTreasureView:RefreshTime(remainTime)
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    if remainTime < 1.5 then
        self.isActivityEnd = true
        self.residualTimeTxt.text = lang.trans("recruitReward_activity_desc11")
    end
    self.residualTimer = Timer.new(remainTime, function(time)
        if time > 1.5 then
            self.residualTimeTxt.text = lang.transstr("residual_time") .. string.convertSecondToTime(time)
            self.isActivityEnd = false
        else
            self.residualTimeTxt.text = lang.trans("recruitReward_activity_desc11")
            self.isActivityEnd = true
        end
    end)
end

function PlayerTreasureView:onDestroy()
    EventSystem.RemoveEvent("BuyPlayerTreasureKey", self, self.RefreshKeyCount)
    EventSystem.RemoveEvent("BuyPlayerOpenBox", self, self.RefreshBuyCount)
    EventSystem.RemoveEvent("PlayerOpenCountBox", self, self.InitLeftArea)
    EventSystem.RemoveEvent("PlayerRefreshRedPointState", self, self.RefreshTaskRedPoint)
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

function PlayerTreasureView:ShowActivityEnd(transKey)
    local tempTransKey = transKey
    if not tempTransKey then
        tempTransKey = "time_limit_growthPlan_desc5"
    end
    DialogManager.ShowToast(lang.trans(tempTransKey))
end

return PlayerTreasureView
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local EventSystems = UnityEngine.EventSystems

local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local TweenExtensions = Tweening.TweenExtensions

local Timer = require("ui.common.Timer")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local TimeLimitPowerShootView = class(ActivityParentView)

-- 射门时球移动的时间
local Move_Time = 1
-- 射门时球=缩放的时间
local Scale_Time = 1.3
-- 击中时的特效时间
local Effect_Time = 1.6

function TimeLimitPowerShootView:ctor()
--------Start_Auto_Generate--------
    self.helpBtn = self.___ex.helpBtn
    self.rewardViewBtn = self.___ex.rewardViewBtn
    self.refreshBtn = self.___ex.refreshBtn
    self.refreshPriceTxt = self.___ex.refreshPriceTxt
    self.rewardTrans = self.___ex.rewardTrans
    self.buyBtn = self.___ex.buyBtn
    self.buyCountPrice1Txt = self.___ex.buyCountPrice1Txt
    self.ballTrans = self.___ex.ballTrans
    self.shootBtn = self.___ex.shootBtn
    self.ballBtn = self.___ex.ballBtn
    self.priceTipBtn = self.___ex.priceTipBtn
    self.buyCountPrice2Txt = self.___ex.buyCountPrice2Txt
    self.timeTxt = self.___ex.timeTxt
    self.titleTxt = self.___ex.titleTxt
    self.activityDesTxt = self.___ex.activityDesTxt
--------End_Auto_Generate----------

    -- 缓存门框里面的卡牌
    self.boxSpt = {}
    self.powerShootItemPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitPowerShoot/PowerShootItem.prefab"
end

function TimeLimitPowerShootView:start()
    self.shootBtn:regOnButtonClick(function()
        self:OnShootBtnClick()
    end)
    self.refreshBtn:regOnButtonClick(function()
        self:OnRefreshBtnClick()
    end)
    self.rewardViewBtn:regOnButtonClick(function()
        self:OnRewardViewBtnClick()
    end)
    self.helpBtn:regOnButtonClick(function()
        self:OnHelpBtnClick()
    end)
    self.priceTipBtn:regOnButtonClick(function()
        self:OnPriceTipBtnClick()
    end)
    self.originPos = self.ballTrans.position
    self.currentEventSystem = EventSystems.EventSystem.current
end

function TimeLimitPowerShootView:InitView(timeLimitPowerShootModel)
    self.timeLimitPowerShootModel = timeLimitPowerShootModel
    self:InitBoxContent()
    self:RefreshContent()
end

-- Instantiate门框里面的卡片
function TimeLimitPowerShootView:InitBoxContent()
    res.ClearChildren(self.rewardTrans)
    local tempObj  -- 减少调用 res.Instantiate
    local contents = self.timeLimitPowerShootModel:GetContents()
    for i, v in ipairs(contents) do
        local tObj
        if not tempObj then
            tempObj = res.Instantiate(self.powerShootItemPath)
            tObj = tempObj
        else
            tObj = Object.Instantiate(tempObj)
        end
        tObj.transform:SetParent(self.rewardTrans, false)
        local spt = tObj:GetComponent(clr.CapsUnityLuaBehav)
        spt.onShoot = function()
            self:OnItemShoot(spt)
        end
        spt:InitView(v)
        self.boxSpt[i] = spt
    end
    GameObjectHelper.FastSetActive(self.tempObj, false)
end

function TimeLimitPowerShootView:RefreshContent()
    local shootFlag = self.timeLimitPowerShootModel:GetShootFlag()
    local purchasePrice = self.timeLimitPowerShootModel:GetCountPrice()
    local refreshPrice = self.timeLimitPowerShootModel:GetRefreshPrice()
    local title = self.timeLimitPowerShootModel:GetTitle()
    local desc = self.timeLimitPowerShootModel:GetDesc()
    GameObjectHelper.FastSetActive(self.shootBtn.gameObject, shootFlag == 0)
    GameObjectHelper.FastSetActive(self.ballBtn.gameObject, shootFlag == 1)

    self.refreshPriceTxt.text = "x" .. refreshPrice
    self.buyCountPrice1Txt.text = "x" .. purchasePrice
    self.buyCountPrice2Txt.text = "x" .. purchasePrice
    self.titleTxt.text = title
    self.activityDesTxt.text = desc
    self:ResetTimer()
end

-- 点击门框里面的卡片
function TimeLimitPowerShootView:OnItemShoot(spt)
    if self.onShoot then
        self.onShoot(spt)
    end
end

-- 刷新
function TimeLimitPowerShootView:OnRefreshBtnClick()
    if self.onRefresh then
        self.onRefresh()
    end
end

-- 射门动画
function TimeLimitPowerShootView:ShootAnim(spt, rewardContent)
    if self.tweener and TweenExtensions.IsPlaying(self.tweener) then
        TweenExtensions.Kill(self.tweener)
    end
    if self.tweenerScale and TweenExtensions.IsPlaying(self.tweenerScale) then
        TweenExtensions.Kill(self.tweenerScale)
    end
    GameObjectHelper.FastSetActive(self.ballTrans.gameObject, true)
    GameObjectHelper.FastSetActive(self.ballBtn.gameObject, false)
    self.ballTrans.localScale = Vector3(1, 1, 1)
    self.ballTrans.position = self.originPos
    local targetPos = spt.transform.position
    self.tweener = ShortcutExtensions.DOMove(self.ballTrans, targetPos, Move_Time, false)
    self.tweenerScale = ShortcutExtensions.DOScale(self.ballTrans, Vector3(0.3, 0.3, 0.3), Scale_Time, false)
    TweenSettingsExtensions.OnComplete(self.tweenerScale, function ()  --Lua assist checked flag
        GameObjectHelper.FastSetActive(self.ballTrans.gameObject, false)
        GameObjectHelper.FastSetActive(self.ballBtn.gameObject, true)
        self.ballTrans.position = self.originPos
        spt:ShowEffect()
    end)
    self:coroutine(function()
        coroutine.yield(UnityEngine.WaitForSeconds(Scale_Time + Effect_Time))
        CongratulationsPageCtrl.new(rewardContent)
        if self.powerShootResetCousume then
            self.powerShootResetCousume(function() self:RefreshContent() end)
        end
        self.currentEventSystem.enabled = true
    end)
end

-- 开始射门按钮
function TimeLimitPowerShootView:OnShootBtnClick()
    if self.startShootClick then
        self.startShootClick()
    end
end

-- 奖励预览
function TimeLimitPowerShootView:OnRewardViewBtnClick()
    local rewardBonds = self.timeLimitPowerShootModel:GetRewardBonds()
    res.PushDialog("ui.controllers.activity.content.timeLimitPowerShoot.PowerShootDetailCtrl", rewardBonds)
end

-- 玩法说明
function TimeLimitPowerShootView:OnHelpBtnClick()
    local simpleIntroduceModel = SimpleIntroduceModel.new()
    simpleIntroduceModel:InitModel(11, "TimeLimitPowerShoot")
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

-- 价格说明
function TimeLimitPowerShootView:OnPriceTipBtnClick()
    local priceTipStr = self.timeLimitPowerShootModel:GetPriceTips()
    DialogManager.ShowAlertPop(lang.trans("tips"), priceTipStr)
end

-- 开始射门后所有卡牌的翻转动画
function TimeLimitPowerShootView:ShootStartAnim()
    for i, v in ipairs(self.boxSpt) do
        v:ChangeSate(false, true)
    end
    GameObjectHelper.FastSetActive(self.shootBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.ballBtn.gameObject, true)
end

-- 刷新卡牌的动画
function TimeLimitPowerShootView:ShootRefreshAnim()
    for i, v in ipairs(self.boxSpt) do
        local contentData = self.timeLimitPowerShootModel:GetContentData(i)
        v:RefreshItemContent(contentData.contents)
        v:ChangeSate(true, true)
    end
    GameObjectHelper.FastSetActive(self.shootBtn.gameObject, true)
    GameObjectHelper.FastSetActive(self.ballBtn.gameObject, false)
end

function TimeLimitPowerShootView:ResetTimer()
    if self.timeLimitPowerShootModel:GetRemainTime() > 0 then
        self:RefreshTimer()
    else
        self:SetRunOutOfTimeView()
    end
end

function TimeLimitPowerShootView:RefreshTimer()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    local remainTime = self.timeLimitPowerShootModel:GetRemainTime()
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

function TimeLimitPowerShootView:SetRunOutOfTimeView()
    self.timeTxt.text = lang.trans("visit_endInfo")
    if self.runOutOfTime then
        self.runOutOfTime()
    end
end

function TimeLimitPowerShootView:OnEnterScene()
    TimeLimitPowerShootView.super.OnEnterScene(self)
    self:ResetTimer()
end

function TimeLimitPowerShootView:OnExitScene()
    TimeLimitPowerShootView.super.OnExitScene(self)
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return TimeLimitPowerShootView

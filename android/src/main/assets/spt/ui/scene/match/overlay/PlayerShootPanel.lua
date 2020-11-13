local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Time = UnityEngine.Time
local WaitForSeconds = UnityEngine.WaitForSeconds
local Vector3 = UnityEngine.Vector3
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease

local MatchInfoModel = require("ui.models.MatchInfoModel")
local MatchConstants = require("ui.scene.match.MatchConstants")
local AudienceAudioConstants = require("ui.scene.match.AudienceAudioConstants")
local UISoundManager = require("ui.control.manager.UISoundManager")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local PlayerShootPanel = class(unity.base)

function PlayerShootPanel:ctor()
    -- 比赛菜单管理器
    self.fightMenuManager = self.___ex.fightMenuManager
    -- 球员名称
    self.playerName = self.___ex.playerName
    -- 正常射门成功率
    self.normalRateNum = self.___ex.normalRateNum
    -- 增加后的射门成功率
    self.increaseRateNum = self.___ex.increaseRateNum
    -- 减少后的射门成功率
    self.reduceRateNum = self.___ex.reduceRateNum
    -- 相对成功率框
    self.relativeRateBox = self.___ex.relativeRateBox
    -- 相对增加成功率
    self.relativeIncreaseRateNum = self.___ex.relativeIncreaseRateNum
    -- 相对减少成功率
    self.relativeReduceRateNum = self.___ex.relativeReduceRateNum
    -- 时间标尺
    self.timeRuler = self.___ex.timeRuler
    -- 剩余时间
    self.countdownTime = self.___ex.countdownTime
    -- 拖尾特效
    self.trailEffect = self.___ex.trailEffect
    -- 发光特效
    self.glowEffect = self.___ex.glowEffect
    self.fingerTest = self.___ex.fingerTest
    -- 倒计时动画播放器
    self.countdownAnimator = self.___ex.countdownAnimator
    -- 倒计时动画文本
    self.countdownEffectTime1 = self.___ex.countdownEffectTime1
    self.countdownEffectTime2 = self.___ex.countdownEffectTime2
    self.homeTeamLogoBox = self.___ex.homeTeamLogoBox
    self.homeTeamLogo = self.___ex.homeTeamLogo
    self.awayTeamLogoBox = self.___ex.awayTeamLogoBox
    self.awayTeamLogo = self.___ex.awayTeamLogo
    -- 射门能力数值
    self.shootNum = self.___ex.shootNum
    -- 增加成功率框
    self.increaseRateBox = self.___ex.increaseRateBox
    -- 减少成功率框
    self.reduceRateBox = self.___ex.reduceRateBox
    -- 倒计时持续时间
    self.countdownDuration = nil
    -- 倒计时起始时间
    self.countdownStartTime = nil
    -- 倒计时终止时间
    self.countdownEndTime = nil
    -- 是否是玩家操作射门
    self.isManualShoot = false
    -- 当前的时间缩放
    self.nowTimeScale = nil
    -- 比赛信息模型
    self.matchInfoModel = nil
    -- 玩家队伍数据
    self.playerTeamData = nil
    -- 对手队伍数据
    self.opponentTeamData = nil
    -- 慢动作的timeScale
    self.slowdownTimeScale = 0.0125
    -- 停止的timeScale
    self.stopTimeScale = 0.000001
    self.stopTimeScaleUpperLimit = 0.00001
    -- 是否开始倒计时
    self.isStartCountdown = false
    -- 是否显示倒计时
    self.isShowCountdown = true
    -- 当前成功率
    self.nowSuccessRate = nil
    -- 旧的成功率
    self.oldSuccessRate = nil
    -- 倒计时结束后的回调
    self.countdownEndedCallback = nil
    -- 当前剩余秒数
    self.nowLastSecond = nil
    -- 相对成功率
    self.relativeSuccessRate = nil
end

function PlayerShootPanel:awake()
    self.matchInfoModel = MatchInfoModel.GetInstance()
    self.playerTeamData = self.matchInfoModel:GetPlayerTeamData()
    self.opponentTeamData = self.matchInfoModel:GetOpponentTeamData()
    TeamLogoCtrl.BuildTeamLogo(self.homeTeamLogo, self.playerTeamData.logo)
    TeamLogoCtrl.BuildTeamLogo(self.awayTeamLogo, self.opponentTeamData.logo)
end

function PlayerShootPanel:InitPlayerShootInfo(athleteData, playerPower, successRate, countdownDuration, isManualShoot)
    self.playerName.text = athleteData.name
    self.shootNum.text = lang.transstr("shoot") .. ": " .. athleteData.abilities.shoot
    self.nowSuccessRate = successRate
    self.countdownDuration = countdownDuration
    self.countdownStartTime = Time.unscaledTime
    self.countdownEndTime = self.countdownStartTime + self.countdownDuration
    self.isManualShoot = isManualShoot
    self.nowTimeScale = Time.timeScale
    local touchShootProgressBar = tobool(___demoManager and ___demoManager:ShouldActivateTouchShootProgressBar())
    self.isShowCountdown = not(self.matchInfoModel:IsDemoMatch() and not touchShootProgressBar)
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_NAME_PANEL, false)
    self:InitTimeRuler()
    self:ShowSuccessRate()
    self:ShowTeamLogo()
    self:StartTimeRulerAnim()
    if self.isManualShoot then
        EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.MANUAL_SHOOT)
    end
end

function PlayerShootPanel:InitPlayerShootState(successRate, shootEvaluationType)
    self.oldSuccessRate = self.nowSuccessRate
    self.relativeSuccessRate = successRate - self.nowSuccessRate
    self.nowSuccessRate = successRate
    if self.relativeSuccessRate == 0 then
        self:EndTimeRulerAnim()
    else
        self.isStartCountdown = false
        if self.relativeSuccessRate > 0 then
            self.relativeIncreaseRateNum.text = "+" .. self.relativeSuccessRate .. "%"
            GameObjectHelper.FastSetActive(self.relativeIncreaseRateNum.gameObject, true)
            GameObjectHelper.FastSetActive(self.relativeReduceRateNum.gameObject, false)
            UISoundManager.play('Match/shootSuccessRateIncrease', 1)
        else
            self.relativeReduceRateNum.text = self.relativeSuccessRate .. "%"
            GameObjectHelper.FastSetActive(self.relativeIncreaseRateNum.gameObject, false)
            GameObjectHelper.FastSetActive(self.relativeReduceRateNum.gameObject, true)
        end
        self.relativeRateBox.anchoredPosition = self.fingerTest:GetBallPosOnCanvas()
        self:PlayTrailEffect()
    end
end

--- 初始化时间标尺
function PlayerShootPanel:InitTimeRuler()
    for i = 1, self.timeRuler.childCount do
        local child = self.timeRuler:GetChild(i - 1).gameObject
        child:SetActive(true)
    end
end

function PlayerShootPanel:OnTouchShootActivated(callback)
    self.countdownEndedCallback = callback
end

function PlayerShootPanel:update()
    self:PlayCountdown()
end

--- 播放倒计时
function PlayerShootPanel:PlayCountdown()
    --stop animation after half of the countdown
    if self.isStartCountdown and self.isShowCountdown then
        local nowTime = Time.unscaledTime
        if nowTime <= self.countdownEndTime then
            if self.isManualShoot then
                self:SetTimeRuler(nowTime - self.countdownStartTime)
            end
        else
            self:EndTimeRulerAnim()
            if self.countdownEndedCallback ~= nil then
                self.countdownEndedCallback()
            end
        end
    end
end

--- 设置时间标尺
function PlayerShootPanel:SetTimeRuler(timeElapsed)
    local lastSecond = self.countdownDuration - math.floor(timeElapsed)
    if self.nowLastSecond ~= lastSecond then
        self.nowLastSecond = lastSecond
        self.countdownTime.text = tostring(lastSecond)
        self.countdownEffectTime1.text = tostring(lastSecond)
        self.countdownEffectTime2.text = tostring(lastSecond)
        self.countdownAnimator:Play("Base Layer.MoveIn", 0, 0)
    end
    local lastTime = self.countdownDuration - timeElapsed
    local timeRate = lastTime / self.countdownDuration
    local childCount = self.timeRuler.childCount
    for i = 1, childCount do
        if i / childCount >= timeRate then
            local child = self.timeRuler:GetChild(i - 1).gameObject
            if child.activeSelf then
                child:SetActive(false)
            end
        end
    end
end

--- 显示成功率
function PlayerShootPanel:ShowSuccessRate()
    self.normalRateNum.text = self.nowSuccessRate .. "%"
end

function PlayerShootPanel:ShowTeamLogo()
    if self.isManualShoot then
        GameObjectHelper.FastSetActive(self.homeTeamLogoBox, true)
        GameObjectHelper.FastSetActive(self.awayTeamLogoBox, false)
    else
        GameObjectHelper.FastSetActive(self.homeTeamLogoBox, false)
        GameObjectHelper.FastSetActive(self.awayTeamLogoBox, true)
    end
end

--- 开始时间标尺动画
function PlayerShootPanel:StartTimeRulerAnim()
    self.isStartCountdown = true
    GameObjectHelper.FastSetActive(self.timeRuler.gameObject, self.isManualShoot and self.isShowCountdown)
    if not self.isShowCountdown then
        TimeWrap.SetTimeScale(self.stopTimeScale)
    else
        TimeWrap.SetTimeScale(self.slowdownTimeScale)
    end
end

--- 结束时间标尺动画
function PlayerShootPanel:EndTimeRulerAnim()
    self.isStartCountdown = false
    GameObjectHelper.FastSetActive(self.timeRuler.gameObject, false)
    GameObjectHelper.FastSetActive(self.normalRateNum.gameObject, true)
    GameObjectHelper.FastSetActive(self.increaseRateNum.gameObject, false)
    GameObjectHelper.FastSetActive(self.increaseRateBox, false)
    GameObjectHelper.FastSetActive(self.reduceRateNum.gameObject, false)
    GameObjectHelper.FastSetActive(self.reduceRateBox, false)
    GameObjectHelper.FastSetActive(self.relativeIncreaseRateNum.gameObject, false)
    GameObjectHelper.FastSetActive(self.relativeReduceRateNum.gameObject, false)
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_SHOOT_PANEL, false)
    self.fightMenuManager:ShowShootBallEffect()
    if TimeWrap.GetTimeScale() > self.stopTimeScaleUpperLimit then
        TimeWrap.SetTimeScale(self.nowTimeScale)
    end
end

--- 播放拖尾特效
function PlayerShootPanel:PlayTrailEffect()
    GameObjectHelper.FastSetActive(self.trailEffect.gameObject, true)
    self.trailEffect.anchoredPosition = self.fingerTest:GetBallPosOnCanvas()
    local tweener = ShortcutExtensions.DOMove(self.trailEffect, self.glowEffect.position, 0.5, false)
    TweenSettingsExtensions.OnComplete(tweener, function ()  --Lua assist checked flag
        GameObjectHelper.FastSetActive(self.trailEffect.gameObject, false)
        self:PlayRateNumEffect()
    end)
end

--- 播放进球概率数据动画
function PlayerShootPanel:PlayRateNumEffect()
    GameObjectHelper.FastSetActive(self.normalRateNum.gameObject, false)
    if self.relativeSuccessRate > 0 then
        GameObjectHelper.FastSetActive(self.increaseRateNum.gameObject, true)
        GameObjectHelper.FastSetActive(self.reduceRateNum.gameObject, false)
        GameObjectHelper.FastSetActive(self.increaseRateBox, true)
        self:PlayNumTweenAnim(self.increaseRateNum, self.oldSuccessRate, self.nowSuccessRate)
    else
        GameObjectHelper.FastSetActive(self.increaseRateNum.gameObject, false)
        GameObjectHelper.FastSetActive(self.reduceRateNum.gameObject, true)
        GameObjectHelper.FastSetActive(self.reduceRateBox, true)
        self:PlayNumTweenAnim(self.reduceRateNum, self.oldSuccessRate, self.nowSuccessRate)
    end
end

--- 播放发光特效
function PlayerShootPanel:PlayGlowEffect()
    GameObjectHelper.FastSetActive(self.glowEffect.gameObject, true)
end

--- 停止发光特效
function PlayerShootPanel:StopGlowEffect()
    GameObjectHelper.FastSetActive(self.glowEffect.gameObject, false)
end

-- 数字补间动画
function PlayerShootPanel:PlayNumTweenAnim(textComp, oldNum, newNum)
    UISoundManager.play('Match/shootSuccessRateChange', 1)
    if oldNum == newNum then
        return
    end
    if newNum == nil then
        return
    end
    if oldNum == nil then
        textComp.text = newNum .. "%"
        return
    end
    textComp.text = oldNum .. "%"
    local localScale = textComp.transform.localScale
    local mySequence = DOTween.Sequence()
    local scaleOutTweener = ShortcutExtensions.DOScale(textComp.transform, Vector3(localScale.x * 1.1, localScale.y * 1.1, 1), 0.3)
    TweenSettingsExtensions.Append(mySequence, scaleOutTweener)
    TweenSettingsExtensions.AppendCallback(mySequence, function ()
        self:PlayGlowEffect()
    end)
    local diffNum = newNum - oldNum
    if diffNum <= 10 and diffNum >= -10 then
        local unitNum = diffNum / math.abs(diffNum)
        for i = 1, math.abs(diffNum) do
            local nowNum = oldNum + i * unitNum
            TweenSettingsExtensions.AppendInterval(mySequence, 0.05)
            TweenSettingsExtensions.AppendCallback(mySequence, function ()
                textComp.text = nowNum .. "%"
            end)
        end
    else
        local unitNum = math.floor(diffNum / 10)
        for i = 1, 10 do
            local nowNum = oldNum + i * unitNum
            if i == 10 then
                nowNum = newNum
            end
            TweenSettingsExtensions.AppendInterval(mySequence, 0.05)
            TweenSettingsExtensions.AppendCallback(mySequence, function ()
                textComp.text = nowNum .. "%"
            end)
        end
    end
    local scaleInTweener = ShortcutExtensions.DOScale(textComp.transform, localScale, 0.3)
    TweenSettingsExtensions.Append(mySequence, scaleInTweener)
    TweenSettingsExtensions.AppendInterval(mySequence, 1)
    TweenSettingsExtensions.AppendCallback(mySequence, function ()
        self:StopGlowEffect()
        self:EndTimeRulerAnim()
    end)
end

return PlayerShootPanel

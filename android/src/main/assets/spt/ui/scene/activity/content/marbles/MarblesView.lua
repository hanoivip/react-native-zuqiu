local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local EventSystems = UnityEngine.EventSystems
local WaitForSeconds = UnityEngine.WaitForSeconds
local Timer = require("ui.common.Timer")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MarblesExchangeItem = require("data.MarblesExchangeItem")
local DialogManager = require("ui.control.manager.DialogManager")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local MarblesView = class(ActivityParentView, "MarblesView")

function MarblesView:ctor()
--------Start_Auto_Generate--------
    self.helpBtn = self.___ex.helpBtn
    self.timeRemainedTxt = self.___ex.timeRemainedTxt
    self.reward1Img = self.___ex.reward1Img
    self.reward2Img = self.___ex.reward2Img
    self.reward3Img = self.___ex.reward3Img
    self.reward4Img = self.___ex.reward4Img
    self.reward5Img = self.___ex.reward5Img
    self.reward6Img = self.___ex.reward6Img
    self.reward7Img = self.___ex.reward7Img
    self.shootBtn = self.___ex.shootBtn
    self.shootImg = self.___ex.shootImg
    self.shootNormalGo = self.___ex.shootNormalGo
    self.shootDisableGo = self.___ex.shootDisableGo
    self.shootPressGo = self.___ex.shootPressGo
    self.shootOneBtn = self.___ex.shootOneBtn
    self.countOne1Txt = self.___ex.countOne1Txt
    self.countOne2Txt = self.___ex.countOne2Txt
    self.shootTenBtn = self.___ex.shootTenBtn
    self.countTen1Txt = self.___ex.countTen1Txt
    self.countTen2Txt = self.___ex.countTen2Txt
    self.ownItemTrans = self.___ex.ownItemTrans
    self.own1Img = self.___ex.own1Img
    self.own1Txt = self.___ex.own1Txt
    self.own2Img = self.___ex.own2Img
    self.own2Txt = self.___ex.own2Txt
    self.own3Img = self.___ex.own3Img
    self.own3Txt = self.___ex.own3Txt
    self.own4Img = self.___ex.own4Img
    self.own4Txt = self.___ex.own4Txt
    self.countRewardBtn = self.___ex.countRewardBtn
    self.countRewardRedPointGo = self.___ex.countRewardRedPointGo
    self.getRewardBtn = self.___ex.getRewardBtn
    self.getRewardRedPointGo = self.___ex.getRewardRedPointGo
    self.buyBallBtn = self.___ex.buyBallBtn
    self.ballCountTxt = self.___ex.ballCountTxt
    self.rewardTaskBtn = self.___ex.rewardTaskBtn
    self.rewardTaskRedPointGo = self.___ex.rewardTaskRedPointGo
--------End_Auto_Generate----------
    self.ballManager = self.___ex.ballManager
    self.rawImg = self.___ex.rawImg
    self.ownImg = {self.own1Img, self.own2Img, self.own3Img, self.own4Img}
    self.ownTxt = {self.own1Txt, self.own2Txt, self.own3Txt, self.own4Txt}
    self.rewardCellImg = {self.reward1Img, self.reward2Img, self.reward3Img, self.reward4Img, self.reward5Img, self.reward6Img, self.reward7Img}
    self.rewardCellAnim = {self.___ex.reward1Anim, self.___ex.reward2Anim, self.___ex.reward3Anim,
                           self.___ex.reward4Anim, self.___ex.reward5Anim, self.___ex.reward6Anim,
                           self.___ex.reward7Anim}
    self.physicalPrefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/Marbles/MarblesPhysicalView.prefab"
    self.itemImgPath = "Assets/CapstonesRes/Game/UI/Common/Images/MarblesExchangeItem/M%d.png"
    self.currentEventSystem = EventSystems.EventSystem.current
end

local maxCount = 60
local pressCount = 0
local modf = math.modf
local fmod = math.fmod
local ShootState = {}
ShootState.NotReady = 1  -- 未放入球 or 发射完毕
ShootState.AddingBall = 2  -- 放球中
ShootState.Ready = 3  -- 球已放入
ShootState.Shooting = 4  -- 发射中
function MarblesView:start()
    self.shootBtn:regOnButtonClick(function()
        self:StartClick()
    end)
    self.shootOneBtn:regOnButtonClick(function()
        local timesBallCount = self.marblesModel:GetTimesBallCount()
        local shootOneInfo = timesBallCount[1]
        self:AddBall(shootOneInfo)
    end)
    self.shootTenBtn:regOnButtonClick(function()
        local timesBallCount = self.marblesModel:GetTimesBallCount()
        local shootTenInfo = timesBallCount[2]
        self:AddBall(shootTenInfo)
    end)
    self.helpBtn:regOnButtonClick(function()
        if self.onBtnIntro then
            self.onBtnIntro()
        end
    end)
    self.rewardTaskBtn:regOnButtonClick(function()
        if self.onBtnRewardTask then
            self.onBtnRewardTask()
        end
    end)
    self.getRewardBtn:regOnButtonClick(function()
        if self.onBtnGetReward then
            self.onBtnGetReward()
        end
    end)
    self.countRewardBtn:regOnButtonClick(function()
        if self.onBtnCountReward then
            self.onBtnCountReward()
        end
    end)
    self.buyBallBtn:regOnButtonClick(function()
        if self.onBtnBuyBall then
            self.onBtnBuyBall()
        end
    end)
    self.isShooting = false
    self.shootImg.fillAmount = 0
    self.behav = self.transform:GetComponent("CapsUnityLuaBehav")
    self.shootState = ShootState.NotReady
end

function MarblesView:InitView(marblesModel)
    self.marblesModel = marblesModel
    self:InstancePhysicalBall()
    self:InitBallCount()
    self:SetShootBtnState()
end

function MarblesView:RefreshContent()
    self:InitTimesBallCount()
    self:InitOwnItemCount()
    self:InitRewardCell()
    self:InitAbsolute()
    self:SetOwnBallCount()
    self:ResetTimer()
    self:IsShowRedPoint()
end

-- 右边的两个按钮 弹一次 弹多次
function MarblesView:InitTimesBallCount()
    local timesBallCount = self.marblesModel:GetTimesBallCount()
    local shootOneInfo = timesBallCount[1]
    local shootTenInfo = timesBallCount[2]
    self.countOne1Txt.text = "X" .. shootOneInfo.ballNum
    self.countOne2Txt.text = lang.trans("marbles_shoot_count", shootOneInfo.count)
    self.countTen1Txt.text = "X" .. shootTenInfo.ballNum
    self.countTen2Txt.text = lang.trans("marbles_shoot_count", shootTenInfo.count)
end

-- 当前拥有的兑换物品
function MarblesView:InitOwnItemCount()
    local ownItem = self.marblesModel:GetOwnItem()
    for i, v in ipairs(self.ownImg) do
        local itemData = ownItem[i]
        local picPath = string.format(self.itemImgPath, itemData.picIndex)
        local imgRes = res.LoadRes(picPath)
        v.sprite = imgRes
        self.ownTxt[i].text = "X" .. itemData.ownCount
    end
end

-- 下方随机物品的格子
function MarblesView:InitRewardCell()
    local randItemList = self.marblesModel:GetRandItemList()
    local ownItem = self.marblesModel:GetOwnItem()
    local ownCount = #ownItem
    local allCount, t2
    for i, v in ipairs(self.rewardCellImg) do
        local itemIndex = randItemList[i]
        local itemData
        if itemIndex then
            itemData = MarblesExchangeItem[tostring(itemIndex)]
        else
            allCount,t2 = math.modf(i / ownCount);
            if t2 == 0 then t2 = 1 end
            itemData = ownItem[t2 * ownCount]
        end
        local picPath = string.format(self.itemImgPath, itemData.picIndex)
        local imgRes = res.LoadRes(picPath)
        v.sprite = imgRes
    end
end

-- 当前拥有的球数
function MarblesView:SetOwnBallCount()
    local ballCnt = self.marblesModel:GetBallCnt()
    self.ballCountTxt.text = tostring(ballCnt)
end

-- 初始化已经掉在待发射格子里的球
function MarblesView:InitBallCount()
    local selectShootCount = self.marblesModel:GetSelectShootCount()
    self.ballCount = selectShootCount
    if selectShootCount > 0 then
        self.currentEventSystem.enabled = false
        self.ballManager:AddBall(selectShootCount, function() self:AddBallComplete() end)
    end
end

-- 初始化障碍物
function MarblesView:InitAbsolute()
    local hideMapPosInfo = self.marblesModel:GetHideMapPosInfo()
    self.ballManager:RandomAbsolute(hideMapPosInfo)
end

-- 生成物理碰撞的prefab
function MarblesView:InstancePhysicalBall()
    local coachInfoObj, coachInfoSpt = res.Instantiate(self.physicalPrefab)
    self.ballManager = coachInfoSpt
    self.ballManager:Init()
    local rt = self.ballManager:GetRT()
    self.rawImg.texture = rt;
    self.rawImg.enabled = true;
    GameObjectHelper.FastSetActive(self.rawImg.gameObject, true)
end

-- 往待发射的格子里添加球
function MarblesView:AddBall(shootBallInfo)
    local isTimeInActivity = self.marblesModel:IsTimeInActivity()
    if not isTimeInActivity then
        return
    end
    if self.shootState ~= ShootState.NotReady then
        DialogManager.ShowToastByLang("marbles_click_start")
        return
    end
    local ballCnt = self.marblesModel:GetBallCnt()
    if shootBallInfo.ballNum > ballCnt then
        if self.onBtnBuyBall then
            self.onBtnBuyBall()
        end
        return
    end
    if self.addBallClick then
        self.addBallClick(shootBallInfo)
    end
end

-- 点击发射按钮
function MarblesView:StartClick()
    local isTimeInActivity = self.marblesModel:IsTimeInActivity()
    if not isTimeInActivity then
        return
    end
    if self.shootState ~= ShootState.Ready then
        DialogManager.ShowToastByLang("marbles_click_add")
        return
    end
    if self.isShooting then
        self:Shoot()
        pressCount = 0
        self.isShooting = false
    else
        self.isShooting = true
        local deltaCount = 0
        clr.bcoroutine(self.behav, function()
            while self.isShooting do
                deltaCount = deltaCount + 2
                self:RefreshImage(deltaCount)
                coroutine.yield(WaitForSeconds(0.02))
            end
        end)
    end
end

-- 发射按钮的进度条
function MarblesView:RefreshImage(count)
    local m = modf(count / maxCount) -- 取整
    local f = fmod(count, maxCount)  -- 取余
    local result = f
    if fmod(m, 2) == 1 then
        result = maxCount - f
    end
    local rate = result / maxCount
    pressCount = result
    self.shootImg.fillAmount = rate
end

-- 第二次点击发射按钮 发射小球
function MarblesView:Shoot()
    self.currentEventSystem.enabled = false
    local rate = pressCount / maxCount
    self.ballManager:StartClick(rate, self.ballCount, function(posTab)
        self:RollBallComplete(posTab)
    end)
    self.shootState = ShootState.Shooting
    pressCount = 0
end

-- 球发射完成 显示奖励
function MarblesView:RollBallComplete(posTab)
    if self.onShootBallComplete then
        self.onShootBallComplete(posTab)
    end
end

-- 球发射完成 刷新
function MarblesView:RollBallCompleteRefresh()
    self.shootImg.fillAmount = 0
    self:ResetBall()
    self.shootState = ShootState.NotReady
    self:SetShootBtnState()
end

-- 球已经添加到待发射格子里 切换状态
function MarblesView:AddBallComplete()
    self.shootState = ShootState.Ready
    self.currentEventSystem.enabled = true
    self:SetShootBtnState()
end

-- 发射球的小手的状态
function MarblesView:SetShootBtnState()
    local selectShootCount = self.marblesModel:GetSelectShootCount()
    GameObjectHelper.FastSetActive(self.shootPressGo, selectShootCount > 0)
    GameObjectHelper.FastSetActive(self.shootDisableGo, selectShootCount == 0)
end

-- 设置倒计时
function MarblesView:ResetTimer()
    if self.marblesModel:GetRemainTime() > 0 then
        self:RefreshTimer()
    else
        self:SetRunOutOfTimeView()
    end
end

function MarblesView:RefreshTimer()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    local remainTime = self.marblesModel:GetRemainTime()
    local timeTitleStr = lang.transstr("residual_time")
    self.residualTimer = Timer.new(remainTime, function(time)
        if time <= 1 then
            self:SetRunOutOfTimeView()
            return
        else
            self.timeRemainedTxt.text = timeTitleStr .. string.convertSecondToTime(time)
        end
    end)
end

function MarblesView:SetRunOutOfTimeView()
    self.timeRemainedTxt.text = lang.trans("visit_endInfo")
    if self.runOutOfTime then
        self.runOutOfTime()
    end
end

-- 重置小球
function MarblesView:ResetBall()
    self.ballManager:ResetBall()
end

-- 红点
function MarblesView:IsShowRedPoint()
    self:IsShowExchangeRedPoint()
    self:IsShowTaskRedPoint()
    self:IsShowCountRedPoint()
end

function MarblesView:IsShowExchangeRedPoint()
    local exchange = ReqEventModel.GetInfo("marblesExchange")
    GameObjectHelper.FastSetActive(self.getRewardRedPointGo, tonumber(exchange) > 0)
end

function MarblesView:IsShowTaskRedPoint()
    local task = ReqEventModel.GetInfo("marblesTask")
    GameObjectHelper.FastSetActive(self.rewardTaskRedPointGo, tonumber(task) > 0)
end

function MarblesView:IsShowCountRedPoint()
    local count = ReqEventModel.GetInfo("marblesCount")
    GameObjectHelper.FastSetActive(self.countRewardRedPointGo, tonumber(count) > 0)
end

function MarblesView:OnEnterScene()
    self.super.OnEnterScene(self)
    EventSystem.AddEvent("ReqEventModel_marblesExchange", self, self.IsShowExchangeRedPoint)
    EventSystem.AddEvent("ReqEventModel_marblesTask", self, self.IsShowTaskRedPoint)
    EventSystem.AddEvent("ReqEventModel_marblesCount", self, self.IsShowCountRedPoint)
end

function MarblesView:OnExitScene()
    self.super.OnExitScene(self)
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    EventSystem.RemoveEvent("ReqEventModel_marblesExchange", self, self.IsShowExchangeRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_marblesTask", self, self.IsShowTaskRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_marblesCount", self, self.IsShowCountRedPoint)
    self.shootImg.fillAmount = 0
    self.isShooting = false
end

function MarblesView:PlayRefreshAnim()
    self.ballManager:PlayAbsoluteAnim()
    for i, v in ipairs(self.rewardCellAnim) do
        self.rewardCellAnim[i]:Play("BallReward")
    end
end

function MarblesView:onDestroy()
    Object.Destroy(self.ballManager.gameObject)
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return MarblesView

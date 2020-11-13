local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local Vector2 = UnityEngine.Vector2
local Time = UnityEngine.Time
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CommonConstants = require("ui.common.CommonConstants")
local UIBgmManager = require("ui.control.manager.UIBgmManager")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local CongratulationsMultiPageView = class(unity.base)

function CongratulationsMultiPageView:ctor()
    -- 遮罩点击层
    self.mask = self.___ex.mask
    -- 动画管理器
    self.animator = self.___ex.animator
    -- 奖励数据
    self.rewardData = nil
    self.isPlayMoveOutAnim = false
    self.playerInfoModel = nil
    self.isPlayMoveInAnim = false
    self.rewardRect = self.___ex.rewardRect
    self.scroll = self.___ex.scroll
    self.titleImg = self.___ex.titleImg
    self.titleInfo = self.___ex.titleInfo
end

function CongratulationsMultiPageView:InitView(rewardData, playerInfoModel, isGuideComment, isVisitInfo)
    self.rewardData = clone(rewardData)
    self.playerInfoModel = playerInfoModel
    self.isGuideComment = isGuideComment
    self.isVisitInfo = isVisitInfo
    self:InitRewardContent()
    if self.isVisitInfo then
        self.titleImg:SetActive(false)
        self.titleInfo.gameObject:SetActive(true)
        self.titleInfo.text = self.isVisitInfo
    else
        self.titleImg.gameObject:SetActive(true)
        self.titleInfo.gameObject:SetActive(false)
    end
end

function CongratulationsMultiPageView:InitRewardContent()
    local rewardParams = {
        parentObj = self.rewardRect,
        rewardData = self.rewardData,
        isShowName = false,
        isReceive = true,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
    }
    RewardDataCtrl.new(rewardParams)
end

function CongratulationsMultiPageView:start()
    self:PlayMoveInAnim()
    self:BindAll()
    
end

function CongratulationsMultiPageView:BindAll()
    -- 遮罩点击层
    self.mask:regOnButtonClick(function ()
        if self.isPlayMoveInAnim then return end

        self:PlayMoveOutAnim()
    end)
end

function CongratulationsMultiPageView:PlayMoveInAnim()
    self.animator:Play("MoveIn", 0)
    self.isPlayMoveInAnim = true
    clr.coroutine(function()
        coroutine.yield(WaitForSeconds(0.25))
        UIBgmManager.play("congratulations")
    end)
end

function CongratulationsMultiPageView:PlayMoveOutAnim()
    self.animator:Play("MoveOut", 0)
    self.isPlayMoveOutAnim = true
end

function CongratulationsMultiPageView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
        self.isPlayMoveInAnim = false
        self:AIScrollSize()
    elseif animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self.isPlayMoveOutAnim = false
        self:Destroy()
    end
end

function CongratulationsMultiPageView:AIScrollSize()
    self:coroutine(function ()
        local isReturn = false
        local isFinish = false
        while true do
            if isReturn then
                self.scroll.normalizedPosition = self.scroll.normalizedPosition - Vector2(Time.deltaTime, 0)
                if self.scroll.normalizedPosition.x < 0.01 then
                    isFinish = true
                end
            else
                self.scroll.normalizedPosition = self.scroll.normalizedPosition + Vector2(Time.deltaTime, 0)
                if self.scroll.normalizedPosition.x > 1.2 then
                    isReturn = true
                end
                if self.scroll.normalizedPosition.x < Time.deltaTime * 0.9 then
                    isFinish = true
                end
            end

            unity.waitForNextEndOfFrame()
            if isFinish then
                break
            end
        end
    end)
end

function CongratulationsMultiPageView:Destroy()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function CongratulationsMultiPageView:onDestroy()
    local playerInfoModel = self.playerInfoModel
    local isGuideComment = self.isGuideComment
    clr.coroutine(function ()
        -- 关闭恭喜获得界面
        GuideManager.Show(res.GetTopCtrl())
        coroutine.yield(WaitForSeconds(0.1))
        EventSystem.SendEvent("CongratulationsPageClosed")
        if isGuideComment and clr.plat == "IPhonePlayer" then
            res.PushDialog("ui.control.guideComment.GoodGuideCtrl", false)
        end
        playerInfoModel:UnlockLevelUp()
        playerInfoModel:UnLockVIPLevelUp()
    end)
end

return CongratulationsMultiPageView

local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local CoachMainPageConfig = require("ui.scene.coach.coachMainPage.CoachMainPageConfig")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")

local CoachGachaRewardView = class(unity.base, "CoachGachaRewardView")

function CoachGachaRewardView:ctor()
--------Start_Auto_Generate--------
    self.againBtn = self.___ex.againBtn
    self.shareBtn = self.___ex.shareBtn
    self.closeBtn = self.___ex.closeBtn
    self.effectTittleGo = self.___ex.effectTittleGo
    self.rewardTrans = self.___ex.rewardTrans
    self.rewardAnimator = self.___ex.rewardAnimator
--------End_Auto_Generate----------
    self.canvasGroup = self.___ex.canvasGroup
    self.rewardUpdateCacheModel = RewardUpdateCacheModel.new()
end

function CoachGachaRewardView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CoachGachaRewardView:InitView(data)
    self.rewardDataForever = {}
    for i, v in pairs(self.rewardTrans) do
        res.ClearChildren(v)
    end
    for i,v in ipairs(data) do
        self.rewardUpdateCacheModel:UpdateCache(v.contents)
        self:SetRewardContent(v.contents, i)
        for k,v in pairs(v.contents) do
            self.rewardDataForever[k] = clone(v)
        end
    end
    self.rewardAnimator:Play("Initial", 0, 0)
end

function CoachGachaRewardView:SetRewardContent(content, i)
    local rewardParams = {
        parentObj = self.rewardTrans[tostring(i)],
        rewardData = content,
        isShowName = true,
        isReceive = true,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        itemParams = {
            -- 名称颜色
            nameColor = Color.white,
            -- 名称阴影颜色
            nameShadowColor = Color.black,
        },
    }
    RewardDataCtrl.new(rewardParams)
end

function CoachGachaRewardView:RegBtnEvent()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.againBtn:regOnButtonClick(function()
        if self.onAgainClick and type(self.onAgainClick) == "function" then
            self.onAgainClick()
            self:PlayEffect()
        end
    end)
    self.shareBtn:regOnButtonClick(function()
        if self.onShareClick and type(self.onShareClick) == "function" then
            self.onShareClick()
        end
    end)
end

function CoachGachaRewardView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            -- 新手引导
            self:CheckGuide()
            self.closeDialog()
        end
        EventSystem.SendEvent("CongratulationsPageClosed", self.rewardDataForever)
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

function CoachGachaRewardView:PlayEffect()
    GameObjectHelper.FastSetActive(self.effectTittleGo, false)
    self:coroutine(function()
        unity.waitForNextEndOfFrame()
        GameObjectHelper.FastSetActive(self.effectTittleGo, true)
    end)
end

function CoachGachaRewardView:CheckGuide()
    -- TODO 新手引导
end

return CoachGachaRewardView

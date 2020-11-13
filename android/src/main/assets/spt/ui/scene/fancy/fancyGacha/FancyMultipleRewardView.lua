local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")

local FancyGachaRewardView = class(unity.base, "FancyGachaRewardView")

function FancyGachaRewardView:ctor()
--------Start_Auto_Generate--------
    self.againBtn = self.___ex.againBtn
    self.closeBtn = self.___ex.closeBtn
    self.effectTittleGo = self.___ex.effectTittleGo
    self.rewardAnim = self.___ex.rewardAnim
--------End_Auto_Generate----------
    self.rewardTrans = self.___ex.rewardTrans
    self.rewardLayOut = self.___ex.rewardLayOut
    self.canvasGroup = self.___ex.canvasGroup
    self.rewardUpdateCacheModel = RewardUpdateCacheModel.new()
end

function FancyGachaRewardView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FancyGachaRewardView:InitView(data)
    if not data then return end
    for i, v in pairs(data) do
        self.rewardUpdateCacheModel:UpdateCache(v)
    end
    for i, v in pairs(self.rewardTrans) do
        res.ClearChildren(v)
    end
    for i, v in ipairs(data) do
        self:SetRewardContent(v, i)
    end
    self.rewardAnim:Play("Initial")
    self.rewardAnim:Update(0)
end

-- 实例化招募奖励（一个）
function FancyGachaRewardView:SetRewardContent(content, i)
    if content.fancyCard then
        self.rewardLayOut[tostring(i)].padding.top = -10
        self.rewardLayOut[tostring(i)].cellSize = Vector2(127, 127)
    else
        self.rewardLayOut[tostring(i)].padding.top = 0
        self.rewardLayOut[tostring(i)].cellSize = Vector2(105, 105)
    end
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

function FancyGachaRewardView:RegBtnEvent()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.againBtn:regOnButtonClick(function()
        if self.onAgainClick and type(self.onAgainClick) == "function" then
            self.onAgainClick()
            self:PlayEffect()
        end
    end)
end

-- 标题闪烁效果
function FancyGachaRewardView:PlayEffect()
    GameObjectHelper.FastSetActive(self.effectTittleGo, false)
    self:coroutine(function()
        unity.waitForNextEndOfFrame()
        GameObjectHelper.FastSetActive(self.effectTittleGo, true)
    end)
end

function FancyGachaRewardView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

return FancyGachaRewardView

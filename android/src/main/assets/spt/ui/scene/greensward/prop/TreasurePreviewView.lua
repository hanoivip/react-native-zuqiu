local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local TextAnchor = UnityEngine.TextAnchor
local RectOffset = UnityEngine.RectOffset
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local TreasurePreviewView = class(unity.base, "TreasurePreviewView")

local contentDefaultHeight = 301
local headTextHeight = 60
local adjustMargin = 30

function TreasurePreviewView:ctor()
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 关闭按钮
    self.btnClose = self.___ex.btnClose
    -- canvasGroup
    self.canvasGroup = self.___ex.canvasGroup
    -- 滑动
    self.scrollRect = self.___ex.scrollRect
    -- 奖励容器
    self.rctContents = self.___ex.rctContents
    self.rctRewards = self.___ex.rctRewards
    -- 排版
    self.gridLayout = self.___ex.gridLayout
end

function TreasurePreviewView:start()
    contentDefaultHeight = self.rctContents.sizeDelta.y
    self:RegBtnEvent()
    self:ShowDisplayArea(false)
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function TreasurePreviewView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function TreasurePreviewView:InitView(treasurePreviewModel)
    self.model = treasurePreviewModel
end

function TreasurePreviewView:RefreshView()
    if not self.model then
        self:ShowDisplayArea(false)
        return
    end

    res.ClearChildren(self.rctRewards)
    local contentsArray = self.model:GetRewardContents()
    local num = #contentsArray
    if num > 5 then
        local col = math.ceil(num / self.gridLayout.constraintCount)
        local contentsHeight = col * self.gridLayout.cellSize.y + (col - 1) * self.gridLayout.spacing.y
        self.rctContents.sizeDelta = Vector2(self.rctContents.sizeDelta.x, contentsHeight + headTextHeight + adjustMargin)
        self.rctRewards.sizeDelta = Vector2(self.rctContents.sizeDelta.x, contentsHeight)
        self.scrollRect.vertical = true
        self.gridLayout.childAlignment = TextAnchor.UpperLeft
        self.gridLayout.padding = RectOffset(5, 0, 0, 0)
    else
        self.rctContents.sizeDelta = Vector2(self.rctContents.sizeDelta.x, contentDefaultHeight)
        self.rctRewards.sizeDelta = Vector2(self.rctContents.sizeDelta.x, contentDefaultHeight - headTextHeight)
        self.scrollRect.vertical = false
        self.gridLayout.childAlignment = TextAnchor.MiddleCenter
        self.gridLayout.padding = RectOffset(0, 0, 0, 0)
    end
    for k, contents in ipairs(contentsArray) do
        local rewardParams = {
            parentObj = self.rctRewards,
            rewardData = contents,
            isShowName = true,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
end

function TreasurePreviewView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.rctContents.gameObject, isShow)
end

function TreasurePreviewView:Close()
    local callback = function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

return TreasurePreviewView

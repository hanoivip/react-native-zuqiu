local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local RewardStatus = require("ui.models.friends.RewardStatus")
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local StageRewardItemView = class(unity.base)

local arrowShowThreshold = 3
function StageRewardItemView:ctor()
    self.pointsNeededTxt = self.___ex.pointsNeededTxt
    self.stagePointsTxt = self.___ex.stagePointsTxt
    self.btnShadowObj = self.___ex.btnShadowObj
    self.btnDisabled = self.___ex.btnDisabled
    self.collectedIcon = self.___ex.collectedIcon
    self.itemContent = self.___ex.itemContent
    self.titleBg = self.___ex.titleBg
    self.lArrow = self.___ex.lArrow
    self.rArrow = self.___ex.rArrow
    self.btnCollect = self.___ex.btnCollect
    self.btnCollectSpt = self.___ex.btnCollectSpt
    self.scrollRect = self.___ex.scrollRect

    self:BindScrollFunc()
end

function StageRewardItemView:InitView(itemModel, goldCupModel)
    self.itemModel = itemModel
    self.goldCupModel = goldCupModel
    
    local stageIndex = self.itemModel:GetStageIndex()
    GameObjectHelper.FastSetActive(self.titleBg, stageIndex < 4)

    GameObjectHelper.FastSetActive(self.lArrow, false)
    GameObjectHelper.FastSetActive(self.rArrow, self.itemModel:IsArrowsShow(arrowShowThreshold))

    self:InitTxtArea()

    self:InstantiateItemsWithShadow()

    self:RefreshButtonState()
end

function StageRewardItemView:InitTxtArea()
    self.pointsNeededTxt.text = self.itemModel:GetPointsNeededStr()
    self.stagePointsTxt.text = self.itemModel:GetStagePointsStr()
end

function StageRewardItemView:InstantiateItemsWithShadow()
    local separateContents = self.itemModel:GetSeparateContents()
    local prefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/GoldCup/ItemWithShadow.prefab"
    for k, v in pairs(separateContents) do
        local obj, spt = res.Instantiate(prefabPath)
        obj.transform:SetParent(self.itemContent, false)
        local itemParent = ((obj.transform:GetChild(1)).transform:GetChild(0)).transform
        self:InitOneItemWithShadow(v, itemParent)
    end
end

function StageRewardItemView:InitOneItemWithShadow(itemContent, parentRect)
    local rewardParams = {
        parentObj = parentRect,
        rewardData = itemContent,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowSymbol = false,
        isShowCardPieceBeforeItem = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function StageRewardItemView:BindScrollFunc()
    self.scrollRect.onValueChanged:AddListener(function(vector2)
        if self.itemModel:IsArrowsShow(arrowShowThreshold) then
            if vector2.x > 0.999 then
                self:UpdateArrowState(true, false)
            elseif vector2.x < 0.001 then
                self:UpdateArrowState(false, true)
            else
                self:UpdateArrowState(true, true)
            end
        end
    end)
end

function StageRewardItemView:UpdateArrowState(isShowL, isShowR)
    GameObjectHelper.FastSetActive(self.lArrow, isShowL)
    GameObjectHelper.FastSetActive(self.rArrow, isShowR)
end

function StageRewardItemView:RefreshButtonState()
    GameObjectHelper.FastSetActive(self.btnCollect, self.itemModel:IsRewardCollectable())
    GameObjectHelper.FastSetActive(self.btnDisabled, self.itemModel:IsRewardInComplete())
    GameObjectHelper.FastSetActive(self.collectedIcon, self.itemModel:IsRewardAlreadyCollected())
    GameObjectHelper.FastSetActive(self.btnShadowObj, not self.itemModel:IsRewardAlreadyCollected())
end

function StageRewardItemView:start()
    self.btnCollectSpt:regOnButtonClick(function()
        local isEnable = self.itemModel:IsRewardCollectable()
        if not isEnable then return end
        
        self:coroutine(function()
            local respone = req.activityFirstPay(self.goldCupModel:GetActivityType(), self.itemModel:GetSubID())
            if api.success(respone) then
                local data = respone.val
                if type(data) == "table" and next(data) then
                    local collected = data.activity.status or RewardStatus.COLLECTED --设置状态为已领取
                    self.itemModel:SetStatus(collected)
                    self:RefreshButtonState()
                    CongratulationsPageCtrl.new(data.contents, false)
                end
            end
        end)
    end)

    EventSystem.AddEvent("GoldCup_RefreshStageRewardBtn", self, self.RefreshButtonState)
end

function StageRewardItemView:onDestroy()
    EventSystem.RemoveEvent("GoldCup_RefreshStageRewardBtn", self, self.RefreshButtonState)
end

return StageRewardItemView

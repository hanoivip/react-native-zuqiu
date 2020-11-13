local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CareerRaceRIViewModel = require("ui.models.quest.CareerRaceRIViewModel")
local RewardItemView = class(unity.base)

local arrowShowThreshold  = 3
function RewardItemView:ctor()
	self.content = self.___ex.content
	self.btnCollect = self.___ex.btnCollect
	self.collectedTag = self.___ex.collectedTag
	self.btnDisable = self.___ex.btnDisable
	self.numText = self.___ex.num
    self.disabledtext = self.___ex.disabledtext
    self.lArrow = self.___ex.lArrow
    self.rArrow = self.___ex.rArrow
    self.scrollRect = self.___ex.scrollRect
	self.cumulativeConsumeItemScrollAtOnce = self.___ex.cumulativeConsumeItemScrollAtOnce

    self.scrollRect.onValueChanged:AddListener(function(vector2)
        if self.model:IsArrowsShow(arrowShowThreshold) then
            if vector2.x > 0.999 then
                self:UpdateArrowState(true, false)
            elseif vector2.x < 0.001 then
                self:UpdateArrowState(false, true)
            else
                self:UpdateArrowState(true, true)
            end
        end
    end)

	self.btnCollect:regOnButtonClick(function()
		self:ClickCollectBtn()
	end)
end

function RewardItemView:InitView(data, parentRect, activityModel)
	if not data or not next(data) then return end
    self.activityModel = activityModel
    self.model = CareerRaceRIViewModel.new(data)
    res.ClearChildren(self.content)
    self:UpdataBtnState()

    GameObjectHelper.FastSetActive(self.lArrow, false)
    GameObjectHelper.FastSetActive(self.rArrow, self.model:IsArrowsShow(arrowShowThreshold))
    self.numText.text = tostring(self.model:GetConditionDesc(), activityModel)
    local rewardParams = {
        parentObj = self.content,
        rewardData = self.model:GetContents(),
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowCardPieceBeforeItem = true,
    }
    self.cumulativeConsumeItemScrollAtOnce.scrollRectInParent = parentRect
    RewardDataCtrl.new(rewardParams)
end

function RewardItemView:UpdateArrowState(isShowL, isShowR)
    GameObjectHelper.FastSetActive(self.lArrow, isShowL)
    GameObjectHelper.FastSetActive(self.rArrow, isShowR)
end

function RewardItemView:start()
    EventSystem.AddEvent("ChangeCareerRaceRewardItemButtonState", self, self.UpdataBtnState)
end

function RewardItemView:UpdataBtnState()
    local isActivityEnd = self.activityModel:GetIsActivityEnd()
    if not isActivityEnd then
    	GameObjectHelper.FastSetActive(self.btnCollect.gameObject, self.model:IsRewardCollectable())
    	GameObjectHelper.FastSetActive(self.btnDisable, self.model:IsRewardUnqualified())
    else
        GameObjectHelper.FastSetActive(self.btnCollect.gameObject, false)
        GameObjectHelper.FastSetActive(self.btnDisable, not self.model:IsRewardAlreadyCollected())
        self.disabledtext.text = lang.transstr("belatedGift_item_nil_time")
    end
    GameObjectHelper.FastSetActive(self.collectedTag, self.model:IsRewardAlreadyCollected())
end

function RewardItemView:ClickCollectBtn()
    local isActivityEnd = self.activityModel:GetIsActivityEnd()
    if isActivityEnd then
        DialogManager.ShowToast(lang.trans("time_limit_growthPlan_desc5"))
        return
    end
    local isEnable = self.model:IsRewardCollectable()
    if not isEnable then return end
    
    self:coroutine(function()
        local respone = req.activityFirstPay(self.activityModel:GetActivityType(), self.model:GetSubID())
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) then
                local collected = data.activity.status or 1 --设置状态为已领取
                self.activityModel:SetRewardStatusByCondition(self.model:GetCondition(), collected)
                self.model:SetStatus(collected)
                self:UpdataBtnState()
                local popCongratulationsPage = function()
                    CongratulationsPageCtrl.new(data.contents, false)
                end
                self:Close(popCongratulationsPage)
            end
        end
    end)
end

function RewardItemView:Close(popCongratulationsPage)
    popCongratulationsPage()
end

function RewardItemView:onDestroy()
    EventSystem.RemoveEvent("ChangeCareerRaceRewardItemButtonState", self, self.UpdataBtnState)
end

return RewardItemView
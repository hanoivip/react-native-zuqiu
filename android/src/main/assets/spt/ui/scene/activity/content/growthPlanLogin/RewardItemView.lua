local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local RewardItemView = class(unity.base)

function RewardItemView:ctor()
	self.content = self.___ex.content
	self.btnCollect = self.___ex.btnCollect
	self.collectedTag = self.___ex.collectedTag
	self.loginDateText = self.___ex.loginDateText
	self.btnDisable = self.___ex.btnDisable
	self.scrollRect =self.___ex.scrollRect
	self.lArrow = self.___ex.lArrow
	self.rArrow = self.___ex.rArrow
	self.cumulativeConsumeItemScrollAtOnce = self.___ex.cumulativeConsumeItemScrollAtOnce

	self.btnCollect:regOnButtonClick(function()
		self:ClickCollectBtn()
	end)

	self.scrollRect.onValueChanged:AddListener(function(vector2)
        if self.model.contentsCount > 3 then
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

function RewardItemView:start()
	EventSystem.AddEvent("ChangeGrowthPlanLoginRewardItemButtonState", self, self.ChangeShowBtn)
end

function RewardItemView:InitView(data, parentRect, activityModel)
	if not data or not next(data) then return end
	self.activityModel = activityModel
	self.model = data
	res.ClearChildren(self.content)
	self:UpdateRewardState(self.model.status)

	GameObjectHelper.FastSetActive(self.lArrow, false)
	GameObjectHelper.FastSetActive(self.rArrow, self.model.contentsCount > 3)
	local dateNum = lang.transstr("number_" .. tostring(data.dateNum))
	self:UpdateButtonAreaState()
    self.loginDateText.text = lang.trans("time_limit_growthPlan_desc2", dateNum)
    local rewardParams = {
        parentObj = self.content,
        rewardData = self.model.contents,
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
-- -1未达成， 0可领取， 1已领取
function RewardItemView:UpdateRewardState(status)
	if status == -1 then
		self:ChangeShowBtn(true, false, false)
	elseif status == 0 then
		self:ChangeShowBtn(false, true, false)
	elseif status == 1 then
		self:ChangeShowBtn(false, false, true)
	else
		dump("status error!")
	end
end

function RewardItemView:ChangeShowBtn(isUnqualified, isQualified, isCollected)
	GameObjectHelper.FastSetActive(self.collectedTag, isCollected)
	GameObjectHelper.FastSetActive(self.btnCollect.gameObject, isQualified)
	GameObjectHelper.FastSetActive(self.btnDisable, isUnqualified)
end

function RewardItemView:ClickCollectBtn()
	local isEnable = self.model.status == 0
	if not isEnable then return end
    if self.activityModel:IsActivityEnd() then 
        DialogManager.ShowToast(lang.trans("time_limit_growthPlan_desc5"))
        return 
    end
	
    self:coroutine(function()
        local respone = req.activityFirstPay(self.activityModel:GetActivityType(), self.model.subID)
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) then
            	local collected = data.activity.status or 1 --设置状态为已领取
                self.activityModel:SetRewardStatusByCondition(self.model.condition, collected)
                self.model.status = collected
                self:UpdateRewardState(collected)
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

function RewardItemView:UpdateButtonAreaState(model)
end

function RewardItemView:UpdateArrowState(isShowL, isShowR)
    GameObjectHelper.FastSetActive(self.lArrow, isShowL)
    GameObjectHelper.FastSetActive(self.rArrow, isShowR)
end

function RewardItemView:onDestroy()
	EventSystem.RemoveEvent("ChangeGrowthPlanLoginRewardItemButtonState", self, self.ChangeShowBtn)
end

return RewardItemView
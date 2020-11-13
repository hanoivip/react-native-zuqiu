local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local RewardDataCtrl = require('ui.controllers.common.RewardDataCtrl')
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local MatchLoader = require("coregame.MatchLoader")
local EventSystem = require("EventSystem")
local Timer = require('ui.common.Timer')
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local DialogManager = require("ui.control.manager.DialogManager")
local Button = UnityEngine.UI.Button

local ActivityTimeLimitedBaseView = class(unity.base)

function ActivityTimeLimitedBaseView:ctor()
    self.diffBtns = self.___ex.diffBtns
    self.rewardParent = self.___ex.rewardParent
    self.mainBtn = self.___ex.mainBtn
    self.powerTxt = self.___ex.powerTxt
    self.mainBtnTxt = self.___ex.mainBtnTxt
    self.gotImg = self.___ex.gotImg
    self.disableBtn = self.___ex.disableBtn
end


function ActivityTimeLimitedBaseView:OnEnterScene()
    EventSystem.AddEvent("PowerTarget_Diff_Change", self, self.OnDiffChange)
    self:OnClick(self.powerTargetModel:GetDefaultIndex(), true)
end

function ActivityTimeLimitedBaseView:OnExitScene()
    EventSystem.RemoveEvent("PowerTarget_Diff_Change", self, self.OnDiffChange)
end


function ActivityTimeLimitedBaseView:OnDiffChange()
    self:RefreshDiffButtonState()
    self:RefreshRewardArea()
end

function ActivityTimeLimitedBaseView:RefreshDiffButtonState()
    for k, v in pairs(self.diffBtns["diff" .. self.powerTargetModel:GetCurrDiff()].___ex.selectImage) do
        v:SetActive(true)
    end
end

function ActivityTimeLimitedBaseView:RefreshRewardArea()
    for i = 1, self.rewardParent.childCount do
        Object.Destroy(self.rewardParent:GetChild(i - 1).gameObject)
    end
    local rewardParams = {
        parentObj = self.rewardParent,
        rewardData = self.powerTargetModel:GetRewardContent(),
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    local power = self.powerTargetModel:GetPower()
    local status = self.powerTargetModel:GetStatus()
    self.powerTxt.text = lang.transstr("powerTarget_powerCondition") .. ": " .. tostring(power)
    if status == 1 then
        self.mainBtn.gameObject:SetActive(false)
        self.disableBtn.gameObject:SetActive(false)
        self.gotImg:SetActive(true)
    elseif status == 0 then
        self.mainBtnTxt.text = lang.transstr("powerTarget_recieve_reward")
        self.mainBtn.gameObject:SetActive(true)
        self.disableBtn.gameObject:SetActive(false)
        self.gotImg:SetActive(false)
        self.mainBtn:regOnButtonClick(function()
            self:RequestRecieve()
        end)
    else
        self.mainBtnTxt.text = lang.transstr("powerTarget_challenge")
        self.gotImg:SetActive(false)
        local playerTeamsModel = PlayerTeamsModel.new()
        local playerPower = tonumber(playerTeamsModel:GetTotalPower())
        if self.powerTargetModel:GetFirstLoseIndex() == self.powerTargetModel:GetCurrDiff() then
            self.mainBtn.gameObject:SetActive(true)
            self.disableBtn.gameObject:SetActive(false)
            self.mainBtn:regOnButtonClick(function ()
               if playerPower >= power then
                    self:RequestMatch()
               else
                    DialogManager.ShowToastByLang("powerTarget_tip_1")
               end
            end)
        else
            self.mainBtn.gameObject:SetActive(false)
            self.disableBtn.gameObject:SetActive(true)
            self.disableBtn:regOnButtonClick(function()
            DialogManager.ShowToastByLang("powerTarget_tip_2")
            end)
        end
    end
end

function ActivityTimeLimitedBaseView:RequestRecieve()
    local activityType = self.powerTargetModel:GetChallengeType()
    clr.coroutine(function()
        local response = req.activityTimeLimitChallengeReceiveReward(activityType, self.powerTargetModel:GetSubId())
        if api.success(response) then
            local data = response.val
            if next(data) then
                CongratulationsPageCtrl.new(data.contents)
                self.powerTargetModel:SetStatus(1)
                self:RefreshRewardArea()
            end
        end
    end)
end

return ActivityTimeLimitedBaseView

local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local UIBgmManager = require("ui.control.manager.UIBgmManager")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local StartGameConstants = require("ui.scene.startGame.StartGameConstants")
local MascotPresentRIViewModel = require("ui.models.activity.mascotPresent.MascotPresentRIViewModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GuildTaskRewardItemView = class(unity.base)

local btnTip = {
    ["1"] = "unfinished",
    ["2"] = "unfinished",
    ["3"] = "unfinished",
    ["4"] = "unfinished",
    ["5"] = "go_task",
    ["6"] = "unfinished",
    ["7"] = "go_task",
    ["8"] = "unfinished",
    ["9"] = "unfinished",
    ["10"] = "unfinished",
    ["11"] = "unfinished",
    ["12"] = "go_task",
}

local specialTaskType = {
    chargeTaskID = "chargeTaskID",
    careerTaskID = "careerTaskID",
    worldTourTaskID = "worldTourTaskID", 
}

local guildArrowShowThreshold  = 3
local memberArrowShowThreshold  = 4
function GuildTaskRewardItemView:ctor()
    self.content = self.___ex.content
    self.btnCollect = self.___ex.btnCollect
    self.collectedTag = self.___ex.collectedTag
    self.btnDisable = self.___ex.btnDisable
    self.numText = self.___ex.num
    self.disabledtext = self.___ex.disabledtext
    self.lArrow = self.___ex.lArrow
    self.rArrow = self.___ex.rArrow
    self.collectText = self.___ex.collectText
    self.taskDescText = self.___ex.taskDescText
    self.btnEffect = self.___ex.btnEffect
    self.progressText = self.___ex.progressText
    self.scrollRect = self.___ex.scrollRect
    self.guildRewardRect = self.___ex.guildRewardRect
    self.select = self.___ex.select
    self.cumulativeConsumeItemScrollAtOnce = self.___ex.cumulativeConsumeItemScrollAtOnce

    self.btnCollect:regOnButtonClick(function()
        self:ClickCollectBtn()
    end)
end

function GuildTaskRewardItemView:InitView(data, parentRect, activityModel, isGuildTask)
    if not data or not next(data) then return end

    GameObjectHelper.FastSetActive(self.select, false)
    self.activityModel = activityModel
    self.isGuildTask = isGuildTask
    local arrowShowThreshold = memberArrowShowThreshold
    if self.isGuildTask then
        arrowShowThreshold = guildArrowShowThreshold
    end
    self:BindScrollFunc(arrowShowThreshold)
    self.model = MascotPresentRIViewModel.new(data)

    res.ClearChildren(self.content)
    local rewardContents = self.model:GetContents()
    self:InitRewardItems(self.content, rewardContents)
    self:UpdataBtnState()

    self.taskDescText.text = tostring(self.model:GetTaskDesc())
    local currentProgressValue = string.formatNumWithUnit(self.model:GetCurrentProgressValue())
    local progressValue = string.formatNumWithUnit(self.model:GetTaskProgressValue())
    self.progressText.text = currentProgressValue .. "/" .. progressValue

    GameObjectHelper.FastSetActive(self.lArrow, false)
    GameObjectHelper.FastSetActive(self.rArrow, self.model:IsArrowsShow(arrowShowThreshold))

    self.cumulativeConsumeItemScrollAtOnce.scrollRectInParent = parentRect

    self:ShowGuildRewardAlone()
end

function GuildTaskRewardItemView:BindScrollFunc(arrowShowThreshold)
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
end

function GuildTaskRewardItemView:ShowGuildRewardAlone()
    if self.isGuildTask and self.guildRewardRect then
        local rewardContents = self.model:GetGuildReward()
        res.ClearChildren(self.guildRewardRect)
        self:InitRewardItems(self.guildRewardRect, rewardContents)
    end
end

function GuildTaskRewardItemView:InitRewardItems(parentRect, rewardContents)
    local rewardParams = {
        parentObj = parentRect,
        rewardData = rewardContents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowCardPieceBeforeItem = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function GuildTaskRewardItemView:start()
    EventSystem.AddEvent("ChangeMascotPresentRewardItemButtonState", self, self.UpdataBtnState)
end

function GuildTaskRewardItemView:UpdataBtnState()
    GameObjectHelper.FastSetActive(self.btnEffect, false)

    if self.model:IsRewardAlreadyCollected() then
        GameObjectHelper.FastSetActive(self.collectedTag, true)
        GameObjectHelper.FastSetActive(self.btnCollect.gameObject, false)
        GameObjectHelper.FastSetActive(self.btnDisable, false)
        GameObjectHelper.FastSetActive(self.select, true)
    else
        GameObjectHelper.FastSetActive(self.collectedTag, false)
        if self.model:IsRewardCollectable() then
            GameObjectHelper.FastSetActive(self.btnCollect.gameObject, true)
            GameObjectHelper.FastSetActive(self.btnEffect, true)
            GameObjectHelper.FastSetActive(self.btnDisable, false)
            self.collectText.text = lang.transstr("receive")
            GameObjectHelper.FastSetActive(self.select, true)
        elseif self.activityModel:GetActivityState() then
            local btnTipKey = self.model:GetTaskType()
            local isDisableShow = btnTip[tostring(btnTipKey)] == "unfinished"
            local btnTextStr = isDisableShow and lang.transstr("unfinished") or lang.transstr("go_task")
            GameObjectHelper.FastSetActive(self.btnCollect.gameObject, not isDisableShow)
            GameObjectHelper.FastSetActive(self.btnEffect, false)
            GameObjectHelper.FastSetActive(self.btnDisable, isDisableShow)
            self.disabledtext.text = btnTextStr
            self.collectText.text = btnTextStr
        else
            GameObjectHelper.FastSetActive(self.btnCollect.gameObject, false)
            GameObjectHelper.FastSetActive(self.btnDisable, true)
            self.disabledtext.text = lang.transstr("belatedGift_item_nil_time")
        end
    end
end

function GuildTaskRewardItemView:UpdateArrowState(isShowL, isShowR)
    GameObjectHelper.FastSetActive(self.lArrow, isShowL)
    GameObjectHelper.FastSetActive(self.rArrow, isShowR)
end

function GuildTaskRewardItemView:ClickCollectBtn()
    if self.model:IsRewardCollectable() then
        self:CollectReward()
    else
        local taskID = self.model:GetTaskType()
        local specialTask = self.model:SpecifyTaskType(taskID)
        if specialTask == specialTaskType.chargeTaskID then
            res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", nil, nil, true)
        elseif specialTask == specialTaskType.careerTaskID then
            UIBgmManager.play("Quest/questEnter")
            local questPageCtrl = res.PushSceneImmediate("ui.controllers.quest.QuestPageCtrl", nil, nil, nil, true)
            if not GuideManager.GuideIsOnGoing("main") then
                EventSystem.SendEvent("GuideManager.MainGuideEnd")
            end
        elseif specialTask == specialTaskType.worldTourTaskID then
            local playerInfoModel = PlayerInfoModel.new()
            local playerLvl = playerInfoModel:GetLevel()
            local worldTourLvlLimit = 40
            if playerLvl >= worldTourLvlLimit then
                res.PushScene("ui.controllers.transfort.TransportMainCtrl")
            else
                DialogManager.ShowToast(lang.trans("mascotPresent_desc25"))
            end
        end
    end
end

function GuildTaskRewardItemView:CollectReward()
    self:coroutine(function()
        local period = self.activityModel:GetActivityPeriod()
        local taskID = self.model:GetTaskID()

        local respone = req.mascotPresentCollectTaskReward(period, taskID)
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) then

                self.model:SetRewardStateCollected()
                self:UpdataBtnState()
                EventSystem.SendEvent("MascotPresent_RefreshGorMRewardRP")

                local addMascotPoint = self.model:GetRewardMascotPoint()
                self.activityModel:AddMyGuildMascotPoint(addMascotPoint)
                EventSystem.SendEvent("MascotPresent_RefreshGuildPointAndProgressGiftArea") 

                CongratulationsPageCtrl.new(data.gift, false)
            end
        end
    end)        
end

function GuildTaskRewardItemView:onDestroy()
    EventSystem.RemoveEvent("ChangeMascotPresentRewardItemButtonState", self, self.UpdataBtnState)
end

return GuildTaskRewardItemView

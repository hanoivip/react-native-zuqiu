local CoachMissionDetail = require("data.CoachMissionDetail")
local Timer = require('ui.common.Timer')
local AssetFinder = require("ui.common.AssetFinder")
local CoachMissionItem = require("data.CoachMissionItem")
local CommonConstants = require("ui.common.CommonConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CoachTaskHelper = require("ui.scene.coach.coachTask.CoachTaskHelper")
local CoachTaskState = require("ui.scene.coach.coachTask.CoachTaskState")

local CoachTaskItemView = class(unity.base)

function CoachTaskItemView:ctor()
    self.qualityImg = self.___ex.qualityImg
    self.descTxt = self.___ex.descTxt
    self.leftTimeTxt = self.___ex.leftTimeTxt
    self.qualityIconImg = self.___ex.qualityIconImg
    self.rewardTrans = self.___ex.rewardTrans
    self.acceptedGo = self.___ex.acceptedGo
    self.executingGo = self.___ex.executingGo
    self.completeGo = self.___ex.completeGo
    self.rewardBtn = self.___ex.rewardBtn
    self.unacceptedBtn = self.___ex.unacceptedBtn
    self.specialRewardTrans = self.___ex.specialRewardTrans
end

function CoachTaskItemView:InitView(data, coachTaskModel)
    local state = data.state
    self:StopTimer()
    self:SetBtnState(state)
    local iconRes = AssetFinder.GetCoachTaskQuality(data.cq)
    self.qualityIconImg.overrideSprite = iconRes
    local bgRes = AssetFinder.GetCoachTaskQualityBG(data.cq)
    self.qualityImg.overrideSprite = bgRes
    local taskTitle = self:GetTaskTitle(data)
    self.descTxt.text = lang.trans("coach_task_title", taskTitle)
    self:SetTime(data, coachTaskModel)
end

function CoachTaskItemView:SetTime(data, coachTaskModel)
    local totalTime = 0
    for i,v in ipairs(data.cond) do
        local index = tostring(v)
        totalTime = totalTime + CoachMissionDetail[index].missionTime
    end
    totalTime = totalTime * 60
    local state = data.state
    if state == CoachTaskState.Unaccepted then
        local allTime = (totalTime / 60) .. lang.transstr("minute")
        self.leftTimeTxt.text = lang.transstr("coach_task_remainTime") .. allTime
    elseif state == CoachTaskState.Executing then
        local serverDeltaTime = cache.getServerDeltaTimeValue()
        local osTime = coachTaskModel:GetOSTime()
        local beginTime = data.bt
        local endTime = beginTime + totalTime
        self:UpdateResidualTimeText(endTime - osTime)
    elseif state == CoachTaskState.Accepted then
        self.leftTimeTxt.text = ""
    else
        self.leftTimeTxt.text = lang.transstr("finished_cumulative_login")
    end
    self:BuildReward(data)
end

function CoachTaskItemView:BuildReward(data)
    local commonReward = {}
    local specialReward = {}
    for i,v in ipairs(data.reward) do
        local missionItemData = CoachMissionItem[tostring(v)]
        -- CoachMissionItem order 标记不为0的为特殊物品分开显示
        if missionItemData.order == 0 then
            table.insert(commonReward, v)
        else
            table.insert(specialReward, v)
        end
    end
    self:BuildCommonReward(commonReward)
    self:BuildSpecialReward(specialReward)
end

function CoachTaskItemView:BuildCommonReward(rewards)
    local reward = CoachTaskHelper.CombineReward(rewards)
    res.ClearChildren(self.rewardTrans)
    local rewardParams = {
        parentObj = self.rewardTrans,
        rewardData = reward,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function CoachTaskItemView:BuildSpecialReward(rewards)
    local reward = CoachTaskHelper.CombineReward(rewards)
    res.ClearChildren(self.specialRewardTrans)
    local rewardParams = {
        parentObj = self.specialRewardTrans,
        rewardData = reward,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function CoachTaskItemView:StopTimer()
    if self.countDownTimer ~= nil then
        self.countDownTimer:Destroy()
    end
end

function CoachTaskItemView:UpdateResidualTimeText(residualSeconds)
    local residualSeconds = tonumber(residualSeconds)
    local timeTitle = lang.transstr("guildwar_remainTime")
    if self.countDownTimer ~= nil then self.countDownTimer:Destroy() end
    self.countDownTimer = Timer.new(residualSeconds, function(time)
        if time > 0 then
            local str =string.convertSecondToTime(time)
            self.leftTimeTxt.text =  timeTitle .. str
        else
            EventSystem.SendEvent("CoachTaskCtrl_TaskTimeOut")
        end
    end)
end

function CoachTaskItemView:SetBtnState(state)
    GameObjectHelper.FastSetActive(self.acceptedGo, state == CoachTaskState.Accepted)
    GameObjectHelper.FastSetActive(self.executingGo, state == CoachTaskState.Executing)
    GameObjectHelper.FastSetActive(self.completeGo, state == CoachTaskState.Complete)
    GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, state == CoachTaskState.Reward)
    GameObjectHelper.FastSetActive(self.unacceptedBtn.gameObject, state == CoachTaskState.Unaccepted)
end

function CoachTaskItemView:onDestroy()
    self:StopTimer()
end

function CoachTaskItemView:GetTaskTitle(data)
    local nameTable = {}
    for key, v in pairs(data.cond) do
        local index = tostring(v)
        local detailData = CoachMissionDetail[index]
        local nameType = detailData.nameType
        local nameTxt = detailData.name
        nameTable[nameType] = nameTxt
    end
    local firstType = nameTable[CoachTaskHelper.NameType.FirstType] or ""
    local secondType = nameTable[CoachTaskHelper.NameType.SecondType] or ""
    return firstType .. secondType
end

return CoachTaskItemView

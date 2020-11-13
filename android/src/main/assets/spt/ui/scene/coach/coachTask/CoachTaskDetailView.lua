local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local CoachTaskHelper = require("ui.scene.coach.coachTask.CoachTaskHelper")
local CoachTaskPlayerChooseModel = require("ui.models.coach.coachTask.CoachTaskPlayerChooseModel")

local CoachTaskDetailView = class(unity.base)

function CoachTaskDetailView:ctor()
    self.acceptBtn = self.___ex.acceptBtn
    self.qualityIconImg = self.___ex.qualityIconImg
    self.qualityImg = self.___ex.qualityImg
    self.rewardTrans = self.___ex.rewardTrans
    self.leftTimeTxt = self.___ex.leftTimeTxt
    self.cardAreaTrans = self.___ex.cardAreaTrans
    self.descTxt = self.___ex.descTxt
    self.specialRewardTrans = self.___ex.specialRewardTrans

    self.taskDescTxt = {self.___ex.taskDesc1Txt, self.___ex.taskDesc2Txt, self.___ex.taskDesc3Txt, self.___ex.taskDesc4Txt, self.___ex.taskDesc5Txt,}
    self.cardTrans = {}
    self.selectCardSpt = {}
end

function CoachTaskDetailView:start()
    self.acceptBtn:regOnButtonClick(function() self:OnAcceptClick() end)
    self:RegisterEvent()
end

function CoachTaskDetailView:InitView(coachTaskDetailModel)
    self.coachTaskDetailModel = coachTaskDetailModel
    local coachTaskQuality = self.coachTaskDetailModel:GetCoachTaskQuality()
    local iconRes = AssetFinder.GetCoachTaskQuality(coachTaskQuality)
    self.qualityIconImg.overrideSprite = iconRes
    local bgRes = AssetFinder.GetCoachTaskQualityBG(coachTaskQuality)
    self.qualityImg.overrideSprite = bgRes

    local totalTime = self.coachTaskDetailModel:GetTaskTotalTime()
    self.leftTimeTxt.text = totalTime


    local taskTitle = self.coachTaskDetailModel:GetTaskTitle()
    self.descTxt.text = lang.trans("coach_task_title", taskTitle)

    local desc = self.coachTaskDetailModel:GetTaskDesc()
    for i,v in ipairs(self.taskDescTxt) do
        if desc[i] then
            self.taskDescTxt[i].text = desc[i]
            GameObjectHelper.FastSetActive(self.taskDescTxt[i].gameObject, true)
        else
            GameObjectHelper.FastSetActive(self.taskDescTxt[i].gameObject, false)
        end
    end
    self:BuildReward()
    self:BuidCardArea()
end

function CoachTaskDetailView:RefreshSelectArea()
    local selectPcidMap = self.coachTaskDetailModel:GetSelectPcidMap()
    for k, pcid in pairs(selectPcidMap) do
        if not self.selectCardSpt[k] then
            local avatarBoxObj, avatarBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/PlayerAvatarBox.prefab")
            avatarBoxObj.transform:SetParent(self.cardTrans[k], false)
            self.selectCardSpt[k] = avatarBoxView
        end
        local playerCardModel = SimpleCardModel.new(pcid)
        local cardId = playerCardModel:GetCid()
        self.selectCardSpt[k]:InitView(cardId, 0, false, true)
    end
end

function CoachTaskDetailView:OnAcceptClick()
    if self.onAcceptClick then
        self.onAcceptClick()
    end
end

function CoachTaskDetailView:OnCardSelectClick(index)
    local data = self.coachTaskDetailModel:GetTaskData()
    local selectPcidMap = self.coachTaskDetailModel:GetSelectPcidMap()
    local taskCardInfo = self.coachTaskDetailModel:GetTaskCardInfo()
    local coachTaskPlayerChooseModel = CoachTaskPlayerChooseModel.new(data, index, selectPcidMap, taskCardInfo)
    res.PushDialog("ui.controllers.coach.coachTask.CoachTaskPlayerChooseCtrl", coachTaskPlayerChooseModel)
end

function CoachTaskDetailView:BuildReward()
    self:BuildCommonReward()
    self:BuildSpecialReward()
end

function CoachTaskDetailView:BuildCommonReward()
    local data = self.coachTaskDetailModel:GetCommonReward()
    local reward = CoachTaskHelper.CombineReward(data)
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

function CoachTaskDetailView:BuildSpecialReward()
    local data = self.coachTaskDetailModel:GetSpecialReward()
    local reward = CoachTaskHelper.CombineReward(data)
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

function CoachTaskDetailView:BuidCardArea()
    local playerNeed = CoachTaskHelper.CoachMissionConfig.playerNeed
    for i = 1 , playerNeed do
        local placeObj, placeSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Coach/CoachTask/CoachTaskDetailCardPlaceItem.prefab")
        local index = i
        table.insert(self.cardTrans, placeSpt.cardTrans)
        placeSpt.addBtn:regOnButtonClick(function() self:OnCardSelectClick(index) end)
        placeObj.transform:SetParent(self.cardAreaTrans, false)
    end
end

--- 注册事件
function CoachTaskDetailView:RegisterEvent()
    EventSystem.AddEvent("CoachTaskPlayerChooseCtrl_OnConfirmClick", self, self.OnCardSelect)
end

--- 移除事件
function CoachTaskDetailView:RemoveEvent()
    EventSystem.RemoveEvent("CoachTaskPlayerChooseCtrl_OnConfirmClick", self, self.OnCardSelect)
end

function CoachTaskDetailView:OnCardSelect(selectPcid, clickIndex)
    self.coachTaskDetailModel:SetSelectPcidMap(selectPcid, clickIndex)
    self:RefreshSelectArea()
end

function CoachTaskDetailView:Close()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function CoachTaskDetailView:onDestroy()
    self:RemoveEvent()
end

return CoachTaskDetailView

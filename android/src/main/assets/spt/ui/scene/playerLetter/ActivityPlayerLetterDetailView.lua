local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Color = UnityEngine.Color
local Image = UI.Image
local Text = UI.Text
local Button = UI.Button
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav

local PlayerLetterConstants = require("ui.scene.playerLetter.PlayerLetterConstants")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CommonConstants = require("ui.common.CommonConstants")
local AssetFinder = require("ui.common.AssetFinder")
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerLetterDetailBaseView = require("ui.scene.playerLetter.PlayerLetterDetailBaseView")

local ActivityPlayerLetterDetailView = class(PlayerLetterDetailBaseView)

function ActivityPlayerLetterDetailView:ctor()
    ActivityPlayerLetterDetailView.super.ctor(self)
end

function ActivityPlayerLetterDetailView:awake()
    ActivityPlayerLetterDetailView.super.awake(self)
end

function ActivityPlayerLetterDetailView:InitView(activityPlayerLetterDetailViewModel, letterIndex) 
    self.playerCardStaticModel = StaticCardModel.new()
    self.activityPlayerLetterDetailViewModel = activityPlayerLetterDetailViewModel
    self.letterIndex = letterIndex
    self.playerCardId = activityPlayerLetterDetailViewModel:GetCardIdByIndex(self.letterIndex)
end

function ActivityPlayerLetterDetailView:OnEnterView()
    ActivityPlayerLetterDetailView.super.OnEnterView(self)
end

function ActivityPlayerLetterDetailView:BindAll()
    -- 回复按钮
    self.replyBtn:regOnButtonClick(function ()
        local state = self.activityPlayerLetterDetailViewModel:GetRewardStatesByIndex(self.letterIndex)
        -- 未完成
        if state == PlayerLetterConstants.LetterState.UNFINISHED then
            DialogManager.ShowToastByLang("playerMail_unfinishedTips")
        -- 已达成，但未领奖
        elseif state == PlayerLetterConstants.LetterState.NOT_AWARD then
            EventSystem.SendEvent("ActivityPlayerLetter.ReplyLetter", self.letterIndex)
        -- 已领奖
        else
            DialogManager.ShowToastByLang("playerMail_haveAwardedTips")
        end
    end)

    self.cardAreaButton:regOnButtonClick(function ()
        EventSystem.SendEvent("ActivityPlayerLetterDetail.ShowCardDetail", self.playerCardId)
    end)

    self.avatarBoxButton:regOnButtonClick(function ()
        EventSystem.SendEvent("ActivityPlayerLetterDetail.ShowCardDetail", self.playerCardId)
    end)

    self.shareBtn:regOnButtonClick(function()
        self:OnBtnShareClick()
    end)
end

-- 注册事件
function ActivityPlayerLetterDetailView:RegisterEvent()
    EventSystem.AddEvent("ActivityPlayerLetterDetailView.InitView", self, self.InitView)
    EventSystem.AddEvent("ActivityPlayerLetterDetailView.OnEnterView", self, self.OnEnterView)
    EventSystem.AddEvent("ActivityPlayerLetterDetailView.BuildReplyBtn", self, self.BuildReplyBtn)
    EventSystem.AddEvent("ActivityPlayerLetterDetailView.Destroy", self, self.Destroy)
    EventSystem.AddEvent("ActivityPlayerLetterDetailView.SendCardId", self, self.SetRewardPlayerCardId)
end

-- 移除事件
function ActivityPlayerLetterDetailView:RemoveEvent()  
    EventSystem.RemoveEvent("ActivityPlayerLetterDetailView.InitView", self, self.InitView)
    EventSystem.RemoveEvent("ActivityPlayerLetterDetailView.OnEnterView", self, self.OnEnterView)
    EventSystem.RemoveEvent("ActivityPlayerLetterDetailView.BuildReplyBtn", self, self.BuildReplyBtn)
    EventSystem.RemoveEvent("ActivityPlayerLetterDetailView.Destroy", self, self.Destroy)
    EventSystem.RemoveEvent("ActivityPlayerLetterDetailView.SendCardId", self, self.SetRewardPlayerCardId)
end

function ActivityPlayerLetterDetailView:BuildView()
    local playerName =  self.activityPlayerLetterDetailViewModel:GetCardNameByIndex(self.letterIndex)
    local conditionSum = self.activityPlayerLetterDetailViewModel:GetQuestConditionDecCountByIndex(self.letterIndex)
    local completedConditionSum = self.activityPlayerLetterDetailViewModel:GetFinishedCountByIndex(self.letterIndex)
    self.playerCardStaticModel:InitWithCache(self.playerCardId)
    self.title.text = lang.trans("activity_playerLetterTitle", playerName)
    self.titleDesc.text = lang.trans("activity_playerLetterContent", playerName)
    self.progress.text = completedConditionSum .. "/" .. conditionSum
    self.progressBar.value = completedConditionSum / conditionSum
    self.avatarImg.sprite = AssetFinder.GetPlayerIcon(self.playerCardStaticModel:GetAvatar())

    if self.cardArea.childCount > 0 then
        local card = self.cardArea:GetChild(0)
        local script = card:GetComponent(CapsUnityLuaBehav)
        script:InitView(self.playerCardStaticModel)
    else
        local card = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        card.transform:SetParent(self.cardArea, false)
        local script = card:GetComponent(CapsUnityLuaBehav)
        script:InitView(self.playerCardStaticModel)
    end

    self:BuildReplyBtn()
    self:BuildQuestConditionList(self.questConditionList1)
end

--- 构建卡牌收集条件列表
function ActivityPlayerLetterDetailView:BuildQuestConditionList(parent)
    local obj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerLetter/ActivityQuestConditionItem.prefab")
    res.ClearChildren(parent)
    local questConditionDecList = self.activityPlayerLetterDetailViewModel:GetQuestConditionDecListByIndex(self.letterIndex)
    local questConditionParamList = self.activityPlayerLetterDetailViewModel:GetQuestConditionParamListByIndex(self.letterIndex)
    for id, state in pairs(questConditionParamList) do
        local conditionData = {}
        conditionData.id = id
        conditionData.state = state
        conditionData.dec = questConditionDecList[id]
        local viewObj = Object.Instantiate(obj)
        viewObj.transform:SetParent(parent, false)
        local script = viewObj:GetComponent(CapsUnityLuaBehav)
        script:InitView(conditionData)
    end
end

--- 构建回复按钮
function ActivityPlayerLetterDetailView:BuildReplyBtn(stateParam)
    local state
    if stateParam ~= nil then 
        state = stateParam
     else
        state = self.activityPlayerLetterDetailViewModel:GetRewardStatesByIndex(self.letterIndex)
    end
    local isCanAward = state == PlayerLetterConstants.LetterState.NOT_AWARD
    self.replyBtn.gameObject:GetComponent(Button).interactable = isCanAward
    GameObjectHelper.FastSetActive(self.replyGold.gameObject, isCanAward)
    GameObjectHelper.FastSetActive(self.replyGray.gameObject, not isCanAward)
    -- 未完成
    if state == PlayerLetterConstants.LetterState.UNFINISHED then
        self.replyGray.text = lang.trans("reply")
        GameObjectHelper.FastSetActive(self.shareBtn.gameObject, false)
    -- 已达成，但未领奖
    elseif state == PlayerLetterConstants.LetterState.NOT_AWARD then
        self.replyGold.text = lang.trans("reply")
        GameObjectHelper.FastSetActive(self.shareBtn.gameObject, false)
    -- 已领奖
    else
        self.replyGray.text = lang.trans("playerMail_haveReply")
    end
end

function ActivityPlayerLetterDetailView:SetRewardPlayerCardId(cid)
    self.getCid = cid
end

function ActivityPlayerLetterDetailView:PlayMoveInAnim()
    ActivityPlayerLetterDetailView.super.PlayMoveInAnim(self)
end

function ActivityPlayerLetterDetailView:PlayMoveOutAnim()
    ActivityPlayerLetterDetailView.super.PlayMoveOutAnim(self)
end

function ActivityPlayerLetterDetailView:Close()
    ActivityPlayerLetterDetailView.super.Close(self)
end

function ActivityPlayerLetterDetailView:Destroy()
    ActivityPlayerLetterDetailView.super.Destroy(self)
end

function ActivityPlayerLetterDetailView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:Destroy()
    end
end

function ActivityPlayerLetterDetailView:onDestroy()
    ActivityPlayerLetterDetailView.super.onDestroy(self)
end

return ActivityPlayerLetterDetailView

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
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local ShareHelper = require("ui.common.ShareHelper")
local ShareConstants = require("ui.scene.shareSDK.ShareConstants")

local PlayerLetterDetailBaseView = class(unity.base)

function PlayerLetterDetailBaseView:ctor()
    -- 标题
    self.title = self.___ex.title
    -- 标题描述
    self.titleDesc = self.___ex.titleDesc
    -- 信件内容
    self.letterContent = self.___ex.letterContent
    -- 进度
    self.progress = self.___ex.progress
    -- 回复按钮
    self.replyBtn = self.___ex.replyBtn
    -- 通关副本条件列表1
    self.questConditionList1 = self.___ex.questConditionList1
    -- 通关副本条件列表2
    self.questConditionList2 = self.___ex.questConditionList2
    -- 收集卡牌条件列表
    self.playerConditionList = self.___ex.playerConditionList
    -- 头像
    self.avatarImg = self.___ex.avatarImg
    -- 回复按钮显示文字的颜色
    self.replyGold = self.___ex.replyGold
    self.replyGray = self.___ex.replyGray
    -- 信封上卡牌显示区域
    self.cardArea = self.___ex.cardArea
    -- 动画管理器
    self.animator = self.___ex.animator
    self.cardAreaButton = self.___ex.cardAreaButton
    self.avatarBoxButton = self.___ex.avatarBoxButton
    -- 特效框
    self.effectBox = self.___ex.effectBox
    -- 进度条
    self.progressBar = self.___ex.progressBar
    -- 分享按钮
    self.shareBtn = self.___ex.shareBtn
    -- 分享奖励信息
    self.shareInfo = self.___ex.shareInfo
    -- 奖励信息文字
    self.shareInfoText = self.___ex.shareInfoText
    -- 信函Id
    self.letterID = nil
    -- 球员信函详情视图模型
    self.playerLetterDetailViewModel = nil
    -- 球员信函单个信件的model
    self.playerLetterItemModel = nil
    -- 完成条件
    self.finishCondition = nil
end

function PlayerLetterDetailBaseView:awake()
    self:RegisterEvent()
    self:BindAll()
end

function PlayerLetterDetailBaseView:OnEnterView()
    self:BuildView()
end

function PlayerLetterDetailBaseView:BindAll()
    -- 回复按钮
    self.replyBtn:regOnButtonClick(function ()
        -- 未完成
        if self:StateIsUnfinished() then
            DialogManager.ShowToastByLang("playerMail_unfinishedTips")
        -- 已达成，但未领奖
        elseif self:StateIsNotAward() then
            EventSystem.SendEvent("PlayerLetter.ReplyLetter", self.letterID)
        -- 已领奖
        else
            DialogManager.ShowToastByLang("playerMail_haveAwardedTips")
        end
    end)

    self.cardAreaButton:regOnButtonClick(function ()
        EventSystem.SendEvent("PlayerLetterDetail.ShowCardDetail", self.letterCardId)
    end)

    self.avatarBoxButton:regOnButtonClick(function ()
        EventSystem.SendEvent("PlayerLetterDetail.ShowCardDetail", self.letterCardId)
    end)

    self.shareBtn:regOnButtonClick(function()
        self:OnBtnShareClick()
    end)
end

function PlayerLetterDetailBaseView:SetViewOnShareRender()
    GameObjectHelper.FastSetActive(self.shareBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.replyBtn.gameObject, true)
end

function PlayerLetterDetailBaseView:SetViewOnShareRenderComplete()
    GameObjectHelper.FastSetActive(self.shareBtn.gameObject, true)
    GameObjectHelper.FastSetActive(self.replyBtn.gameObject, false)
end

function PlayerLetterDetailBaseView:UpdateShareTaskState()
    GameObjectHelper.FastSetActive(self.shareInfo, not cache.getIsShareTaskComplete())
end

function PlayerLetterDetailBaseView:SetViewOnShareComplete()
    GameObjectHelper.FastSetActive(self.shareInfo, not cache.getIsShareTaskComplete())
end

function PlayerLetterDetailBaseView:OnShareComplete()
    self:SetViewOnShareComplete()
end

function PlayerLetterDetailBaseView:OnShareCancel()
    self:SetViewOnShareRenderComplete()
end

-- 注册事件
function PlayerLetterDetailBaseView:RegisterEvent()
    EventSystem.AddEvent("PlayerLetterDetail.InitView", self, self.InitView)
    EventSystem.AddEvent("PlayerLetterDetail.OnEnterView", self, self.OnEnterView)
    EventSystem.AddEvent("PlayerLetterDetail.BuildReplyBtn", self, self.BuildReplyBtn)
    EventSystem.AddEvent("PlayerLetterDetail.Destroy", self, self.Destroy)
    EventSystem.AddEvent("PlayerLetter.SendCardId", self, self.SetRewardPlayerCardId)
    EventSystem.AddEvent("ShareRenderComplete", self, self.SetViewOnShareRenderComplete)
    EventSystem.AddEvent("ShareTask_UpdateState", self, self.UpdateShareTaskState)
    luaevt.reg("ShareSDK_OnComplete", function(cate, action)
        self:OnShareComplete()
    end)
    luaevt.reg("ShareSDK_OnCancel", function(cate, action)
        self:OnShareCancel()
    end)
end

-- 移除事件
function PlayerLetterDetailBaseView:RemoveEvent()  
    EventSystem.RemoveEvent("PlayerLetterDetail.InitView", self, self.InitView)
    EventSystem.RemoveEvent("PlayerLetterDetail.OnEnterView", self, self.OnEnterView)
    EventSystem.RemoveEvent("PlayerLetterDetail.BuildReplyBtn", self, self.BuildReplyBtn)
    EventSystem.RemoveEvent("PlayerLetterDetail.Destroy", self, self.Destroy)
    EventSystem.RemoveEvent("PlayerLetter.SendCardId", self, self.SetRewardPlayerCardId)
    EventSystem.RemoveEvent("ShareRenderComplete", self, self.SetViewOnShareRenderComplete)
    EventSystem.RemoveEvent("ShareTask_UpdateState", self, self.UpdateShareTaskState)
    luaevt.unreg("ShareSDK_OnComplete")
    luaevt.unreg("ShareSDK_OnCancel")
end

function PlayerLetterDetailBaseView:BuildView()
    local staticData = self.playerLetterItemModel:GetStaticData()
    local conditionSum = self.playerLetterItemModel:GetConditionSum()
    local completedConditionSum = self.playerLetterItemModel:GetCompletedConditionSum()
    self.letterCardId = staticData.contents.card[1].id
    self.playerCardStaticModel:InitWithCache(self.letterCardId)
    self.title.text = staticData.title
    self.letterContent.text = staticData.text
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

    -- 如果有收集卡牌的条件
    if self.finishCondition.card ~= nil then
        self.titleDesc.text = lang.trans("playerMail_playerCondition")
        self.questConditionList1.gameObject:SetActive(false)
        self.questConditionList2.gameObject:SetActive(false)
        self.playerConditionList.gameObject:SetActive(true)
        self:BuildPlayerConditionList()
    else
        self.titleDesc.text = lang.trans("playerMail_questCondition")
        self.playerConditionList.gameObject:SetActive(false)
        -- 如果条件数量大于3，则构建通关副本条件列表2，因为列表1最多显示3个
        if conditionSum > 3 then
            self.questConditionList1.gameObject:SetActive(false)
            self.questConditionList2.gameObject:SetActive(true)
            self:BuildQuestConditionList(self.questConditionList2)
        else
            self.questConditionList1.gameObject:SetActive(true)
            self.questConditionList2.gameObject:SetActive(false)
            self:BuildQuestConditionList(self.questConditionList1)
        end
    end
end

--- 构建通关副本条件列表
function PlayerLetterDetailBaseView:BuildQuestConditionList(parent)

end

--- 构建收集卡牌条件列表
function PlayerLetterDetailBaseView:BuildPlayerConditionList()
    local obj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerLetter/PlayerConditionItem.prefab")
    res.ClearChildren(self.playerConditionList)
    for cardId, conditionData in pairs(self.finishCondition.card) do
        local viewObj = Object.Instantiate(obj)
        viewObj.transform:SetParent(self.playerConditionList, false)
        local script = viewObj:GetComponent(CapsUnityLuaBehav)
        script:InitView(conditionData)
    end
end

--- 构建回复按钮
function PlayerLetterDetailBaseView:BuildReplyBtn()
    local isCanAward = self:StateIsNotAward()
    self.replyBtn.gameObject:GetComponent(Button).interactable = isCanAward
    GameObjectHelper.FastSetActive(self.replyGold.gameObject, isCanAward)
    GameObjectHelper.FastSetActive(self.replyGray.gameObject, not isCanAward)
    -- 未完成
    if self:StateIsUnfinished() then
        self.replyGray.text = lang.trans("reply")
        GameObjectHelper.FastSetActive(self.shareBtn.gameObject, false)
    -- 已达成，但未领奖
    elseif self:StateIsNotAward() then
        self.replyGold.text = lang.trans("reply")
        GameObjectHelper.FastSetActive(self.shareBtn.gameObject, false)
    -- 已领奖
    else
        self.replyGray.text = lang.trans("playerMail_haveReply")
        local isOpenShareSDK = cache.getIsOpenShareSDK()
        if isOpenShareSDK then
            GameObjectHelper.FastSetActive(self.replyBtn.gameObject, false)
            GameObjectHelper.FastSetActive(self.shareBtn.gameObject, true)
            GameObjectHelper.FastSetActive(self.shareInfo, not cache.getIsShareTaskComplete())
        end
    end
end

function PlayerLetterDetailBaseView:SetRewardPlayerCardId(cid)
    self.getCid = cid
end

function PlayerLetterDetailBaseView:OnBtnShareClick()
    self:SetViewOnShareRender()
    self:coroutine(function()
        unity.waitForNextEndOfFrame()
        ShareHelper.CaptrueCamera(ShareConstants.Type.PlayerLetter, self.playerCardStaticModel:GetName())
    end)
end

function PlayerLetterDetailBaseView:StateIsUnfinished()
    local state = self.playerLetterItemModel:GetState()
    return state == PlayerLetterConstants.LetterState.UNFINISHED
end

function PlayerLetterDetailBaseView:StateIsNotAward()
    local state = self.playerLetterItemModel:GetState()
    return state == PlayerLetterConstants.LetterState.NOT_AWARD
end

function PlayerLetterDetailBaseView:PlayMoveInAnim()
    GameObjectHelper.FastSetActive(self.effectBox, true)
    self.animator:Play("MoveIn", 0)
end

function PlayerLetterDetailBaseView:PlayMoveOutAnim()
    GameObjectHelper.FastSetActive(self.effectBox, false)
    self.animator:Play("MoveOut", 0)
end

function PlayerLetterDetailBaseView:Close()
    self:PlayMoveOutAnim()
end

function PlayerLetterDetailBaseView:Destroy()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function PlayerLetterDetailBaseView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:Destroy()
    end
end

function PlayerLetterDetailBaseView:onDestroy()
    self:RemoveEvent()
end

return PlayerLetterDetailBaseView

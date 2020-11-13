local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Color = UnityEngine.Color
local Image = UI.Image
local Text = UI.Text
local Button = UI.Button
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2

local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CommonConstants = require("ui.common.CommonConstants")
local PlayerLetterDetailBaseView = require("ui.scene.playerLetter.PlayerLetterDetailBaseView")

local PlayerLetterDetailView = class(PlayerLetterDetailBaseView)

function PlayerLetterDetailView:ctor()
    PlayerLetterDetailView.super.ctor(self)
end

function PlayerLetterDetailView:awake()
    PlayerLetterDetailView.super.awake(self)
end

function PlayerLetterDetailView:InitView(playerLetterDetailViewModel)   
    self.playerCardStaticModel = StaticCardModel.new()
    self.playerLetterDetailViewModel = playerLetterDetailViewModel
    self.playerLetterItemModel = self.playerLetterDetailViewModel:GetModel()
    self.letterID = self.playerLetterItemModel:GetID()
    self.finishCondition = self.playerLetterItemModel:GetFinishCondition()
end

function PlayerLetterDetailView:OnEnterView()
    PlayerLetterDetailView.super.OnEnterView(self)
end

function PlayerLetterDetailView:BindAll()
    PlayerLetterDetailView.super.BindAll(self) 
end

function PlayerLetterDetailView:SetViewOnShareRender()
    PlayerLetterDetailView.super.SetViewOnShareRender(self)
end

function PlayerLetterDetailView:SetViewOnShareRenderComplete()
    PlayerLetterDetailView.super.SetViewOnShareRenderComplete(self)
end

function PlayerLetterDetailView:UpdateShareTaskState()
    PlayerLetterDetailView.super.UpdateShareTaskState(self)
end

function PlayerLetterDetailView:SetViewOnShareComplete()
    PlayerLetterDetailView.super.SetViewOnShareComplete(self)
end

function PlayerLetterDetailView:OnShareComplete()
    PlayerLetterDetailView.super.OnShareComplete(self)
end

function PlayerLetterDetailView:OnShareCancel()
    PlayerLetterDetailView.super.OnShareCancel(self)
end

-- 注册事件
function PlayerLetterDetailView:RegisterEvent()
    PlayerLetterDetailView.super.RegisterEvent(self)
end

-- 移除事件
function PlayerLetterDetailView:RemoveEvent()  
    PlayerLetterDetailView.super.RemoveEvent(self)
end

function PlayerLetterDetailView:BuildView()
    PlayerLetterDetailView.super.BuildView(self)
end

--- 构建通关副本条件列表
function PlayerLetterDetailView:BuildQuestConditionList(parent)
    local obj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerLetter/QuestConditionItem.prefab")
    res.ClearChildren(parent)

    -- 如果有通关章节的条件
    if self.finishCondition.journey3 ~= nil then
        for chapterId, conditionData in pairs(self.finishCondition.journey3) do
            local viewObj = Object.Instantiate(obj)
            viewObj.transform:SetParent(parent, false)
            local script = viewObj:GetComponent(clr.CapsUnityLuaBehav)
            script:InitView(conditionData)
        end
    end

    -- 如果有通关关卡的条件
    if self.finishCondition.quest ~= nil then
        for stageId, conditionData in pairs(self.finishCondition.quest) do
            local viewObj = Object.Instantiate(obj)
            viewObj.transform:SetParent(parent, false)
            local script = viewObj:GetComponent(clr.CapsUnityLuaBehav)
            script:InitView(conditionData)
        end
    end
end

--- 构建收集卡牌条件列表
function PlayerLetterDetailView:BuildPlayerConditionList()
    PlayerLetterDetailView.super.BuildPlayerConditionList(self)
end

--- 构建回复按钮
function PlayerLetterDetailView:BuildReplyBtn()
    PlayerLetterDetailView.super.BuildReplyBtn(self)
end

function PlayerLetterDetailView:SetRewardPlayerCardId(cid)
    self.getCid = cid
end

function PlayerLetterDetailView:OnBtnShareClick()
    PlayerLetterDetailView.super.OnBtnShareClick(self)
end

function PlayerLetterDetailView:StateIsUnfinished()
    return PlayerLetterDetailView.super.StateIsUnfinished(self)
end

function PlayerLetterDetailView:StateIsNotAward()
    return PlayerLetterDetailView.super.StateIsNotAward(self)
end

function PlayerLetterDetailView:PlayMoveInAnim()
    PlayerLetterDetailView.super.PlayMoveInAnim(self)
end

function PlayerLetterDetailView:PlayMoveOutAnim()
    PlayerLetterDetailView.super.PlayMoveOutAnim(self)
end

function PlayerLetterDetailView:Close()
    PlayerLetterDetailView.super.Close(self)
end

function PlayerLetterDetailView:Destroy()
    PlayerLetterDetailView.super.Destroy(self)
end

function PlayerLetterDetailView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:Destroy()
    end
end

function PlayerLetterDetailView:onDestroy()
    PlayerLetterDetailView.super.onDestroy(self)
end

return PlayerLetterDetailView

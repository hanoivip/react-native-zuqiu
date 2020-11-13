local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local EventSystems = UnityEngine.EventSystems
local BaseCtrl = require("ui.controllers.BaseCtrl")
local LegendRoadModel = require("ui.models.legendRoad.LegendRoadModel")
local ImproveType = require("ui.models.legendRoad.LegendRoadImproveType")
local DialogManager = require("ui.control.manager.DialogManager")

local LegendRoadCtrl = class(BaseCtrl, "LegendRoadCtrl")

LegendRoadCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/LegendRoad/Prefabs/Common/LegendRoad.prefab"

function LegendRoadCtrl:ctor()
    LegendRoadCtrl.super.ctor(self)
end

function LegendRoadCtrl:Init(playerCardModel)
    self.view.onBtnBackClick = function() self:OnBtnBackClick() end
    self.view.onChapterNodeClick = function(chapterData) self:OnChapterNodeClick(chapterData) end
    self.view.onStageNodeClick = function(index) self:OnStageNodeClick(index) end
    self.view.onUnlockClick = function() self:OnUnlockClick() end
    self.view.onToggleClick = function(improveType, index) self:OnToggleClick(improveType, index) end
    self.view:ShowDisplayArea(true)
end

function LegendRoadCtrl:Refresh(playerCardModel, isInit)
    LegendRoadCtrl.super.Refresh(self)
    self.model = LegendRoadModel.new(playerCardModel)
    self.model:InitWithProtocol()
    if isInit then
        local chapterProgress, stageProgress = self.model:GetCardLegendProgress()
        self.model:SetCurrChapterId(chapterProgress)
        local stageNums = self.model:GetStageNum(chapterProgress)
        local nextStageId = tobool(tonumber(stageProgress) < stageNums) and tonumber(stageProgress) + 1 or tonumber(stageProgress)
        self.model:SetCurrStageId(nextStageId)
        self.view:InitStageRect()
    end
    local isSupported = playerCardModel:IsHasSupportCard()
    self.view:InitView(self.model, isSupported)
end

function LegendRoadCtrl:GetStatusData()
    return self.model:GetStatusData()
end

function LegendRoadCtrl:OnEnterScene()
    self.view:EnterScene()
end

function LegendRoadCtrl:OnExitScene()
    self.view:ExitScene()
end

function LegendRoadCtrl:OnToggleClick(improveType, selectSlot)
    local playerCardModel = self.model:GetCardModel()
    local pcid = playerCardModel:GetPcid()
    local chapterId = self.model:GetCurrChapterId()
    local stageId = self.model:GetCurrStageId()
    if improveType == ImproveType.Attr_Single then -- 单属性增加，3
        self.view:coroutine(function()
            local response = req.cardLegendSelectAttr(pcid, chapterId, stageId, selectSlot)
            if api.success(response) then
                local data = response.val
                local legendCardData = data.data or {}
                self.model:RefreshLegendMapModel(legendCardData)
            end
        end)
    elseif improveType == ImproveType.Skill_Single then -- 单技能等级增加，4
        self.view:coroutine(function()
            local response = req.cardLegendSelectSkill(pcid, chapterId, stageId, selectSlot)
            if api.success(response) then
                local data = response.val
                local legendCardData = data.data or {}
                self.model:RefreshLegendMapModel(legendCardData)
            end
        end)
    end
end

local EffectTime = 1
-- 管卡解锁会影响属性
function LegendRoadCtrl:OnUnlockClick()
    local playerCardModel = self.model:GetCardModel()
    local isUnlockStage, isNextUnlock = self.model:IsUnlockStage()
    if isNextUnlock then
        local isQualified = true
        local consumePieceModels = self.model:GetConsumePieceModel()
        for i, pieceModel in ipairs(consumePieceModels) do
            local consumeNum = pieceModel:GetAddNum()
            local ownedNum = self.model:GetBagPieceNum(pieceModel)
            if ownedNum < consumeNum then
                isQualified = false
                break
            end
        end

        if isQualified then -- self.view:coroutine 在WaitForSeconds 中有其它动画的时候会有几率卡住
            clr.coroutine(function()
                local pcid = playerCardModel:GetPcid()
                local chapterId = self.model:GetCurrChapterId()
                local stageId = self.model:GetCurrStageId()
                local response = req.cardLegendUnlockStage(pcid, chapterId, stageId)
                if api.success(response) then
                    local data = response.val
                    local cost = data.cost or {}
                    local legendCardData = data.data or {}
                    self.model:CostPiece(cost)
                    local stageNums = self.model:GetStageNum(chapterId)
                    local nextStageId = 0

                    local currentEventSystem = EventSystems.EventSystem.current
                    if tonumber(stageId) < stageNums then
                        nextStageId = tonumber(stageId) + 1
                        currentEventSystem.enabled = false
                        self.model:SetCurrStageId(nextStageId)
                        EventSystem.SendEvent("LegendRoad_Stage_Levelup_Effect", stageId, EffectTime)
                        coroutine.yield(WaitForSeconds(EffectTime))
                        self.model:RefreshLegendMapModel(legendCardData)
                        currentEventSystem.enabled = true
                    else
                        nextStageId = tonumber(stageId)
                        self.model:SetCurrStageId(nextStageId)
                        self.model:RefreshLegendMapModel(legendCardData)
                    end
                    currentEventSystem.enabled = true
                end
            end)
        else
            DialogManager.ShowToast(lang.trans("need_piece_enough"))
        end
    end
end

-- 点击返回按钮
function LegendRoadCtrl:OnBtnBackClick()
    res.PopScene()
end

-- 切换章节
function LegendRoadCtrl:OnChapterNodeClick(chapter)
    local currChapterId = self.model:GetCurrChapterId()
    chapter = tonumber(chapter)
    if tonumber(currChapterId) ~= chapter then
        local chapterProgress, stageProgress = self.model:GetCardLegendProgress()
        if chapter <= chapterProgress then
            local nextStageId = self.model:GetStageNum(chapter)
            if chapter == chapterProgress then
                nextStageId = stageProgress < nextStageId and tonumber(stageProgress) + 1 or nextStageId
            end
            self.model:SetCurrChapterId(chapter)
            self.model:SetCurrStageId(nextStageId)
            self.view:ChangeChapterView()
        else
            res.PushDialog("ui.controllers.legendRoad.LegendChapterPreviewCtrl", self.model, chapter)
        end
    end
end

-- 切换关卡
function LegendRoadCtrl:OnStageNodeClick(index)
    local currStageId = self.model:GetCurrStageId()
    if tonumber(currStageId) ~= tonumber(index) then
        self.model:SetCurrStageId(index)
        self.view:RefreshStageView()
    end
end

return LegendRoadCtrl

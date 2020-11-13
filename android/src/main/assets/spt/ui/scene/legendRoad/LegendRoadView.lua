local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local GameObjectHelper = require("ui.common.GameObjectHelper")

local LegendRoadView = class(unity.base, "LegendRoadView")

function LegendRoadView:ctor()
    self.btnBack = self.___ex.btnBack
    self.mainView = self.___ex.mainView
    -- 头像
    self.imgHead = self.___ex.imgHead
    -- 章节
    self.sptChapters = self.___ex.sptChapters
    -- 章节标题
    self.txtChapterTitle = self.___ex.txtChapterTitle
    -- 关卡道路
    self.rctStages = self.___ex.rctStages
    -- 关卡标题
    self.txtStageTitle = self.___ex.txtStageTitle
    -- 关卡描述
    self.txtStageDesc = self.___ex.txtStageDesc
    -- 关卡效果
    self.objImproveLocked = self.___ex.objImproveLocked
    self.objImproveUnlocked = self.___ex.objImproveUnlocked
    self.sptImproveUnlocked = self.___ex.sptImproveUnlocked
    self.lockIntroduceTxt = self.___ex.lockIntroduceTxt
    self.btnUnlock = self.___ex.btnUnlock
    self.consumeArea = self.___ex.consumeArea
    self.unlockButton = self.___ex.unlockButton

    self.stageRect = self.___ex.stageRect
    self.improveRect = self.___ex.improveRect
    self.leftStageRectTrans = self.___ex.leftStageRectTrans
    self.rightStageRectTrans = self.___ex.rightStageRectTrans
    self.btnArrow = self.___ex.btnArrow
    self.arrowRect = self.___ex.arrowRect

    self.supporterTip = self.___ex.supporterTip
    self.supporterTipTxt = self.___ex.supporterTipTxt
end

function LegendRoadView:start()
    self:ShowDisplayArea(false)
    self:RegBtnEvent()

    self.sptChapters.onChapterNodeClick = function(chapterData) self:OnChapterNodeClick(chapterData) end
end

function LegendRoadView:RegBtnEvent()
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBackClick()
    end)
    self.btnUnlock:regOnButtonClick(function()
        self:OnBtnUnlockClick()
    end)
    self.btnArrow:regOnButtonClick(function()
        self:OnBtnArrowClick()
    end)
end

function LegendRoadView:InitView(legendRoadModel, isSupported)
    self.model = legendRoadModel
    self.isSupported = isSupported
    -- 初始化上方章节显示
    self.sptChapters:InitView(self.model)
    -- 初始化关卡显示
    self:InitStagesView()
    -- 头像
    self:RefreshHeadIcon()

    self:RefreshView()
end

-- 初始化关卡显示
-- 创建该关卡的道路prefab并初始化
function LegendRoadView:InitStagesView()
    res.ClearChildren(self.rctStages)
    local obj, spt = res.Instantiate(self.model:GetCurrStageResPath())
    obj.transform:SetParent(self.rctStages, false)
    self.sptStages = spt
    self.sptStages.onStageNodeClick = function(index) self:OnStageNodeClick(index) end
    self.sptStages:InitView(self.model)
    self.sptImproveUnlocked:InitView(self.model)
end

function LegendRoadView:RefreshView()
    if not self.model then
        self:ShowDisplayArea(false)
        return
    end
    -- 上方
    self:RefreshChapterView()
    -- 右侧
    self:RefreshStageView()
    -- 底部
    self:RefreshImproveArea()
end

-- 刷新头像
function LegendRoadView:RefreshHeadIcon()
    local picIndex = tostring(self.model:GetPicIndex())
    local iconRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/LegendRoad/Bytes/Players/" .. picIndex .. ".png")
    if not table.isEmpty(iconRes) then
        self.imgHead.overrideSprite = iconRes
        GameObjectHelper.FastSetActive(self.imgHead.gameObject, true)
    else
        GameObjectHelper.FastSetActive(self.imgHead.gameObject, false)
    end
    GameObjectHelper.FastSetActive(self.supporterTip, self.isSupported)
    if self.isSupported then
        local cardModel = self.model:GetCardModel()
        local isUseSelf = cardModel:IsLegendRoadUseSelf()
        if isUseSelf then
            self.supporterTipTxt.text = lang.transstr("support_self_lr_title")
        else
            self.supporterTipTxt.text = lang.transstr("support_other_lr_title")
        end
    end
end

-- 左侧界面，与章节相关刷新
function LegendRoadView:RefreshChapterView()
    local chapterTitle = self.model:GetCurrChapterTitle()
    -- 章节标题
    self.txtChapterTitle.text = tostring(chapterTitle)
    -- 章节序列
    self.sptChapters:RefreshView()
end

function LegendRoadView:GetImproveTab()
    if not self.improveTabRes then
        self.improveTabRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/LegendRoad/Prefabs/Common/ImproveTab.prefab")
    end
    return self.improveTabRes
end

local ScrollNum = 3 --最大滑动数量
function LegendRoadView:RefreshImproveArea()
    res.ClearChildren(self.leftStageRectTrans)
    res.ClearChildren(self.rightStageRectTrans)
    local improveMap = self.model:GetCurrentChapterImprove(self.model:GetCurrChapterId())
    self.isShowArrow = false
    if next(improveMap) then
        local leftOrderMap, rightOrderMap = self.model:AllotImproveOrder(improveMap)
        self:BuildImproveTab(leftOrderMap, self.leftStageRectTrans)
        self:BuildImproveTab(rightOrderMap, self.rightStageRectTrans)
        self.isShowArrow = table.nums(leftOrderMap) > ScrollNum or table.nums(rightOrderMap) > ScrollNum
    end
    GameObjectHelper.FastSetActive(self.btnArrow.gameObject, self.isShowArrow or self.onExpand)
end

local ImproveExpandHeight = 397
local ImproveRetractHeight = 132
local StageExpandHeight = 334
local StageRetractHeight = 63
local MoveTime = 0.6
function LegendRoadView:OnBtnArrowClick()
    if self.isPlaying then return end

    self.isPlaying = true
    local improveVec2, stageVec2
    if self.onExpand then
        improveVec2 = Vector2(self.improveRect.sizeDelta.x, ImproveRetractHeight)
        stageVec2 = Vector2(self.stageRect.sizeDelta.x, StageExpandHeight)
    else
        improveVec2 = Vector2(self.improveRect.sizeDelta.x, ImproveExpandHeight)
        stageVec2 = Vector2(self.stageRect.sizeDelta.x, StageRetractHeight)
    end
    local moveInTweener = ShortcutExtensions.DOSizeDelta(self.improveRect, improveVec2, MoveTime, false)
    TweenSettingsExtensions.SetEase(moveInTweener, Ease.OutCubic)
    TweenSettingsExtensions.OnComplete(moveInTweener, function ()
        self.isPlaying = false
        self.onExpand = not self.onExpand
        local scaleY = self.onExpand and -1 or 1
        self.arrowRect.localScale = Vector3(1, scaleY, 1)
        GameObjectHelper.FastSetActive(self.btnArrow.gameObject, self.isShowArrow or self.onExpand)
    end)
end

function LegendRoadView:InitStageRect()
    local improveVec2 = Vector2(self.improveRect.sizeDelta.x, ImproveRetractHeight)
    self.improveRect.sizeDelta = improveVec2
    self.arrowRect.localScale = Vector3(1, 1, 1)
    self.onExpand = false
end

function LegendRoadView:BuildImproveTab(orderMap, areaRect, improveTabRes)
    local cardModel = self.model:GetCardModel()
    for i, v in ipairs(orderMap) do
        local tabObject = Object.Instantiate(self:GetImproveTab())
        tabObject.transform:SetParent(areaRect, false)
        local tabView = res.GetLuaScript(tabObject)
        tabView:InitView(v, cardModel)
    end
end

function LegendRoadView:RefreshStageNodes()
    if self.sptStages ~= nil then
        self.sptStages:RefreshView()
    end
end

-- 右侧界面，与关卡相关刷新
function LegendRoadView:RefreshStageView()
    local stageDetailData = self.model:GetCurrStageDetailData()
    -- 关卡标题
    self.txtStageTitle.text = tostring(stageDetailData.stageTitle)
    -- 关卡描述
    self.txtStageDesc.text = tostring(stageDetailData.stageDesc)
    -- 当前关卡效果
    local isShowUnlocked, isNextUnlock = self.model:IsUnlockStage()
    local cardModel = self.model:GetCardModel()
    local isLrUseSelf = cardModel:IsLegendRoadUseSelf()
    stageDetailData = self.model:GetCurrStageDetailData()
    local improveConfig = stageDetailData.improveConfig
    local desc = self.model:GetUnlockedDesc(improveConfig)
    self.lockIntroduceTxt.text = desc
    self:RefreshStageNodes()
    res.ClearChildren(self.consumeArea)
    local bShow = not self.isSupported or (self.isSupported and isLrUseSelf)
    GameObjectHelper.FastSetActive(self.btnUnlock.gameObject, bShow)
    GameObjectHelper.FastSetActive(self.consumeArea.gameObject, bShow)
    GameObjectHelper.FastSetActive(self.objImproveLocked.gameObject, not isShowUnlocked)
    GameObjectHelper.FastSetActive(self.objImproveUnlocked.gameObject, isShowUnlocked)
    if isShowUnlocked then
        self.sptImproveUnlocked:RefreshView(improveConfig)
        self.unlockButton.interactable = false
        return
    end
    if self.isSupported and not isLrUseSelf then
        self.lockIntroduceTxt.text = lang.transstr("supporter_locking_lr")
    end
    local consumePieceModels = self.model:GetConsumePieceModel()
    for i, pieceModel in ipairs(consumePieceModels) do
        self:BuildPieceConsume(pieceModel)
    end
    self.unlockButton.interactable = isNextUnlock
end

function LegendRoadView:BuildPieceConsume(pieceModel)
    local piecePath = "Assets/CapstonesRes/Game/UI/Scene/LegendRoad/Prefabs/Common/ConsumeNode.prefab"
    local obj, spt = res.Instantiate(piecePath)
    obj.transform:SetParent(self.consumeArea, false)
    spt:InitView(pieceModel, self.model)
end

function LegendRoadView:ToggleSelect(improveType, index)
    if self.onToggleClick and type(self.onToggleClick) == "function" then
        self.onToggleClick(improveType, index)
    end
end

function LegendRoadView:RefreshLegendCardData()
    self:RefreshStageView()
    self:RefreshImproveArea()
end

function LegendRoadView:ChangeChapterView()
    self:RefreshChapterView()
    -- 右侧
    self:RefreshStageView()
    -- 左下侧
    self:RefreshImproveArea()
end

function LegendRoadView:EnterScene()
    EventSystem.AddEvent("LegendCards_ResetLegendCard", self, self.RefreshLegendCardData)
    EventSystem.AddEvent("LegendCards_UnlockChapter", self, self.ChangeChapterView)
    EventSystem.AddEvent("LegendRoad_ToggleSelect", self, self.ToggleSelect)
end

function LegendRoadView:ExitScene()
    EventSystem.RemoveEvent("LegendCards_ResetLegendCard", self, self.RefreshLegendCardData)
    EventSystem.RemoveEvent("LegendCards_UnlockChapter", self, self.ChangeChapterView)
    EventSystem.RemoveEvent("LegendRoad_ToggleSelect", self, self.ToggleSelect)
end

function LegendRoadView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.mainView.gameObject, isShow)
end

-- 点击返回按钮
function LegendRoadView:OnBtnBackClick()
    if self.onBtnBackClick and type(self.onBtnBackClick) == "function" then
        self.onBtnBackClick()
    end
end

-- 点击解锁
function LegendRoadView:OnBtnUnlockClick()
    if self.onUnlockClick and type(self.onUnlockClick) == "function" then
        self.onUnlockClick()
    end
end

-- 切换章节
function LegendRoadView:OnChapterNodeClick(chapter)
    if self.onChapterNodeClick and type(self.onChapterNodeClick) == "function" then
        self.onChapterNodeClick(chapter)
    end
end

-- 切换关卡
function LegendRoadView:OnStageNodeClick(index)
    if self.onStageNodeClick and type(self.onStageNodeClick) == "function" then
        self.onStageNodeClick(index)
    end
end

function LegendRoadView:onDestroy()
    self.improveTabRes = nil
end

return LegendRoadView

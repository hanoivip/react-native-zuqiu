local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LegendRoadChapterPreview = class(unity.base, "LegendRoadChapterPreview")

function LegendRoadChapterPreview:ctor()
    self.previewTitle = self.___ex.previewTitle
    self.additionRectArea = self.___ex.additionRectArea
    self.unlockRectArea = self.___ex.unlockRectArea
    self.skillArea = self.___ex.skillArea
    self.btnUnlock = self.___ex.btnUnlock
    self.unlockButton = self.___ex.unlockButton
    self.btnClose = self.___ex.btnClose
    self.lockIntroduce = self.___ex.lockIntroduce
    self.lockIntroduceTxt = self.___ex.lockIntroduceTxt
end

function LegendRoadChapterPreview:start()
    DialogAnimation.Appear(self.transform)
    self.btnUnlock:regOnButtonClick(function()
        self:OnUnlockClick()
    end)
    self.btnClose:regOnButtonClick(function()
        self:OnCloseClick()
    end)
end

function LegendRoadChapterPreview:OnUnlockClick()
    if not self.isUnlockConditionPass then return end
    if self.unlockClick then
        self.unlockClick()
    end
end

function LegendRoadChapterPreview:OnCloseClick()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function LegendRoadChapterPreview:GetPreviewTab()
    if not self.previewTabRes then
        self.previewTabRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/LegendRoad/Prefabs/Common/PreviewBar.prefab")
    end
    return self.previewTabRes
end

function LegendRoadChapterPreview:GetSkillTab()
    if not self.skillTabRes then
        self.skillTabRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/LegendRoad/Prefabs/Common/LegendSkillBar.prefab")
    end
    return self.skillTabRes
end

function LegendRoadChapterPreview:InitView(legendRoadModel, chapter)
    local chapterTitle = legendRoadModel:GetChapterTitle(chapter)
    local numberTxt = lang.transstr("number_" .. chapter) or ""
    self.previewTitle.text = lang.transstr("legend_chapterPreview", numberTxt, tostring(chapterTitle))

    local grayColor = ColorConversionHelper.ConversionColor(82, 85, 90, 255)
    local white = ColorConversionHelper.ConversionColor(255, 255, 255, 255)
    local black = ColorConversionHelper.ConversionColor(0, 0, 0, 255)
    local previewData, skillIdMap = legendRoadModel:GetPreviewData(chapter)
    for i, v in ipairs(previewData) do
        local tabObject = Object.Instantiate(self:GetPreviewTab())
        GameObjectHelper.SetParent(tabObject, self.additionRectArea)
        local tabView = res.GetLuaScript(tabObject)
        tabView:InitView(v)
        tabView:SetBgColor(white)
        tabView:SetTxtColor(grayColor)
    end
    if next(skillIdMap) then
        for i, skillId in ipairs(skillIdMap) do
            local tabObject = Object.Instantiate(self:GetSkillTab())
            GameObjectHelper.SetParent(tabObject, self.skillArea)
            local tabView = res.GetLuaScript(tabObject)
            tabView:InitView(legendRoadModel, skillId)
        end
    end

    local cardModel = legendRoadModel:GetCardModel()
    local isSupported = cardModel:IsHasSupportCard()
    local isLrUseother = not cardModel:IsLegendRoadUseSelf()
    GameObjectHelper.FastSetActive(self.lockIntroduce, isSupported and isLrUseother)
    if isSupported and isLrUseother then
        self.lockIntroduceTxt.text = lang.transstr("supporter_locking_lr")
        GameObjectHelper.FastSetActive(self.btnUnlock.gameObject, false)
        return
    end

    local isUnlockConditionPass = true
    local unlockData = legendRoadModel:GetPreviewUnlockData(chapter)
    for i, v in ipairs(unlockData) do
        local tabObject = Object.Instantiate(self:GetPreviewTab())
        GameObjectHelper.SetParent(tabObject, self.unlockRectArea)
        local tabView = res.GetLuaScript(tabObject)
        tabView:InitView(v)
        tabView:SetBgColor(black)
        tabView:SetTxtColor(white)
        if not v.isUnlock then -- 只要一个条件不满足即不能解锁
            isUnlockConditionPass = false
        end
    end
    self.unlockButton.interactable = isUnlockConditionPass
    self.isUnlockConditionPass = isUnlockConditionPass
end

function LegendRoadChapterPreview:onDestroy()
    self.previewTabRes = nil
    self.skillTabRes = nil
end

return LegendRoadChapterPreview
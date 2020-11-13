local UnityEngine = clr.UnityEngine
local EventSystems = UnityEngine.EventSystems
local Vector3 = UnityEngine.Vector3
local Tweening = clr.DG.Tweening
local Ease = Tweening.Ease
local Tweener = Tweening.Tweener
local RotateMode = Tweening.RotateMode
local ShortcutExtensions = Tweening.ShortcutExtensions
local RectTransformUtility = UnityEngine.RectTransformUtility
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local TurntableDialog = class(unity.base)

function TurntableDialog:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.unlockTxt = self.___ex.unlockTxt
    self.arrowTrans = self.___ex.arrowTrans
    self.targetPosAreaTrans = self.___ex.targetPosAreaTrans
    self.closeBtnSpt = self.___ex.closeBtnSpt
    self.rollBtn = self.___ex.rollBtn
    self.buyTxt = self.___ex.buyTxt
    self.consumeGo = self.___ex.consumeGo
    self.consumeCountTxt = self.___ex.consumeCountTxt
    self.moraleGo = self.___ex.moraleGo
    self.fightGo = self.___ex.fightGo
    self.remainCountTxt = self.___ex.remainCountTxt
--------End_Auto_Generate----------
    self.rollButton = self.___ex.rollButton
    self.pieceViews = self.___ex.pieceViews
    self.currentEventSystem = EventSystems.EventSystem.current
end

function TurntableDialog:start()
	DialogAnimation.Appear(self.transform)
    self.closeBtnSpt:regOnButtonClick(function()
        self:Close()
    end)
    self.rollBtn:regOnButtonClick(function()
        self:OnRoll()
    end)
    self.cam = res.GetDialogCamera()
end

function TurntableDialog:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function TurntableDialog:OnRoll()
    if self.onRollClick then
        self.onRollClick()
    end
end

function TurntableDialog:OnRollAnim(data)
    self.currentEventSystem.enabled = false
    local index = data.pos
    local radius = 780 - 60 * index
    local rewardContent = data.cellResult.contents
    local cost = data.cellResult.cost
    self.eventModel:SetRollState(true)
    self.tweener = ShortcutExtensions.DORotate(self.arrowTrans, Vector3(0, 0, -radius), 4, RotateMode.FastBeyond360)
    TweenSettingsExtensions.SetEase(self.tweener, Ease.OutBounce)
    TweenSettingsExtensions.OnUpdate(self.tweener, function ()
        local sPos = RectTransformUtility.WorldToScreenPoint(self.cam, self.targetPosAreaTrans.position)
        for i, v in pairs(self.pieceViews) do
            local isIn = RectTransformUtility.RectangleContainsScreenPoint(v.posAreaTrans, sPos, self.cam)
            v:SetPieceState(isIn)
        end
    end)
    TweenSettingsExtensions.OnComplete(self.tweener, function ()
        self.eventModel:SetRollState(false)
        local selectPieceView = self.pieceViews[tostring(index)]
        selectPieceView:SetAcceptPieceState(true)
        local isAdventureCurrency = (rewardContent and (rewardContent.morale or rewardContent.fight)) or
                                    (cost and (cost.type == "morale" or cost.type == "fight"))

        if isAdventureCurrency then
            local rcPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/RewardCurrencyDialog.prefab"
            local dialog, dialogcomp = res.ShowDialog(rcPath, "camera", true, true)
            local spt = dialogcomp.contentcomp
            local title = lang.trans("tips")
            local isPlus, tip, contents
            if cost then
                tip = lang.trans("bad_luck_minus")
                isPlus = false
                contents = cost
            else
                tip = lang.trans("congratulations")
                isPlus = true
                contents = rewardContent
            end
            spt:InitView(title, tip, isPlus, contents)
        else
            if rewardContent and type(rewardContent) == "table" and next(rewardContent) then
                CongratulationsPageCtrl.new(rewardContent)
            end
        end
        self:RefreshContent()
        self.currentEventSystem.enabled = true
    end)
end

function TurntableDialog:RefreshContent()
    local remainCount = self.eventModel:GetRemainCount()
    local totalCount = self.eventModel:GetTotalCount()
    self.remainCountTxt.text = lang.trans("untranslated_2544", remainCount, totalCount)
    if remainCount <= 0 then
        self.rollButton.interactable = false
        self.buyTxt.text = lang.trans("tanks_join")
        GameObjectHelper.FastSetActive(self.consumeGo, false)
    end
    self:SetConsumeBtn()
end

function TurntableDialog:InitView(eventModel)
    self.eventModel = eventModel
    self.titleTxt.text = eventModel:GetEventName()
    local blockPoint = eventModel:GetBlockPoint()
    self:InitPieceViews()
    self:RefreshContent()
    self.unlockTxt.text = lang.trans("unlock_terrain_condition", blockPoint)
end

function TurntableDialog:InitPieceViews()
    local rollList = self.eventModel:GetRollList()
    for i, v in ipairs(rollList) do
        local index = tostring(i)
        if self.pieceViews[index] then
            self.pieceViews[index]:InitView(v)
        end
    end
end

function TurntableDialog:SetConsumeBtn()
    local index = self.eventModel:GetOpenTimesIndex()
    local moraleState = self.eventModel:ConsumeByMorale()
    local powerState = self.eventModel:ConsumeByPower()
    local count = 0
    local color = self.consumeCountTxt.color
    if moraleState then
        local starSymbol = 0
        count, starSymbol = self.eventModel:GetConsumeMorale(index)
        if starSymbol ~= 0 then
            local r, g, b = self.eventModel:GetConvertColor(starSymbol)
            color = ColorConversionHelper.ConversionColor(r, g, b)
        end
    elseif powerState then
        count = self.eventModel:GetConsumeFight()
    end
    GameObjectHelper.FastSetActive(self.fightGo, powerState)
    GameObjectHelper.FastSetActive(self.moraleGo, moraleState)
    self.consumeCountTxt.text = "x" .. count
    self.consumeCountTxt.color = color
end

return TurntableDialog

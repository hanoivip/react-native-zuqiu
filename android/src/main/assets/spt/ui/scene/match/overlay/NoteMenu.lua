local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease

local MatchFormationPageCtrl = require("ui.controllers.match.formation2.MatchFormationPageCtrl")
local UISoundManager = require("ui.control.manager.UISoundManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local MatchConstants = require("ui.scene.match.MatchConstants")
local DialogManager = require("ui.control.manager.DialogManager")
local CommonConstants = require("ui.common.CommonConstants")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

local NoteMenu = class(unity.base)

function NoteMenu:ctor()
    self.tacticsBtn = self.___ex.tacticsBtn
    self.accelerateBtn = self.___ex.accelerateBtn
    self.accelerateBtnText = self.___ex.accelerateBtnText
    self.accelerateBtnButton = self.___ex.accelerateBtnButton
    self.changeBtn = self.___ex.changeBtn
    self.tacticsBtnText = self.___ex.tacticsBtnText
    self.changeBtnText = self.___ex.changeBtnText
    self.tacticsBtnButton = self.___ex.tacticsBtnButton
    self.changeBtnButton = self.___ex.changeBtnButton
    self.stateBtn = self.___ex.stateBtn
    self.stateBtnButton = self.___ex.stateBtnButton
    self.stateBtnText = self.___ex.stateBtnText
    self.speedNumText = self.___ex.speedNumText
    self.stateBtnArrowDown = self.___ex.stateBtnArrowDownIcon
    self.stateBtnArrowUp = self.___ex.stateBtnArrowUpIcon
    self.giveupBtn = self.___ex.giveupBtn
    self.giveupBtnText = self.___ex.giveupBtnText
    self.giveupBtnButton = self.___ex.giveupBtnButton
    self.skipBtn = self.___ex.skipBtn
    self.skipBtnButton = self.___ex.skipBtnButton
    self.skipBtnText = self.___ex.skipBtnText
    self.accelerateIcon = self.___ex.accelerateIcon
    self.normalSpeedIcon = self.___ex.normalSpeedIcon
    self.autoBtn = self.___ex.autoBtn
    self.autoBtnButton = self.___ex.autoBtnButton
    self.autoBtnText = self.___ex.autoBtnText
    self.skipTipBox = self.___ex.skipTipBox
    self.guideArrow = self.___ex.guideArrow
    -- 机能面板是否可见
    self.isStatePanelVisible = false
    -- 是否是2倍速状态
    self.isAccelerateState = false
    -- 是否自动操作
    self.isAuto = false
    self.matchInfoModel = nil
    self.itemsMapModel = nil
    self.sweepCuponNum = nil
    self.inPenaltyShootOut = nil
end

function NoteMenu:start()
    self.matchInfoModel = MatchInfoModel.GetInstance()
    self.itemsMapModel = ItemsMapModel.new()
    self.sweepCuponNum = self:GetSweepCuponNum()
    self:DisableButton()
    self:BuildAccelerateBtn()
    self:SetAccelerateBtnAndAutoBtnActive()
    self:SetGiveUpBtnActive()
    self:RegisterEvent()
    self:BindAll()
    -- 争霸赛防假球系统:根据比赛类型隐藏换人按钮
    GameObjectHelper.FastSetActive(self.changeBtnButton.gameObject, not self.matchInfoModel:IsChangeAthleteDisabled())
end

function NoteMenu:BindAll()
    self.tacticsBtn:regOnButtonClick(function ()
        if self.tacticsBtnButton.interactable then
            self:TacticsClick()
        end
    end)
    
    self.changeBtn:regOnButtonClick(function ()
        if self.changeBtnButton.interactable then
            self:ChangePlayer()
        end
    end)

    self.accelerateBtn:regOnButtonClick(function ()
        if self.accelerateBtnButton.interactable then
            self:SwitchAccelerateAndAutoState()
        end
    end)

    self.stateBtn:regOnButtonClick(function ()
        if self.stateBtnButton.interactable then
            self:ToggleStatePanel()
        end
    end)

    local function onGiveUpClick()
        if self.giveupBtnButton.isActiveAndEnabled and self.giveupBtnButton.interactable then
            if self.matchInfoModel:GetMatchType() == MatchConstants.MatchType.QUEST then
                DialogManager.ShowConfirmPopByLang("tips", "match_quest_confirm_giveup", function ()
                    self:GiveUpMatch()
                end)
            else
                DialogManager.ShowConfirmPopByLang("tips", "match_confirm_giveup", function ()
                    self:GiveUpMatch()
                end)
            end
        end
    end
    self.giveupBtn:regOnButtonClick(onGiveUpClick)
    luaevt.trig("SetOnBackType", "match", onGiveUpClick)

    self.skipBtn:regOnButtonClick(function ()
        if self.skipBtnButton.interactable then
            GameObjectHelper.FastSetActive(self.guideArrow, false)
            if not self.matchInfoModel:IsCostSweepCupon() then
                self:SkipMatch()
            else
                if self.sweepCuponNum <= 0 then
                    DialogManager.ShowToastByLang("sweepCuponNotEnough")
                else
                    self:ShowSkipTipBox()
                    self:SkipMatch()
                end
            end
        end
    end)

    self.autoBtn:regOnButtonClick(function ()
        if self.autoBtnButton.interactable then
            self:SwitchAccelerateAndAutoState()
        end
    end)
end

--- 注册事件
function NoteMenu:RegisterEvent()
    EventSystem.AddEvent("NoteMenu.ToggleStatePanel", self, self.ToggleStatePanel)
    EventSystem.AddEvent("NoteMenu.HideStatePanel", self, self.HideStatePanel)
    EventSystem.AddEvent("Match_TipToSkip", self, self.TipToSkip)
end

--- 移除事件
function NoteMenu:RemoveEvent()
    EventSystem.RemoveEvent("NoteMenu.ToggleStatePanel", self, self.ToggleStatePanel)
    EventSystem.RemoveEvent("NoteMenu.HideStatePanel", self, self.HideStatePanel)
    EventSystem.RemoveEvent("Match_TipToSkip", self, self.TipToSkip)
end

function NoteMenu:ToggleStatePanel()
    self.isStatePanelVisible = not self.isStatePanelVisible
    self.stateBtnArrowDown.gameObject:SetActive(self.isStatePanelVisible)
    self.stateBtnArrowUp.gameObject:SetActive(not self.isStatePanelVisible)
    ___matchUI:setStatePanelVisible(self.isStatePanelVisible)
end

function NoteMenu:HideStatePanel()
    self.isStatePanelVisible = false
    self.stateBtnArrowDown.gameObject:SetActive(self.isStatePanelVisible)
    self.stateBtnArrowUp.gameObject:SetActive(not self.isStatePanelVisible)
    ___matchUI:setStatePanelVisible(self.isStatePanelVisible)
end

function NoteMenu:TacticsClick()
    res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Formation2/TacticsDlg/TacticsDlg.prefab", "overlay", false, true)
end

function NoteMenu:ChangePlayer()
    MatchFormationPageCtrl.new()
end

function NoteMenu:GiveUpMatch()
    luaevt.trig("SetOnBackType", "match", nil)
    self.matchInfoModel:SetIsGiveUpMatch(true)
    ___matchUI:onGiveUpMatch()
end

function NoteMenu:SkipMatch()
    self.matchInfoModel:SetIsSkipMatch(true)
    TimeLineWrap.TLFreeze()
    ___matchUI:onSkipMatch()
end

function NoteMenu:DisableButton()
    self.changeBtnButton.interactable = false
    self.changeBtnText.color = Color(0.5, 0.5, 0.5)
    self.tacticsBtnButton.interactable = false
    self.tacticsBtnText.color = Color(0.5, 0.5, 0.5)
    self.stateBtnButton.interactable = false
    self.stateBtnText.color = Color(0.5, 0.5, 0.5)
    self.giveupBtnButton.interactable = false
    self.giveupBtnText.color = Color(0.5, 0.5, 0.5)
    self.skipBtnButton.interactable = false
    self.skipBtnText.color = Color(0.5, 0.5, 0.5)
    self.stateBtnArrowDown.color = Color(0.5, 0.5, 0.5)
    self.stateBtnArrowUp.color = Color(0.5, 0.5, 0.5)
    self:DisableAccelerateBtn()
end

function NoteMenu:EnableButton()
    if not self.inPenaltyShootOut then
        self.changeBtnButton.interactable = true
        self.changeBtnText.color = Color.white
        self.tacticsBtnButton.interactable = true
        self.tacticsBtnText.color = Color.white
    end
    self.stateBtnButton.interactable = true
    self.stateBtnText.color = Color.white
    self.giveupBtnButton.interactable = true
    self.giveupBtnText.color = Color.white
    self.skipBtnButton.interactable = true
    self.skipBtnText.color = Color.white
    self.stateBtnArrowDown.color = Color(1, 229.0 / 255, 122.0 / 255)
    self.stateBtnArrowUp.color = Color(1, 229.0 / 255, 122.0 / 255)
    self:EnableAccelerateBtn()
end

function NoteMenu:DisableChangeButton()
    self.changeBtnButton.interactable = false
    self.changeBtnText.color = Color(0.5, 0.5, 0.5)
end

function NoteMenu:EnableChangeButton()
    if not self.inPenaltyShootOut then
        self.changeBtnButton.interactable = true
        self.changeBtnText.color = Color.white
    end
end

function NoteMenu:EnableSkipButton()
    self.skipBtnButton.interactable = true
    self.skipBtnText.color = Color.white
end

function NoteMenu:DisableAccelerateBtn()
    self.accelerateBtnButton.interactable = false
    self.accelerateBtnText.color = Color(0.5, 0.5, 0.5)
    self.autoBtnButton.interactable = false
    self.autoBtnText.color = Color(0.5, 0.5, 0.5)
end

function NoteMenu:EnableAccelerateBtn()
    self.accelerateBtnButton.interactable = true
    self.accelerateBtnText.color = Color.white
    self.autoBtnButton.interactable = true
    self.autoBtnText.color = Color.white
end

function NoteMenu:BuildAccelerateBtn()
    GameObjectHelper.FastSetActive(self.accelerateIcon, self.isAccelerateState)
    GameObjectHelper.FastSetActive(self.normalSpeedIcon, not self.isAccelerateState)
    if self.isAccelerateState then
        self.accelerateBtnText.text = lang.trans("match_accelerate")
        self.speedNumText.text = "x2"
    else
        self.accelerateBtnText.text = lang.trans("match_normal")
        self.speedNumText.text = "x1"
    end
end

function NoteMenu:SetAccelerateBtnAndAutoBtnActive()
    GameObjectHelper.FastSetActive(self.autoBtn.gameObject, self.isAuto)
    GameObjectHelper.FastSetActive(self.accelerateBtn.gameObject, not self.isAuto)
end

--- 切换加速状态
function NoteMenu:SwitchAccelerateAndAutoState()
    if self.isAccelerateState then
        if self.matchInfoModel:IsReplay() then
            TimeLineWrap.StopFastForward()
            self.isAccelerateState = not self.isAccelerateState
            self:BuildAccelerateBtn()    
        else
            self.isAuto = not self.isAuto
            self.matchInfoModel:SetIsAuto(self.isAuto)
            self:SetAccelerateBtnAndAutoBtnActive()
            if not self.isAuto then
                TimeLineWrap.StopFastForward()
                self.isAccelerateState = not self.isAccelerateState
                self:BuildAccelerateBtn()
            end
        end
    else
        TimeLineWrap.StartFastForward(1.5)
        self.isAccelerateState = not self.isAccelerateState
        self:BuildAccelerateBtn()
    end
end

function NoteMenu:SetGiveUpBtnActive()
    if self.matchInfoModel:GetMatchType() == MatchConstants.MatchType.QUEST and not GuideManager.GuideIsOnGoing("main") then
        GameObjectHelper.FastSetActive(self.giveupBtn.gameObject, true)
    else
        GameObjectHelper.FastSetActive(self.giveupBtn.gameObject, false)
    end
end

--- 获取扫荡券的数量
function NoteMenu:GetSweepCuponNum()
    local items = self.itemsMapModel:GetItems()
    if type(items) == "table" then
        return self.itemsMapModel:GetItemNum(CommonConstants.SweepItemId)
    else
        return 0
    end
end

function NoteMenu:ShowSkipTipBox()
    GameObjectHelper.FastSetActive(self.skipTipBox.gameObject, true)
    self.skipTipBox.localScale = Vector3.zero
    local tweenerScaleIn = ShortcutExtensions.DOScale(self.skipTipBox, 1, 0.2)
    TweenSettingsExtensions.SetEase(tweenerScaleIn, Ease.OutBack)

    local tweenerScaleOut = ShortcutExtensions.DOScale(self.skipTipBox, 0, 0.2)
    TweenSettingsExtensions.SetEase(tweenerScaleOut, Ease.OutBack)

    local mySequence = DOTween.Sequence()
    TweenSettingsExtensions.Append(mySequence, tweenerScaleIn)
    TweenSettingsExtensions.AppendInterval(mySequence, 3)
    TweenSettingsExtensions.Append(mySequence, tweenerScaleOut)
    TweenSettingsExtensions.AppendCallback(mySequence, function ()
        GameObjectHelper.FastSetActive(self.skipTipBox.gameObject, false)
    end)
end

function NoteMenu:TipToSkip()
    -- 前五小关首次战斗、且进球数比NPC多2球时、点掉对话框会自动为玩家跳过比赛
    self:SkipMatch()
end

function NoteMenu:EnterPenaltyShootOut()
    self.inPenaltyShootOut = true
end

function NoteMenu:onDestroy()
    luaevt.trig("SetOnBackType", "match", nil)
    self:RemoveEvent()
end

return NoteMenu

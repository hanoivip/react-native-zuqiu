local Transform = clr.UnityEngine.Transform
local RectTransform = clr.UnityEngine.RectTransform
local Vector3 = clr.UnityEngine.Vector3
local MatchInfoModel = require("ui.models.MatchInfoModel")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local UISoundManager = require("ui.control.manager.UISoundManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local TacticsDlg = class(unity.base)

function TacticsDlg:ctor()
    self.saveBtn = self.___ex.saveBtn
    self.cancelBtn = self.___ex.cancelBtn
    self.passTactic = self.___ex.passTactic
    self.passTacticListener = self.___ex.passTacticListener
    self.passTacticHelperBtn = self.___ex.passTacticHelperBtn
    self.attackEmphasis = self.___ex.attackEmphasis
    self.attackEmphasisListener = self.___ex.attackEmphasisListener
    self.attackRhythm = self.___ex.attackRhythm
    self.attackRhythmListener = self.___ex.attackRhythmListener
    self.AttackRhythmHelperBtn = self.___ex.AttackRhythmHelperBtn
    self.attackMentality = self.___ex.attackMentality
    self.attackMentalityListener = self.___ex.attackMentalityListener
    self.AttackMentalityHelperBtn = self.___ex.AttackMentalityHelperBtn
    self.defenseMentality = self.___ex.defenseStrategy
    self.defenseStrategyListener = self.___ex.defenseStrategyListener
    self.DefenseStrategyHelperBtn = self.___ex.DefenseStrategyHelperBtn
    self.canvasGroup = self.___ex.canvasGroup
    self.attackEmphasisDetail = self.___ex.attackEmphasisDetail
    self.attackEmphasisDetailDisable = self.___ex.attackEmphasisDetailDisable
    self.attackEmphasisDetailListener = self.___ex.attackEmphasisDetailListener
    self.AttackEmphasisDetailHelperBtn = self.___ex.AttackEmphasisDetailHelperBtn
    self.leftBottomBtn = self.___ex.leftBottomBtn
    self.leftBottomSelected = self.___ex.leftBottomSelected
    self.leftInsideBtn = self.___ex.leftInsideBtn
    self.leftInsideSelected = self.___ex.leftInsideSelected
    self.rightBottomBtn = self.___ex.rightBottomBtn
    self.rightBottomSelected = self.___ex.rightBottomSelected
    self.rightInsideBtn = self.___ex.rightInsideBtn
    self.rightInsideSelected = self.___ex.rightInsideSelected
    self.wideTendency = self.___ex.wideTendency
    self.wideTendencyDisable = self.___ex.wideTendencyDisable
    self.sideGuardLeftForwardBtn = self.___ex.sideGuardLeftForwardBtn
    self.sideGuardLeftKeepBtn = self.___ex.sideGuardLeftKeepBtn
    self.sideGuardRighttForwardBtn = self.___ex.sideGuardRighttForwardBtn
    self.sideGuardRightKeepBtn = self.___ex.sideGuardRightKeepBtn
    self.sideGuardLeftForwardSelected = self.___ex.sideGuardLeftForwardSelected
    self.sideGuardLeftKeepSelected = self.___ex.sideGuardLeftKeepSelected
    self.sideGuardRightForwardSelected = self.___ex.sideGuardRightForwardSelected
    self.sideGuardRightKeepSelected = self.___ex.sideGuardRightKeepSelected
    self.sideMidFieldLeftForwardBtn = self.___ex.sideMidFieldLeftForwardBtn
    self.sideMidFieldLeftKeepBtn = self.___ex.sideMidFieldLeftKeepBtn
    self.sideMidFieldRightForwardBtn = self.___ex.sideMidFieldRightForwardBtn
    self.sideMidFieldRightKeepBtn = self.___ex.sideMidFieldRightKeepBtn
    self.sideMidFieldLeftForwardSelected = self.___ex.sideMidFieldLeftForwardSelected
    self.sideMidFieldLeftKeepSelected = self.___ex.sideMidFieldLeftKeepSelected
    self.sideMidFieldRightForwardSelected = self.___ex.sideMidFieldRightForwardSelected
    self.sideMidFieldRightKeepSelected = self.___ex.sideMidFieldRightKeepSelected

    self.matchInfoModel = nil
    self.playerTeamData = nil
    self.saveBtnInteractable = false
    self.sideTactic = {}
    self.sideGuardTactic = {}
    self.sideMidFieldTactic = {}

    self:initData()
end

function TacticsDlg:initData()
    self.matchInfoModel = MatchInfoModel.GetInstance()
    self.playerTeamData = self.matchInfoModel:GetPlayerTeamData()
    if self.playerTeamData ~= nil then
        local tactics = self.playerTeamData.tactics
        self.attackEmphasis.value = tactics.attackEmphasis
        self.attackRhythm.value = tactics.attackRhythm
        self.passTactic.value = tactics.passTactic
        self.attackMentality.value = tactics.attackMentality
        self.defenseMentality.value = tactics.defenseMentality
        self.attackEmphasisDetail.value = tactics.attackEmphasisDetail or 0
        self.attackEmphasisDetailDisable.value = tactics.attackEmphasisDetail or 0
        GameObjectHelper.FastSetActive(self.wideTendency, self.attackEmphasis.value < 3)
        GameObjectHelper.FastSetActive(self.wideTendencyDisable, not (self.attackEmphasis.value < 3))
        if tactics.sideTactic == nil then
            tactics.sideTactic = {}
        end
        self.sideTactic.left = tactics.sideTactic.left or 0
        self.sideTactic.right = tactics.sideTactic.right or 0

        GameObjectHelper.FastSetActive(self.leftBottomSelected, self.sideTactic.left == 1)
        GameObjectHelper.FastSetActive(self.leftInsideSelected, self.sideTactic.left == 2)
        GameObjectHelper.FastSetActive(self.rightBottomSelected, self.sideTactic.right == 1)
        GameObjectHelper.FastSetActive(self.rightInsideSelected, self.sideTactic.right == 2)

        if tactics.sideGuardTactic == nil then
            tactics.sideGuardTactic = {}
        end
        self.sideGuardTactic.left = tactics.sideGuardTactic.left or 0
        self.sideGuardTactic.right = tactics.sideGuardTactic.right or 0
        GameObjectHelper.FastSetActive(self.sideGuardLeftForwardSelected, self.sideGuardTactic.left == 1)
        GameObjectHelper.FastSetActive(self.sideGuardLeftKeepSelected, self.sideGuardTactic.left == 2)
        GameObjectHelper.FastSetActive(self.sideGuardRightForwardSelected, self.sideGuardTactic.right == 1)
        GameObjectHelper.FastSetActive(self.sideGuardRightKeepSelected, self.sideGuardTactic.right == 2)
        if tactics.sideMidFieldTactic == nil then
            tactics.sideMidFieldTactic = {}
        end
        self.sideMidFieldTactic.left = tactics.sideMidFieldTactic.left or 0
        self.sideMidFieldTactic.right = tactics.sideMidFieldTactic.right or 0
        GameObjectHelper.FastSetActive(self.sideMidFieldLeftForwardSelected, self.sideMidFieldTactic.left == 1)
        GameObjectHelper.FastSetActive(self.sideMidFieldLeftKeepSelected, self.sideMidFieldTactic.left == 2)
        GameObjectHelper.FastSetActive(self.sideMidFieldRightForwardSelected, self.sideMidFieldTactic.right == 1)
        GameObjectHelper.FastSetActive(self.sideMidFieldRightKeepSelected, self.sideMidFieldTactic.right == 2)

    end
end

function TacticsDlg:start()
    self:BuildView()
    self:BindAll()
    self:RegisterEvent()
    self:PlayMoveInAnim()
end

function TacticsDlg:RegisterEvent()
    EventSystem.AddEvent("TacticsDlg.Destroy", self, self.Destroy)
end

function TacticsDlg:RemoveEvent()
    EventSystem.RemoveEvent("TacticsDlg.Destroy", self, self.Destroy)
end

function TacticsDlg:BuildView()
    self:ToggleSaveBtn(self.saveBtnInteractable)
end

function TacticsDlg:BindAll()
    self.cancelBtn:regOnButtonClick(function ()
        self:PlayMoveOutAnim()
    end)
    self.saveBtn:regOnButtonClick(function ()
        self:CommitData()
        self:PlayMoveOutAnim()
    end)
    self.passTacticListener:regOnButtonClick(function ()
        self:EnabledSaveBtn()
    end)
    self.attackEmphasisListener:regOnButtonClick(function ()
        self:EnabledSaveBtn()
    end)
    self.attackRhythmListener:regOnButtonClick(function ()
        self:EnabledSaveBtn()
    end)
    self.attackMentalityListener:regOnButtonClick(function ()
        self:EnabledSaveBtn()
    end)
    self.defenseStrategyListener:regOnButtonClick(function ()
        self:EnabledSaveBtn()
    end)
    self.passTacticListener:regOnDrag(function ()
        self:EnabledSaveBtn()
    end)
    self.attackEmphasisListener:regOnDrag(function ()
        self:EnabledSaveBtn()
    end)
    self.attackRhythmListener:regOnDrag(function ()
        self:EnabledSaveBtn()
    end)
    self.attackMentalityListener:regOnDrag(function ()
        self:EnabledSaveBtn()
    end)
    self.defenseStrategyListener:regOnDrag(function ()
        self:EnabledSaveBtn()
    end)
    self.attackEmphasisDetailListener:regOnDrag(function ()
        self:EnabledSaveBtn()
    end)
    self.attackEmphasis.onValueChanged:AddListener(function (value)
        GameObjectHelper.FastSetActive(self.wideTendency, value < 3)
        GameObjectHelper.FastSetActive(self.wideTendencyDisable, not (value < 3))
    end)
    self.attackEmphasisDetail.onValueChanged:AddListener(function (value)
        self.attackEmphasisDetailDisable.value = value
    end)

    self.sideGuardLeftForwardBtn:regOnButtonClick(function ()
        self:EnabledSaveBtn()
        local oldState = self.sideGuardLeftForwardSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideGuardLeftForwardSelected, not oldState)
        if not oldState then
            self.sideGuardTactic.left = 1
        end

        if self.sideGuardLeftKeepSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideGuardLeftKeepSelected, false)
        else
            if oldState then
                self.sideGuardTactic.left = 0
            end
        end
    end)
    self.sideGuardLeftKeepBtn:regOnButtonClick(function ()
        self:EnabledSaveBtn()
        local oldState = self.sideGuardLeftKeepSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideGuardLeftKeepSelected, not oldState)
        if not oldState then
            self.sideGuardTactic.left = 2
        end

        if self.sideGuardLeftForwardSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideGuardLeftForwardSelected, false)
        else
            if oldState then
                self.sideGuardTactic.left = 0
            end
        end
    end)
    self.sideGuardRighttForwardBtn:regOnButtonClick(function ()
        self:EnabledSaveBtn()
        local oldState = self.sideGuardRightForwardSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideGuardRightForwardSelected, not oldState)
        if not oldState then
            self.sideGuardTactic.right = 1
        end

        if self.sideGuardRightKeepSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideGuardRightKeepSelected, false)
        else
            if oldState then
                self.sideGuardTactic.right = 0
            end
        end
    end)
    self.sideGuardRightKeepBtn:regOnButtonClick(function ()
        self:EnabledSaveBtn()
        local oldState = self.sideGuardRightKeepSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideGuardRightKeepSelected, not oldState)
        if not oldState then
            self.sideGuardTactic.right = 2
        end

        if self.sideGuardRightForwardSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideGuardRightForwardSelected, false)
        else
            if oldState then
                self.sideGuardTactic.right = 0
            end
        end
    end)
    
    self.sideMidFieldLeftForwardBtn:regOnButtonClick(function ()
        self:EnabledSaveBtn()
        local oldState = self.sideMidFieldLeftForwardSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideMidFieldLeftForwardSelected, not oldState)
        if not oldState then
            self.sideMidFieldTactic.left = 1
        end

        if self.sideMidFieldLeftKeepSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideMidFieldLeftKeepSelected, false)
        else
            if oldState then
                self.sideMidFieldTactic.left = 0
            end
        end
    end)
    self.sideMidFieldLeftKeepBtn:regOnButtonClick(function ()
        self:EnabledSaveBtn()
        local oldState = self.sideMidFieldLeftKeepSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideMidFieldLeftKeepSelected, not oldState)
        if not oldState then
            self.sideMidFieldTactic.left = 2
        end

        if self.sideMidFieldLeftForwardSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideMidFieldLeftForwardSelected, false)
        else
            if oldState then
                self.sideMidFieldTactic.left = 0
            end
        end
    end)
    self.sideMidFieldRightForwardBtn:regOnButtonClick(function ()
        self:EnabledSaveBtn()
        local oldState = self.sideMidFieldRightForwardSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideMidFieldRightForwardSelected, not oldState)
        if not oldState then
            self.sideMidFieldTactic.right = 1
        end

        if self.sideMidFieldRightKeepSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideMidFieldRightKeepSelected, false)
        else
            if oldState then
                self.sideMidFieldTactic.right = 0
            end
        end
    end)
    self.sideMidFieldRightKeepBtn:regOnButtonClick(function ()
        self:EnabledSaveBtn()
        local oldState = self.sideMidFieldRightKeepSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideMidFieldRightKeepSelected, not oldState)
        if not oldState then
            self.sideMidFieldTactic.right = 2
        end

        if self.sideMidFieldRightForwardSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideMidFieldRightForwardSelected, false)
        else
            if oldState then
                self.sideMidFieldTactic.right = 0
            end
        end
    end)

    self.leftBottomBtn:regOnButtonClick(function ()
        self:EnabledSaveBtn()
        local oldState = self.leftBottomSelected.activeSelf
        GameObjectHelper.FastSetActive(self.leftBottomSelected, not oldState)
        if not oldState then
            self.sideTactic.left = 1
        end

        if self.leftInsideSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.leftInsideSelected, false)
        else
            if oldState then
                self.sideTactic.left = 0
            end
        end
    end)
    self.leftInsideBtn:regOnButtonClick(function ()
        self:EnabledSaveBtn()
        local oldState = self.leftInsideSelected.activeSelf
        GameObjectHelper.FastSetActive(self.leftInsideSelected, not oldState)
        if not oldState then
            self.sideTactic.left = 2
        end
        if self.leftBottomSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.leftBottomSelected, false)
        else
            if oldState then
                self.sideTactic.left = 0
            end
        end
    end)
    self.rightBottomBtn:regOnButtonClick(function ()
        self:EnabledSaveBtn()
        local oldState = self.rightBottomSelected.activeSelf
        GameObjectHelper.FastSetActive(self.rightBottomSelected, not oldState)
        if not oldState then
            self.sideTactic.right = 1
        end
        if self.rightInsideSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.rightInsideSelected, false)
        else
            if oldState then
                self.sideTactic.right = 0
            end
        end
    end)
    self.rightInsideBtn:regOnButtonClick(function ()
        self:EnabledSaveBtn()
        local oldState = self.rightInsideSelected.activeSelf
        GameObjectHelper.FastSetActive(self.rightInsideSelected, not oldState)
        if not oldState then
            self.sideTactic.right = 2
        end
        if self.rightBottomSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.rightBottomSelected, false)
        else
            if oldState then
                self.sideTactic.right = 0
            end
        end
    end)
    self.passTacticHelperBtn:regOnButtonClick(function ()
        local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Formation2/TacticsDlg/TacticsHelper.prefab", "overlay", true, false)
        dialogcomp.contentcomp:InitData("PassTactic")
        self:coroutine(function()
            unity.waitForNextEndOfFrame()
            local newPos = self.passTacticHelperBtn.gameObject.transform.position
            dialogcomp.contentcomp.gameObject.transform.position = Vector3(newPos.x, newPos.y, newPos.z)
            dialogcomp.contentcomp.gameObject:SetActive(true)
        end)
    end)
    self.AttackRhythmHelperBtn:regOnButtonClick(function ()
        local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Formation2/TacticsDlg/TacticsHelper.prefab", "overlay", true, false)
        dialogcomp.contentcomp:InitData("AttackRhythm")
        self:coroutine(function()
            unity.waitForNextEndOfFrame()
            local newPos = self.AttackRhythmHelperBtn.gameObject.transform.position
            dialogcomp.contentcomp.gameObject.transform.position = Vector3(newPos.x, newPos.y, newPos.z)
            dialogcomp.contentcomp.gameObject:SetActive(true)
        end)
    end)
    self.AttackMentalityHelperBtn:regOnButtonClick(function ()
        local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Formation2/TacticsDlg/TacticsHelper.prefab", "overlay", true, false)
        dialogcomp.contentcomp:InitData("AttackMentality")
        self:coroutine(function()
            unity.waitForNextEndOfFrame()
            local newPos = self.AttackMentalityHelperBtn.gameObject.transform.position
            dialogcomp.contentcomp.gameObject.transform.position = Vector3(newPos.x, newPos.y, newPos.z)
            dialogcomp.contentcomp.gameObject:SetActive(true)
        end)
    end)
    self.DefenseStrategyHelperBtn:regOnButtonClick(function ()
        local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Formation2/TacticsDlg/TacticsHelper.prefab", "overlay", true, false)
        dialogcomp.contentcomp:InitData("DefenseStrategy")
        self:coroutine(function()
            unity.waitForNextEndOfFrame()
            local newPos = self.DefenseStrategyHelperBtn.gameObject.transform.position
            dialogcomp.contentcomp.gameObject.transform.position = Vector3(newPos.x, newPos.y, newPos.z)
            dialogcomp.contentcomp.gameObject:SetActive(true)
        end)
    end)
    self.AttackEmphasisDetailHelperBtn:regOnButtonClick(function ()
        local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Formation2/TacticsDlg/TacticsHelper.prefab", "overlay", true, false)
        dialogcomp.contentcomp:InitData("AttackEmphasisDetail")
        self:coroutine(function()
            unity.waitForNextEndOfFrame()
            local newPos = self.AttackEmphasisDetailHelperBtn.gameObject.transform.position
            dialogcomp.contentcomp.gameObject.transform.position = Vector3(newPos.x, newPos.y, newPos.z)
            dialogcomp.contentcomp.gameObject:SetActive(true)
        end)
    end)
end

function TacticsDlg:ToggleSaveBtn(isEnabled)
    self.saveBtn:onPointEventHandle(isEnabled)
end

function TacticsDlg:EnabledSaveBtn()
    UISoundManager.play("Match/tacticsSlider", 1)
    if not self.saveBtnInteractable then
        self.saveBtnInteractable = true
        self:ToggleSaveBtn(self.saveBtnInteractable)
    end
end

function TacticsDlg:CommitData()
    local tactics = {}
    tactics.sideTactic = {}
    tactics.sideGuardTactic = {}
    tactics.sideMidFieldTactic = {}
    if self.playerTeamData ~= nil then
        tactics = self.playerTeamData.tactics
    end
    
    if self.attackEmphasis.value ~= tactics.attackEmphasis
        or self.attackRhythm.value ~= tactics.attackRhythm
        or self.passTactic.value ~= tactics.passTactic
        or self.attackMentality.value ~= tactics.attackMentality
        or self.defenseMentality.value ~= tactics.defenseMentality
        or self.attackEmphasisDetail.value ~= tactics.attackEmphasisDetail 
        or self.sideTactic.left ~= tactics.sideTactic.left
        or self.sideTactic.right ~= tactics.sideTactic.right 
        or self.sideGuardTactic.left ~= tactics.sideGuardTactic.left
        or self.sideGuardTactic.right ~= tactics.sideGuardTactic.right 
        or self.sideMidFieldTactic.left ~= tactics.sideMidFieldTactic.left
        or self.sideMidFieldTactic.right ~= tactics.sideMidFieldTactic.right 
        then
        
        tactics.attackEmphasis = self.attackEmphasis.value
        tactics.attackRhythm = self.attackRhythm.value
        tactics.passTactic = self.passTactic.value
        tactics.attackMentality = self.attackMentality.value
        tactics.defenseMentality = self.defenseMentality.value
        tactics.attackEmphasisDetail = self.attackEmphasisDetail.value
        tactics.sideTactic.left = self.sideTactic.left
        tactics.sideTactic.right = self.sideTactic.right
        tactics.sideGuardTactic.left = self.sideGuardTactic.left
        tactics.sideGuardTactic.right = self.sideGuardTactic.right
        tactics.sideMidFieldTactic.left = self.sideMidFieldTactic.left
        tactics.sideMidFieldTactic.right = self.sideMidFieldTactic.right

        EmulatorInputWrap.SetTacticsJson(json.encode(tactics))
        self.matchInfoModel:UpdatePlayerTacticsData(tactics)
        EmulatorInputWrap.SetIsTacticsChanged(true)
    end
end

function TacticsDlg:PlayMoveInAnim()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function TacticsDlg:PlayMoveOutAnim()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        self:Destroy()
    end)
end

function TacticsDlg:Destroy()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function TacticsDlg:onDestroy()
    self:RemoveEvent()
end

return TacticsDlg

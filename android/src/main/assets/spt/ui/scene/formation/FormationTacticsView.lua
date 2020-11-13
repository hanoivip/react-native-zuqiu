local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local MatchConstants = require("ui.scene.match.MatchConstants")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local UISoundManager = require("ui.control.manager.UISoundManager")

local FormationTacticsView = class(unity.base)

function FormationTacticsView:ctor()
    self.cancelBtn = self.___ex.cancelBtn
    self.btnConfirm = self.___ex.btnConfirm
    self.passTactic = self.___ex.passTactic
    self.passTacticListener = self.___ex.passTacticListener
    self.passTacticHelperBtn = self.___ex.passTacticHelperBtn
    self.attackEmphasis = self.___ex.attackEmphasis
    self.attackEmphasisListener = self.___ex.attackEmphasisListener
    self.AttackEmphasisDetailHelperBtn = self.___ex.AttackEmphasisDetailHelperBtn
    self.attackRhythm = self.___ex.attackRhythm
    self.attackRhythmListener = self.___ex.attackRhythmListener
    self.AttackRhythmHelperBtn = self.___ex.AttackRhythmHelperBtn
    self.attackMentality = self.___ex.attackMentality
    self.attackMentalityListener = self.___ex.attackMentalityListener
    self.AttackMentalityHelperBtn = self.___ex.AttackMentalityHelperBtn
    self.defenseMentality = self.___ex.defenseMentality
    self.defenseMentalityListener = self.___ex.defenseMentalityListener
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

    self.playerTeamsModel = nil
    self.formationCacheDataModel = nil
    self.teamTacticsData = nil
end

function FormationTacticsView:InitView(playerTeamsModel, formationCacheDataModel)
    self.playerTeamsModel = playerTeamsModel
    self.formationCacheDataModel = formationCacheDataModel
    self.teamTacticsData = self.formationCacheDataModel:GetTacticsCacheData()
    self.attackEmphasis.value = self.teamTacticsData.attackEmphasis
    self.attackRhythm.value = self.teamTacticsData.attackRhythm
    self.passTactic.value = self.teamTacticsData.passTactic
    self.attackMentality.value = self.teamTacticsData.attackMentality
    self.defenseMentality.value = self.teamTacticsData.defenseMentality
    self.attackEmphasisDetail.value = self.teamTacticsData.attackEmphasisDetail or 0
    self.attackEmphasisDetailDisable.value = self.teamTacticsData.attackEmphasisDetail or 0

    GameObjectHelper.FastSetActive(self.wideTendency, self.attackEmphasis.value < 3)
    GameObjectHelper.FastSetActive(self.wideTendencyDisable, not (self.attackEmphasis.value < 3))

    if not self.teamTacticsData.sideTactic then
        self.teamTacticsData.sideTactic = {}
    end
    self.teamTacticsData.sideTactic.left = self.teamTacticsData.sideTactic.left or 0
    self.teamTacticsData.sideTactic.right = self.teamTacticsData.sideTactic.right or 0
    GameObjectHelper.FastSetActive(self.leftBottomSelected, self.teamTacticsData.sideTactic.left == 1)
    GameObjectHelper.FastSetActive(self.leftInsideSelected, self.teamTacticsData.sideTactic.left == 2)
    GameObjectHelper.FastSetActive(self.rightBottomSelected, self.teamTacticsData.sideTactic.right == 1)
    GameObjectHelper.FastSetActive(self.rightInsideSelected, self.teamTacticsData.sideTactic.right == 2)

    if not self.teamTacticsData.sideGuardTactic then
        self.teamTacticsData.sideGuardTactic = {}
    end
    GameObjectHelper.FastSetActive(self.sideGuardLeftForwardSelected, self.teamTacticsData.sideGuardTactic.left == 1)
    GameObjectHelper.FastSetActive(self.sideGuardLeftKeepSelected, self.teamTacticsData.sideGuardTactic.left == 2)
    GameObjectHelper.FastSetActive(self.sideGuardRightForwardSelected, self.teamTacticsData.sideGuardTactic.right == 1)
    GameObjectHelper.FastSetActive(self.sideGuardRightKeepSelected, self.teamTacticsData.sideGuardTactic.right == 2)

    if not self.teamTacticsData.sideMidFieldTactic then
        self.teamTacticsData.sideMidFieldTactic = {}
    end
    GameObjectHelper.FastSetActive(self.sideMidFieldLeftForwardSelected, self.teamTacticsData.sideMidFieldTactic.left == 1)
    GameObjectHelper.FastSetActive(self.sideMidFieldLeftKeepSelected, self.teamTacticsData.sideMidFieldTactic.left == 2)
    GameObjectHelper.FastSetActive(self.sideMidFieldRightForwardSelected, self.teamTacticsData.sideMidFieldTactic.right == 1)
    GameObjectHelper.FastSetActive(self.sideMidFieldRightKeepSelected, self.teamTacticsData.sideMidFieldTactic.right == 2)
end

function FormationTacticsView:start()
    self.cancelBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.btnConfirm:regOnButtonClick(function ()
        self:OnConfirm()
    end)
    self.attackEmphasis.onValueChanged:AddListener(function(value) self:OnTacticsChanged(FormationConstants.FormationTacticsType.ATTACKEMPHASIS, value) end)
    self.attackRhythm.onValueChanged:AddListener(function(value) self:OnTacticsChanged(FormationConstants.FormationTacticsType.ATTACKRHYTHM, value) end)
    self.passTactic.onValueChanged:AddListener(function(value) self:OnTacticsChanged(FormationConstants.FormationTacticsType.PASSTACTIC, value) end)
    self.attackMentality.onValueChanged:AddListener(function(value) self:OnTacticsChanged(FormationConstants.FormationTacticsType.ATTACKMENTALITY, value) end)
    self.defenseMentality.onValueChanged:AddListener(function(value) self:OnTacticsChanged(FormationConstants.FormationTacticsType.DEFENSEMENTALITY, value) end)
    self.attackEmphasisDetail.onValueChanged:AddListener(function (value) self:OnTacticsChanged(FormationConstants.FormationTacticsType.ATTACKEMPHASISDETAIL, value) end)

    self.passTacticListener:regOnDrag(function ()
        self:PlaySound()
    end)
    self.attackEmphasisListener:regOnDrag(function ()
        self:PlaySound()
    end)
    self.attackRhythmListener:regOnDrag(function ()
        self:PlaySound()
    end)
    self.attackMentalityListener:regOnDrag(function ()
        self:PlaySound()
    end)
    self.defenseMentalityListener:regOnDrag(function ()
        self:PlaySound()
    end)
    self.attackEmphasisDetailListener:regOnDrag(function ()
        self:PlaySound()
    end)
    self.sideGuardLeftForwardBtn:regOnButtonClick(function ()
        self:PlaySound()
        local oldState = self.sideGuardLeftForwardSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideGuardLeftForwardSelected, not oldState)
        if not oldState then
            self.teamTacticsData.sideGuardTactic.left = 1
        end

        if self.sideGuardLeftKeepSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideGuardLeftKeepSelected, false)
        else
            if oldState then
                self.teamTacticsData.sideGuardTactic.left = 0
            end
        end
    end)
    self.sideGuardLeftKeepBtn:regOnButtonClick(function ()
        self:PlaySound()
        local oldState = self.sideGuardLeftKeepSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideGuardLeftKeepSelected, not oldState)
        if not oldState then
            self.teamTacticsData.sideGuardTactic.left = 2
        end

        if self.sideGuardLeftForwardSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideGuardLeftForwardSelected, false)
        else
            if oldState then
                self.teamTacticsData.sideGuardTactic.left = 0
            end
        end
    end)
    self.sideGuardRighttForwardBtn:regOnButtonClick(function ()
        self:PlaySound()
        local oldState = self.sideGuardRightForwardSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideGuardRightForwardSelected, not oldState)
        if not oldState then
            self.teamTacticsData.sideGuardTactic.right = 1
        end

        if self.sideGuardRightKeepSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideGuardRightKeepSelected, false)
        else
            if oldState then
                self.teamTacticsData.sideGuardTactic.right = 0
            end
        end
    end)
    self.sideGuardRightKeepBtn:regOnButtonClick(function ()
        self:PlaySound()
        local oldState = self.sideGuardRightKeepSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideGuardRightKeepSelected, not oldState)
        if not oldState then
            self.teamTacticsData.sideGuardTactic.right = 2
        end

        if self.sideGuardRightForwardSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideGuardRightForwardSelected, false)
        else
            if oldState then
                self.teamTacticsData.sideGuardTactic.right = 0
            end
        end
    end)

    self.sideMidFieldLeftForwardBtn:regOnButtonClick(function ()
        self:PlaySound()
        local oldState = self.sideMidFieldLeftForwardSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideMidFieldLeftForwardSelected, not oldState)
        if not oldState then
            self.teamTacticsData.sideMidFieldTactic.left = 1
        end

        if self.sideMidFieldLeftKeepSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideMidFieldLeftKeepSelected, false)
        else
            if oldState then
                self.teamTacticsData.sideMidFieldTactic.left = 0
            end
        end
    end)
    self.sideMidFieldLeftKeepBtn:regOnButtonClick(function ()
        self:PlaySound()
        local oldState = self.sideMidFieldLeftKeepSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideMidFieldLeftKeepSelected, not oldState)
        if not oldState then
            self.teamTacticsData.sideMidFieldTactic.left = 2
        end

        if self.sideMidFieldLeftForwardSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideMidFieldLeftForwardSelected, false)
        else
            if oldState then
                self.teamTacticsData.sideMidFieldTactic.left = 0
            end
        end
    end)
    self.sideMidFieldRightForwardBtn:regOnButtonClick(function ()
        self:PlaySound()
        local oldState = self.sideMidFieldRightForwardSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideMidFieldRightForwardSelected, not oldState)
        if not oldState then
            self.teamTacticsData.sideMidFieldTactic.right = 1
        end

        if self.sideMidFieldRightKeepSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideMidFieldRightKeepSelected, false)
        else
            if oldState then
                self.teamTacticsData.sideMidFieldTactic.right = 0
            end
        end
    end)
    self.sideMidFieldRightKeepBtn:regOnButtonClick(function ()
        self:PlaySound()
        local oldState = self.sideMidFieldRightKeepSelected.activeSelf
        GameObjectHelper.FastSetActive(self.sideMidFieldRightKeepSelected, not oldState)
        if not oldState then
            self.teamTacticsData.sideMidFieldTactic.right = 2
        end

        if self.sideMidFieldRightForwardSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.sideMidFieldRightForwardSelected, false)
        else
            if oldState then
                self.teamTacticsData.sideMidFieldTactic.right = 0
            end
        end
    end)

    self.leftBottomBtn:regOnButtonClick(function ()
        self:PlaySound()
        local oldState = self.leftBottomSelected.activeSelf
        GameObjectHelper.FastSetActive(self.leftBottomSelected, not oldState)
        if not oldState then
            self.teamTacticsData.sideTactic.left = 1
        end

        if self.leftInsideSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.leftInsideSelected, false)
        else
            if oldState then
                self.teamTacticsData.sideTactic.left = 0
            end
        end
    end)
    self.leftInsideBtn:regOnButtonClick(function ()
        self:PlaySound()
        local oldState = self.leftInsideSelected.activeSelf
        GameObjectHelper.FastSetActive(self.leftInsideSelected, not oldState)
        if not oldState then
            self.teamTacticsData.sideTactic.left = 2
        end
        if self.leftBottomSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.leftBottomSelected, false)
        else
            if oldState then
                self.teamTacticsData.sideTactic.left = 0
            end
        end
    end)
    self.rightBottomBtn:regOnButtonClick(function ()
        self:PlaySound()
        local oldState = self.rightBottomSelected.activeSelf
        GameObjectHelper.FastSetActive(self.rightBottomSelected, not oldState)
        if not oldState then
            self.teamTacticsData.sideTactic.right = 1
        end
        if self.rightInsideSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.rightInsideSelected, false)
        else
            if oldState then
                self.teamTacticsData.sideTactic.right = 0
            end
        end
    end)
    self.rightInsideBtn:regOnButtonClick(function ()
        self:PlaySound()
        local oldState = self.rightInsideSelected.activeSelf
        GameObjectHelper.FastSetActive(self.rightInsideSelected, not oldState)
        if not oldState then
            self.teamTacticsData.sideTactic.right = 2
        end
        if self.rightBottomSelected.activeSelf then
            GameObjectHelper.FastSetActive(self.rightBottomSelected, false)
        else
            if oldState then
                self.teamTacticsData.sideTactic.right = 0
            end
        end
    end)
    self.passTacticHelperBtn:regOnButtonClick(function ()
        local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Formation2/TacticsDlg/TacticsHelper.prefab", "camera", true, false)
        dialogcomp.contentcomp:InitData("PassTactic")
        self:coroutine(function()
            unity.waitForNextEndOfFrame()
            local newPos = self.passTacticHelperBtn.gameObject.transform.position
            dialogcomp.contentcomp.gameObject.transform.position = Vector3(newPos.x, newPos.y, newPos.z)
            dialogcomp.contentcomp.gameObject:SetActive(true)
        end)
    end)
    self.AttackRhythmHelperBtn:regOnButtonClick(function ()
        local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Formation2/TacticsDlg/TacticsHelper.prefab", "camera", true, false)
        dialogcomp.contentcomp:InitData("AttackRhythm")
        self:coroutine(function()
            unity.waitForNextEndOfFrame()
            local newPos = self.AttackRhythmHelperBtn.gameObject.transform.position
            dialogcomp.contentcomp.gameObject.transform.position = Vector3(newPos.x, newPos.y, newPos.z)
            dialogcomp.contentcomp.gameObject:SetActive(true)
        end)
    end)
    self.AttackMentalityHelperBtn:regOnButtonClick(function ()
        local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Formation2/TacticsDlg/TacticsHelper.prefab", "camera", true, false)
        dialogcomp.contentcomp:InitData("AttackMentality")
        self:coroutine(function()
            unity.waitForNextEndOfFrame()
            local newPos = self.AttackMentalityHelperBtn.gameObject.transform.position
            dialogcomp.contentcomp.gameObject.transform.position = Vector3(newPos.x, newPos.y, newPos.z)
            dialogcomp.contentcomp.gameObject:SetActive(true)
        end)
    end)
    self.DefenseStrategyHelperBtn:regOnButtonClick(function ()
        local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Formation2/TacticsDlg/TacticsHelper.prefab", "camera", true, false)
        dialogcomp.contentcomp:InitData("DefenseStrategy")
        self:coroutine(function()
            unity.waitForNextEndOfFrame()
            local newPos = self.DefenseStrategyHelperBtn.gameObject.transform.position
            dialogcomp.contentcomp.gameObject.transform.position = Vector3(newPos.x, newPos.y, newPos.z)
            dialogcomp.contentcomp.gameObject:SetActive(true)
        end)
    end)
    self.AttackEmphasisDetailHelperBtn:regOnButtonClick(function ()
        local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Formation2/TacticsDlg/TacticsHelper.prefab", "camera", true, false)
        dialogcomp.contentcomp:InitData("AttackEmphasisDetail")
        self:coroutine(function()
            unity.waitForNextEndOfFrame()
            local newPos = self.AttackEmphasisDetailHelperBtn.gameObject.transform.position
            dialogcomp.contentcomp.gameObject.transform.position = Vector3(newPos.x, newPos.y, newPos.z)
            dialogcomp.contentcomp.gameObject:SetActive(true)
        end)
    end)
    self:PlayInAnimator()
end

function FormationTacticsView:PlaySound()
    UISoundManager.play("Match/tacticsSlider", 1)
end


function FormationTacticsView:OnTacticsChanged(tacticsType, tacticsValue)
    if tacticsType == FormationConstants.FormationTacticsType.ATTACKEMPHASIS then
        self.teamTacticsData.attackEmphasis = tacticsValue
        GameObjectHelper.FastSetActive(self.wideTendency, tacticsValue < 3)
        GameObjectHelper.FastSetActive(self.wideTendencyDisable, not (tacticsValue < 3))
    elseif tacticsType == FormationConstants.FormationTacticsType.ATTACKRHYTHM then
        self.teamTacticsData.attackRhythm = tacticsValue
    elseif tacticsType == FormationConstants.FormationTacticsType.PASSTACTIC then
        self.teamTacticsData.passTactic = tacticsValue
    elseif tacticsType == FormationConstants.FormationTacticsType.ATTACKMENTALITY then
        self.teamTacticsData.attackMentality = tacticsValue
    elseif tacticsType == FormationConstants.FormationTacticsType.DEFENSEMENTALITY then
        self.teamTacticsData.defenseMentality = tacticsValue
    elseif tacticsType == FormationConstants.FormationTacticsType.ATTACKEMPHASISDETAIL then
        self.teamTacticsData.attackEmphasisDetail = tacticsValue
        self.attackEmphasisDetailDisable.value = tacticsValue
    end
end

function FormationTacticsView:OnConfirm()
    self.formationCacheDataModel:SetTacticsCacheData(self.teamTacticsData)
    EventSystem.SendEvent("FormationPageView.ChangeTactic")
    self:Close()
end

function FormationTacticsView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FormationTacticsView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function FormationTacticsView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function FormationTacticsView:Close()
    self:PlayOutAnimator()
end

return FormationTacticsView

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local TrainingUnlock = require("data.TrainingUnlock")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local SupporterType = require("ui.models.cardDetail.supporter.SupporterType")
local DialogManager = require("ui.control.manager.DialogManager")
local TrainingSupporterView = class(unity.base, "TrainingSupporterView")

function TrainingSupporterView:ctor()
--------Start_Auto_Generate--------
    self.otherDetailBtn = self.___ex.otherDetailBtn
    self.supportProgressTxt = self.___ex.supportProgressTxt
    self.supportProgressDescTxt = self.___ex.supportProgressDescTxt
    self.supportSkillTxt = self.___ex.supportSkillTxt
    self.supportTog = self.___ex.supportTog
    self.unLockTrans = self.___ex.unLockTrans
    self.closeFuncGo = self.___ex.closeFuncGo
    self.selfDetailBtn = self.___ex.selfDetailBtn
    self.selfProgressTxt = self.___ex.selfProgressTxt
    self.selfProgressDescTxt = self.___ex.selfProgressDescTxt
    self.selfSkillTxt = self.___ex.selfSkillTxt
    self.selfTog = self.___ex.selfTog
--------End_Auto_Generate----------
end

function TrainingSupporterView:start()
    self.otherDetailBtn:regOnButtonClick(function()
        local supportTraining = self.model:GetSupportTraining()
        local supportMaxTraining = self.model:GetSupportMaxTraining()
        self:OnDetailBtnClick(supportTraining, supportMaxTraining)
    end)
    self.selfDetailBtn:regOnButtonClick(function()
        local selfTraining = self.model:GetSelfTraining()
        local selfMaxTraining = self.model:GetSelfMaxTraining()
        self:OnDetailBtnClick(selfTraining, selfMaxTraining)
    end)
    self.supportTog.onValueChanged.AddListener(function(isOn)
        if isOn then
            self:OnToggleClick(SupporterType.StType.SupportCard)
        end
    end)
    self.selfTog.onValueChanged.AddListener(function(isOn)
        if isOn then
            self:OnToggleClick(SupporterType.StType.SelfCard)
        end
    end)
end

function TrainingSupporterView:InitView(trainingSupporterModel)
    self.model = trainingSupporterModel
    local supportModel = self.model:GetSupportModel()
    local supportCardModel = supportModel:GetSupportCardModel()
    GameObjectHelper.FastSetActive(self.transform.gameObject, supportCardModel ~= nil)
    if not supportCardModel then
        return
    end
    local supportMaxTraining = self.model:GetSupportMaxTraining()
    local supportMinTraining = self.model:GetSupportMinTraining()
    local supportExSkillLock = self.model:GetSupportExSkillLock()
    local selfMaxTraining = self.model:GetSelfMaxTraining()
    local selectTrainingType = self.model:GetSelectTrainingType()
    local selfExSkill = self.model:GetSelfExSkill()
    local supportProgressStr, supportProgressDescStr, supportSkillTxtStr, selfProgressStr, selfProgressDescStr, selfSkillTxtStr
    local progressTitle = lang.transstr("timelimit_league_letter_progress")
    if supportMaxTraining.chapter == -1 then
        supportProgressStr = progressTitle .. lang.transstr("not_open")
        supportProgressDescStr = ""
        supportSkillTxtStr = lang.transstr("support_train_skill") .. lang.transstr("not_unlock")
    else
        supportProgressStr ="<color=#0B8110>" .. supportMinTraining.chapter .. "-" .. supportMinTraining.stage .. "</color>"
        supportProgressStr = progressTitle .. supportProgressStr .. "/" .. supportMaxTraining.chapter .. "-" .. supportMaxTraining.stage
        if supportMinTraining.stage == 0 then
            supportProgressDescStr = lang.transstr("special_events_not_open")
        else
            supportProgressDescStr = lang.transstr("number_" .. supportMinTraining.stage)
            supportProgressDescStr = lang.transstr("support_train_stage", supportProgressDescStr)
        end
        supportProgressDescStr = TrainingUnlock[tostring(supportMinTraining.chapter)].name .. "," .. supportProgressDescStr

        supportSkillTxtStr = lang.transstr("support_train_skill")
        if next(supportExSkillLock) then
            supportSkillTxtStr = lang.transstr("support_train_skill")
            for i, v in ipairs(supportExSkillLock) do
                if v.open and not v.close then
                    supportSkillTxtStr = supportSkillTxtStr .. v.chapter .. "-" .. v.stage .. "  "
                end
            end
            supportSkillTxtStr = supportSkillTxtStr .. lang.transstr("unlock")
        else
            supportSkillTxtStr = supportSkillTxtStr .. lang.transstr("support_train_none_skill")
        end
    end

    if selfMaxTraining.chapter == -1 then
        selfProgressStr = progressTitle .. lang.transstr("not_open")
        selfProgressDescStr = ""
        selfSkillTxtStr = lang.transstr("support_train_skill") .. lang.transstr("not_unlock")
    else
        selfProgressStr = progressTitle .. selfMaxTraining.chapter .. "-" .. selfMaxTraining.stage
        if selfMaxTraining.stage == 0 then
            selfProgressDescStr = lang.transstr("special_events_not_open")
        else
            selfProgressDescStr = lang.transstr("number_" .. selfMaxTraining.stage)
            selfProgressDescStr = lang.transstr("support_train_stage", selfProgressDescStr)
        end
        selfProgressDescStr = progressTitle .. TrainingUnlock[tostring(selfMaxTraining.chapter)].name .. "," .. selfProgressDescStr
        selfSkillTxtStr = lang.transstr("support_train_skill")
        if next(selfExSkill) then
            selfSkillTxtStr = lang.transstr("support_train_skill")
            for i, v in ipairs(selfExSkill) do
                selfSkillTxtStr = selfSkillTxtStr .. v.chapter .. "-" .. v.stage .. " "
            end
            selfSkillTxtStr = selfSkillTxtStr .. lang.transstr("unlock")
        else
            selfSkillTxtStr = selfSkillTxtStr .. lang.transstr("support_train_none_skill")
        end
    end

    GameObjectHelper.FastSetActive(self.supportTog.gameObject, supportMaxTraining.chapter ~= -1)
    GameObjectHelper.FastSetActive(self.transform.gameObject, selfMaxTraining.chapter ~= -1)
    GameObjectHelper.FastSetActive(self.closeFuncGo, supportMaxTraining.chapter == -1)

    if selectTrainingType == SupporterType.StType.SupportCard then
        self.supportTog.isOn = true
    elseif selectTrainingType == SupporterType.StType.SelfCard then
        self.selfTog.isOn = true
    end

    self.trainingType = selectTrainingType
    self.supportProgressTxt.text = supportProgressStr
    self.supportProgressDescTxt.text = supportProgressDescStr
    self.supportSkillTxt.text = supportSkillTxtStr
    self.selfProgressTxt.text = selfProgressStr
    self.selfProgressDescTxt.text = selfProgressDescStr
    self.selfSkillTxt.text = selfSkillTxtStr
    self:InitSupportLockArea(supportExSkillLock)
end

function TrainingSupporterView:InitSupportLockArea(supportExSkillLock)
    res.ClearChildren(self.unLockTrans)
    local ascendLock = self.model:GetAscendLock()
    local supportModel = self.model:GetSupportModel()
    local lockRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Supporter/TrainingLockItem.prefab")
    if ascendLock then
        local lockObj = Object.Instantiate(lockRes)
        local lockSpt = res.GetLuaScript(lockObj)
        lockObj.transform:SetParent(self.unLockTrans, false)
        lockSpt:InitView(ascendLock, false, supportModel)
    end
    for i, v in ipairs(supportExSkillLock) do
        if (not v.open) or v.close then
            local lockObj = Object.Instantiate(lockRes)
            local lockSpt = res.GetLuaScript(lockObj)
            lockObj.transform:SetParent(self.unLockTrans, false)
            lockSpt:InitView(v, true, supportModel)
            return -- 只有符合条件的第一条显示
        end
    end
end

function TrainingSupporterView:OnDetailBtnClick(trainingData, maxTrainingId)
    local prefabPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Supporter/SupportTrainingReview.prefab"
    local resDlg, dialogcomp = res.ShowDialog(prefabPath, "camera", true, true)
    dialogcomp.contentcomp:InitView(trainingData, maxTrainingId)
end

function TrainingSupporterView:OnToggleClick(trainingType)
    local selectTrainingType = self.model:GetSelectTrainingType()
    if trainingType == selectTrainingType then
        return
    end
    local maxTrainType = self.model:GetMaxTrainingType()
    local maxSelf = self.model:GetSelfMaxTraining()
    local maxSupport = self.model:GetSupportMaxTraining()
    maxSelf = tonumber(maxSelf.chapter) * 100 + tonumber(maxSelf.stage)
    maxSupport = tonumber(maxSupport.chapter) * 100 + tonumber(maxSupport.stage)
    if trainingType ~= maxTrainType and maxSelf ~= maxSupport then
        if selectTrainingType == SupporterType.StType.SelfCard then
            self.selfTog.isOn = true
        else
            self.supportTog.isOn = true
        end
        DialogManager.ShowConfirmPopByLang("tips", "support_train_switch",
                function() self:SwitchTrain(trainingType) end)
    else
        self:SwitchTrain(trainingType)
    end
end

function TrainingSupporterView:SwitchTrain(trainingType)
    self.trainingType = trainingType
    self.model:SetSelectTrainingType(self.trainingType)
    EventSystem.SendEvent("Supporter_Select_type")
    if trainingType == SupporterType.StType.SelfCard then
        self.selfTog.isOn = true
    else
        self.supportTog.isOn = true
    end
    DialogManager.ShowToastByLang("support_train_success")
end

function TrainingSupporterView:EnterScene()

end

function TrainingSupporterView:ExitScene()

end

return TrainingSupporterView

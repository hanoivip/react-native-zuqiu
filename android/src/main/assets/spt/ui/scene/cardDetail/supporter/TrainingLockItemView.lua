local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")

local TrainingLockItemView = class(unity.base, "TrainingLockItemView")

function TrainingLockItemView:ctor()
--------Start_Auto_Generate--------
    self.lockTxt = self.___ex.lockTxt
    self.lockConditionTxt = self.___ex.lockConditionTxt
    self.addGo = self.___ex.addGo
    self.addBtn = self.___ex.addBtn
--------End_Auto_Generate----------
    self.disableColor =  Color(0.48, 0.48, 0.48)
    self.normalColor = Color(0.2, 0.2, 0.2)
end

function TrainingLockItemView:start()
    self.addBtn:regOnButtonClick(function ()
        self:OnAddClick()
    end)
end

function TrainingLockItemView:InitView(lockData, isSkill, supportModel)
    self.supportModel = supportModel
    self.lockData = lockData
    local reqStr = lang.transstr("support_require")
    local cardModel = supportModel:GetCardModel()
    local quality = cardModel:GetCardQuality()
    local qualitySpecial = cardModel:GetCardQualitySpecial()
    local qualitySuffix = CardHelper.GetQualityNameConfigFixed(quality, qualitySpecial)
    local cardName = cardModel:GetName()
    local addGoState = true
    cardName = qualitySuffix .. cardName
    if isSkill then
        local trainStr = lockData.chapter .. "-" .. lockData.stage
        local tStr = trainStr .. lang.transstr("support_train_ex")
        self.lockTxt.text = lang.trans("support_train_progress", tStr)
        self.lockConditionTxt.text = reqStr .. lang.transstr("support_train_card", lockData.cardNum, cardName)
        local tColor
        if lockData.close then
            if lockData.open then
                tColor = self.normalColor
                self.lockConditionTxt.text = reqStr .. lang.transstr("support_train_ascend", cardName, lockData.throughCondition)
                addGoState = false
            else
                tColor = self.disableColor
            end
        else
            tColor = self.normalColor
        end
        self.lockTxt.color = tColor
        self.lockConditionTxt.color = tColor
    else
        local throughCondition = lockData.throughCondition
        local trainStr = lockData.throughChapter .. "-" .. lockData.throughStage
        self.lockTxt.text = lang.trans("support_train_progress", trainStr)
        self.lockConditionTxt.text = reqStr .. lang.transstr("support_train_ascend", cardName, throughCondition)
        addGoState = false
    end
    GameObjectHelper.FastSetActive(self.addGo, addGoState)
end

function TrainingLockItemView:OnAddClick()
    local cardModel = self.supportModel:GetCardModel()
    local isHasSupportCard = cardModel:IsHasSupportCard()
    if not isHasSupportCard then
        DialogManager.ShowToastByLang("support_confirm_tip")
        return
    end
    local isTrainingUseSelf = cardModel:IsTrainingUseSelf()
    if isTrainingUseSelf then
        DialogManager.ShowToastByLang("support_support_switch_tip")
        return
    end
    local playerCardsMapModel = PlayerCardsMapModel.new()
    local cid = cardModel:GetCid()
    local sameCard = playerCardsMapModel:GetSameCardList(cid)
    if not next(sameCard) then
        DialogManager.ShowToastByLang("support_card_none")
        return
    end
    
    if not self.lockData.close then
        local selectPrefabPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Supporter/SupportTrainingSelect.prefab"
        local resDlg, dialogcomp = res.ShowDialog(selectPrefabPath,"camera", true, true)
        dialogcomp.contentcomp:InitView(cardModel, self.lockData)
    end
end

return TrainingLockItemView

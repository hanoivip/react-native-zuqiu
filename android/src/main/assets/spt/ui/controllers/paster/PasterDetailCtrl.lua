local DialogManager = require("ui.control.manager.DialogManager")
local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local PasterStateType = require("ui.scene.paster.PasterStateType")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PasterDetailCtrl = class(BaseCtrl)
PasterDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Paster/PasterDetail.prefab"
PasterDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function PasterDetailCtrl:Init(pasterModel, bSupporter)
    self.cardPastersMapModel = CardPastersMapModel.new()
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.pasterModel = pasterModel
    self.bSupporter = bSupporter
    self.view.clickUse = function() self:OnClickUse() end
    self.view.clickSkill = function() self:OnClickSkill() end
    self.view.clickSplit = function() self:OnClickSplit() end
    self.view.clicUpgrade = function() self:OnClickUpgrade() end
end

function PasterDetailCtrl:Refresh()
    PasterDetailCtrl.super.Refresh(self)
    self.view:InitView(self.pasterModel, self.cardPastersMapModel, self.bSupporter)
end

function PasterDetailCtrl:GetStatusData()
    return self.pasterModel
end

function PasterDetailCtrl:OnClickSkill()
    if self.pasterModel:IsCompetePaster() then
        return
    end
    res.PushDialog("ui.controllers.paster.PasterSkillInstructionCtrl", self.pasterModel, self.bSupporter)
end

function PasterDetailCtrl:OnClickUpgrade()
    res.PushDialog("ui.controllers.pasterUpgrade.PasterUpgradeCtrl", self.pasterModel)
    self.view:Close()
end

function PasterDetailCtrl:OnClickSplit()
    local ptid = self.pasterModel:GetId()
    local callback = function()
        clr.coroutine(function()
            local respone = req.pasterDecomposition(ptid)
            if api.success(respone) then
                local data = respone.val
                local paster = data.cost.paster
                self.cardPastersMapModel:RemovePasterData(paster.ptid)
                CongratulationsPageCtrl.new(data.contents)
                self.view:Close()
            end
        end)
    end

    local pieceTypeDesc = ""
    if self.pasterModel:IsWeekPaster() then
        pieceTypeDesc = lang.transstr("paster_piece_week")
    elseif self.pasterModel:IsMonthPaster() then
        descText = lang.trans("paster_month_instruction")
        pieceTypeDesc = lang.transstr("paster_piece_month")
    elseif self.pasterModel:IsHonorPaster() then
        pieceTypeDesc = lang.transstr("paster_piece_honor")
    elseif self.pasterModel:IsAnnualPaster() then
        pieceTypeDesc = lang.transstr("paster_piece_annual")
    elseif self.pasterModel:IsCompetePaster() then
        pieceTypeDesc = lang.transstr("paster_piece_compete")
    end
    local tipTitle = lang.trans("split_paster")
    local tipContent = lang.trans("split_paster_content", pieceTypeDesc)
    self:OnMessageBox(tipTitle, tipContent, callback) 
end

function PasterDetailCtrl:OnMessageBox(titleText, contentText, callback) 
    local content = { }
    content.title = titleText
    content.content = contentText
    content.button1Text = lang.trans("cancel")
    content.button2Text = lang.trans("confirm")
    content.onButton2Clicked = function()
        callback()
    end
    local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/MessageBox.prefab', 'overlay', true, true, nil, nil, 10000)
    dialogcomp.contentcomp:initData(content)
end

function PasterDetailCtrl:OnClickUse()
    local pasterState = self.pasterModel:GetPasterState()
    if pasterState == PasterStateType.CanUse then
        local cardsMap = {}
        local cardList = self.playerCardsMapModel:GetCardList()
        if self.pasterModel:GetPasterUsedByAll() then
            -- 争霸贴纸特殊处理，有对应技能加成球员才显示在界面中
            if self.pasterModel:IsCompetePaster() then
                local competeSid = self.pasterModel:GetCompetePasterSkill()
                for i, pcid in ipairs(cardList) do
                    local cardModel = PlayerCardModel.new(pcid)
                    local skills = cardModel:GetSkills()
                    local hasCompeteSkill = false
                    for k, v in pairs(skills) do
                        if v.sid == competeSid then
                            hasCompeteSkill = true
                            break
                        end
                    end
                    if hasCompeteSkill then table.insert(cardsMap, cardModel) end
                end
            else
                for i, pcid in ipairs(cardList) do
                    local cardModel = PlayerCardModel.new(pcid)
                    table.insert(cardsMap, cardModel)
                end
            end
        elseif self.pasterModel:IsPasterUsedByPosition() then -- 同位置球员贴纸
            for i, pcid in ipairs(cardList) do
                local cardModel = PlayerCardModel.new(pcid)
                if self:CheckPlayerPosition(cardModel) then
                    table.insert(cardsMap, cardModel)
                end
            end
        else
            local cardIds = self.pasterModel:GetPasterUsedByCard()
            for i, cid in ipairs(cardIds) do
                local sameCardList = self.playerCardsMapModel:GetSameCardList(cid)
                for pcid, v in pairs(sameCardList) do
                    local cardModel = PlayerCardModel.new(pcid)
                    table.insert(cardsMap, cardModel)
                end
            end
        end

        if next(cardsMap) then 
            self.view:Close()
            res.PushDialog("ui.controllers.paster.PasterCardChooseCtrl", self.pasterModel, cardsMap)
        else
            DialogManager.ShowToast(lang.trans("paster_not_player"))
        end
    elseif pasterState == PasterStateType.Unload then 
        local ptid = self.pasterModel:GetId()
        local pcid = self.pasterModel:GetPcid()

        local callback = function() 
            clr.coroutine(function()
                local respone = req.pasterUnEquip(pcid, ptid)
                if api.success(respone) then
                    local data = respone.val
                    local card = data.card
                    local paster = data.paster
                    self.cardPastersMapModel:AddPasterData(paster.ptid, paster)
                    self.playerCardsMapModel:ResetCardData(card.pcid, card)
                    local cardModel = PlayerCardModel.new(pcid)
                    cardModel:InitPasterModel()
                    EventSystem.SendEvent("Paster_UnloadToCard", cardModel)
                    self.view:Close()
                end
            end)
        end
        local titleText = lang.trans("unload_paster")
        local contentText = ""
        if self.pasterModel:IsHonorPaster() or self.pasterModel:IsAnnualPaster() or self.pasterModel:IsCompetePaster() then 
            contentText = lang.trans("unload_paster_honor_content")
        else
            contentText = lang.trans("unload_paster_content")
        end
        DialogManager.ShowMessageBox(titleText, contentText, callback) 
    end
end

-- 检测球员是否能使用该贴纸（同位置球员贴纸）
function PasterDetailCtrl:CheckPlayerPosition(cardModel)
    local playerPositions = cardModel:GetPosition()
    local availablePositions = self.pasterModel:GetPasterUsedByPosition()
    for i, availablePosition in ipairs(availablePositions) do
        for i, playerPosition in ipairs(playerPositions) do
            if playerPosition == availablePosition then
                return true
            end
        end
    end
    return false
end

function PasterDetailCtrl:OnEnterScene()
    self.view:EnterScene()
end

function PasterDetailCtrl:OnExitScene()
    self.view:ExitScene()
end

return PasterDetailCtrl


local UnityEngine = clr.UnityEngine
local EventSystems = clr.UnityEngine.EventSystems
local WaitForSeconds = UnityEngine.WaitForSeconds
local UpgradeBoxPopCtrl = require("ui.controllers.cardDetail.UpgradeBoxPopCtrl")
local TipUpgradeCtrl = require("ui.controllers.cardDetail.TipUpgradeCtrl")
local CustomEvent = require("ui.common.CustomEvent")
local DialogManager = require("ui.control.manager.DialogManager")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local ItemDetailModel = require("ui.models.itemDetail.ItemDetailModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local EventSystems = clr.UnityEngine.EventSystems
local AdvanceCtrl = class()

function AdvanceCtrl:ctor(view) 
    self.view = view
    self.view.clickOnekey = function() self:OnBtnOnekey() end
    self.view.clickAdvance = function() self:OnBtnAdvance() end
    self.view.clickEquip = function(slot) self:OnBtnEquip(slot) end
    self.view.clickSkill = function(slot) self:OnBtnSkill(slot) end
    self.view.updateUpgradeData = function(upgradeData) self:UpdateUpgradeData(upgradeData) end
end

function AdvanceCtrl:EnterScene()
    self.view:EnterScene()
end

function AdvanceCtrl:ExitScene()
    self.view:ExitScene()
end

function AdvanceCtrl:InitControl(cardDetailModel) 
    self.cardDetailModel = cardDetailModel
    self.view:InitView(cardDetailModel)
end

function AdvanceCtrl:OnBtnSkill(slot) 
    local skillModel = self.cardDetailModel:GetSkillModel(slot)
    if skillModel then
        res.AddCache("Assets/CapstonesRes/Game/UI/Scene/SkillDetail/SkillDetail.prefab")
        res.PushDialog("ui.controllers.skill.SkillDetailCtrl", slot, self.cardDetailModel:GetCardModel())
    end
end

function AdvanceCtrl:OnBtnOnekey()
    local cardModel = self.cardDetailModel:GetCardModel()
    if not cardModel:IsOperable() then 
        return 
    end
    local isSupporterCloseByConfig = self.cardDetailModel:IsSupporterCloseByConfig()
    if isSupporterCloseByConfig then
        return
    end
    local isCanUseSupporter = cardModel:CanUseSupporter()
    if isCanUseSupporter then
        if cardModel:IsSupportOtherCard() then
            local sppcid = cardModel:GetSppcid()
            local sppcidCardModel = PlayerCardModel.new(sppcid)
            local name = sppcidCardModel:GetName()
            local quality = sppcidCardModel:GetCardQuality()
            local QualitySpecial = sppcidCardModel:GetCardQualitySpecial()
            local fixQuality = CardHelper.GetQualityFixed(quality, QualitySpecial)
            local qualitySign = CardHelper.GetQualitySign(fixQuality)
            DialogManager.ShowToast(lang.trans("support_tip_7", qualitySign, name))
        else
            res.PushDialog("ui.controllers.cardDetail.supporter.SupporterCtrl", cardModel)
        end
        return
    end
    local availableEquip, availableEquipPiece = cardModel:GetAvailableEquipToSwear()
    if next(availableEquip) or next(availableEquipPiece) then 
        local pcid = cardModel:GetPcid()
        local postAvailableEquipData = {}
        local postAvailableEquipPieceData = {}
        for i, slot in ipairs(availableEquip) do
            local slots = {slot}
            local postEquipData = {pcid = pcid, slots = slots}
            table.insert(postAvailableEquipData, postEquipData)
        end
        for i, data in ipairs(availableEquipPiece) do
            local slots = {data.slot}
            local postEquipPieceData = {pcid = pcid, eid = data.eid, slots = slots}
            table.insert(postAvailableEquipPieceData, postEquipPieceData)
        end

        clr.coroutine(function()
            local respone = req.cardOnekeyEquip(pcid, postAvailableEquipData, postAvailableEquipPieceData)
            if api.success(respone) then
                local data = respone.val
                local equips = data.equips
                local currentEventSystem = EventSystems.EventSystem.current
                currentEventSystem.enabled = false
                if equips then -- 服务器的数据有点冗余
                    for i, equipData in ipairs(equips) do
                        local slotData = equipData.slot
                        for m, ret in pairs(slotData) do
                            cardModel:WearEquip(ret.slot)
                            local itemDetailModel = ItemDetailModel.new(ret.eid)
                            itemDetailModel:ResetEquipNum(ret.eid, ret.num)
                            coroutine.yield(WaitForSeconds(0.1))
                        end
                    end
                end
                local equipPieces = data.equipPieces
                if equipPieces then
                    for i, equipPieceData in ipairs(equipPieces) do
                        local slotData = equipPieceData.equips.slot
                        local eid
                        for k, ret in pairs(slotData) do
                            cardModel:WearEquip(ret.slot)
                            eid = ret.eid
                            coroutine.yield(WaitForSeconds(0.1))
                        end
                        local itemDetailModel = ItemDetailModel.new(eid)
                        itemDetailModel:ResetEquipPieceNum(equipPieceData.equipPieces)
                    end
                end
                self.cardDetailModel:ResetCardData(data.card)
		currentEventSystem.enabled = true
                GuideManager.Show(self)
                currentEventSystem.enabled = true
            end
        end)
    elseif cardModel:GetUpgrade() >= cardModel:GetMaxUpgradeNum() then 
        DialogManager.ShowToast(lang.trans("one_key_equip_tip3"))
    elseif cardModel:HasEquipFull() then 
        DialogManager.ShowToast(lang.trans("one_key_equip_tip2"))
    else
        DialogManager.ShowToast(lang.trans("one_key_equip_tip"))
    end
end

function AdvanceCtrl:OnBtnEquip(slot)
    local equipModel = self.cardDetailModel:GetEquipModel(slot)
    if equipModel then
        res.AddCache("Assets/CapstonesRes/Game/UI/Scene/EquipDetail/EquipDetail.prefab")
        local eid = equipModel:GetEquipID()
        clr.coroutine(function()
            local currentEventSystem = EventSystems.EventSystem.current
            currentEventSystem.enabled = false
            unity.waitForEndOfFrame()
            local equipDetailCtrl = res.PushDialogImmediate("ui.controllers.equip.EquipDetailCtrl", eid, self.cardDetailModel, slot)
            -- 点击第一个装备栏位
            GuideManager.Show(equipDetailCtrl)
            currentEventSystem.enabled = true
            cache.setRequiredEquipCount(1)
        end)
    end
end

function AdvanceCtrl:OnBtnAdvance()
    local cardModel = self.cardDetailModel:GetCardModel()
    if not cardModel:IsOperable() then 
        return 
    end
    local interactable = cardModel:IsOperable() and cardModel:IsCanUpgrade()
    if interactable then 
        local pcid = cardModel:GetPcid()

        clr.coroutine(function()
            local respone = req.cardUpgrade(pcid)
            if api.success(respone) then
                local data = respone.val
                self.view:ShowAdvanceEffect(data)
            end
        end)
    else
        if cardModel:GetUpgrade() >= cardModel:GetMaxUpgradeNum() then 
            DialogManager.ShowToast(lang.trans("tip_upgrade2"))
        else
            TipUpgradeCtrl.new(self.cardDetailModel)
        end
    end
end

-- 在进阶特效播放完毕后再更新界面
function AdvanceCtrl:UpdateUpgradeData(data)
    CustomEvent.CardGradeUp()
    self.cardDetailModel:ResetCardData(data.card)
    local cardModel = self.cardDetailModel:GetCardModel()
    self:PopUpgradeInfoBox(cardModel, data.card.upgrade)
    -- 点击进阶按钮
    GuideManager.Show(res.curSceneInfo.ctrl)
end

function AdvanceCtrl:PopUpgradeInfoBox(skillModelMap, upgrade)
    UpgradeBoxPopCtrl.new(skillModelMap, upgrade)
end

return AdvanceCtrl
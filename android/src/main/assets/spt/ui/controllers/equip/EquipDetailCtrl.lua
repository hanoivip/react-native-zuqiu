local BaseCtrl = require("ui.controllers.BaseCtrl")
local TipEquipCtrl = require("ui.controllers.cardDetail.TipEquipCtrl")
local CardDialogType = require("ui.controllers.cardDetail.CardDialogType")
local ItemDetailModel = require("ui.models.itemDetail.ItemDetailModel")
local DialogManager = require("ui.control.manager.DialogManager")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local UIBgmManager = require("ui.control.manager.UIBgmManager")

local EquipDetailCtrl = class(BaseCtrl)
EquipDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/EquipDetail/EquipDetail.prefab"

EquipDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function EquipDetailCtrl:Init(equipID, model, slot)
    self.view.clickEquip = function(isCanEquip) self:OnBtnUseClick(isCanEquip) end
    self.view.clickComposite = function() self:OnBtnCompositeClick() end

    self.view.resetEquipAndPieceCallBack = function() self:ResetEquipAndPieceCallBack() end
    self.view.showDetail = function() self:ShowDetail() end
end

function EquipDetailCtrl:Refresh(equipID, model, slot)
    EquipDetailCtrl.super.Refresh(self)
    self.equipID = equipID
    self.model = model
    self.slot = slot
    self.itemDetailModel = ItemDetailModel.new(self.equipID)
    self.equipItemModel = self.model:GetCardModel():GetEquipModel(self.slot)

    self:InitView()

    EventSystem.SendEvent("CardDetail_ClickDialog", CardDialogType.EQUIP)
end

function EquipDetailCtrl:GetStatusData()
    return self.equipID, self.model, self.slot
end

function EquipDetailCtrl:OnEnterScene()
    self.view:EnterScene()
end

function EquipDetailCtrl:OnExitScene()
    self.view:ExitScene()
end

function EquipDetailCtrl:ShowDetail()
    EventSystem.SendEvent("CardDetail_ShowDetail")
end

function EquipDetailCtrl:InitView()
    self.view:InitView(self.itemDetailModel, self.equipItemModel, self.model, self.slot)
end

function EquipDetailCtrl:ResetEquipAndPieceCallBack()
    self:InitView()
end

function EquipDetailCtrl:OnBtnUseClick(isCanEquip)
    local cardModel = self.model:GetCardModel()
    local isOperable = cardModel:IsOperable()
    if not isOperable then
        return 
    elseif self.equipItemModel:IsEquip() then
        if GuideManager.GuideIsOnGoing("main") then
            GuideManager.Show(res.curSceneInfo.ctrl)
            self.view:Close(true)
        end
        return
    elseif not isCanEquip then
        DialogManager.ShowToast(lang.trans("no_equip"), { initPosition = {x = 0, y = 200} })
        return 
    else
        local isReachLevel = self.model:IsEquipToReachCardLevel(self.slot)
        if not isReachLevel then 
            DialogManager.ShowToast(lang.trans("equip_level_tip"), { initPosition = {x = 0, y = 200} })
            return
        end
    end
    
    local pcid = cardModel:GetPcid()
    local slots = {self.slot}

    local equipNum = tonumber(self.itemDetailModel:GetEquipNum())
    if equipNum > 0 then 
        if self.model:IsEquipToReachCardLevel(self.slot) then 
            clr.coroutine(function()
                local respone = req.cardUpgradeEquips(pcid, slots)
                if api.success(respone) then
                    UIBgmManager.play('Card/synthesis')
                    local data = respone.val

                    for slot, ret in pairs(data.slot) do
                        cardModel:WearEquip(ret.slot)
                        self.itemDetailModel:ResetEquipNum(ret.eid, ret.num)
                        -- 点击装备按钮
                        GuideManager.Show(res.curSceneInfo.ctrl)
                        -- 穿完装备关闭界面
                        self.view:Close(true)
                    end
                    self.model:ResetCardData(data.card)
                end
            end)
        else    
            DialogManager.ShowToast(lang.trans("equip_level_tip"), { initPosition = {x = 0, y = 200} })
        end
    else
        local eid = self.equipItemModel:GetEquipID()
        clr.coroutine(function()
            local respone = req.cardUpgradeEquipsDirect(eid, pcid, slots)
            if api.success(respone) then
                UIBgmManager.play('Card/synthesis')
                local data = respone.val

                self.itemDetailModel:ResetEquipPieceNum(data.equipPieces)
                for slot, ret in pairs(data.equips.slot) do
                    cardModel:WearEquip(ret.slot)
                    -- 穿完装备关闭界面
                    self.view:Close(true)
                end
                self.model:ResetCardData(data.card)
            end
        end)
    end
end

function EquipDetailCtrl:OnBtnCompositeClick()
    local currentPieceNum = tonumber(self.itemDetailModel:GetEquipPieceNum())
    local compositePieceNum = tonumber(self.itemDetailModel:GetCompositePieceNum())
    local isComposite = currentPieceNum >= compositePieceNum
    if isComposite then 
        local eid = self.itemDetailModel:GetEquipID()
        clr.coroutine(function()
            local respone = req.equipIncorporate(eid)
            if api.success(respone) then
                UIBgmManager.play('Card/synthesis')
                local data = respone.val
                self.itemDetailModel:ResetEquipAndPiece(data)
            end
        end)
    else
        TipEquipCtrl.new(self.itemDetailModel)
    end    
end

return EquipDetailCtrl

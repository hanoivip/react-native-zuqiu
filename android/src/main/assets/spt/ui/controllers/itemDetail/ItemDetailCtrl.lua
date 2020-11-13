local BaseCtrl = require("ui.controllers.BaseCtrl")
local ItemDetailCtrl = class(BaseCtrl)

local ItemDetailModel = require("ui.models.itemDetail.ItemDetailModel")

local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds

ItemDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/ItemDetail/ItemDetail.prefab"

ItemDetailCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function ItemDetailCtrl:Init(equipID, cardModel, isOperable, isAllowChangeScene)
    self.view.clickUse = function() self:OnBtnUseClick() end
    self.view.clickComposite = function() self:OnBtnCompositeClick() end

    self.view.resetEquipAndPieceCallBack = function() self:ResetEquipAndPieceCallBack() end
end

function ItemDetailCtrl:Refresh(equipID, cardModel, isOperable, isAllowChangeScene, slot)
    ItemDetailCtrl.super.Refresh(self)

    self.equipID = equipID
    self.cardModel = cardModel
    self.isOperable = isOperable
    self.isAllowChangeScene = isAllowChangeScene
    self.slot = slot
    self.itemDetailModel = ItemDetailModel.new(self.equipID)
    local equipItemModel = self.itemDetailModel:GetEquipModel()
    equipItemModel.GetAddNum = function() 
        return self.itemDetailModel:GetEquipNum()
    end
    self:InitView()
end

function ItemDetailCtrl:GetStatusData()
    return self.equipID, self.cardModel, self.isOperable, self.isAllowChangeScene, self.slot
end

function ItemDetailCtrl:OnEnterScene()
    self.view:EnterScene()
end

function ItemDetailCtrl:OnExitScene()
    self.view:ExitScene()
end

function ItemDetailCtrl:InitView()
    self.view:InitView(self.itemDetailModel, self.cardModel, self.isOperable, self.slot)
    self:SetPieceIconAndSource()
end

function ItemDetailCtrl:ResetEquipAndPieceCallBack()
    self:InitView()
end

function ItemDetailCtrl:OnBtnUseClick()
    local pcid = self.cardModel:GetPcid()
    local slots = {self.slot}

    clr.coroutine(function()
        local respone = req.cardUpgradeEquips(pcid, slots)
        if api.success(respone) then
            local data = respone.val
            --[[
            equips = {
                {
                    eid = "1104",
                    isEquip = true,
                    priceUp = 3,
                    slot = 0,
                },
                {
                    eid = "1216",
                    isEquip = false,
                    priceUp = 0,
                    slot = 1,
                },
                {
                    eid = "1308",
                    isEquip = false,
                    priceUp = 0,
                    slot = 2,
                },
            },
            slot = {
                {
                    eid = 1104,
                    num = 1002,
                    reduce = 1,
                },
            },
            --]]
            self.cardModel:ResetEquipsData(data.equips)
            for k, ret in pairs(data.slot) do
                self.cardModel:WearEquip(ret.slot)
                self.itemDetailModel:ResetEquipNum(ret.eid, ret.num)

                -- 穿完装备关闭界面
                if type(self.view.closeDialog) == "function" then
                    self.view.closeDialog()
                end
                EventSystem.SendEvent("WearEquip_Effect", ret.slot, data.equips)
            end
        end
    end)
end

function ItemDetailCtrl:OnBtnCompositeClick()
    local eid = self.itemDetailModel:GetEquipID()
    clr.coroutine(function()
        local respone = req.equipIncorporate(eid)
        if api.success(respone) then
            local data = respone.val
            self.itemDetailModel:ResetEquipAndPiece(data)
        end
    end)    
end

function ItemDetailCtrl:GetPieceScript()
    if  not self.pieceScript then 
        local prefab, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/EquipBox.prefab")
        prefab.transform:SetParent(self.view.pieceIconParent.transform, false)
        self.pieceScript = spt
    end
    return self.pieceScript 
end

function ItemDetailCtrl:SetPieceIconAndSource()
    local spt = self:GetPieceScript()
    local equipItemModel = self.itemDetailModel:GetEquipModel()
    spt:InitView(equipItemModel, false, false, false, true)

    if self.itemDetailModel:GetCompositePieceNum() <= 1 then
        self.view:SetEquipSource(self.itemDetailModel, false, self.isAllowChangeScene)
        return
    else 
        self.view:SetEquipSource(self.itemDetailModel, true, self.isAllowChangeScene)
    end
end

return ItemDetailCtrl

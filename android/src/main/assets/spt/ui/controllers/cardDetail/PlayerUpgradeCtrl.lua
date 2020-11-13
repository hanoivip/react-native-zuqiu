local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local UpgradeBoxPopCtrl = require("ui.controllers.cardDetail.UpgradeBoxPopCtrl")
local CustomEvent = require("ui.common.CustomEvent")
local PlayerUpgradeCtrl = class()

function PlayerUpgradeCtrl:ctor(cardDetailModel, mountPoint)
    assert(cardDetailModel and mountPoint)
    self.cardDetailModel = cardDetailModel

    local viewObject, viewSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/AdvanceGroupJp.prefab")
    viewObject.transform:SetParent(mountPoint.transform, false)
    self.upgradeView = viewSpt

    self:InitView()

    self.upgradeView.clickEquip = function(slot, eid)
        res.PushDialog("ui.controllers.itemDetail.ItemDetailCtrl", eid, self.cardDetailModel:GetCardModel(), self.cardDetailModel:IsOperable(), self.cardDetailModel:IsAllowChangeScene(), slot)
    end
    self.upgradeView.clickUpgrade = function()
        if not self.cardDetailModel:CanUpgrade() then return end
        local pcid = self.cardDetailModel:GetCardModel():GetPcid()
        local preEquipsList = self.cardDetailModel:GetEquipsList()
        local preEquipsMap = self.cardDetailModel:GetEquipsMap()

        clr.coroutine(function()
            local respone = req.cardUpgrade(pcid)
            if api.success(respone) then
                local data = respone.val
                CustomEvent.CardGradeUp()
                self.cardDetailModel:ResetCardData(data.card)
                EventSystem.SendEvent("Upgrade_Effect", preEquipsList, preEquipsMap)
                local cardModel = self.cardDetailModel:GetCardModel()
                self:PopUpgradeInfoBox(cardModel, data.card.upgrade)
            end
        end)
    end
end

function PlayerUpgradeCtrl:PopUpgradeInfoBox(skillModelMap, upgrade)
    clr.coroutine(function()
        local curEventSystemGo = UnityEngine.EventSystems.EventSystem.current.gameObject
        curEventSystemGo:SetActive(false)
        coroutine.yield(WaitForSeconds(3))
        curEventSystemGo:SetActive(true)
        UpgradeBoxPopCtrl.new(skillModelMap, upgrade)
    end)
end

function PlayerUpgradeCtrl:InitView(cardDetailModel)
    if cardDetailModel then
        self.cardDetailModel = cardDetailModel
    end

    local equipsList = self.cardDetailModel:GetEquipsList()
    local equipsMap = self.cardDetailModel:GetEquipsMap()
    self.upgradeView.gameObject:SetActive(true)
    self.upgradeView:InitView(equipsList, equipsMap, self.cardDetailModel)

    return true
end

function PlayerUpgradeCtrl:HideView()
    self.upgradeView.gameObject:SetActive(false)
end

return PlayerUpgradeCtrl

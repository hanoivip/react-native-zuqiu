local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Object = UnityEngine.Object
local WaitForSeconds = UnityEngine.WaitForSeconds
local UISoundManager = require("ui.control.manager.UISoundManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerUpgradeView = class(unity.base)

function PlayerUpgradeView:ctor()
    self.equipLayout = self.___ex.equipLayout -- table
    self.btnUpgrade = self.___ex.btnUpgrade
    self.upgradeButton = self.___ex.upgradeButton
    self.upgradeDesc = self.___ex.upgradeDesc
    self.upgradeEffectParent = self.___ex.upgradeEffectParent
    self.equipParent = self.___ex.equipParent
end

function PlayerUpgradeView:start()
    self.btnUpgrade:regOnButtonClick(function()
        if type(self.clickUpgrade) == "function" then
            UISoundManager.play('Player/PlayerUpgrade', 1)
            self.clickUpgrade()
        end
    end)
    self:RegModelHandler()
end

function PlayerUpgradeView:SetButtonState(interactable)
    self.upgradeButton.interactable = interactable
    self.btnUpgrade:onPointEventHandle(interactable)
    local color = interactable and Color(0.478, 0.306, 0.118) or Color(0.196, 0.196, 0.196)
    self.upgradeDesc.color = color
end

function PlayerUpgradeView:InitView(equipsList, equipsMap, cardDetailModel)
    assert(equipsList and equipsMap)
    self.isOperable = cardDetailModel:IsOperable()
    local interactable = cardDetailModel:IsOperable() and cardDetailModel:GetCardModel():IsCanUpgrade()
    self:SetButtonState(interactable)

    local equipNum = #equipsList
    for i = 1, 6 do
        if equipNum ~= i then
            GameObjectHelper.FastSetActive(self.equipLayout["layout" .. tostring(i)]["obj"], false)
        end
    end

    if not self.equipItemsView then
        self.equipItemsView = {}
    end

    if not self.equipItemsView["layout" .. tostring(equipNum)] then
        self.equipItemsView["layout" .. tostring(equipNum)] = {}
    end

    local currentLayout = self.equipLayout["layout" .. tostring(equipNum)]
    GameObjectHelper.FastSetActive(currentLayout["obj"], true)
    local currentLayoutView = self.equipItemsView["layout" .. tostring(equipNum)]

    for i, equipData in ipairs(equipsList) do
        local equipView = currentLayoutView["e" .. tostring(i)]
        if not equipView then
            local viewObj, viewSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/EquipItemJp.prefab")
            viewObj.transform:SetParent(currentLayout["e" .. tostring(i)].transform, false)
            currentLayoutView["e" .. tostring(i)] = viewSpt
            equipView = viewSpt
        end

        local equipItemModel = equipsMap[tostring(equipData.slot)]
        equipView:InitView(equipItemModel, cardDetailModel, equipData.eid)
        equipView.button:regOnButtonClick(function()
            if type(self.clickEquip) == "function" then
                self.clickEquip(equipData.slot, equipData.eid)
            end
        end)
    end
    GameObjectHelper.FastSetActive(self.equipParent, true)
end

function PlayerUpgradeView:UpgradeShow(equipsList, equipsMap)
    local equipNum = #equipsList
    local prefabRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/UpgradeItem.prefab")
    local currentLayout = self.equipLayout["layout" .. tostring(equipNum)]
    GameObjectHelper.FastSetActive(self.equipParent, false)
    for i, equipData in ipairs(equipsList) do
        local viewObj = Object.Instantiate(prefabRes)
        local viewSpt = res.GetLuaScript(viewObj)
        viewObj.transform:SetParent(self.upgradeEffectParent, false)
        viewObj.transform.anchoredPosition = currentLayout["e" .. tostring(i)].transform.anchoredPosition
        local equipItemModel = equipsMap[tostring(equipData.slot)]
        viewSpt:InitView(equipItemModel)
    end

    self:coroutine(function()
        coroutine.yield(WaitForSeconds(2))
        GameObjectHelper.FastSetActive(self.equipParent, true)
    end)
end

function PlayerUpgradeView:WearEquipEffect(slot, equipsList)
    local equipNum = #equipsList
    local currentLayoutView = self.equipItemsView["layout" .. tostring(equipNum)]
    for i, equipData in ipairs(equipsList) do
        if tostring(slot) == tostring(equipData.slot) then
            currentLayoutView["e" .. tostring(i)]:WearEquip(slot)
            break
        end
    end
end

function PlayerUpgradeView:RegModelHandler()
    if self.isOperable then 
        EventSystem.AddEvent("Upgrade_Effect", self, self.UpgradeShow)
        EventSystem.AddEvent("WearEquip_Effect", self, self.WearEquipEffect)
    end
end

function PlayerUpgradeView:onDestroy()
    EventSystem.RemoveEvent("Upgrade_Effect", self, self.UpgradeShow)
    EventSystem.RemoveEvent("WearEquip_Effect", self, self.WearEquipEffect)
end

return PlayerUpgradeView

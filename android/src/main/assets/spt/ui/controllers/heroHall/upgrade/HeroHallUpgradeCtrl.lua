local BaseCtrl = require("ui.controllers.BaseCtrl")
local HeroHallUpgradeModel = require("ui.models.heroHall.upgrade.HeroHallUpgradeModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local EventSystem = require("EventSystem")

local HeroHallUpgradeCtrl = class(BaseCtrl, "HeroHallUpgradeCtrl")

HeroHallUpgradeCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/HeroHall/Upgrade/Prefabs/HeroHallUpgrade.prefab"

HeroHallUpgradeCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function HeroHallUpgradeCtrl:ctor()
    HeroHallUpgradeCtrl.super.ctor(self)
end

function HeroHallUpgradeCtrl:Init(statueData, cardModel, heroHallDataModel)
    self.view.onClickBtnUpgrade = function(canMaterialUpgrade, canSpecialUpgrade, material, materialNotEnoughList) self:OnClickBtnUpgrade(canMaterialUpgrade, canSpecialUpgrade, material, materialNotEnoughList) end
end

function HeroHallUpgradeCtrl:Refresh(statueData, cardModel, heroHallDataModel)
    HeroHallUpgradeCtrl.super.Refresh(self)
    self.model = HeroHallUpgradeModel.new(statueData, cardModel, heroHallDataModel)
    self.view:InitView(self.model)
end

function HeroHallUpgradeCtrl:GetStatusData()
    return self.model:GetStatueData(), self.model:GetCardModel(), self.model:GetHeroHallDataModel()
end

function HeroHallUpgradeCtrl:OnClickBtnUpgrade(canMaterialUpgrade, canSpecialUpgrade, material, materialNotEnoughList)
    if self.model:IsMaxLevel() then
        DialogManager.ShowToastByLang("hero_hall_upgrade_max_level")
        return
    end
    if not canSpecialUpgrade then
        return
    end
    if not canMaterialUpgrade then
        local materialNotEnoughContent = ""
        for currencyType, isEnough in pairs(materialNotEnoughList) do
            if not isEnough then
                local tempContent = self:GetCurrencyLanguage(currencyType)
                materialNotEnoughContent = materialNotEnoughContent .. tempContent .. "、"
            end
        end
        materialNotEnoughContent = string.sub(tostring(materialNotEnoughContent), 1, -4)
        materialNotEnoughContent = lang.transstr("lack_item_tips", materialNotEnoughContent)
        DialogManager.ShowToast(materialNotEnoughContent)
        return
    end

    local confirmCallback = function()
        clr.coroutine(function()
            local response = req.heroHallUpgradeStatue(self.model:GetHallId(), self.model:GetBaseId())
            if api.success(response) then
                local data = response.val
                self.model:UpdateAfterUpgrade(data.data)
                -- 更新货币
                self.model:UpdateCurrency(data.cost)
                local newStatueData = self.model:GetStatueData()
                EventSystem.SendEvent("herohall.aftergrade", self.model:GetStatueData())

                self.view:CloseDialog()
            end
        end)
    end

    local title = lang.trans("hero_hall_statue_upgrade")
    local confirmContent = ""
    for currencyType, currencyValue in pairs(material) do
        if currencyValue > 0 then
            local tempContent = self:GetCurrencyLanguage(currencyType)
            confirmContent = confirmContent .. tempContent .. string.formatNumWithUnit(currencyValue) .. "、"
        end
    end
    -- 去掉最后一个顿号
    confirmContent = string.sub(tostring(confirmContent), 1, -4)
    confirmContent = lang.trans("hero_hall_upgrade_confirm", confirmContent)
    DialogManager.ShowConfirmPop(title, confirmContent, confirmCallback)
end

function HeroHallUpgradeCtrl:GetCurrencyLanguage(currencyType)
    local tempContent = ""
    if currencyType == CurrencyType.Money then-- 欧元
        tempContent = lang.transstr("goldCoin")
    elseif currencyType == CurrencyType.Diamond then-- 钻石
        tempContent = lang.transstr("diamond")
    elseif currencyType == CurrencyType.HeroHallSmd then-- 殿堂精华
        tempContent = lang.transstr("hero_hall_smd")
    elseif currencyType == CurrencyType.HeroHallSmb then-- 殿堂升阶石
        tempContent = lang.transstr("hero_hall_smb")
    else
        dump("illegal currency type")
    end
    return tempContent
end

return HeroHallUpgradeCtrl
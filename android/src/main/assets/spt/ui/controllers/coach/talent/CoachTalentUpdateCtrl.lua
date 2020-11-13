local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")

local CoachTalentUpdateCtrl = class(BaseCtrl, "CoachTalentUpdateCtrl")

CoachTalentUpdateCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Talent/Prefabs/CoachTalentUpdate.prefab"

CoachTalentUpdateCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CoachTalentUpdateCtrl:ctor()
    CoachTalentUpdateCtrl.super.ctor(self)
end

function CoachTalentUpdateCtrl:Init()
    CoachTalentUpdateCtrl.super.Init(self)
    self.view.onBtnUpdateClick = function(itemData) self:OnBtnUpdateClick(itemData) end
end

function CoachTalentUpdateCtrl:Refresh(coachTalentUpdateModel)
    CoachTalentUpdateCtrl.super.Refresh(self)
    if not coachTalentUpdateModel then
        local CoachTalentUpdateModel = require("ui.models.coach.talent.CoachTalentUpdateModel")
        self.model = CoachTalentUpdateModel.new()
    else
        self.model = coachTalentUpdateModel
    end
    self.view:InitView(self.model)
end

function CoachTalentUpdateCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CoachTalentUpdateCtrl:OnExitScene()
    self.view:OnExitScene()
end

-- 点击升级/解锁按钮
function CoachTalentUpdateCtrl:OnBtnUpdateClick(itemData)
    if itemData.isLocked then
        self:UnlockSkill(itemData)
    else
        self:UpdateSkill(itemData)
    end
end

-- 解锁函数
function CoachTalentUpdateCtrl:UnlockSkill(skillData)
    if not skillData.canUnlock then
        DialogManager.ShowToast(skillData.unlockContidionStr)
        return
    end

    local ctp = self.model:GetCtp()
    local needCtp = tonumber(skillData.talentPoint[tonumber(skillData.lvl) + 1]) or 0
    if ctp < needCtp then
        DialogManager.ShowToast(lang.trans("lack_item_tips", lang.transstr(CurrencyNameMap.ctp))) -- 教练天赋点不足
        return
    end

    local money = self.model:GetMoney()
    local needMoney = tonumber(skillData.priceTalent) + tonumber(skillData.lvl) * tonumber(skillData.priceTalentLevelUp)
    if money < needMoney then
        DialogManager.ShowToast(lang.trans("lack_item_tips", lang.transstr(CurrencyNameMap.m))) -- 金币不足
        return
    end

    local confirmCallback = function()
        self.view:coroutine(function()
            local response = req.coachTalentUpgrade(skillData.id)
            if api.success(response) then
                local data = response.val
                local cost = data.cost
                local talent = data.coach.talent
                self.model:UpdateAfterUnlock(skillData, talent, cost)
                self.view:UpdateAfterUnlock()
            else
                DialogManager.ShowToast(lang.transstr("unlock") .. lang.transstr("match_lose")) -- 解锁失败
            end
        end)
    end

    local title = lang.transstr("talent") .. lang.transstr("unlock") -- 天赋解锁
    local msg = lang.transstr("activation_code_confirm") .. lang.transstr("unlock") .. skillData.talentName .. "?"  -- 确认升级XX?
    DialogManager.ShowConfirmPop(title, msg, confirmCallback)
end

-- 升级函数
function CoachTalentUpdateCtrl:UpdateSkill(skillData)
    if skillData.isMaxLvl then
        DialogManager.ShowToastByLang("hero_hall_upgrade_max_level") -- 已满级
        return
    end

    local ctp = self.model:GetCtp()
    local needCtp = tonumber(skillData.talentPoint[tonumber(skillData.lvl) + 1]) or 0
    if ctp < needCtp then
        DialogManager.ShowToast(lang.trans("lack_item_tips", lang.transstr(CurrencyNameMap.ctp))) -- 教练天赋点不足
        return
    end

    local money = self.model:GetMoney()
    local needMoney = tonumber(skillData.priceTalent) + tonumber(skillData.lvl) * tonumber(skillData.priceTalentLevelUp)
    if money < needMoney then
        DialogManager.ShowToast(lang.trans("lack_item_tips", lang.transstr(CurrencyNameMap.m))) -- 金币不足
        return
    end

    local confirmCallback = function()
        self.view:coroutine(function()
            local response = req.coachTalentUpgrade(skillData.id)
            if api.success(response) then
                local data = response.val
                local cost = data.cost
                local talent = data.coach.talent
                self.model:UpdateAfterUpgrade(skillData, talent, cost)
                self.view:UpdateAfterUpgrade()
            else
                DialogManager.ShowToastByLang("paster_upgrade_failure") -- 升级失败
            end
        end)
    end

    local title = lang.transstr("coach_talent_update") -- 天赋升级
    local msg = lang.transstr("activation_code_confirm") .. lang.transstr("levelUp") .. skillData.talentName .. "?" -- 确认升级XX?
    DialogManager.ShowConfirmPop(title, msg, confirmCallback)
end

return CoachTalentUpdateCtrl

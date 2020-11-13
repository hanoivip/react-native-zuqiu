local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local LevelLimit = require("data.LevelLimit")
local DialogManager = require("ui.control.manager.DialogManager")
local CardDialogType = require("ui.controllers.cardDetail.CardDialogType")
local SkillStateType = require("ui.scene.skill.SkillStateType")
local SkillCostType = require("ui.scene.skill.SkillCostType")
local SkillShowType = require("ui.scene.skill.SkillShowType")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local VIP = require("data.VIP")

local SkillDetailCtrl = class(BaseCtrl)

SkillDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/SkillDetail/SkillDetail.prefab"

SkillDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function SkillDetailCtrl:Init(slot, cardModel, skillShowType)
    self.view.levelUpClick = function(skillState, costType)
        self:OnLevelUp(skillState, costType)
    end

    self.view.onOneClickLvlUp = function(skillState, costType)
        self:OnOneClickLvlUp(skillState, costType)
    end

    self.view.jumpClick = function()
        self:OnJumpClick()
    end

    self.view.updateSkillLevelUpCallBack = function(pcid)
        self:UpdateSkill(pcid)
    end

    self.view.showDetail = function() self:ShowDetail() end

    self.view:AdjustInitPos(skillShowType)
end

function SkillDetailCtrl:OnJumpClick()
    local needLvl = LevelLimit['littleGame'] and LevelLimit['littleGame'].playerLevel
    local playerLevel = self.playerInfoModel:GetLevel()
    if tonumber(playerLevel) >= tonumber(needLvl) then 
        res.PushScene("ui.controllers.training.TrainCtrl")
    else
        DialogManager.ShowToast(lang.trans("train_level_not_enough", needLvl))
    end
end

function SkillDetailCtrl:OnLevelUp(skillState, costType)
    local isOperable = self.cardModel:IsOperable()
    if not isOperable then
        return
    elseif skillState == SkillStateType.NotOpen then
        DialogManager.ShowToast(lang.trans("skill_button_tip5"))
        return
    elseif skillState == SkillStateType.Lock then
        DialogManager.ShowToast(lang.trans("skill_button_tip6"))
        return
    elseif skillState == SkillStateType.Max then
        DialogManager.ShowToast(lang.trans("skill_button_tip4"))
        return
    elseif skillState == SkillStateType.NeedAscend then
        DialogManager.ShowToast(lang.trans("skill_button_tip2"))
        return
    elseif skillState == SkillStateType.NeedUpgrade then
        DialogManager.ShowToast(lang.trans("skill_button_tip3"))
        return
    end

    local diffLvl = 1
    if costType == SkillCostType.SkillItem then
        self:RequestSkillLevelUp(self.slot, costType, diffLvl)
    elseif costType == SkillCostType.Diamond then
        -- 使用钻石升级
        local title = lang.trans("consume_tips")
        local content = lang.trans("skillDetail_costMoneyLevelUpTips", SkillCostType.DiamondCost)
        local vipLevel = self.playerInfoModel:GetVipLevel()
        local openDiamond = VIP[vipLevel + 1] and (tonumber(VIP[vipLevel + 1].skillUp) == 1)
        if not openDiamond then
            DialogManager.ShowConfirmPop(title, lang.trans("skill_tip"), function()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", "vip", 3)
            end)
        else
            DialogManager.ShowConfirmPop(title, content, function() self:RequestSkillLevelUp(self.slot, costType, diffLvl) end)
        end
    end
end

function SkillDetailCtrl:OnOneClickLvlUp(skillState, costType)
    local isOperable = self.cardModel:IsOperable()
    if not isOperable then
        return
    elseif skillState == SkillStateType.NotOpen then
        DialogManager.ShowToast(lang.trans("skill_button_tip5"))
        return
    elseif skillState == SkillStateType.Lock then
        DialogManager.ShowToast(lang.trans("skill_button_tip6"))
        return
    elseif skillState == SkillStateType.Max then
        DialogManager.ShowToast(lang.trans("skill_button_tip4"))
        return
    elseif skillState == SkillStateType.NeedAscend then
        DialogManager.ShowToast(lang.trans("skill_button_tip2"))
        return
    elseif skillState == SkillStateType.NeedUpgrade then
        DialogManager.ShowToast(lang.trans("skill_button_tip3"))
        return
    end
    
    local maxLvl = self.skillItemModel:GetSkillMaxLevel()
    local currLvl = self.skillItemModel:GetLevel()
    local diffLvl = maxLvl - currLvl
    if costType == SkillCostType.SkillItem then
        local itemsMapModel = ItemsMapModel.new()
        local currCoupon = itemsMapModel:GetItemNum(SkillCostType.SkillCouponId)
        local needCoupon = maxLvl - currLvl
        if needCoupon > currCoupon then
            diffLvl = currCoupon
            needCoupon = currCoupon
        end
        self:RequestSkillLevelUp(self.slot, costType, diffLvl)
    elseif costType == SkillCostType.Diamond then
        -- 使用钻石升级
        local currDiamond = self.playerInfoModel:GetDiamond()
        local needDiamond = (maxLvl - currLvl) * SkillCostType.DiamondCost
        if needDiamond > currDiamond then
            diffLvl = math.floor(currDiamond / SkillCostType.DiamondCost)
            needDiamond = diffLvl * SkillCostType.DiamondCost
        end
        local title = lang.trans("consume_tips")
        local content = lang.trans("skillDetail_costDiamondOneClickLevelUpTips", needDiamond, currLvl + diffLvl)
        local vipLevel = self.playerInfoModel:GetVipLevel()
        local openDiamond = VIP[vipLevel + 1] and (tonumber(VIP[vipLevel + 1].skillUp) == 1)
        if not openDiamond then
            DialogManager.ShowConfirmPop(title, lang.trans("skill_tip"), function()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", "vip", 3)
            end)
        else
            if diffLvl <= 0 then
                DialogManager.ShowConfirmPopByLang("tips", "diamondNotEnoughAndBuy", function()
                    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
                end)
            else
                DialogManager.ShowConfirmPop(title, content, function() self:RequestSkillLevelUp(self.slot, costType, diffLvl) end)
            end
        end
    end
end

function SkillDetailCtrl:UpdateSkill(pcid)
    if tostring(pcid) ~= tostring(self.cardModel:GetPcid()) then return end
    self:InitView(self.cardModel)
end

function SkillDetailCtrl:RequestSkillLevelUp(slot, costType, diffLvl)
    local costKey
    if costType == SkillCostType.Diamond then
        costKey = "d"
    elseif costType == SkillCostType.SkillItem then
        costKey = "skillCoupon"
    end

    local pcid = self.cardModel:GetPcid()
    if costType == SkillCostType.Diamond then
        CostDiamondHelper.CostDiamond(SkillCostType.DiamondCost * diffLvl, nil, function()
            clr.coroutine(function()
                -- 在lua环境中使用的slot数从1开始，但是向服务器发送请求的时候需要（slot-1）
                local respone = req.cardSkillLvlUp(pcid, slot - 1, costKey, diffLvl)
                if api.success(respone) then
                    local data = respone.val
                    assert(data.cost.type == costKey)

                    CustomEvent.CardSkillUp()
                    self.playerInfoModel:SetDiamond(data.cost.curr_num)
                    CustomEvent.ConsumeDiamond("8", data.cost.curr_num)
                    self.cardModel:UpdateSkillLevelUp(pcid, 0, data.skills)

                    self.view:SetEffect()
                end
            end)
        end)
    elseif costType == SkillCostType.SkillItem then
        clr.coroutine(function()
            -- 在lua环境中使用的slot数从1开始，但是向服务器发送请求的时候需要（slot-1）
            local respone = req.cardSkillLvlUp(pcid, slot - 1, costKey, diffLvl)
            if api.success(respone) then
                local data = respone.val
                assert(data.cost.type == costKey)

                CustomEvent.CardSkillUp()
                local itemsMapModel = ItemsMapModel.new()
                itemsMapModel:ResetItemNum(SkillCostType.SkillCouponId, data.cost.curr_num)
                self.cardModel:UpdateSkillLevelUp(pcid, 0, data.skills)

                self.view:SetEffect()
            end
        end)
    end
end

function SkillDetailCtrl:Refresh(slot, cardModel, skillShowType)
    SkillDetailCtrl.super.Refresh(self)
    self.skillShowType = skillShowType or SkillShowType.IsDefault
    self.playerInfoModel = PlayerInfoModel.new()
    self.slot = slot
    self:InitView(cardModel)

    if self.skillShowType == SkillShowType.IsDefault then 
        EventSystem.SendEvent("CardDetail_ClickDialog", CardDialogType.SKILL)
    end
end

function SkillDetailCtrl:GetStatusData()
    return self.slot, self.cardModel, self.skillShowType
end

function SkillDetailCtrl:OnEnterScene()
    self.view:EnterScene()
end

function SkillDetailCtrl:OnExitScene()
    self.view:ExitScene()
end

function SkillDetailCtrl:ShowDetail()
    if self.skillShowType == SkillShowType.IsDefault then 
        EventSystem.SendEvent("CardDetail_ShowDetail")
    end
end

function SkillDetailCtrl:InitView(cardModel)
    self.cardModel = cardModel
    self.skillItemModel = self.cardModel:GetSkillModel(self.slot)
    self.view:InitView(self.skillItemModel, self.cardModel, self.playerInfoModel, self.skillShowType)
end

return SkillDetailCtrl

local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local MedalUpgradeCtrl = class(BaseCtrl)
MedalUpgradeCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalUpgrade.prefab"
MedalUpgradeCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MedalUpgradeCtrl:Init()
    self.view.clickEvent = function() self:ClickEvent() end
    self.view.clickConfirm = function(medalSingleModel, protected) self:ClickConfirm(medalSingleModel, protected) end
end

function MedalUpgradeCtrl:ClickEvent()
    EventSystem.SendEvent("ShowMedalPage")
end

local StardustId = '1'
local BenedictionId = '2'
function MedalUpgradeCtrl:ClickConfirm(medalSingleModel, protected)
    local typeId, needItemNum = StardustId, 0
    local advancedId = medalSingleModel:GetMedalAdvanced()
    if advancedId then 
        local nextMedalSingleModel = PlayerMedalModel.new()
        nextMedalSingleModel:InitWithStatic(advancedId)
        if nextMedalSingleModel:GetStatic() then 
            local advancedConsume = medalSingleModel:GetAdvancedConsume()
            typeId, needItemNum = next(advancedConsume) 
        end
    end
    needItemNum = tonumber(needItemNum)
    local advancedProtect = medalSingleModel:GetAdvancedProtect()
    if protected and next(advancedProtect) then
        local typeId2, needItemNum2 = next(advancedProtect)
        needItemNum2 = tonumber(needItemNum2)
        if typeId == typeId2 then
            needItemNum  = needItemNum + needItemNum2
        else
            if self:CheckCostMsg(typeId2, needItemNum2) then
                return
            end
        end
    end

    if self:CheckCostMsg(typeId, needItemNum) then 
        return 
    end

    local func = function()
        clr.coroutine(function()
            local pmid = medalSingleModel:GetPmid()
            local respone = req.medalUpgrade(pmid, protected)
            if api.success(respone) then
                local data = respone.val
                local contents = data.contents or {}
                local newMedalModel = nil
                local bChange = false
                if contents.card and next(contents.card) then 
                    local playerCardsMapModel = PlayerCardsMapModel.new()
                    playerCardsMapModel:ResetCardData(contents.card.pcid, contents.card)

                    local pos = medalSingleModel:GetPos()
                    local playerCardModel = SimpleCardModel.new(contents.card.pcid)
                    playerCardModel:InitMedalModel()
                    newMedalModel = playerCardModel:GetPosMedalModel(pos)
                    -- 已装备的勋章，重置medalMap缓存
                    local newMedalCacheData
                    for k, medalData in pairs(contents.card.medals) do
                        if medalData.pmid == pmid then
                            newMedalCacheData = medalData
                        end
                    end
                    local playerMedalsMapModel = PlayerMedalsMapModel.new()
                    bChange = playerMedalsMapModel:ResetMedalData(pmid, newMedalCacheData)
                elseif contents.medal and next(contents.medal) then 
                    local playerMedalsMapModel = PlayerMedalsMapModel.new()
                    bChange = playerMedalsMapModel:ResetMedalData(contents.medal.pmid, contents.medal)

                    newMedalModel = playerMedalsMapModel:GetSingleMedalModel(contents.medal.pmid)
                end
                if data.cost and next(data.cost) then 
                    local playerInfoModel = PlayerInfoModel.new()
                    local sd = playerInfoModel:GetStardustCount()
                    playerInfoModel:SetStardustCount(tonumber(sd) - tonumber(data.cost.sd))
                    local bs = playerInfoModel:GetBenedictionCount()
                    playerInfoModel:SetBenedictionCount(tonumber(bs) - tonumber(data.cost.bs))
                end
                self.view:Close()
                res.PushDialog("ui.controllers.medal.MedalUpgradeBoardCtrl", newMedalModel, bChange)
            end
        end)
    end
    if medalSingleModel:GetQuality() == 5 and not protected then
        DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("SSMedal_tip"), func)
    else
        func()
    end
end

function MedalUpgradeCtrl:CheckCostMsg(nType, needItemNum)
    local playerInfoModel = PlayerInfoModel.new()
    if tonumber(nType == BenedictionId and playerInfoModel:GetBenedictionCount() or playerInfoModel:GetStardustCount()) < needItemNum then
        DialogManager.ShowToast(nType == BenedictionId and lang.trans("medal_upgrade_fail2") or lang.trans("medal_upgrade_fail1"))
        return true
    end
    return false
end

function MedalUpgradeCtrl:Refresh(medalSingleModel, playerInfoModel)
    MedalUpgradeCtrl.super.Refresh(self)
    self.view:InitView(medalSingleModel, playerInfoModel)
end

function MedalUpgradeCtrl:OnBtnUpgrade()
    self.view:DisablePage()
end

function MedalUpgradeCtrl:OnBtnBenedictionUpgrade()
    self.view:DisablePage()
end

function MedalUpgradeCtrl:OnBtnBenedictionReplace()
    self.view:DisablePage()
end

return MedalUpgradeCtrl

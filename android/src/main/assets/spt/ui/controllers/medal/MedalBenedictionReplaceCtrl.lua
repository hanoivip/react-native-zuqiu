local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local MedalBenedictionReplaceCtrl = class(BaseCtrl)
MedalBenedictionReplaceCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalBenedictionReplace.prefab"
MedalBenedictionReplaceCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MedalBenedictionReplaceCtrl:Init()
    self.view.clickEvent = function() self:ClickEvent() end
    self.view.clickConfirm = function(medalSingleModel) self:ClickConfirm(medalSingleModel) end
end

function MedalBenedictionReplaceCtrl:ClickEvent()
    EventSystem.SendEvent("ShowMedalPage")
end

function MedalBenedictionReplaceCtrl:ClickConfirm(medalSingleModel)
    local needItemNum = medalSingleModel:GetBenedictionReplaceConsume()
    local playerInfoModel = PlayerInfoModel.new()
    local ownerItem = playerInfoModel:GetBenedictionCount()
    local desc = lang.trans("medal_upgrade_fail4")
    if tonumber(ownerItem) < tonumber(needItemNum) then 
        DialogManager.ShowToast(desc)
        return 
    end

    clr.coroutine(function()
        local pmid = medalSingleModel:GetPmid()
        local respone = req.medalChangeBenediction(pmid)
        if api.success(respone) then
            local data = respone.val
            local contents = data.contents or {}
            local newMedalModel = nil
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
                        break
                    end
                end
                local playerMedalsMapModel = PlayerMedalsMapModel.new()
                playerMedalsMapModel:ResetMedalData(pmid, newMedalCacheData)
            elseif contents.medal and next(contents.medal) then 
                local playerMedalsMapModel = PlayerMedalsMapModel.new()
                playerMedalsMapModel:ResetMedalData(contents.medal.pmid, contents.medal)

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
            res.PushDialog("ui.controllers.medal.MedalBenedictionBoardCtrl", newMedalModel)
        end
    end)
end

function MedalBenedictionReplaceCtrl:Refresh(medalSingleModel, playerInfoModel)
    MedalBenedictionReplaceCtrl.super.Refresh(self)
    self.view:InitView(medalSingleModel, playerInfoModel)
end

function MedalBenedictionReplaceCtrl:OnBtnUpgrade()
    self.view:DisablePage()
end

function MedalBenedictionReplaceCtrl:OnBtnBenedictionUpgrade()
    self.view:DisablePage()
end

function MedalBenedictionReplaceCtrl:OnBtnBenedictionReplace()
    self.view:DisablePage()
end

return MedalBenedictionReplaceCtrl

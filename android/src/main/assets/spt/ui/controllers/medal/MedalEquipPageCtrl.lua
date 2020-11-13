local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local MedalEquipPageCtrl = class(BaseCtrl)
MedalEquipPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalEquipPage.prefab"
MedalEquipPageCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MedalEquipPageCtrl:Init()
    self.view.clickEquip = function(equipMedalModel, isSelectModel) self:OnClickEquip(equipMedalModel, isSelectModel) end
end

function MedalEquipPageCtrl:Refresh(pos, pcid, medalSelectModel)
    MedalEquipPageCtrl.super.Refresh(self)
    self.pos = pos
    self.pcid = pcid
    self.medalSelectModel = medalSelectModel
    self.view:InitView(pos, medalSelectModel)
end

function MedalEquipPageCtrl:OnClickEquip(equipMedalModel, isSelectModel)
    -- 不是我的自己装备的勋章并且已经被其他球员装备
    if not isSelectModel and equipMedalModel:HasEquiped() then
        return
    end
    clr.coroutine(function()
        local playerCardsMapModel = PlayerCardsMapModel.new()
        local playerMedalsMapModel = PlayerMedalsMapModel.new()
        if isSelectModel then
            --卸下
            local pmid = self.medalSelectModel:GetPmid()
            local respone = req.medalSingleUnload(self.pcid, pmid)
            if api.success(respone) then
                local data = respone.val
                playerCardsMapModel:ResetCardData(data.card.pcid, data.card)
                if data.medal and next(data.medal) then
                    playerMedalsMapModel:ResetMedalData(data.medal.pmid, data.medal)
                end
                self.view:Close()
            end
        else
            -- 装备/替换
            local pmid = equipMedalModel:GetPmid()
            local respone = req.medalEquip(pmid, self.pcid, self.pos)
            if api.success(respone) then
                local data = respone.val
                playerCardsMapModel:ResetCardData(data.card.pcid, data.card)
                local newMedalData = playerMedalsMapModel:GetMedalData(pmid)
                newMedalData.pcid = tonumber(self.pcid)
                playerMedalsMapModel:ResetMedalData(pmid, newMedalData)
                if data.medal and next(data.medal) then
                    -- 替换时返回旧的medal字段
                    data.medal.pcid = nil
                    playerMedalsMapModel:ResetMedalData(data.medal.pmid, data.medal)
                end
                self.view:Close()
            end
        end
    end)
end

return MedalEquipPageCtrl

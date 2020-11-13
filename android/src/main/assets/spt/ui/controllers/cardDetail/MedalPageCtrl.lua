local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local MedalPageCtrl = class(nil, "MedalPageCtrl")

function MedalPageCtrl:ctor(view, content)
    self:Init(content)
    self.pageView.showEquipPage = function(pos, pcid, medalSingleModel) self:ShowEquipPage(pos, pcid, medalSingleModel) end
    self.pageView.unloadMedal = function() self:UnloadMedal() end
    self.pageView.strengthin = function(medalSingleModel) self:Strengthin(medalSingleModel) end
    self.pageView.clickMenu = function() self:ClickMenu() end
    self.pageView.clickTip = function() self:ClickTip() end
end

function MedalPageCtrl:EnterScene()
    self.pageView:EnterScene()
end

function MedalPageCtrl:ExitScene()
    self.pageView:ExitScene()
end

function MedalPageCtrl:ShowEquipPage(pos, pcid, medalSingleModel)
    if not self.cardModel:IsOperable() then 
        return 
    end
    -- medalSingleModel有值代表卸下/替换功能
    res.PushDialog("ui.controllers.medal.MedalEquipPageCtrl", pos, pcid, medalSingleModel)
end

function MedalPageCtrl:ClickTip()
    local simpleIntroduceModel = SimpleIntroduceModel.new()
    simpleIntroduceModel:InitModel(19, "MedalTips")
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

function MedalPageCtrl:UnloadMedal()
    if not self.cardModel:IsOperable() then 
        return 
    end
    clr.coroutine(function()
        local pcid = self.cardModel:GetPcid()
        local respone = req.medalUnload(pcid)
        if api.success(respone) then
            local data = respone.val
            local playerCardsMapModel = PlayerCardsMapModel.new()
            playerCardsMapModel:ResetCardData(data.card.pcid, data.card)
            if data.medal and next(data.medal) then 
                local playerMedalsMapModel = PlayerMedalsMapModel.new()
                for i, v in ipairs(data.medal) do
                    playerMedalsMapModel:ResetMedalData(v.pmid, v)
                end
            end
        end
    end)
end

function MedalPageCtrl:Strengthin(medalSingleModel)
    if not self.cardModel:IsOperable() then 
        return 
    end
    local showStrengthflag = medalSingleModel:GetState(1) or medalSingleModel:GetState(2) or medalSingleModel:GetState(3)
    if not showStrengthflag then
        DialogManager.ShowAlertAlignmentPop(lang.trans("instruction"), lang.trans("medal_upgrade_fail_tip"), 3)
        return
    end
    res.PushDialog("ui.controllers.medal.MedalStrengthinPageCtrl", medalSingleModel)
end

function MedalPageCtrl:ClickMenu()
    res.PushDialog("ui.controllers.medal.MedalMenuCtrl")
end

function MedalPageCtrl:Init(content)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/MedalPage.prefab")
    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt
end

function MedalPageCtrl:InitView(cardDetailModel)
    self.cardDetailModel = cardDetailModel
    self.cardModel = cardDetailModel:GetCardModel()
    self.pageView:InitView(cardDetailModel)
end

function MedalPageCtrl:ShowPageVisible(isVisible)
    self.pageView:ShowPageVisible(isVisible)
end

return MedalPageCtrl

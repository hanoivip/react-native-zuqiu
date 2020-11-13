local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")

local CardTrainingItemCtrl = class()

function CardTrainingItemCtrl:ctor(cardTrainingMainModel, parent)
    self:Init(cardTrainingMainModel, parent)
end

function CardTrainingItemCtrl:Init(cardTrainingMainModel, parent)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/ItemContent.prefab")
    pageObject.transform:SetParent(parent, false)
    self.cardTrainingMainModel = cardTrainingMainModel
    self.view = pageSpt
    self.view:InitView(cardTrainingMainModel)
    self.view.onConfirmBtnClick = function () self:OnConfirmBtnClick() end
end

function CardTrainingItemCtrl:ShowGameObject()
    GameObjectHelper.FastSetActive(self.view.gameObject, true)
    self.view:InitView()
end

function CardTrainingItemCtrl:HideGameObject()
    GameObjectHelper.FastSetActive(self.view.gameObject, false)
end

function CardTrainingItemCtrl:OnConfirmBtnClick()
    local pcid = self.cardTrainingMainModel:GetPcid()
    local lvl = self.cardTrainingMainModel:GetCurrLevelSelected()
    local subId = self.cardTrainingMainModel:GetSubIdByLevel(lvl)
    local option = self.cardTrainingMainModel:GetOption()

    if not self.view.isFinish then
        DialogManager.ShowToastByLang("card_training_finish_tip")
        return
    end

    local function server()
        clr.coroutine(function ()
            local respone = req.cardTrainingFinish(pcid, lvl, subId, option)
            if api.success(respone) then
                local data = respone.val
                if data.cost then
                    assert(data.cost.curr_num, "server has problem!")
                    PlayerInfoModel.new():SetDiamond(data.cost.curr_num)
                end
                assert(data.card, "server need return card info")
                if data.card then
                    PlayerCardsMapModel.new():ResetCardData(data.card.pcid, data.card)
                end
                if data.supporterCard and data.supporterCard.pcid then
                    PlayerCardsMapModel.new():ResetCardData(data.supporterCard.pcid, data.supporterCard)
                end
                EventSystem.SendEvent("CardTraining_RefreshMainView")
            end
        end)
    end

    local coolTime = self.cardTrainingMainModel:GetCurrLvlCoolTime() or 0
    local function buyConfirm()
        if coolTime and coolTime > 0 then
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("card_training_cooltime_tip", math.ceil(coolTime / 1800) * 50), function ()
                server()
            end)
        else
            server()
        end
    end

    CostDiamondHelper.CostDiamond(math.ceil(coolTime / 1800) * 50, self.view, function ()
        buyConfirm()
    end)
end

function CardTrainingItemCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CardTrainingItemCtrl:OnExitScene()
    self.view:OnExitScene()
end

return CardTrainingItemCtrl

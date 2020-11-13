local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PasterUpgradeResultBoardCtrl = class(BaseCtrl)

PasterUpgradeResultBoardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/PasterUpgrade/PasterUpgradeResultBoard.prefab"

function PasterUpgradeResultBoardCtrl:Init(upgradeResult, originPasterModel, cardResourceCache)
    self.upgradeResult = upgradeResult
    self.originPasterModel = originPasterModel
    self.cardResourceCache = cardResourceCache
    self.cardPastersMapModel = CardPastersMapModel.new()
end

function PasterUpgradeResultBoardCtrl:Refresh(upgradeResult)
    PasterUpgradeResultBoardCtrl.super.Refresh(self)
    self.upgradeResult = upgradeResult
    self:InitView()
    local cost = upgradeResult.cost
    if type(cost) == "table" then
        for i, ptid in ipairs(cost) do
            local isExistPaster = self.cardPastersMapModel:GetPasterData(ptid)
            if isExistPaster then 
                self.cardPastersMapModel:RemovePasterData(ptid)
            end
        end
    end

    local card = upgradeResult.card
    if type(card) == "table" then
        local cardsMapModel = PlayerCardsMapModel.new()
        cardsMapModel:ResetCardData(card.pcid, card)
        EventSystem.SendEvent("Paster_LevelUp")
    end

    local content = upgradeResult.content
    if type(content) == "table" and next(content) then
        local ptid = content.ptid
        local pasterData = self.cardPastersMapModel:GetPasterData(ptid)
        -- 这张贴纸不在背包里也不在球员身上
        local isExistPaster = (not pasterData) and (not card)
        if isExistPaster then
            self.cardPastersMapModel:AddPasterData(ptid, content)
        end
        EventSystem.SendEvent("PasterUpgradeView_RefreshOriginPaster", content)
    end
end

function PasterUpgradeResultBoardCtrl:OnBtnConfirm()
    local filterMap = self.pasterUpgradeFilterModel:GetFilterMap()
    EventSystem.SendEvent("PasterUpgrade_OnFilterConfirmClick", filterMap)
    self.view:Close()
end

function PasterUpgradeResultBoardCtrl:InitView()
    self.view:InitView(self.upgradeResult, self.originPasterModel, self.cardResourceCache)
end

function PasterUpgradeResultBoardCtrl:GetStatusData()
    return self.pasterUpgradeFilterModel
end

function PasterUpgradeResultBoardCtrl:OnEnterScene()
    EventSystem.AddEvent("MedalSearchView.UpdateSelectSkill", self, self.UpdateSelectSkill)
end

function PasterUpgradeResultBoardCtrl:OnExitScene()
    EventSystem.RemoveEvent("MedalSearchView.UpdateSelectSkill", self, self.UpdateSelectSkill)
end

return PasterUpgradeResultBoardCtrl

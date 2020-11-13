local BaseCtrl = require("ui.controllers.BaseCtrl")
local CardBuilder = require("ui.common.card.CardBuilder")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local SpecialEventsPlayerTeamsModel = require("ui.models.specialEvents.SpecialEventsPlayerTeamsModel")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local SpecialEventsFormationCacheDataModel = require("ui.models.specialEvents.SpecialEventsFormationCacheDataModel")
local SpecificMatchBase = require("data.SpecificMatchBase")

local SpecialEventsFormationCtrl = class(BaseCtrl)
SpecialEventsFormationCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/SpecialEvents/SpecialEventsFormationPage.prefab"

function SpecialEventsFormationCtrl:Init()
    self:BindEvent()
end

local function GetIndexByMatchId(matchId)
    return tonumber(SpecificMatchBase[tostring(matchId)].id)
end

function SpecialEventsFormationCtrl:Refresh(matchId, playerTeamsModel, formationCacheDataModel)
    SpecialEventsFormationCtrl.super.Refresh(self)
    self.matchId = matchId
    self.eventId = GetIndexByMatchId(matchId)
    if playerTeamsModel then
        self.playerTeamsModel = playerTeamsModel
    end

    if formationCacheDataModel then
        self.formationCacheDataModel = formationCacheDataModel
    end

    local isPush = nil
    local loadType = self:GetLoadType()
    if loadType == res.LoadType.Pop then
        isPush = false
    else
        isPush = true
    end
    self.view:InitView(self.matchId, self.playerTeamsModel, self.formationCacheDataModel)
    self.view:RefreshPage(isPush)
    --隐藏掉特殊赛事的一键上阵按钮
    self.view:HideAutoBtnAndMoveClearBtn()
end

function SpecialEventsFormationCtrl:AheadRequest(matchId)
    self.matchId = matchId
    self.eventId = GetIndexByMatchId(matchId)
    local response = req.specificGetTeam(self.eventId)
    if api.success(response) then
        local data = response.val
        self.playerTeamsModel = SpecialEventsPlayerTeamsModel.new()
        self.playerTeamsModel:InitWithProtocol(data, self.matchId)
        self.playerTeamsModel:SetTeamType(FormationConstants.TeamType.SPECIFIC)
        self.formationCacheDataModel = SpecialEventsFormationCacheDataModel.new(self.playerTeamsModel, matchId)
    end
end

function SpecialEventsFormationCtrl:OnEnterScene()
    self.view:RegisterEvent()
end

function SpecialEventsFormationCtrl:OnExitScene()
    self.view:UnRegisterEvent()
end

function SpecialEventsFormationCtrl:BindEvent()
    self.view.onCardClick = function(cardList, index, tid)
        self:OnCardClick(cardList, index, tid)
    end
    self.view:RegOnDynamicLoad(
        function(child)
            self.infoBarCtrl = InfoBarCtrl.new(child, self)
            self.infoBarCtrl:RegOnBtnBack(
                function()
                    self.view:OnBack()
                end
            )
        end
    )
    self.view.onShowPower = function(powerValue)
        self:OnShowPower(powerValue)
    end
end

function SpecialEventsFormationCtrl:OnCardClick(cardList, index, tid)
    assert(tid)
    local currentModel = CardBuilder.GetFormationCardModel(cardList[index], self.formationCacheDataModel)
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", cardList, index, currentModel)
end

function SpecialEventsFormationCtrl:OnShowPower(powerValue)
    if not self.powerCtrl then
        self.powerCtrl = CardPowerCtrl.new(self.view.powerNumArea, 4, 8)
    end
    self.powerCtrl:InitPower(powerValue)
end

function SpecialEventsFormationCtrl:GetStatusData()
    return self.matchId, self.playerTeamsModel, self.formationCacheDataModel
end

return SpecialEventsFormationCtrl

local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local FormationType = require("ui.common.enum.FormationType")
local CardBuilder = require("ui.common.card.CardBuilder")
local FormationCacheDataModel = require("ui.models.formation.FormationCacheDataModel")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local ReqEventModel = require("ui.models.event.ReqEventModel")

local FormationPageCtrl = class(BaseCtrl)
FormationPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Formation/FormationPage.prefab"

function FormationPageCtrl:Init(playerTeamsModel, formationCacheDataModel)
    self.playerTeamsModel = playerTeamsModel
    self.formationCacheDataModel = formationCacheDataModel

    if self.playerTeamsModel == nil then
        self.playerTeamsModel = PlayerTeamsModel.new()
    end

    if self.formationCacheDataModel == nil then
        self.formationCacheDataModel = FormationCacheDataModel.new(self.playerTeamsModel)
    end

    self:InitView()
end

function FormationPageCtrl:Refresh(playerTeamsModel)
    self.playerTeamsModel = playerTeamsModel or self.playerTeamsModel
    self.formationCacheDataModel:InitPlayerTeamsModel(self.playerTeamsModel)

    FormationPageCtrl.super.Refresh(self)
    local isPush = nil
    local loadType = self:GetLoadType()
    if loadType == res.LoadType.Pop then
        isPush = false
    else
        isPush = true
    end
    local team = ReqEventModel.GetInfo("team")
    if tonumber(team) > 0 then
        clr.coroutine(function()
            local respone = req.teamIndex()
            if api.success(respone) then
                local data = respone.val
                if data.teams then
                    self.playerTeamsModel:InitWithProtocol(data.teams)
                    self.formationCacheDataModel = FormationCacheDataModel.new(self.playerTeamsModel)
                    self.view:InitView(self.playerTeamsModel, self.formationCacheDataModel)
                    self.view:RefreshPage(isPush, self.playerTeamsModel, self.formationCacheDataModel)
                    self.view:ResetCardsLock(data)
                end
            end
        end)
    else
        self.view:RefreshPage(isPush, self.playerTeamsModel, self.formationCacheDataModel)
    end
end

function FormationPageCtrl:OnEnterScene()
    self.view:RegisterEvent()
end

function FormationPageCtrl:OnExitScene()
    self.view:UnRegisterEvent()
end

function FormationPageCtrl:InitView(playerTeamsModel, formationCacheDataModel)
    if playerTeamsModel then
        self.playerTeamsModel = playerTeamsModel
    end

    if formationCacheDataModel then
        self.formationCacheDataModel = formationCacheDataModel
    end

    self.view:RegOnAccess(function()
        -- 打开阵型页面
        GuideManager.Show(self)
    end)
    self.view:InitView(self.playerTeamsModel, self.formationCacheDataModel)
    self.view.onCardClick = function (cardList, index, tid)
        self:OnCardClick(cardList, index, tid)
    end
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self.view:OnBack()
        end)
    end)
    self.view.onShowPower = function (powerValue)
        self:OnShowPower(powerValue)
    end
end

function FormationPageCtrl:OnCardClick(cardList, index, tid)
    assert(tid)
    local formationType
    if tid == 0 then
        formationType = FormationType.NO1
    elseif tid == 1 then
        formationType = FormationType.NO2
    elseif tid == 2 then
        formationType = FormationType.NO3
    end

    local currentModel = CardBuilder.GetFormationCardModel(cardList[index], self.formationCacheDataModel)
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", cardList, index, currentModel, nil, true)
end

function FormationPageCtrl:OnShowPower(powerValue)
    if not self.powerCtrl then
        self.powerCtrl = CardPowerCtrl.new(self.view.powerNumArea, 4, 8)
    end
    self.powerCtrl:InitPower(powerValue)
end

function FormationPageCtrl:GetStatusData()
    return self.playerTeamsModel, self.formationCacheDataModel
end

return FormationPageCtrl
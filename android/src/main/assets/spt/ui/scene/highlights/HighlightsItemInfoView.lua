local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local MatchConstants = require("ui.scene.match.MatchConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local FormationConstants = require("ui.scene.formation.FormationConstants")

local HighlightsItemInfoView = class(LuaButton)

function HighlightsItemInfoView:ctor()
    HighlightsItemInfoView.super.ctor(self)
    self.cardParent = self.___ex.cardParent
    self.cardName = self.___ex.cardName
    self.moment = self.___ex.moment
    self.goalInfo = self.___ex.goalInfo
    self.chooseSign = self.___ex.chooseSign
end

function HighlightsItemInfoView:InitView(data, index)
    self.data = data
    self.index = index
    if self.cardObj == nil or self.cardView == nil then
        self.cardObj, self.cardView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Formation/PlayerCardCircle.prefab")
        self.cardObj.transform:SetParent(self.cardParent.transform, false)
        self.cardObj.transform.localScale = Vector3(1, 1, 1)
    end
    self:BulidPage()
    self:regOnButtonClick(function()
        self:OnItemClick()
    end)
end

function HighlightsItemInfoView:BulidPage()
    local cardModel = StaticCardModel.new(self.data.goalPlayer.cid)
    self.cardView:initDataByModel(cardModel:GetPosition(), cardModel, FormationConstants.CardShowType.MAIN_INFO, FormationConstants.PlayersClassifyInFormation.INIT, false, false, true)
    self.cardView:BuildPage()
    self.cardView:ToggleDownFlag(false)
    self.cardName.text = lang.trans("highlights_goalInfo", self.data.goalPlayer.name)
    self.moment.text = string.convertSecondToTimeString(self.data.goalTime)
    self.goalInfo.text = self.data.goalCount > #MatchConstants.GoalEvent and MatchConstants.GoalEvent[#MatchConstants.GoalEvent] or MatchConstants.GoalEvent[self.data.goalCount]
    self:UpdateChooseSignState()
end

function HighlightsItemInfoView:OnItemClick()
    if self.onItemClick then
        self.onItemClick()
    end
    self:UpdateChooseSignState()
end

function HighlightsItemInfoView:UpdateChooseSignState()
    GameObjectHelper.FastSetActive(self.chooseSign, self.data.isSelected)
end

return HighlightsItemInfoView

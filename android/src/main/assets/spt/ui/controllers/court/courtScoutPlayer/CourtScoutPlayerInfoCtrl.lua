local BaseCtrl = require("ui.controllers.BaseCtrl")
local CourtScoutPlayerInfoCtrl = class(BaseCtrl)
local CardResourceCache = require("ui.common.card.CardResourceCache")
CourtScoutPlayerInfoCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/ScoutPlayerInfo.prefab"

function CourtScoutPlayerInfoCtrl:Init(courtBuildModel)
    self.cardResourceCache = CardResourceCache.new() 
    self.view.clickEvent = function() self:ClickEvent() end
    self.view.clickExtra = function(beActivatedPlayers) self:ClickExtra(beActivatedPlayers) end
end

function CourtScoutPlayerInfoCtrl:Refresh(courtBuildModel)
    self.courtBuildModel = courtBuildModel
    self.view:InitView(courtBuildModel, self.cardResourceCache)
end

function CourtScoutPlayerInfoCtrl:GetStatusData()
    return self.courtBuildModel
end

function CourtScoutPlayerInfoCtrl:ClickEvent()
    EventSystem.SendEvent("ShowBuild")
    self.cardResourceCache:Clear()
end

function CourtScoutPlayerInfoCtrl:ClickExtra(beActivatedPlayers)
    self.view:DisableScoutPlayerInfo()
    res.PushDialog("ui.controllers.court.courtScoutPlayer.CourtScoutExtraPlayerInfoCtrl", self.cardResourceCache, beActivatedPlayers, self.courtBuildModel)
end

return CourtScoutPlayerInfoCtrl

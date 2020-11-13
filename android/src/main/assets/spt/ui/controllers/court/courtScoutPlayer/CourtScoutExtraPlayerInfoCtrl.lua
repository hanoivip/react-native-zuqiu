local BaseCtrl = require("ui.controllers.BaseCtrl")
local CourtScoutExtraPlayerInfoCtrl = class(BaseCtrl)
CourtScoutExtraPlayerInfoCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/ScoutExtraPlayerInfo.prefab"

function CourtScoutExtraPlayerInfoCtrl:Init()
    self.view.clickEvent = function() self:ClickEvent() end
end

function CourtScoutExtraPlayerInfoCtrl:Refresh(cardResourceCache, beActivatedPlayers, courtBuildModel)
    self.cardResourceCache = cardResourceCache
    self.beActivatedPlayers = beActivatedPlayers
    self.courtBuildModel = courtBuildModel
    self.view:InitView(cardResourceCache, beActivatedPlayers, courtBuildModel)
end

function CourtScoutExtraPlayerInfoCtrl:GetStatusData()
    return self.cardResourceCache, self.beActivatedPlayers, self.courtBuildModel
end

function CourtScoutExtraPlayerInfoCtrl:ClickEvent()
    EventSystem.SendEvent("ShowScoutPlayerInfo")
end

return CourtScoutExtraPlayerInfoCtrl

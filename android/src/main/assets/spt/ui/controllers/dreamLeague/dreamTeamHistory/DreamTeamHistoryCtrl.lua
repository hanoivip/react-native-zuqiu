local EventSystem = require ("EventSystem")
local DialogManager = require("ui.control.manager.DialogManager")
local DreamTeamHistoryModel = require("ui.models.dreamLeague.dreamTeamHistory.DreamTeamHistoryModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamTeamHistoryCtrl = class(BaseCtrl)

DreamTeamHistoryCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

DreamTeamHistoryCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamTeamHistory/DreamTeamHistory.prefab"

function DreamTeamHistoryCtrl:Init(dreamTeamHistoryModel)
    self.dreamTeamHistoryModel = dreamTeamHistoryModel
end


function DreamTeamHistoryCtrl:Refresh(dreamTeamHistoryModel)
    self.view.clickDetailCallBack = function(matchTag, dcid)  self:ClickDetailCallBack(matchTag, dcid) end
    self.view:InitView(dreamTeamHistoryModel)
end

function DreamTeamHistoryCtrl:ClickDetailCallBack(matchTag, dcid)

    clr.coroutine(function()
        local response = req.dreamLeagueTeamcard(matchTag, dcid)
        if api.success(response) then
            local data = response.val
            res.PushDialog("ui.controllers.dreamLeague.dreamTeamHistory.DreamPlayerHistoryDetailCtrl", data.card)
        end
    end)
end

function DreamTeamHistoryCtrl:OnBtnReset()
    self.view:OnReset()
end

function DreamTeamHistoryCtrl:OnEnterScene()
    if self.view.OnEnterScene then
        self.view:OnEnterScene()
    end
end

function DreamTeamHistoryCtrl:OnExitScene()
    if self.view.OnExitScene then
        self.view:OnExitScene()
    end
end

function DreamTeamHistoryCtrl:GetStatusData()
    return self.dreamTeamHistoryModel
end

return DreamTeamHistoryCtrl

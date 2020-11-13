local Version = require("emulator.version")
local CompeteScheduleListModel = require("ui.models.compete.cross.schedule.CompeteScheduleListModel")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CrossContentOrder = require("ui.scene.compete.cross.CrossContentOrder")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CompeteScheduleListCtrl = class(BaseCtrl, "CompeteScheduleListCtrl")

CompeteScheduleListCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/Schedule/CompeteScheduleList.prefab"

function CompeteScheduleListCtrl:AheadRequest(crossType, teamList)
	if self.view then 
		self.view:ShowDisplayArea(false)
	end

	self.competeScheduleListModel = CompeteScheduleListModel.new()
    local response = req.competeSchedule(CrossContentOrder.TeamScoreKey[crossType])
    if api.success(response) then
        local data = response.val
		local playerInfoModel = PlayerInfoModel.new()
		local playerId = playerInfoModel:GetID()
		self.competeScheduleListModel:SetPlayerRoleId(playerId)
        self.competeScheduleListModel:InitWithProtocol(data, crossType, teamList)
		self.view:ShowDisplayArea(true)
    end	
end

function CompeteScheduleListCtrl:Init()
    self.view.clickBack = function() self:OnClickBack() end
    self.view.onClickCheckFormation = function(pid, sid) self:OnClickCheckFormation(pid, sid) end
end

function CompeteScheduleListCtrl:OnClickBack()
	res.PopScene()
end

function CompeteScheduleListCtrl:Refresh(crossType, teamList)
	self.crossType = crossType
	self.teamList = teamList
    CompeteScheduleListCtrl.super.Refresh(self)
    self.view:InitView(self.competeScheduleListModel)
end

function CompeteScheduleListCtrl:GetStatusData()
	return self.crossType, self.teamList
end

function CompeteScheduleListCtrl:OnEnterScene()
    self.view:EnterScene()

end

function CompeteScheduleListCtrl:OnExitScene()
    self.view:ExitScene()
end

function CompeteScheduleListCtrl:OnClickVideo(vid, version)
    local isVideoExpired = version and tonumber(version) ~= tonumber(Version.version) or false
    if isVideoExpired then 
        DialogManager.ShowToast(lang.trans("videoReplay_expired"))
    else
        self.view:coroutine(function()
            local response = req.arenaVideo(vid)
            if api.success(response) then
                local ReplayCheckHelper = require("coregame.ReplayCheckHelper")
                ReplayCheckHelper.StartReplay(response.val.video, vid)
            end
        end)
    end
end

function CompeteScheduleListCtrl:OnClickCheckFormation(pid, sid)
	if pid and sid then 
		PlayerDetailCtrl.ShowPlayerDetailView(function() return req.competeFormationDetail(pid, sid, "worldTournament") end, pid, sid)
	end
end

return CompeteScheduleListCtrl

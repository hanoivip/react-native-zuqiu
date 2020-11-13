local Version = require("emulator.version")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PersonScheduleCtrl = class(BaseCtrl)

PersonScheduleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/PersonSchedule.prefab"

function PersonScheduleCtrl:Init()
    self.view.clickVideo = function(vid, version) self:OnClickVideo(vid, version) end
end

function PersonScheduleCtrl:Refresh(arenaPersonScheduleModel, arenaScheduleTeamModel)
    PersonScheduleCtrl.super.Refresh(self)
    self.arenaPersonScheduleModel = arenaPersonScheduleModel
    self.arenaScheduleTeamModel = arenaScheduleTeamModel
    self.view:InitView(arenaPersonScheduleModel, arenaScheduleTeamModel)
end

function PersonScheduleCtrl:OnEnterScene()
    self.view:EnterScene()
end

function PersonScheduleCtrl:OnExitScene()
    self.view:ExitScene()
end

function PersonScheduleCtrl:GetStatusData()
    return self.arenaPersonScheduleModel, self.arenaScheduleTeamModel
end

function PersonScheduleCtrl:OnClickVideo(vid, version)
    local isVideoExpired = version and tonumber(version) ~= tonumber(Version.version) or false
    if isVideoExpired then 
        DialogManager.ShowToast(lang.trans("videoReplay_expired"))
    else
        clr.coroutine(function()
            local response = req.arenaVideo(vid)
            if api.success(response) then
                local ReplayCheckHelper = require("coregame.ReplayCheckHelper")
                ReplayCheckHelper.StartReplay(response.val.video, vid)
            end
        end)
    end
end

return PersonScheduleCtrl
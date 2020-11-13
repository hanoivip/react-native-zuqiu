local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ArenaModel = require("ui.models.arena.ArenaModel")
local ArenaTeamMatchModel = require("ui.models.arena.schedule.ArenaTeamMatchModel")
local Version = require("emulator.version")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local GroupPageCtrl = class(nil, "GroupPageCtrl")

function GroupPageCtrl:ctor(view, content)
    self:Init(content)
end

function GroupPageCtrl:Init(content)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/GroupPage.prefab")
    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt
    self.pageView.clickVideo = function(vid, version) self:OnClickVideo(vid, version) end
    self.pageView.onClickCheckFormation = function(id, sid) self:OnClickCheckFormation(id, sid) end
end

function GroupPageCtrl:EnterScene()
    self.pageView:EnterScene()
end

function GroupPageCtrl:ExitScene()
    self.pageView:ExitScene()
end

function GroupPageCtrl:InitView(arenaType)
    self.arenaType = arenaType
    local arenaTeamMatchModel = ArenaTeamMatchModel.GetInstance()
    if not arenaTeamMatchModel then
        clr.coroutine(function()
            local response = req.getArenaGroupSchedule(arenaType)
            if api.success(response) then
                local data = response.val
                arenaTeamMatchModel = ArenaTeamMatchModel.new()
                arenaTeamMatchModel:InitWithProtocol(data)
                local playerInfoModel = PlayerInfoModel.new()
                local playerId = playerInfoModel:GetID()
                local defaultIndex = arenaTeamMatchModel:GetPlayerTeamInScore(playerId)
                self.pageView:InitView(arenaTeamMatchModel, defaultIndex)
            end
        end)
    else
        self.pageView:InitView(arenaTeamMatchModel)
    end
end

function GroupPageCtrl:OnClickVideo(vid, version)
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

function GroupPageCtrl:OnClickCheckFormation(id, sid)
    local arenaModel = ArenaModel.new()
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.arenaOtherTeam(id, sid, self.arenaType) end, id, sid, arenaModel:GetPayerSid() ~= sid, nil, nil, nil, self.arenaType)
end

function GroupPageCtrl:ShowPageVisible(isVisible)
    self.pageView:ShowPageVisible(isVisible)
end

return GroupPageCtrl

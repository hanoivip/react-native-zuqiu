local ArenaKnockoutModel = require("ui.models.arena.schedule.ArenaKnockoutModel")
local Version = require("emulator.version")
local DialogManager = require("ui.control.manager.DialogManager")
local ArenaOutSchedulePageCtrl = class(nil, "ArenaOutSchedulePageCtrl")

function ArenaOutSchedulePageCtrl:ctor(view, content)
    self:Init(content)
end

function ArenaOutSchedulePageCtrl:Init(content)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/ArenaOutSchedulePage.prefab")
    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt
    self.pageView.clickVideo = function(vid, version) self:OnClickVideo(vid, version) end
end

function ArenaOutSchedulePageCtrl:EnterScene()
    self.pageView:EnterScene()
end

function ArenaOutSchedulePageCtrl:ExitScene()
    self.pageView:ExitScene()
end

function ArenaOutSchedulePageCtrl:OnClickVideo(vid, version)
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

function ArenaOutSchedulePageCtrl:InitView(arenaType)
    local arenaKnockoutModel = ArenaKnockoutModel.GetInstance()
    if not arenaKnockoutModel then
        clr.coroutine(function()
            local response = req.getArenaOutScheduleBoard(arenaType)
            if api.success(response) then
                local data = response.val
                arenaKnockoutModel = ArenaKnockoutModel.new()
                arenaKnockoutModel:InitWithProtocol(data)
                self.pageView:InitView(arenaKnockoutModel)
            end
        end)
    else
        self.pageView:InitView(arenaKnockoutModel)
    end
end

function ArenaOutSchedulePageCtrl:ShowPageVisible(isVisible)
    self.pageView:ShowPageVisible(isVisible)
end

return ArenaOutSchedulePageCtrl

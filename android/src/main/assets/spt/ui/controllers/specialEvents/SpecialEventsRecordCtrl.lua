local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local MenuBarCtrl = require("ui.controllers.common.MenuBarCtrl")
local SpecialEventsMainModel = require("ui.models.specialEvents.SpecialEventsMainModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")

local BaseCtrl = require("ui.controllers.BaseCtrl")
local SpecialEventsRecordCtrl = class(BaseCtrl)

SpecialEventsRecordCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/SpecialEvents/SpecialEventsRecord.prefab"

function SpecialEventsRecordCtrl:Init()
    self.view.onFormationButtonClick = function(itemModel)
        self:OnFormationButtonClick(itemModel)
    end
    self.view.onVideoButtonClick = function(itemModel)
        self:OnVideoButtonClick(itemModel)
    end
end

function SpecialEventsRecordCtrl:Refresh(matchId, model)
    if matchId ~= nil then
        self.matchId = matchId
    end

    if model ~= nil then
        self.model = model
    end
    self.view:InitView(self.model)
end

function SpecialEventsRecordCtrl:AheadRequest(matchId)
    self.matchId = matchId
    if not self.debugMode then
        local model, timestamp = cache.getSpecialEvents()
        assert(model)
        self.model = model.data.video[tostring(self.matchId)]
    else
        local respone = req.specificIndex()
        if api.success(respone) then
            local data = respone.val
            local model = SpecialEventsMainModel.new()
            model:InitWithProtocol(data)
            self.model = model.data.video[tostring(self.matchId)]
        end
    end
end

function SpecialEventsRecordCtrl:GetStatusData()
    return self.matchId, self.model
end

function SpecialEventsRecordCtrl:OnEnterScene()
end

function SpecialEventsRecordCtrl:OnExitScene()
end

function SpecialEventsRecordCtrl:OnFormationButtonClick(itemModel)
    PlayerDetailCtrl.ShowPlayerDetailView(
        function()
            return req.specificViewTeam(itemModel.pid, itemModel.sid, itemModel.ptid, self.matchId)
        end,
        itemModel.pid,
        itemModel.sid,
        itemModel.pid == require("ui.models.PlayerInfoModel").new():GetID(),
        nil,
        nil,
        self.matchId
    )
end

function SpecialEventsRecordCtrl:OnVideoButtonClick(itemModel)
    clr.coroutine(
        function()
            local respone = req.specificVideo(itemModel.vid)
            if api.success(respone) then
                local ReplayCheckHelper = require("coregame.ReplayCheckHelper")
                ReplayCheckHelper.StartReplay(respone.val, itemModel.vid)
            end
        end
    )
end
return SpecialEventsRecordCtrl

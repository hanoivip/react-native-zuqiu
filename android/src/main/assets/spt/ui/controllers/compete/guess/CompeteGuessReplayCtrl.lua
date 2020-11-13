local BaseCtrl = require("ui.controllers.BaseCtrl")
local CompeteGuessReplayModel = require("ui.models.compete.guess.CompeteGuessReplayModel")

local CompeteGuessReplayCtrl = class(BaseCtrl, "CompeteGuessReplayCtrl")

CompeteGuessReplayCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Guess/CompeteGuessReplay.prefab"

CompeteGuessReplayCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CompeteGuessReplayCtrl:ctor()
    CompeteGuessReplayCtrl.super.ctor(self)
end

function CompeteGuessReplayCtrl:Init(matchData)
    self.view.onClickBtnReplay = function(vid) self:OnClickBtnReplay(vid) end
end

function CompeteGuessReplayCtrl:GetStatusData()
    return self.model:GetStatusData()
end

function CompeteGuessReplayCtrl:Refresh(matchData)
    CompeteGuessReplayCtrl.super.Refresh(self)
    self.model = CompeteGuessReplayModel.new()
    self.model:InitWithMatchData(matchData)
    self.view:InitView(self.model)
end

function CompeteGuessReplayCtrl:OnClickBtnReplay(vid)
    self.view:coroutine(function()
        local respone = req.worldTournamentVideo(vid)
        if api.success(respone) then
            local ReplayCheckHelper = require("coregame.ReplayCheckHelper")
            ReplayCheckHelper.StartReplay(respone.val.video, vid)
        end
    end)
end

return CompeteGuessReplayCtrl

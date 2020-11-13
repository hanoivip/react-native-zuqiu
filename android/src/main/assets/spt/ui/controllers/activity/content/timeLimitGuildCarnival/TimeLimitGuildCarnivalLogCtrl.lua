local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local TimeLimitGuildCarnivalLogModel = require("ui.models.activity.timeLimitGuildCarnival.TimeLimitGuildCarnivalLogModel")

local TimeLimitGuildCarnivalLogCtrl = class(BaseCtrl, "TimeLimitGuildCarnivalLogCtrl")

TimeLimitGuildCarnivalLogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/TimeLimitGuildCarnival/TimeLimitGuildCarnivalLog.prefab"

TimeLimitGuildCarnivalLogCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function TimeLimitGuildCarnivalLogCtrl:ctor()
    TimeLimitGuildCarnivalLogCtrl.super.ctor(self)
end

function TimeLimitGuildCarnivalLogCtrl:Init()
    self.view.onClickTabRank = function() self:OnClickTabRank() end
    self.view.onClickTabMyLog = function() self:OnClickTabMyLog() end
    self.view.onRankItemClickViewPlayer = function(pid, sid) self:OnRankItemClickViewPlayer(pid, sid) end
end

function TimeLimitGuildCarnivalLogCtrl:Refresh()
    TimeLimitGuildCarnivalLogCtrl.super.Refresh(self)
    self.model = TimeLimitGuildCarnivalLogModel.new()
    self.view.tabGroup:selectMenuItem(self.view.menuTags.rank)
    self:OnClickTabRank()
end

function TimeLimitGuildCarnivalLogCtrl:OnClickTabRank()
    self.view:coroutine(function()
        local response = req.guildCarnivalRank()
        if api.success(response) then
            local data = response.val
            self.model:UpdateRankData(data)
            self.view:InitRankView(self.model)
        end
    end)
end

function TimeLimitGuildCarnivalLogCtrl:OnClickTabMyLog()
    if self.model:HasMyLogData() then
        self.view:InitMyLogView(self.model)
        return
    end
    self.view:coroutine(function()
        local response = req.guildCarnivalRecord()
        if api.success(response) then
            local data = response.val
            self.model:UpdateMyLogData(data)
            self.view:InitMyLogView(self.model)
        end
    end)
end

function TimeLimitGuildCarnivalLogCtrl:OnRankItemClickViewPlayer(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

return TimeLimitGuildCarnivalLogCtrl
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local OurPartSeatsDetailCtrl = class(BaseCtrl, "OurPartSeatsDetailCtrl")

OurPartSeatsDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/OurPartSeatsDetail.prefab"

OurPartSeatsDetailCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function OurPartSeatsDetailCtrl:Init(index, guildWarModel, isAttackPage)
    self.index = index
    self.guildWarModel = guildWarModel
    self.isAttackPage = isAttackPage
end

function OurPartSeatsDetailCtrl:Refresh(index, guildWarModel, isAttackPage)
    OurPartSeatsDetailCtrl.super.Refresh(self)
    if isAttackPage then
        self.guildData = clone(self.guildWarModel:GetGuardPosition(index))
        self.guildData.countLimit = self.guildWarModel:GetCountLimit()
        self.guildData.warCnt = self.guildWarModel:GetWarCnt()
        self.guildData.isSeized = self.guildWarModel:GetSelfIsSeized()
        clr.coroutine(function ()
            local response = req.getTargetGuardDetail(index)
            if api.success(response) then
                local data = response.val
                self.view:InitView(data, self.guildData, isAttackPage)
                self.view.onClickChallengeBtn = function (pos)
                    self:OnClickChallengeBtn(pos)
                end
                self.view.onClickDetailBtn = function ()
                    self:OnClickDetailBtn(data.detail.pid, data.detail.sid)
                end
            end
        end)
    else
        self.guildData = clone(self.guildWarModel:GetGuardPosition(index))
        self.guildData.hasAuthority = (self.guildWarModel:GetSelfAuthority() < 3)
        clr.coroutine(function ()
            local response = req.getSelfGuardDetail(index)
            if api.success(response) then
                local data = response.val
                self.view:InitView(data, self.guildData, isAttackPage)
                self.view.onClickChangeBtn = function (pos)
                    self:OnClickChangeBtn(pos)
                end
                self.view.onClickDetailBtn = function ()
                    self:OnClickDetailBtn(self.guildData.pid, self.guildData.sid)
                end
            end
        end)
    end
end

function OurPartSeatsDetailCtrl:GetStatusData()
    return self.index, self.guildWarModel, self.isAttackPage
end

function OurPartSeatsDetailCtrl:OnClickChallengeBtn(pos)
    self.view:Close()
    clr.coroutine(function ()
        local response = req.startWar(pos)
        if api.success(response) then
            local data = response.val
            if data.matchData then
                self.guildWarModel:SetWarCnt(tonumber(self.guildWarModel:GetWarCnt()) + 1)
                local matchLoader = require("coregame.MatchLoader")
                matchLoader.startMatch(data.matchData)
            else
                EventSystem.SendEvent("GuildWarAttackView_Refresh")
                DialogManager.ShowToast(lang.trans("guild_has_capture"))
            end
        end
    end)
end

function OurPartSeatsDetailCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function OurPartSeatsDetailCtrl:OnExitScene()
    self.view:OnExitScene()
end

-- 更换席位
function OurPartSeatsDetailCtrl:OnClickChangeBtn(pos)
    self.view:Close()
    res.PushDialog("ui.controllers.guild.guildWar.GuildWarGuardDetailCtrl", self.guildData, self.guildWarModel)
end

function OurPartSeatsDetailCtrl:OnClickDetailBtn(pid, sid)
    if pid and sid then
        PlayerDetailCtrl.ShowPlayerDetailView(function() return req.viewPlayer(pid, sid) end, pid, sid)
    end
end

return OurPartSeatsDetailCtrl
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local GuildWarFightType = require("ui.models.guild.guildMistWar.GuildWarFightType")
local MistOurPartSeatsDetailModel = require("ui.models.guild.guildMistWar.MistOurPartSeatsDetailModel")

local BaseCtrl = require("ui.controllers.BaseCtrl")

local MistOurPartSeatsDetailCtrl = class(BaseCtrl, "MistOurPartSeatsDetailCtrl")

MistOurPartSeatsDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/MistOurPartSeatsDetail.prefab"

-- 防守详情和进攻详情公用
function MistOurPartSeatsDetailCtrl:AheadRequest(index, mistMapModel)
    self.index = index
    self.mistMapModel = mistMapModel
    local fightType = self.mistMapModel:GetGuildWarFightType()
    local response
    if fightType == GuildWarFightType.Attack then
        response = req.guildWarTargetGuardDetailMist(index)
    elseif fightType == GuildWarFightType.Defend then
        response = req.guildWarSelfGuardDetailMist(index)
    end
    if api.success(response) then
        local data = response.val
        if not self.model then
            self.model = MistOurPartSeatsDetailModel.new()
            self.model:SetMistMapModel(self.mistMapModel)
        end
        local detail = self.mistMapModel:GetGuardDataByIndex(index)
        data.detail = detail
        self.model:InitWithProtocol(data)
    end
end

function MistOurPartSeatsDetailCtrl:Init(index, mistMapModel)
    self.index = index
    self.mistMapModel = mistMapModel
    self.view.onClickChallengeBtn = function(pos) self:OnClickChallengeBtn(pos) end
    self.view.onClickDetailBtn = function() self:OnClickDetailBtn() end
end

function MistOurPartSeatsDetailCtrl:Refresh(index, mistMapModel)
    MistOurPartSeatsDetailCtrl.super.Refresh(self)
    if self.model then
        self.view:InitView(index, self.model)
    else
        self.view.closeDialog()
    end
end

function MistOurPartSeatsDetailCtrl:GetStatusData()
    return self.index, self.mistMapModel
end

function MistOurPartSeatsDetailCtrl:OnClickChallengeBtn(pos)
    self.view:Close()
    clr.coroutine(function ()
        local response = req.guildWarStartMist(pos)
        if api.success(response) then
            local data = response.val
            if data.matchData then
                local matchLoader = require("coregame.MatchLoader")
                matchLoader.startMatch(data.matchData)
            else
                self.model:RefreshAttackGuardData(data)
                DialogManager.ShowToast(lang.trans("guild_has_capture"))
            end
        end
    end)
end

function MistOurPartSeatsDetailCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function MistOurPartSeatsDetailCtrl:OnExitScene()
    self.view:OnExitScene()
end

-- 更换席位
function MistOurPartSeatsDetailCtrl:OnClickChangeBtn(pos)
    self.view:Close()
    res.PushDialog("ui.controllers.guild.guildWar.GuildWarGuardDetailCtrl", self.guildData, self.guildWarModel)
end

function MistOurPartSeatsDetailCtrl:OnClickDetailBtn()
    local pid = self.model:GetPid()
    local sid = self.model:GetSid()
    if sid then
        PlayerDetailCtrl.ShowPlayerDetailView(function() return req.viewPlayer(pid, sid) end, pid, sid)
    end
end

return MistOurPartSeatsDetailCtrl

local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaModel = require("ui.models.arena.ArenaModel")
local ArenaInfoBarCtrl = require("ui.controllers.common.ArenaInfoBarCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local ArenaAllotTeamCtrl = class(BaseCtrl, "CourtMainCtrl")

ArenaAllotTeamCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/AllotTeam.prefab"

function ArenaAllotTeamCtrl:Init(arenaType)
    self.arenaType = arenaType
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = ArenaInfoBarCtrl.new(child, self)
        GameObjectHelper.FastSetActive(child.btnBack.gameObject, false)
    end)
    self.view.clickConfirm = function() self:OnClickConfirm() end
    self.view.clickRule = function() self:OnClickRule() end
    self.view.clickBack = function() self:OnClickBack() end
end

function ArenaAllotTeamCtrl:OnClickRule()
    res.PushScene("ui.controllers.arena.ArenaRuleCtrl")
end

function ArenaAllotTeamCtrl:OnClickBack()
    res.PushScene("ui.controllers.arena.ArenaRewardCtrl", self.arenaType)
end

function ArenaAllotTeamCtrl:OnClickConfirm()
    self.view:OnClickBackAnimation()
end

function ArenaAllotTeamCtrl:Refresh()
    ArenaAllotTeamCtrl.super.Refresh(self)
    clr.coroutine(function()
        local response = req.arenaGroupInfo(self.arenaType)
        if api.success(response) then
            local data = response.val
            self.view:InitView(data, self.arenaType)
            local arenaModel = ArenaModel.new()
            arenaModel:SetMatchTeamsStage(self.arenaType, data.stage)
        end
    end)
end

return ArenaAllotTeamCtrl

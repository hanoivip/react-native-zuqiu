local ArenaModel = require("ui.models.arena.ArenaModel")
local ArenaInfoBarCtrl = require("ui.controllers.common.ArenaInfoBarCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local ArenaRewardCtrl = class(BaseCtrl, "CourtMainCtrl")

ArenaRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/ArenaReward.prefab"

function ArenaRewardCtrl:Init(arenaType)
    self.arenaType = arenaType
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = ArenaInfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self:OnClickConfirm()
        end)
    end)
    self.view.clickConfirm = function() self:OnClickConfirm() end
    self.view.clickRule = function() self:OnClickRule() end
end

function ArenaRewardCtrl:OnClickRule()
    res.PushScene("ui.controllers.arena.ArenaRuleCtrl")
end

function ArenaRewardCtrl:OnClickConfirm()
    res.PushScene("ui.controllers.arena.schedule.ArenaScheduleCtrl", self.arenaType)
end

function ArenaRewardCtrl:Refresh()
    ArenaRewardCtrl.super.Refresh(self)
    local arenaModel = ArenaModel.new()
    local teamsStage = arenaModel:GetMatchTeamsStage(self.arenaType)
    if teamsStage then 
        self.view:InitView(arenaModel, self.arenaType)
    else
        clr.coroutine(function()
            local response = req.arenaGroupInfo(self.arenaType)
            if api.success(response) then
                local data = response.val
                arenaModel:SetMatchTeamsStage(self.arenaType, data.stage)
                self.view:InitView(arenaModel, self.arenaType)
            end
        end)
    end
end

return ArenaRewardCtrl

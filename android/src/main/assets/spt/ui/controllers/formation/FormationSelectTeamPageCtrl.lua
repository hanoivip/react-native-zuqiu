local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

local FormationSelectTeamPageCtrl = class(BaseCtrl)
FormationSelectTeamPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Formation/FormationSelectTeamPage.prefab"

function FormationSelectTeamPageCtrl:ctor(view)
    self.playerTeamsModel = nil
    self.view = view
    self:Init()
end

function FormationSelectTeamPageCtrl:Init()
    self.playerTeamsModel = PlayerTeamsModel.new()
    self:InitView()
end

function FormationSelectTeamPageCtrl:Refresh()
    FormationSelectTeamPageCtrl.super.Refresh(self)
    local needUpdate = nil
    local loadType = self:GetLoadType()
    if loadType == res.LoadType.Pop then
        needUpdate = false
    else
        needUpdate = true
    end
    self.view:RefreshPage(needUpdate)
end

function FormationSelectTeamPageCtrl:OnEnterScene()
    self.view:RegisterEvent()
end

function FormationSelectTeamPageCtrl:OnExitScene()
    self.view:UnRegisterEvent()
end

function FormationSelectTeamPageCtrl:InitView()
    self.view:InitView(self.playerTeamsModel)
    self.view.onFormationEdit = function() self:OnFormationEdit() end
end

function FormationSelectTeamPageCtrl:OnFormationEdit()
    res.PushScene("ui.controllers.formation.FormationPageCtrl", self.playerTeamsModel)
    GuideManager.Show()
end

function FormationSelectTeamPageCtrl:GetStatusData()
end

return FormationSelectTeamPageCtrl
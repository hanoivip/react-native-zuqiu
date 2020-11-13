local EventSystem = require("EventSystem")
local DreamMainModel = require("ui.models.dreamLeague.dreamMain.DreamMainModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local DreamMainCtrl = class(BaseCtrl)

DreamMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamMain/DreamMain.prefab"

function DreamMainCtrl:AheadRequest()
    local response = req.dreamLeagueMatchIndex()
    if api.success(response) then
        local data = response.val
        self.dreamMainModel = DreamMainModel.new()
        self.dreamMainModel:InitWithProtocol(data)
    end
end

function DreamMainCtrl:Init()
    DreamMainCtrl.super.Init(self)
    self.view.startBattleBtnClick = function () self:OnStartBattleBtnClick() end
end

function DreamMainCtrl:OnStartBattleBtnClick()
    res.PushScene("ui.controllers.dreamLeague.dreamBattle.DreamBattleMainCtrl")
end

function DreamMainCtrl:Refresh(dreamMainModel)
    DreamMainCtrl.super.Refresh(self)
    self.view:InitView(self.dreamMainModel or dreamMainModel)
end

function DreamMainCtrl:OnEnterScene()
    EventSystem.AddEvent("DreamMainCtrl_Refresh", self, self.Refresh)
end

function DreamMainCtrl:OnExitScene()
    EventSystem.RemoveEvent("DreamMainCtrl_Refresh", self, self.Refresh)
end

function DreamMainCtrl:GetStatusData()
    return self.dreamMainModel
end

return DreamMainCtrl

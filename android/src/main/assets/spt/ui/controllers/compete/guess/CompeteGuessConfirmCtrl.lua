local DialogManager = require("ui.control.manager.DialogManager")
local CompeteGuessConfirmModel = require("ui.models.compete.guess.CompeteGuessConfirmModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local CompeteGuessConfirmCtrl = class(BaseCtrl, "CompeteGuessConfirmCtrl")

CompeteGuessConfirmCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Guess/CompeteGuessConfirm.prefab"

CompeteGuessConfirmCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function CompeteGuessConfirmCtrl:ctor()
    CompeteGuessConfirmCtrl.super.ctor(self)
end

function CompeteGuessConfirmCtrl:Init(data, competeMainModel)
    self.view.onClickConfirm = function() self:OnClickConfirm() end
    self.view.onToggleClick = function(label) self:OnToggleClick(label) end
end

function CompeteGuessConfirmCtrl:Refresh(data, competeMainModel)
    CompeteGuessConfirmCtrl.super.Refresh(self)
    if self.model == nil then
        self.model = CompeteGuessConfirmModel.new()
    end
    self.model:SetCompeteMainModel(competeMainModel)
    self.model:InitWithProtocol(data)
    self.view:InitView(self.model)
end

function CompeteGuessConfirmCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CompeteGuessConfirmCtrl:OnExitScene()
    self.view:OnExitScene()
end

function CompeteGuessConfirmCtrl:OnClickConfirm()
    local confirm = self.model:GetLabel()
    if not confirm then
        DialogManager.ShowToastByLang("please_choose")
        return
    end
    self.view:coroutine(function()
        local response = req.competeGuessConfirm(confirm)
        if api.success(response) then
            local data = response.val
            self.view:Close()
        end
    end)
end

function CompeteGuessConfirmCtrl:OnToggleClick(label)
    self.model:SetLabel(tonumber(label))
end

return CompeteGuessConfirmCtrl

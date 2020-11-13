local EventSystem = require ("EventSystem")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local DreamPlayerChooseCtrl = class(BaseCtrl)

DreamPlayerChooseCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

DreamPlayerChooseCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamHall/DreamPlayerPlayerChoose.prefab"

-- 因为该选人界面需要多处复用，但回调不同，可以将回调传入
function DreamPlayerChooseCtrl:Init(dreamPlayerChooseModel, confirmCallback)
    self.dreamPlayerChooseModel = dreamPlayerChooseModel
    self.confirmCallback = confirmCallback
end

function DreamPlayerChooseCtrl:Refresh(dreamPlayerChooseModel)
    self.view:InitView(dreamPlayerChooseModel)
    self.view.onAddPlayerClick = function(posIndex) self:ClickAddPlayer(posIndex) end
end

function DreamPlayerChooseCtrl:ClickAddPlayer(posIndex)
    local allDcids = self.dreamPlayerChooseModel:GetAllDcids()
    local allNations = self.dreamPlayerChooseModel:GetAllNations()
    self.view.closeDialog()
    res.PushScene("ui.controllers.dreamLeague.dreamBag.DreamBagCtrl", allDcids, true, posIndex, allNations, self.confirmCallback)
end

function DreamPlayerChooseCtrl:OnBtnReset()
    self.view:OnReset()
end

function DreamPlayerChooseCtrl:OnEnterScene()
    if self.view.OnEnterScene then
        self.view:OnEnterScene()
    end
end

function DreamPlayerChooseCtrl:OnExitScene()
    if self.view.OnExitScene then
        self.view:OnExitScene()
    end
end

function DreamPlayerChooseCtrl:GetStatusData()
    return self.dreamPlayerChooseModel, self.confirmCallback
end

return DreamPlayerChooseCtrl

local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local RedPacketMapModel = require("ui.models.RedPacketMapModel")
local RedPacketDescCtrl = class(BaseCtrl, "RedPacketDescCtrl")


RedPacketDescCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/ItemList/RedPacketDesc.prefab"

RedPacketDescCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function RedPacketDescCtrl:Init(model)
    self.model = model
    self.view.OnClickConfirmBtn = function (inputDesc) self:OnClickConfirmBtn(inputDesc) end
end

function RedPacketDescCtrl:Refresh(model)
    self.view:InitView()
end

function RedPacketDescCtrl:OnClickConfirmBtn(inputDesc)
    self.view:Close()
    clr.coroutine(function()
        local respone = req.sendRedEnvelope(self.model:GetId(), "itemRedPacket", inputDesc)
        if api.success(respone) then
            local rpMapModel = RedPacketMapModel.new()
            rpMapModel:ResetRedPacketNum(self.model:GetId(), rpMapModel:GetItemNum(self.model:GetId()) - 1)
            local data = respone.val
            if data.ok == true then
                DialogManager.ShowToastByLang("guild_sendPacket")
            end
        end
    end)
end

return RedPacketDescCtrl
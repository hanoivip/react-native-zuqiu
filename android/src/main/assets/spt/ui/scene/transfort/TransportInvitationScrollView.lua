local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local TransportInvitationScrollView = class(LuaScrollRectExSameSize)

function TransportInvitationScrollView:start()
end

function TransportInvitationScrollView:InitView(data, model)
    self.itemDatas = data
    self.model = model
    self:refresh()
end

function TransportInvitationScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Transfort/TransportInvitationItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function TransportInvitationScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    spt:InitView(data, self.model)

    spt.onDetailBtnClick = function () self:OnViewDetail(data.pid, data.sid) end
    spt.onInviteBtnClick = function ()
        clr.coroutine(function ()
            local idsAndSids = {}
            idsAndSids[data.pid] = data.sid
            local response = req.transportGuardApply(idsAndSids)
            if api.success(response) then
                DialogManager.ShowToastByLang("tramsport_invite_finish")
                EventSystem.SendEvent("Refresh_Transport_Invitation_Main_View")
            end
        end)
    end
end

function TransportInvitationScrollView:OnViewDetail(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

return TransportInvitationScrollView
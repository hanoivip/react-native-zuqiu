local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local TransportInviteHistoryScrollView = class(LuaScrollRectExSameSize)

function TransportInviteHistoryScrollView:start()
end

function TransportInviteHistoryScrollView:InitView(data, model)
    self.itemDatas = data
    self.model = model
    self:refresh()
end

function TransportInviteHistoryScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Transfort/TransportInviteHistoryItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function TransportInviteHistoryScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    spt:InitView(data, self.model)
    spt.onDetailBtnClick = function () self:OnViewDetail(data.pid, data.sid) end

    spt.onAcceptBtnClick = function ()
        self:OnAcceptBtnClick(data.pid, data.sid)
    end
end

function TransportInviteHistoryScrollView:OnAcceptBtnClick(pid, sid)
    clr.coroutine(function ()
        local response = req.transportAcceptGuard(pid, sid)
        if api.success(response) then
            DialogManager.ShowToastByLang("transfort_assept_invite_finish")
            EventSystem.SendEvent("Transport_Refresh_Invitation_History")
        end
    end)
end

function TransportInviteHistoryScrollView:OnViewDetail(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

return TransportInviteHistoryScrollView
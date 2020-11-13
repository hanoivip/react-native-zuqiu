local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local TransportJournalMatchSignScrollView = class(LuaScrollRectExSameSize)

function TransportJournalMatchSignScrollView:start()
end

function TransportJournalMatchSignScrollView:InitView(data, model)
    self.itemDatas = data
    self.model = model
    self:refresh()
end

function TransportJournalMatchSignScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Transfort/MatchSigntem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function TransportJournalMatchSignScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    spt:InitView(data, self.model)
    spt.onDeleteBtnClick = function () self:OnDeleteBtnClick(data.pid) end
    spt.onDetailBtnClick = function () self:OnViewDetail(data.pid, data.sid) end
end

function TransportJournalMatchSignScrollView:OnDeleteBtnClick(pid)
    clr.coroutine(function ()
        local response = req.transportRemoveMark(pid)
        if api.success(response) then
            DialogManager.ShowToastByLang("transport_delete_finish")
            EventSystem.SendEvent("Refresh_Transport_Journal_Main_View")
        end
    end)
end

function TransportJournalMatchSignScrollView:OnViewDetail(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

return TransportJournalMatchSignScrollView
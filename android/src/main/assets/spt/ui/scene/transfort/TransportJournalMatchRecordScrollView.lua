local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local TransportJournalMatchRecordScrollView = class(LuaScrollRectExSameSize)

function TransportJournalMatchRecordScrollView:start()
end

function TransportJournalMatchRecordScrollView:InitView(data)
    self.itemDatas = data
    self:refresh()
end

function TransportJournalMatchRecordScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Transfort/MatchRecordItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function TransportJournalMatchRecordScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    spt:InitView(data)
    spt.onSigntBtnClick = function ()
        clr.coroutine(function ()
            local response = req.transportMark(data.pid, data.sid)
            if api.success(response) then
                EventSystem.SendEvent("Refresh_Transport_Journal_Main_View")
            end
        end)
    end
    spt.onDetailBtnClick = function () self:OnViewDetail(data.pid, data.sid) end
end

function TransportJournalMatchRecordScrollView:OnViewDetail(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

return TransportJournalMatchRecordScrollView
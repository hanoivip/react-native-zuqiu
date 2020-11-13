local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local TransportJournalMatchProtectRecordScrollView = class(LuaScrollRectExSameSize)

function TransportJournalMatchProtectRecordScrollView:start()
end

function TransportJournalMatchProtectRecordScrollView:InitView(data, model)
    self.itemDatas = data
    self.model = model
    self:refresh()
end

function TransportJournalMatchProtectRecordScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Transfort/MatchProtectRecordItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function TransportJournalMatchProtectRecordScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    spt.onDetailBtnClick = function () self:OnDetailBtnClick(data.pid, data.sid) end
    spt.onReveiveBtnClick = function () self:OnReveiveBtnClick(data._id) end
    spt:InitView(data)
end

function TransportJournalMatchProtectRecordScrollView:OnDetailBtnClick(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

function TransportJournalMatchProtectRecordScrollView:OnReveiveBtnClick(id)
    clr.coroutine(function ()
        local response = req.transportGuardReceive(id)
        if api.success(response) then
        local data = response.val
        CongratulationsPageCtrl.new(data.gift)
            EventSystem.SendEvent("Refresh_Transport_Journal_Main_View")
        end
    end)
end

return TransportJournalMatchProtectRecordScrollView
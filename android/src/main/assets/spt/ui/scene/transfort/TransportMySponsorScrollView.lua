local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local TransportMySponsorScrollView = class(LuaScrollRectExSameSize)

function TransportMySponsorScrollView:ctor()
    self.scrollerPointGroup = self.___ex.scrollerPointGroup
    self.scrollRect = self.___ex.scrollRect
    self.bgRect = self.___ex.bgRect
    self.super.ctor(self)
end

function TransportMySponsorScrollView:start()
    self:regOnItemIndexChanged(function (index)
        self:SetPointGroup(index)
    end)

    self:ResetWithCellSize(self.bgRect.sizeDelta.x, self.bgRect.rect.height)
end

function TransportMySponsorScrollView:InitView(data, model)
    self.itemDatas = data
    self.model = model
    self:refresh()
    self:BuildPointGroup()
    self:SetPointGroup(1)
    self.scrollRect.enabled = #self.itemDatas > 1
end

function TransportMySponsorScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Transfort/MySponsorItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function TransportMySponsorScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    spt.onSignBtnClick = function () self:OnSignBtnClick(index) end
    spt.onStartBtnClick = function () self:OnStartBtnClick() end
    spt.onInviteBtnClick = function () self:OnInviteBtnClick(data) end
    spt.onReceiveBtnClick = function () self:OnReceiveBtnClick() end
    spt:InitView(data, self.model)
end

function TransportMySponsorScrollView:OnInviteBtnClick(data)
    if data.guardPlayer then
        PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(data.guardPlayer.pid, data.guardPlayer.sid) end, data.guardPlayer.pid, data.guardPlayer.sid)
    else
        res.PushDialog("ui.controllers.transfort.TransportInvitationCtrl")
    end
end

function TransportMySponsorScrollView:OnSignBtnClick(index)
    local data = self.itemDatas[index]
    clr.coroutine(function ()
        local response = req.transportSign()
        if api.success(response) then
            self.model:SetMySponsorDataList(response.val.transport.express)
        end
    end)
end

function TransportMySponsorScrollView:OnClickInviteBtn(index)
    res.PushDialog("ui.controllers.transfort.TransportInvitationCtrl")
end

local BeginFlag = -1
function TransportMySponsorScrollView:OnStartBtnClick()
    clr.coroutine(function ()
        local response = req.transportStart()
        if api.success(response) then
            self.model:SetMySponsorDataList(response.val.transport.express)
            EventSystem.SendEvent("Transfort_Refresh_Sponsor_Info", BeginFlag)
        end
    end)
end

function TransportMySponsorScrollView:OnReceiveBtnClick()
    clr.coroutine(function ()
        local response = req.transportReceive()
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.gift)
            EventSystem.SendEvent("Transport_Refresh_Main_View")
        end
    end)
end

function TransportMySponsorScrollView:BuildPointGroup()
    if #self.itemDatas <= 1 then
        GameObjectHelper.FastSetActive(self.scrollerPointGroup.gameObject, false)
        return
    else
        GameObjectHelper.FastSetActive(self.scrollerPointGroup.gameObject, true)
    end
    
    local pointObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Transfort/PageScrollerPoint.prefab")
    local childLoadedCount = self.scrollerPointGroup.childCount
    if childLoadedCount < #self.itemDatas then
        for i = childLoadedCount + 1, #self.itemDatas do
            local pointGo = Object.Instantiate(pointObj)
            pointGo.transform:SetParent(self.scrollerPointGroup, false)
        end
    elseif childLoadedCount > #self.itemDatas then
        for i = #self.itemDatas + 1, childLoadedCount do
            Object.Destroy(self.scrollerPointGroup:GetChild(i - 1).gameObject)
        end
    end
end

function TransportMySponsorScrollView:SetPointGroup(index)
    if #self.itemDatas <= 1 then
        return
    end
    for i = 1, self.scrollerPointGroup.childCount do
        local child = self.scrollerPointGroup:GetChild(i - 1)
        local point = child:GetChild(0).gameObject
        GameObjectHelper.FastSetActive(point, i == index)
    end
end

return TransportMySponsorScrollView

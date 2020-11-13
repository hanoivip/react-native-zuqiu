local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ChargeItemModel = require("ui.models.store.ChargeItemModel")
local VIPModel = require("ui.models.store.VIPModel")
local EventSystem = require("EventSystem")
local VIP = require("data.VIP")

local ChargeAndVIPCtrl = class(BaseCtrl, "ChargeAndVIP")

ChargeAndVIPCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Charge/ChargeAndVIP.prefab"

ChargeAndVIPCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function ChargeAndVIPCtrl:Init()
    self.view.refresh = function(tag, vipLevel) self:Refresh(tag, vipLevel) end

    self.view:RegOnSwitchBtnClick(function()
        if self.currentTag == "charge" then
            self:Refresh("vip")
        elseif self.currentTag == "vip" then
            self:Refresh("charge")
        end
    end)

    self.canAskFor = true
end

function ChargeAndVIPCtrl:Refresh(tag, showVIPLevel, isBlackDiamond)
    ChargeAndVIPCtrl.super.Refresh(self)
    if not tag then tag = "charge" end
    self.currentTag = tag
    if self.canAskFor then
    clr.coroutine(function()
        local resp = req.vipInfo()
        if api.success(resp) then
            local playerInfoModel = PlayerInfoModel.new()
            local vipLevel = resp.val.vip.lvl
            local currentDiamond = resp.val.vip.d
            playerInfoModel:SetVipLevel(vipLevel)
            playerInfoModel:SetVipCost(currentDiamond, VIPModel)
           -- 配了个0，是没有充值过
            self.view.MaxVIPLevel = table.nums(VIP) - 1
            if tag == "vip" then
                local datas = clone(VIPModel)
                datas[0] = nil
                self.view:InitAsVIP(vipLevel, currentDiamond, datas, resp.val.vipBag.bag, showVIPLevel)
            elseif tag == "charge" then
                local response = req.storeChargeList()
                if api.success(response) then
                    local list = response.val.list
                    table.sort(list, function (a, b) return a.order < b.order end)
                    local prefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Charge/ChargeItem.prefab")
                    local items = {}
                    for i, v in ipairs(list) do
                        local item = Object.Instantiate(prefab)
                        local spt = res.GetLuaScript(item)
                        local model = ChargeItemModel.new(v)
                        spt:Init(model)
                        table.insert(items, spt)
                    end
                    self.view:InitAsCharge(vipLevel, currentDiamond, items, isBlackDiamond)
                end
            end
        end
    end)
    end
end

function ChargeAndVIPCtrl:GetStatusData()
    return self.currentTag, self.view.currVIPLevel
end

function ChargeAndVIPCtrl:RefreshTop()
    if not self.canAskFor then return end
    self.canAskFor = false
    clr.coroutine(function()
        local resp = req.vipInfo()
        if api.success(resp) then
            local vipLevel = resp.val.vip.lvl
            local currentDiamond = resp.val.vip.d
            local playerInfoModel = PlayerInfoModel.new()
            playerInfoModel:SetVipLevel(vipLevel)
            playerInfoModel:SetVipCost(currentDiamond, VIPModel)
            self.view:InitTop(vipLevel, currentDiamond)
        end
        self.canAskFor = true
    end)
end

function ChargeAndVIPCtrl:OnEnterScene()
    EventSystem.AddEvent("PlayerInfo", self, self.RefreshTop)
end

function ChargeAndVIPCtrl:OnExitScene()
    EventSystem.RemoveEvent("PlayerInfo", self, self.RefreshTop)
end

return ChargeAndVIPCtrl
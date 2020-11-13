local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CustomEvent = require("ui.common.CustomEvent")
local VIPItemView = class(unity.base)

function VIPItemView:ctor()
    self.vipLevel1 = self.___ex.vipLevel1
    self.vipLevel2 = self.___ex.vipLevel2
    self.privilege = self.___ex.privilege
    self.packContent = self.___ex.packContent
    self.price = self.___ex.price
    self.buyBtn = self.___ex.buyBtn
    self.bought = self.___ex.bought
    self.buyBtn:regOnButtonClick(function()
        local resp = req.buyVIPBag(self.vipLevel)
        if api.success(resp) then
            local data = resp.val
            if type(data.cost) == "table" then
                self.buyBtn.gameObject:SetActive(false)
                self.price.gameObject:SetActive(false)
                self.bought:SetActive(true)
                self.boughtInfo[tostring(self.vipLevel)] = true

                local playerInfoModel = PlayerInfoModel.new()
                playerInfoModel:Init()
                playerInfoModel:AddDiamond(-1 * data.cost.cost)
                local mInfo = {}
                mInfo.phylum = "vipStore"
                mInfo.classfield = "vip" .. (self.vipLevel or "")
                CustomEvent.GetDiamond("2", data.cost.cost, mInfo)
                -- DialogManager.ShowToastByLang("buy_item_success")

                CongratulationsPageCtrl.new(data.gift)
            end
        end
    end)
end

function VIPItemView:Init(VIPLevel, desc, price, packData, boughtInfo)
    self.boughtInfo = boughtInfo
    self.vipLevel = VIPLevel
    self.vipLevel1.text = format("VIP%s", VIPLevel)
    self.vipLevel2.text = format("VIP%s", VIPLevel)
    self.privilege.text = tostring(desc)
    self.price.text = format("X %s", price)
    res.ClearChildren(self.packContent)
    local rewardParams = {
        parentObj = self.packContent,
        rewardData = packData,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
    local isBought = boughtInfo[tostring(VIPLevel)]
    if isBought then
        self.buyBtn.gameObject:SetActive(false)
        self.price.gameObject:SetActive(false)
        self.bought:SetActive(true)
    else
        self.buyBtn.gameObject:SetActive(true)
        self.price.gameObject:SetActive(true)
        self.bought:SetActive(false)
    end
end

return VIPItemView

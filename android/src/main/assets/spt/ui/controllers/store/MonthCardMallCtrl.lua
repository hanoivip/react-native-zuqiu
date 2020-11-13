local StoreItemCtrl = require("ui.controllers.store.StoreItemCtrl")
local StoreModel = require("ui.models.store.StoreModel")
local MonthCardMallModel = require('ui.models.store.MonthCardMallModel')

local MonthCardMallCtrl = class(nil, "MonthCardMallCtrl")

function MonthCardMallCtrl:ctor(content)
    self.model = MonthCardMallModel.new()
    self:Init(content)
end

function MonthCardMallCtrl:Init(content)
    local object, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Store/MonthCardMall.prefab")
    object.transform:SetParent(content, false)
    self.view = spt
end

function MonthCardMallCtrl:EnterScene()
    self.view:EnterScene()
end

function MonthCardMallCtrl:OnExitScene()
    EventSystem.RemoveEvent("monthCardMall.refreshAfterBought", self, self.UpdateAfterBought)
    EventSystem.RemoveEvent("Charge_Success", self, self.RefreshAfterCharge)
    EventSystem.RemoveEvent("gotoSupremeMonthCard", self, self.GotoSupremeMonthCard)
end

function MonthCardMallCtrl:InitView()
   clr.coroutine(function()
        local response = req.monthCardShopInfo()
        if api.success(response) then
            local data = response.val
            self.model:InitWithProtocol(data)
            self.view:InitView(self.model)
        end
    end)
end

function MonthCardMallCtrl:ShowPageVisible(isShow)
    if isShow then
        EventSystem.AddEvent("monthCardMall.refreshAfterBought", self, self.UpdateAfterBought)
        EventSystem.AddEvent("Charge_Success", self, self.RefreshAfterCharge)
        EventSystem.AddEvent("gotoSupremeMonthCard", self, self.GotoSupremeMonthCard)
    else
        EventSystem.RemoveEvent("monthCardMall.refreshAfterBought", self, self.UpdateAfterBought)
        EventSystem.RemoveEvent("Charge_Success", self, self.RefreshAfterCharge)
        EventSystem.RemoveEvent("gotoSupremeMonthCard", self, self.GotoSupremeMonthCard)
    end
    self.view:ShowPageVisible(isShow)
end

function MonthCardMallCtrl:UpdateAfterBought(id, cnt)
    self.model:UpdateAfterBought(id, cnt)
    self.view:InitView(self.model)
end

function MonthCardMallCtrl:RefreshAfterCharge()
    self:InitView()
end

function MonthCardMallCtrl:GotoSupremeMonthCard()
    EventSystem.SendEvent("SwitchMenu", StoreModel.MenuTags.GiftBox)
end

return MonthCardMallCtrl
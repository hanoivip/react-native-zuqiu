local LuaButton = require("ui.control.button.LuaButton")
local CommonConstants = require("ui.common.CommonConstants")
local DialogManager = require("ui.control.manager.DialogManager")
local CustomEvent = require("ui.common.CustomEvent")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local Vector3 = clr.UnityEngine.Vector3
local ChargeItemView = class(LuaButton)

function ChargeItemView:ctor()
    ChargeItemView.super.ctor(self)
    self.title = self.___ex.title
    self.icon = self.___ex.icon
    self.descBoard = self.___ex.descBoard
    self.descText = self.___ex.descText
    self.price = self.___ex.price
    self.btnArea = self.___ex.btnArea
end

function ChargeItemView:start()
    self.btnArea:regOnButtonClick(function()
        local productId = self.model:GetProductId()
        if luaevt.trig("HasPurchaseSystem") then
            luaevt.trig("Do_Pay", productId, self.model, self)
        else
            local initResp = req.payInit(productId, true)
            if api.success(initResp) then
                local orderId = initResp.val.order_id
                local testResp = req.payTest(orderId)
                if api.success(testResp) then
                    local testData = testResp.val
                    local playerInfoModel = PlayerInfoModel.new()
                    playerInfoModel:Init()
                    playerInfoModel:AddDiamond(testData.totalDiamond)
                    playerInfoModel:SetBlackDiamond(testData.bkd)
                    CustomEvent.GetDiamond("1", testData.totalDiamond)
                    DialogManager.ShowToastByLang("buy_item_success")
                    EventSystem.SendEvent("Charge_Success")
                    EventSystem.SendEvent("Consume_RMB", self.model:GetItemPrice())
                    self:SetNotFirst()
                    EventSystem.SendEvent("TransferMarketModel_RefreshTransferMarketModel")
                end
            end
        end
    end)
end

function ChargeItemView:SetNotFirst()
    if self.model:GetFirstPay() then
        self.model:SetFirstPay(false)
        local desc = self.model:GetItemDesc()
        if type(desc) == "string" and desc ~= "" then
            self.descBoard:SetActive(true)
            self.descText.text = desc
        else
            self.descBoard:SetActive(false)
        end
    end
end

local currencySymbol = "$  "
local function formatCurrency(amount)
    return currencySymbol .. tostring(amount / 100)
end

function ChargeItemView:Init(model)
    self.model = model
    local title = model:GetItemName()
    local iconId = model:GetPicIndex()
    local desc = model:GetItemDesc()
    local price = model:GetItemPrice()
    local hotColor = model:GetHotColor()
    local hotText = model:GetHotText()

    self.title.text = tostring(title)
    self.icon.overrideSprite = res.LoadRes(format("Assets/CapstonesRes/Game/UI/Scene/Charge/Image/%s.png", iconId))
    if type(desc) == "string" and desc ~= "" then
        self.descBoard:SetActive(true)
        self.descText.text = desc
    else
        self.descBoard:SetActive(false)
    end
    self.price.text = model:GetShowPrice() or formatCurrency(price)

    self:InitEffects(iconId)
end

function ChargeItemView:InitEffects(iconId)
    local path = format("Assets/CapstonesRes/Game/UI/Scene/Charge/%s.prefab", iconId)
    local prefab = res.Instantiate(path)
    if prefab then
        if iconId == "BlackDiamondOne" or iconId == "BlackDiamondTwo" or iconId == "BlackDiamondThree" then
            prefab.transform:SetParent(self.icon.gameObject.transform, false)
            prefab.transform:SetSiblingIndex(self.icon.transform:GetSiblingIndex() + 1)
        else
            prefab.transform:SetParent(self.gameObject.transform, false)
            prefab.transform:SetSiblingIndex(self.icon.transform:GetSiblingIndex())
        end
    end

    if iconId == "MonthCard" then
        path = format("Assets/CapstonesRes/Game/UI/Scene/Charge/%s.prefab", "MonthCardMask")
        prefab = res.Instantiate(path)
        prefab.transform:SetParent(self.icon.gameObject.transform)
        prefab.transform.localPosition = Vector3(4.1, -2.8, 0)
    end
end

return ChargeItemView

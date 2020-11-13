local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")

local GreenswardMoraleSupplyCtrl = class(BaseCtrl, "GreenswardMoraleSupplyCtrl")

GreenswardMoraleSupplyCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/MoraleSupply/GreenswardMoraleSupply.prefab"

GreenswardMoraleSupplyCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GreenswardMoraleSupplyCtrl:AheadRequest(model)
    if model then
        self.model = model
    end
    if self.view then
        self.view:ShowDisplayArea(false)
    end
    local response = req.greenswardAdventureFriend()
    if api.success(response) then
        local data = response.val
        self.model:InitWithProtocol(data)
        self.view:ShowDisplayArea(true)
    end
end

function GreenswardMoraleSupplyCtrl:Init(model)
    GreenswardMoraleSupplyCtrl.super.Init(self)
    self.model = model
    self.view.onBtnGet = function(itemData) self:OnBtnGet(itemData) end
    self.view.onBtnSend = function(itemData) self:OnBtnSend(itemData) end
    self.view.onBtnGetBatch = function() self:OnBtnGetBatch() end
    self.view.onBtnSendBatch = function() self:OnBtnSendBatch() end
    self.view:InitView(self.model)
end

function GreenswardMoraleSupplyCtrl:Refresh(model)
    GreenswardMoraleSupplyCtrl.super.Refresh(self)
    self.model = model
    self.view:RefreshView()
end

-- 领取单个好友士气
function GreenswardMoraleSupplyCtrl:OnBtnGet(itemData)
    if self.model:IsNotRcv(itemData.advRcv) then
        DialogManager.ShowToastByLang("friend_not_send") -- 好友未赠送
        return
    end

    if not self.model:IsNotReceive(itemData.advRcv) then
        DialogManager.ShowToastByLang("have_received") -- 已领取
        return
    end

    if self.model:IsMoraleLimit() then
        -- 士气已满，先消耗一些再来吧
        local moralName = lang.transstr(CurrencyNameMap.morale)
        DialogManager.ShowToast(lang.transstr("greensward_morale_supply_moralelimit", moralName))
        return
    end

    if self.model:GetLeftTimes() <= 0 then
        DialogManager.ShowToastByLang("greensward_morale_supply_rcvlimit") -- 今日领取次数已达上限
        return
    end

    self.view:coroutine(function()
        local response = req.greenswardAdventureRcvMorale(itemData.pid, itemData.sid)
        if api.success(response) then
            local data = response.val
            local contents = data.contents
            if not table.isEmpty(contents) then
                CongratulationsPageCtrl.new(contents)
            end
            self.model:UpdateAfterGetBatch(data)
            self.view:UpdateAfterGetBatch()
        end
    end)
end

-- 赠送单个好友士气
function GreenswardMoraleSupplyCtrl:OnBtnSend(itemData)
    if not self.model:IsNotSend(itemData.advSend) then
        DialogManager.ShowToastByLang("have_sent") -- 已赠送
        return
    end

    self.view:coroutine(function()
        local response = req.greenswardAdventureSendMorale(itemData.pid, itemData.sid)
        if api.success(response) then
            local data = response.val
            DialogManager.ShowToastByLang("greensward_morale_supply_sent") -- 赠送成功
            self.model:UpdateAfterSendBatch(data)
            self.view:UpdateAfterSendBatch()
        end
    end)
end

-- 一键领取
function GreenswardMoraleSupplyCtrl:OnBtnGetBatch()
    if not self.model:HasNotReceived() then
        DialogManager.ShowToast(lang.transstr("greensward_morale_supply_allrcv", lang.transstr(CurrencyNameMap.morale))) -- 当前没有可领取的士气
        return
    end

    if self.model:IsMoraleLimit() then
        -- 士气已满，先消耗一些再来吧
        DialogManager.ShowToast(lang.transstr("greensward_morale_supply_moralelimit", lang.transstr(CurrencyNameMap.morale)))
        return
    end

    if self.model:GetLeftTimes() <= 0 then
        DialogManager.ShowToastByLang("greensward_morale_supply_rcvlimit") -- 今日领取次数已达上限
        return
    end

    self.view:coroutine(function()
        local response = req.greenswardAdventureRcvMorales()
        if api.success(response) then
            local data = response.val
            local contents = data.contents
            if not table.isEmpty(contents) then
                CongratulationsPageCtrl.new(contents)
            end
            self.model:UpdateAfterGetBatch(data)
            self.view:UpdateAfterGetBatch()
        end
    end)
end

-- 一键赠送
function GreenswardMoraleSupplyCtrl:OnBtnSendBatch()
    if not self.model:HasNotSend() then
        DialogManager.ShowToastByLang("greensward_morale_supply_allsent") -- 已全部赠送
        return
    end

    self.view:coroutine(function()
        local response = req.greenswardAdventureSendMorales()
        if api.success(response) then
            local data = response.val
            DialogManager.ShowToastByLang("greensward_morale_supply_sent") -- 赠送成功
            self.model:UpdateAfterSendBatch(data)
            self.view:UpdateAfterSendBatch()
        end
    end)
end

function GreenswardMoraleSupplyCtrl:GetStatusData()
    return self.model
end

return GreenswardMoraleSupplyCtrl

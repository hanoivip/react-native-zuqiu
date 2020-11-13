local Mall = require("data.Mall")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local StoreModel = require("ui.models.store.StoreModel")
local StoreItemModel = require("ui.models.store.StoreItemModel")
local CommonConstants = require("ui.common.CommonConstants")
local FancyGachaInfoBarCtrl = class()


function FancyGachaInfoBarCtrl:ctor(infoBarView, param)
    self.playerInfoModel = nil
    self.infoBarView = infoBarView
    self.param = param or {}
    self:Init()
end

function FancyGachaInfoBarCtrl:Init()
    self.playerInfoModel = PlayerInfoModel.new()
    self:InitView()
    if not self.param.isHideFancyTicket1 and not self.param.isHideFancyTicket10 then
        self:InitMallData()
    end
end

function FancyGachaInfoBarCtrl:InitView()
    self.infoBarView:InitView(self.param)
    self.infoBarView.clickBack = function() self:OnBtnBack() end
    self.infoBarView.clickDiamond = function() self:OnBtnDiamond() end
    self.infoBarView.clickFancyOneTicket = function() self:OnBtnFancyOneTicket() end
    self.infoBarView.clickFancyTenTicket = function() self:OnBtnFancyTenTicket() end
    self.infoBarView.clickFancyPiece = function() self:OnBtnItem(34) end
    self.infoBarView.clickFs = function() self:OnBtnItem(33) end
    self.infoBarView.clickMoney = function() self:OnBtnMoney() end
    self.infoBarView:EventPlayerInfo(self.playerInfoModel)
    self.infoBarView:EventItemListInfo()
end

function FancyGachaInfoBarCtrl:RegOnBtnBack(func)
    if type(func) == "function" then
        self.infoBarView.clickBack = func
    end
end

function FancyGachaInfoBarCtrl:Refresh()
end

function FancyGachaInfoBarCtrl:OnBtnBack()
    res.PopSceneImmediate()
end

function FancyGachaInfoBarCtrl:OnBtnDiamond()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
end

function FancyGachaInfoBarCtrl:OnBtnMoney()
    res.PushScene("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.ITEM)
end

function FancyGachaInfoBarCtrl:OnBtnFancyOneTicket()
    for i, v in pairs(self.itemDatas) do
        if v.picIndex == tostring(CommonConstants.FancyOneTicket) then
            local model = StoreItemModel.new(v)
            res.PushDialog("ui.controllers.store.StoreItemDetailMultiCtrl", model)
        end
    end
end

function FancyGachaInfoBarCtrl:OnBtnFancyTenTicket()
    for i, v in pairs(self.itemDatas) do
        if v.picIndex == tostring(CommonConstants.FancyTenTicket) then
            local model = StoreItemModel.new(v)
            res.PushDialog("ui.controllers.store.StoreItemDetailMultiCtrl", model)
        end
    end
end

function FancyGachaInfoBarCtrl:OnBtnItem(id)
    local MenuType = require("ui.controllers.itemList.MenuType")
    local ItemModel = require("ui.models.ItemModel")
    local itemModel = ItemModel.new(id)
    if id == CommonConstants.FancyPiece then
        res.PushDialog("ui.controllers.fancy.fancyStore.FancyPieceDetailCtrl", itemModel)
    else
        res.PushDialog("ui.controllers.itemList.OtherItemDetailCtrl", MenuType.ITEM, itemModel)
    end
end

function FancyGachaInfoBarCtrl:InitMallData()
    clr.coroutine(function()
        local response = req.storeItemList(nil, nil, true)
        if api.success(response) then
            local data = response.val
            local itemList = { }
            for id, item in pairs(data) do
                local mallData = Mall[tostring(id)]
                if mallData then
                    table.merge(item, mallData)
                    item.id = id
                    table.insert(itemList, item)
                end
            end
            StoreModel.InitData(StoreModel.MenuTags.ITEM, itemList)
            self.itemDatas = StoreModel.GetItemDatas(StoreModel.MenuTags.ITEM)
        end
    end)
end

return FancyGachaInfoBarCtrl


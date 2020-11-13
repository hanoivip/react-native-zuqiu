local AssetFinder = require("ui.common.AssetFinder")
local ItemModel = require("ui.models.ItemModel")
local CommonConstants = require("ui.common.CommonConstants")
local ArenaMedalType = require("ui.scene.arena.ArenaMedalType")
local ArenaModel = require("ui.models.arena.ArenaModel")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")
local MenuType = require("ui.controllers.itemList.MenuType")
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local LimitType = require("ui.scene.itemList.LimitType")
local ItemPlateType = require("ui.scene.itemList.ItemPlateType")
local ArenaItemView = class(unity.base)

function ArenaItemView:ctor()
    self.icon = self.___ex.icon
    self.nameTxt = self.___ex.nameTxt
    self.buyBtn = self.___ex.buyBtn
    self.moneyImg = self.___ex.moneyImg
    self.priceTxt = self.___ex.priceTxt
    self.iconBGImg = self.___ex.iconBGImg
    self.iconBtn = self.___ex.iconBtn
    self.efftectSS = self.___ex.efftectSS
    self.effectA = self.___ex.effectA
    self.effectS = self.___ex.effectS
    self.effectB = self.___ex.effectB
end

function ArenaItemView:InitView(data)
    self.data = data
    self.nameTxt.text = data.name
    self.priceTxt.text = "x" .. data.price.num
    local itemModel = ItemModel.new(data.item.id)
    self.icon.overrideSprite = AssetFinder.GetItemIcon(itemModel:GetIconIndex())
    local medalType = data.price["type"]
    self.moneyImg.overrideSprite = AssetFinder.GetArenaStoreMoneyIcon(ArenaMedalType[medalType])
    self.iconBGImg.overrideSprite = AssetFinder.GetItemQualityBoard(itemModel:GetQuality())

    self.iconBtn:regOnButtonClick(function ()
        if itemModel:GetId() == tostring(CommonConstants.OneTicket) or itemModel:GetId() == tostring(CommonConstants.TenTicket) then
             res.PushDialog("ui.controllers.itemList.ItemDetailCtrl", MenuType.ITEM, itemModel, ItemOriginType.ITEMLIST)
        else
            res.PushDialog("ui.controllers.arena.store.ArenaStoreItemPopCtrl", itemModel, true)
        end
    end)

    self.buyBtn:regOnButtonClick(function ()
        local currentMedalNum = ArenaModel.new():GetArenaMedal(medalType)
        local limitAmount = math.floor(currentMedalNum / data.price.num)
        if limitAmount < 1 then
            local tip = "not_enough_" .. medalType
            DialogManager.ShowToast(lang.trans(tip))
            return
        end
        local args = {
            currencyType = medalType,
            price = data.price.num,
            plateType = ItemPlateType.OrdinaryItemMultiWithMax,
            boughtTime = 0,
            itemId = data.item.id,
            limitAmount = limitAmount,
            limitType = LimitType.NoLimit
        }

        local function purchaseCallback(num)
            self:BuyStoreItem(num)
        end
        res.PushDialog("ui.controllers.itemList.ItemPurchaseCtrl", args, function (num)
            purchaseCallback(num)
        end)
    end)

    GameObjectHelper.FastSetActive(self.effectB, tonumber(data.ID) == 1)
    GameObjectHelper.FastSetActive(self.effectA, tonumber(data.ID) == 2)
    GameObjectHelper.FastSetActive(self.effectS, tonumber(data.ID) == 3)
    GameObjectHelper.FastSetActive(self.efftectSS, tonumber(data.ID) == 4)
end

function ArenaItemView:BuyStoreItem(num)
    local arenaModel = ArenaModel.new()
    local medalType = self.data.price["type"]
    local needPrice = self.data.price.num
    local currentMedalNum = arenaModel:GetArenaMedal(medalType)
    if currentMedalNum >= needPrice then 
        clr.coroutine(function ()
            local response = req.buyArenaStore(self.data.ID, num)
            if api.success(response) then
                CongratulationsPageCtrl.new(response.val.contents)
                -- 这里需更改货币的总额
                local data = response.val
                if data.cost.type == "silverM" then
                    arenaModel:SetSilverMoney(data.cost.curr_num)
                elseif data.cost.type == "goldenM" then
                    arenaModel:SetGoldMoney(data.cost.curr_num)
                elseif data.cost.type == "blackM" then
                    local blackM = arenaModel:GetBlackGoldMoney()
                    arenaModel:SetBlackGoldMoney(data.cost.curr_num)
                elseif data.cost.type == "platinumM" then
                    arenaModel:SetPlatinaMoney(data.cost.curr_num)
                elseif data.cost.type == "peakChampionM" then
                    arenaModel:SetPeakChampionMoney(data.cost.curr_num)
                end
            end
        end)
    else
        local tip = "not_enough_" .. medalType
        DialogManager.ShowToast(lang.trans(tip))
    end
end

return ArenaItemView
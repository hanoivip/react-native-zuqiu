local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local ItemPlateType = require("ui.scene.itemList.ItemPlateType")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local ItemModel = require("ui.models.ItemModel")
local ProbabilityType = require("ui.scene.itemList.ProbabilityType")
local LimitType = require("ui.scene.itemList.LimitType")
local ItemType = require("ui.scene.itemList.ItemType")
local EquipModel = require("ui.models.EquipModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local EquipModel = require("ui.models.EquipModel")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local GreenswardItemModel = require("ui.models.greensward.item.GreenswardItemModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local VIP = require("data.VIP")
local ArenaModel = require("ui.models.arena.ArenaModel")
local Vector2 = clr.UnityEngine.Vector2
local Vector3 = clr.UnityEngine.Vector3
local CommonConstants = require("ui.common.CommonConstants")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local FancyCardModel = require("ui.models.fancy.FancyCardModel")

local ItemPurchaseView = class(unity.base)

function ItemPurchaseView:ctor()
    self.giftboxContent = self.___ex.giftboxContent
    self.multiPurchaseContent = self.___ex.multiPurchaseContent
    self.purchaseBtn = self.___ex.purchaseBtn
    self.closeBtn = self.___ex.closeBtn
    self.minusBtn = self.___ex.minusBtn
    self.plusBtn = self.___ex.plusBtn
    self.maxBtn = self.___ex.maxBtn
    self.itemNameTxt = self.___ex.itemNameTxt
    self.priceTxt = self.___ex.priceTxt
    self.moneyImg = self.___ex.moneyImg
    self.itemArea = self.___ex.itemArea
    self.giftboxArea = self.___ex.giftboxArea
    self.buyBtnTxt = self.___ex.buyBtnTxt
    self.buyBtnImg = self.___ex.buyBtnImg
    self.tipTxt = self.___ex.tipTxt
    self.timeTxt = self.___ex.timeTxt
    self.numTxt = self.___ex.numTxt
    self.price1Txt = self.___ex.price1Txt
    self.money1Img = self.___ex.money1Img
    self.buyTipText =self.___ex.buyTipText
    -- 附带额外信息
    self.txtAttach = self.___ex.txtAttach
    -- 默认是显示的状态
    self.isMultiPurchaseContentHidden = false

    self.number = 1
    self.MaxBuyCount = 999

    DialogAnimation.Appear(self.transform, nil)
end

function ItemPurchaseView:InitView(data)
    self.boughtTime = data.boughtTime
    self.limitAmount = data.limitAmount
    self.currencyType = data.currencyType
    self.itemId = data.itemId
    self.price = data.price
    self.limitType = data.limitType
    self.plateType = data.plateType
    self.itemType = data.itemType or ItemType.Item
    self.contents = data.contents
    self.hideLimitText = data.hideLimitText or false
    self.vip = data.vip or 0
    self.tips = data.tips
    self.attachInfo = data.attachInfo
    self.ownerCurrency = data.ownerCurrency
    self:SaveMulType(data)

    if self.hideLimitText then
        GameObjectHelper.FastSetActive(self.timeTxt.gameObject, false)
    end
    
    if self.plateType == ItemPlateType.OrdinaryItemOne then
        self.transform.sizeDelta = Vector2(540, 343.7)
        self.giftboxContent:SetActive(false)
        self.multiPurchaseContent:SetActive(false)
        self.isMultiPurchaseContentHidden = true
        self:InitOrdinaryView()
    elseif self.plateType == ItemPlateType.OrdinaryItemMulti then
        self.transform.sizeDelta = Vector2(540, 445)
        self.giftboxContent:SetActive(false)
        self:InitOrdinaryView()
    elseif self.plateType == ItemPlateType.OrdinaryItemMultiWithMax then
        self.transform.sizeDelta = Vector2(540, 445)
        self.giftboxContent:SetActive(false)
        self.maxBtn.gameObject:SetActive(true)
        self:InitOrdinaryView()
    elseif self.plateType == ItemPlateType.GiftBoxOne then
        self.transform.sizeDelta = Vector2(540, 510)
        self.multiPurchaseContent:SetActive(false)
        self.isMultiPurchaseContentHidden = true
        self:InitGiftBoxMultiView()
    elseif self.plateType == ItemPlateType.GiftBoxMulti then
        self:InitGiftBoxMultiView()
    elseif self.plateType == ItemPlateType.GiftBoxMultiWithMax then
        self.maxBtn.gameObject:SetActive(true)
        self:InitGiftBoxMultiView()
    end

    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)

    local pressAddData = {
        acceleration = 1,
        clickCallback = function()
            self:OnClickMinusBtn()
        end,
        durationCallback = function(count)
            self:OnClickMinusBtn()
        end,
    }
    self.minusBtn:regOnButtonPressing(pressAddData)

    pressAddData = {
        acceleration = 1,
        clickCallback = function()
            self:OnClickPlusBtn()
        end,
        durationCallback = function(count)
            self:OnClickPlusBtn()
        end,
    }
    self.plusBtn:regOnButtonPressing(pressAddData)

    self.plusBtn:regOnButtonUp(function()
        self.hasShowToast = false
    end)

    self.maxBtn:regOnButtonClick(function ()
        self.number = self.limitAmount - self.boughtTime
        self.numTxt.text = tostring(self.number)
        self.buyBtnTxt.text = "x" .. string.formatIntWithTenThousands(self.price * self.number)
    end)
    if data and data.vip and data.vip ~= 0 then
        local str = self:GetBuyTipVIPStr(data.vip)
        self.buyTipText.text = lang.transstr("timeLimit_giftBag_desc1", str)
    else
        self.buyTipText.text = ""
    end

    if self.attachInfo and string.len(self.attachInfo) > 0 then
        self.txtAttach.text = self.attachInfo
    else
        self.txtAttach.text = ""
    end
end

function ItemPurchaseView:GetBuyTipVIPStr(vipValue)
    local maxVIPValue = self:GetMaxVIPLevelValue()
    local str = tostring(vipValue)
    if tonumber(vipValue) < tonumber(maxVIPValue) then
        str = str .. lang.transstr("timeLimit_giftBag_desc3")
    end
    return str
end

function ItemPurchaseView:GetMaxVIPLevelValue()
    local maxVIPValue = cache.getMaxVIPLevelValue()
    if maxVIPValue then return maxVIPValue end

    maxVIPValue = 0
    for k, v in pairs(VIP) do
        if tonumber(v.vipLv) > maxVIPValue then
            maxVIPValue = tonumber(v.vipLv)
        end
    end
    cache.setMaxVIPLevelValue(maxVIPValue)
    return maxVIPValue
end

function ItemPurchaseView:SaveMulType(data)
    if data.mulCurrencyTypes then
        self.price = data.mulPrices["other"]
        self.price1 = data.mulPrices["honor"]
        self.currencyType = data.mulCurrencyTypes["other"]
        self.currencyType1 = data.mulCurrencyTypes["honor"]
    end
end

function ItemPurchaseView:CheckMulType()
    if self.currencyType1 then
        self.price1Txt.text = "x" ..  string.formatIntWithTenThousands(self.price1)
        if self.currencyType1 == CurrencyType.HonorDiamond then
            self.money1Img.material = nil
        end
        self.money1Img.overrideSprite = res.LoadRes(CurrencyImagePath[self.currencyType1])
        self.buyBtnImg.gameObject:SetActive(false)
        self.buyBtnTxt.transform.localPosition = clr.UnityEngine.Vector3.zero
        self.buyBtnTxt.text = lang.trans("buy")
    else
        self.price1Txt.gameObject:SetActive(false)
    end
end

function ItemPurchaseView:InitOrdinaryView()
    self.priceTxt.text = "x" ..  string.formatIntWithTenThousands(self.price)
    self.moneyImg.overrideSprite = res.LoadRes(CurrencyImagePath[self.currencyType])
    self.buyBtnImg.overrideSprite = res.LoadRes(CurrencyImagePath[self.currencyType])
    self.buyBtnTxt.text = "x" ..  string.formatIntWithTenThousands(self.price)
    self:CheckMulType()
    if self.limitType == LimitType.NoLimit then
        self.timeTxt.text = ""
    elseif self.limitType == LimitType.DayLimit then
        self.timeTxt.text = lang.trans("buy_times_limit_everyday_2", self.limitAmount - self.boughtTime, self.limitAmount)
    elseif self.limitType == LimitType.ForeverLimit or
            self.limitType == LimitType.TimeLimit or
            self.limitType == LimitType.ExistLimit or
            self.limitType == LimitType.PlayerLimit then
        self.timeTxt.text = lang.trans("buy_times_limit_permanently_2", self.limitAmount - self.boughtTime, self.limitAmount)
    end

    local contents = {}
    if self.itemType == ItemType.Item then
        local itemModel = ItemModel.new(self.itemId)
        self.itemNameTxt.text = itemModel:GetName()
        local isValid = itemModel:HasValid()
        if isValid then
            self.itemNameTxt.text = itemModel:GetName()
            local tipType = itemModel:GetProbability()
            if tipType == ProbabilityType.Must then
                self.tipTxt.text = lang.trans("reward_Tip")
            elseif tipType == ProbabilityType.Options then
                self.tipTxt.text = lang.trans("reward_tip_1")
            elseif tipType == ProbabilityType.Random then
                self.tipTxt.text = lang.trans("reward_tip_2")
            end
        end

        contents.item = {}
        table.insert(contents.item, {id = tostring(self.itemId), num = 1})
    elseif self.itemType == ItemType.Paster then
        local pasterModel = CardPasterModel.new()
        pasterModel:InitWithStatic(self.itemId)
        self.itemNameTxt.text = pasterModel:GetName()

        contents.paster = {}
        table.insert(contents.paster, {id = tostring(self.itemId), num = 1})
    elseif self.itemType == ItemType.Card then
        self.itemNameTxt.text = StaticCardModel.new(self.itemId):GetName()

        contents.card = {}
        table.insert(contents.card, {id = tostring(self.itemId), num = 1})
    elseif self.itemType == ItemType.CardPiece then
        local pieceModel = CardPieceModel.new()
        pieceModel:InitWithStatic(self.itemId)
        local pieceEx = ""
        if self.itemId ~= "generalPiece" then
            pieceEx = lang.transstr("piece")
        end
        self.itemNameTxt.text = pieceModel:GetName() .. pieceEx

        contents.cardPiece = {}
        table.insert(contents.cardPiece, {id = tostring(self.itemId), num = 1})
    elseif self.itemType == ItemType.PasterPiece then
        local pieceModel = CardPasterPieceModel.new()
        pieceModel:InitWithStatic(self.itemId)
        self.itemNameTxt.text = pieceModel:GetName()

        contents.pasterPiece = {}
        table.insert(contents.pasterPiece, {id = tostring(self.itemId), num = 1})
    elseif self.itemType == ItemType.Eqs then
        self.itemNameTxt.text = EquipModel.new(self.itemId):GetName()
        contents.eqs = {}
        table.insert(contents.eqs, {id = tostring(self.itemId), num = 1})
    elseif self.itemType == ItemType.Medal then
        local playerMedalModel = PlayerMedalModel.new()
        playerMedalModel:InitWithStatic(self.itemId)
        self.itemNameTxt.text = playerMedalModel:GetName()
    elseif self.itemType == ItemType.AdvItem then
        self.itemNameTxt.text = GreenswardItemModel.new(self.itemId):GetName()
        contents.advItem = {}
        table.insert(contents.advItem, {id = tostring(self.itemId), num = 1})
    elseif CurrencyNameMap[self.itemType] ~= nil then
        local currencyNum, currencyName = self:GetPlayerCurrencyNum(self.itemType)
        self.itemNameTxt.text = tostring(currencyName)
    elseif self.itemType == ItemType.FancyCard then
        local itemModel = FancyCardModel.new()
        itemModel:InitData(self.itemId)
        self.itemNameTxt.text = itemModel:GetName()
        contents.fancyCard = {}
        table.insert(contents.fancyCard, {id = tostring(self.itemId), num = 1})
        self.itemArea.localScale = Vector3(0.68, 0.68, 1)
        self.itemArea.localPosition = Vector3(-205, 25, 1)
    end

    local rewardParams = {
        parentObj = self.itemArea,
        rewardData = self.contents or contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
end

function ItemPurchaseView:InitGiftBoxCommonView()
    self.priceTxt.text = "x" ..  string.formatIntWithTenThousands(self.price)
    self.moneyImg.overrideSprite = res.LoadRes(CurrencyImagePath[self.currencyType])
    self.buyBtnImg.overrideSprite = res.LoadRes(CurrencyImagePath[self.currencyType])
    self.buyBtnTxt.text = "x" ..  string.formatIntWithTenThousands(self.price)
    self:CheckMulType()
    if self.limitType == LimitType.NoLimit then
        self.timeTxt.text = ""
    elseif self.limitType == LimitType.DayLimit then
        self.timeTxt.text = lang.trans("buy_times_limit_everyday_2", self.limitAmount - self.boughtTime, self.limitAmount)
    elseif self.limitType == LimitType.ForeverLimit or
            self.limitType == LimitType.TimeLimit or
            self.limitType == LimitType.ExistLimit or
            self.limitType == LimitType.PlayerLimit then
        self.timeTxt.text = lang.trans("buy_times_limit_permanently_2", self.limitAmount - self.boughtTime, self.limitAmount)
    end
end

function ItemPurchaseView:InitGiftBoxMultiView()
    self:InitGiftBoxCommonView()
    local contents = {}
    if self.itemType == ItemType.Item then
        contents.item = {}
        table.insert(contents.item, {id = tostring(self.itemId), num = 1})

        local itemModel = ItemModel.new(self.itemId)
        local isValid = itemModel:HasValid()
        if isValid then
            self.itemNameTxt.text = itemModel:GetName()
            local tipType = itemModel:GetProbability()
            if tipType == ProbabilityType.Must then
                self.tipTxt.text = lang.trans("reward_Tip")
            elseif tipType == ProbabilityType.Options then
                self.tipTxt.text = lang.trans("reward_tip_1")
            elseif tipType == ProbabilityType.Random then
                self.tipTxt.text = lang.trans("reward_tip_2")
            end
        end
        self.itemNameTxt.text = itemModel:GetName()
        local giftboxRewardData = itemModel:GetItemContent()
        assert(giftboxRewardData)
        for i, v in ipairs(giftboxRewardData) do
            local rewardParams = {
                parentObj = self.giftboxArea,
                rewardData = v.contents,
                isShowName = false,
                isReceive = false,
                isShowBaseReward = true,
                isShowCardReward = true,
                isShowDetail = true,
            }
            RewardDataCtrl.new(rewardParams)
        end
    elseif self.itemType == ItemType.Paster then
        contents.paster = {}
        table.insert(contents.paster, {id = tostring(self.itemId), num = 1})
    elseif self.itemType == ItemType.Card then
        contents.card = {}
        table.insert(contents.card, {id = tostring(self.itemId), num = 1})
    elseif self.itemType == ItemType.CardPiece then
        contents.cardPiece = {}
        table.insert(contents.cardPiece, {id = tostring(self.itemId), num = 1})
    elseif self.itemType == ItemType.PasterPiece then
        contents.pasterPiece = {}
        table.insert(contents.pasterPiece, {id = tostring(self.itemId), num = 1})
    elseif self.itemType == ItemType.Eqs then
        contents.eqs = {}
        table.insert(contents.eqs, {id = tostring(self.itemId), num = 1})
    elseif self.itemType == ItemType.AdvItem then
        contents.advItem = {}
        table.insert(contents.advItem, {id = tostring(self.itemId), num = 1})
    end

    local rewardParams = {
        parentObj = self.itemArea,
        rewardData = contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
end

function ItemPurchaseView:OnClickPlusBtn()
    local canBuyTime = self.limitType == LimitType.NoLimit and self.MaxBuyCount or self.limitAmount - self.boughtTime
    if self.number >= canBuyTime then
        if not self.hasShowToast then
            if self.tips then
                DialogManager.ShowToast(self.tips)
            else
                DialogManager.ShowToast(lang.trans("can_buy_is_full"))
            end
            self.hasShowToast = true
        end
        return
    end

    local isEnough, notEnoughTip = self:IsCurrencyEnough(true)
    if not isEnough then
        DialogManager.ShowToast(lang.trans("lack_item_tips", notEnoughTip))
        return
    end

    self.number = self.number + 1
    self.numTxt.text = tostring(self.number)
    if not self.currencyType1 then
        self.buyBtnTxt.text = "x" .. string.formatIntWithTenThousands(self.price * self.number)
    end
end

function ItemPurchaseView:IsCurrencyEnough(isPlus)
    local isEnough = true
    local notEnoughTip = ""
    local nextNumber = self.number
    if isPlus then nextNumber = nextNumber + 1 end
    local currencyNum, currencyName = self:GetPlayerCurrencyNum(self.currencyType)
    if nextNumber * self.price > currencyNum then
        isEnough = false
        notEnoughTip = notEnoughTip .. currencyName .. "、"
    end
    if self.currencyType1 then-- 荣誉商店两种货币
        local currencyNum1, currencyName1 = self:GetPlayerCurrencyNum(self.currencyType1)
        if nextNumber * self.price1 > currencyNum1 then
            isEnough = false
            notEnoughTip = notEnoughTip .. currencyName1.. "、"
        end
    end
    if string.len(notEnoughTip) > 0 then
        notEnoughTip = string.sub(notEnoughTip, 1, -4)-- 去掉顿号
    end
    return isEnough, notEnoughTip
end

function ItemPurchaseView:GetPlayerCurrencyNum(currencyType)
    local num = 0
    local currencyName = ""
    if not currencyType then
        return num, currencyName
    end
    if self.ownerCurrency and type(self.ownerCurrency) == "number" then
        num = self.ownerCurrency
    end
    local playerInfoModel = PlayerInfoModel.new()
    local arenaModel = ArenaModel.new()
    if currencyType == CurrencyType.Diamond then-- 钻石
        num = playerInfoModel:GetDiamond()
    elseif currencyType == CurrencyType.Money then-- 欧元
        num = playerInfoModel:GetMoney()
    elseif currencyType == CurrencyType.LadderDiamond then-- 天梯币
        num = playerInfoModel:GetLadderPoint()
    elseif currencyType == CurrencyType.BlackDiamond then-- 豪门币
        num = playerInfoModel:GetBlackDiamond()
    elseif currencyType == CurrencyType.PeakDiamond then-- 巅峰币
        num = playerInfoModel:GetPeakDiamond()
    elseif currencyType == CurrencyType.HonorDiamond then-- 荣耀币
        num = playerInfoModel:GetHonorDiamond()
    elseif currencyType == CurrencyType.CompeteCoin then-- 争霸币
        num = playerInfoModel:GetCompeteCurrency()
    elseif currencyType == CurrencyType.HeroHallSmd then-- 殿堂精华
        num = playerInfoModel:GetHeroHallSmdCurrency()
    elseif currencyType == CurrencyType.HeroHallSmb then-- 殿堂升阶石
        num = playerInfoModel:GetHeroHallSmbCurrency()
    elseif currencyType == CurrencyType.SilverM then-- 白银币
        num = arenaModel:GetSilverMoney()
    elseif currencyType == CurrencyType.GoldenM then-- 黄金币
        num = arenaModel:GetGoldMoney()
    elseif currencyType == CurrencyType.BlackM then-- 黑金币
        num = arenaModel:GetBlackGoldMoney()
    elseif currencyType == CurrencyType.PlatinumM then-- 白金币
        num = arenaModel:GetPlatinaMoney()
    elseif currencyType == CurrencyType.peakChampionM then --红金币
        num = arenaModel:GetPeakChampionMoney()
    elseif currencyType == CurrencyType.Fan then-- 球迷币
        local fanCoinModel = ItemModel.new(CommonConstants.FanCoin)
        num = fanCoinModel:GetItemNum()
    elseif currencyType == CurrencyType.Morale then --[绿茵征途]士气
        num = playerInfoModel:GetMorale()
    elseif currencyType == CurrencyType.Fight then -- [绿茵征途]斗志
        num = playerInfoModel:GetFight()
    elseif currencyType == CurrencyType.Fs then --[梦幻卡]球魂
        num = playerInfoModel:GetFS()
    elseif currencyType == CurrencyType.FancyPiece then -- [梦幻卡]梦幻卡碎片
        num = playerInfoModel:GetFancyPiece()
    end
    if CurrencyNameMap[currencyType] == nil then
        currencyName = ""
    else
        currencyName = lang.transstr(CurrencyNameMap[currencyType]) or ""
    end
    return num, currencyName
end

function ItemPurchaseView:OnClickMinusBtn()
    if self.number <= 1 then
        return
    end
    self.number = self.number - 1
    self.numTxt.text = tostring(self.number)
    if not self.currencyType1 then
        self.buyBtnTxt.text = "x" .. string.formatIntWithTenThousands(self.price * self.number)
    end
end

function ItemPurchaseView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return ItemPurchaseView

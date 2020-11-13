local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Color = UnityEngine.Color
local EquipItemModel = require("ui.models.cardDetail.EquipItemModel")
local ItemModel = require("ui.models.cardDetail.ItemModel")
local EquipPieceModel = require("ui.models.cardDetail.EquipPieceModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local CouponModel = require("ui.models.activity.CouponModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local RedPacketModel = require("ui.models.RedPacketModel")
local ExchangeItemModel = require("ui.models.cardDetail.ExchangeItemModel")
local GreenswardItemModel = require("ui.models.greensward.item.GreenswardItemModel")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")
local CoachItemMapModel = require("ui.models.coach.common.CoachItemMapModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")
local MarblesItemModel = require("ui.models.activity.marbles.MarblesItemModel")
local CommonConstants = require("ui.common.CommonConstants")
local FancyCardModel = require("ui.models.fancy.FancyCardModel")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local MailRewardType = require("ui.scene.mail.MailRewardType")

local RewardDataCtrl = class()

--- 构建奖励的道具
-- @param params示例如下；
-- {
--     -- 父节点
--     parentObj = xxx,
--     -- 奖励数据
--     rewardData = {xxx},
--     -- 是否显示名称
--     isShowName = true,
--     -- 是否已获得
--     isReceive = true,
--     -- 是否显示已拥有标签
--     isShowSymbol = true,
--     -- 是否显示基础奖励
--     isShowBaseReward = false,
--     -- 是否显示卡牌奖励
--     isShowCardReward = false,
--     -- 是否点击显示详情
--     isShowDetail = false,
--     -- 是否显示右上角数字
--     hideCount = false
--     -- 道具装备参数
--     itemParams = {
--         -- 名称颜色
--         nameColor = Color.white,
--         -- 名称阴影颜色
--         nameShadowColor = Color.black,
--         -- 个数字号
--         numFont = 14,
--     },
--     -- 是否隐藏等级
--     isHideLvl = true,
--     --是否顯示頭像背景
--     isShowBg = false
--     -- 是否保留生成的itemModel，卡牌无法保存
--     isSavedItemModel = false
-- }
function RewardDataCtrl:ctor(params)
    if type(params) ~= "table" then
        return
    end

    self.parentTrans = params.parentObj and params.parentObj.transform or nil
    self.rewardData = params.rewardData
    if self.parentTrans == nil or self.rewardData == nil then
        return
    end

    self.isShowName = params.isShowName or false
    self.isReceive = params.isReceive or false
    self.isShowBaseReward = params.isShowBaseReward or false
    self.isShowCardReward = params.isShowCardReward or false
    self.isShowDetail = params.isShowDetail or false
    self.isShowCount = not params.hideCount
    self.isShowSymbol = params.isShowSymbol
    self.itemParams = params.itemParams
    self.isShowCardPieceBeforeItem = params.isShowCardPieceBeforeItem or false
    self.isHideLvl = params.isHideLvl or false

    self.cardLv = params.cardLv or 1

    self.isSavedItemModel = params.isSavedItemModel or false
    self.isShowBg = params.isShowBg or false
    self.coachItemMapModel = CoachItemMapModel.new()

    -- 绿茵征途道具
    self.greenswardItemMapModel = GreenswardItemMapModel.new()

    self.savedItemModels = nil

    self:BuildReward()
end

function RewardDataCtrl:BuildReward()
    if self.isShowBaseReward then
        self:BuildBaseReward()
    end
    if self.isShowCardReward then
        self:BuildCardReward()
    end
    if self.isShowCardPieceBeforeItem then
        self:BuildCardPieceReward()
    end
    self:BuildItemReward()
    self:BuildExchangeItemReward()
    self:BuildMedalReward()
    self:BuildEquipReward()
    self:BuildEquipPieceReward()
    self:BuildRedPacketReward()
    if not self.isShowCardPieceBeforeItem then
        self:BuildCardPieceReward()
    end
    self:BuildPlayerPieceReward()
    self:BuildCouponReward()
    self:BuildPasterReward()
    self:BuildCtiReward()
    self:BuildAdventureItemReward()
    self:BuildMarblesItemReward()
    self:BuildFancyCardReward()
end

--- 构建基础奖励，货币类
function RewardDataCtrl:BuildBaseReward()
    -- 欧元
    if self.rewardData.m ~= nil and self.rewardData.m ~= 0 then
        if not self.rewardData.mDetail then
            local itemModel = ItemModel.new()
            itemModel:InitWithMoneyAddNum(self.rewardData.m)
            self:InstantiateItemBox(itemModel, CurrencyType.Money)
        else
            for i, v in ipairs(self.rewardData.mDetail) do
                local itemModel = ItemModel.new()
                itemModel:InitWithMoneyAddNum(v)
                self:InstantiateItemBox(itemModel, "mDetail")
            end
        end
    end

    -- 钻石
    if self.rewardData.d ~= nil and self.rewardData.d ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithDiamondAddNum(self.rewardData.d)
        self:InstantiateItemBox(itemModel, CurrencyType.Diamond)
    end

    -- 体力
    if self.rewardData.sp ~= nil and self.rewardData.sp ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithStrengthAddNum(self.rewardData.sp)
        self:InstantiateItemBox(itemModel, CurrencyType.Strength)
    end

    -- 经验
    if type(self.rewardData.exp) == "number" then
        local itemModel = ItemModel.new()
        itemModel:InitWithExpAddNum(self.rewardData.exp)
        self:InstantiateItemBox(itemModel, CurrencyType.Exp)
    elseif type(self.rewardData.exp) == "table" and tonumber(self.rewardData.exp.addExp) > 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithExpAddNum(self.rewardData.exp.addExp)
        self:InstantiateItemBox(itemModel, CurrencyType.Exp)
    end

    -- 友情
    if self.rewardData.fp ~= nil and self.rewardData.fp ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithFriendship(self.rewardData.fp)
        self:InstantiateItemBox(itemModel, CurrencyType.FriendShip)
    end

    -- 天梯荣誉
    if self.rewardData.lp ~= nil and self.rewardData.lp ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithLadderHonorAddNum(self.rewardData.lp)
        self:InstantiateItemBox(itemModel, CurrencyType.LadderDiamond)
    end

    -- 意志精华
    if self.rewardData.sd ~= nil and self.rewardData.sd ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithStardustAddNum(self.rewardData.sd)
        self:InstantiateItemBox(itemModel, CurrencyType.Stardust)
    end

    -- 巨星气质
    if self.rewardData.bs ~= nil and self.rewardData.bs ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithBenedictionAddNum(self.rewardData.bs)
        self:InstantiateItemBox(itemModel, CurrencyType.Benediction)
    end

    -- 巅峰币
    if self.rewardData.pp ~= nil and self.rewardData.pp ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithPeakPointAddNum(self.rewardData.pp)
        self:InstantiateItemBox(itemModel, CurrencyType.PeakDiamond)
    end

    -- 梦幻碎片
    if self.rewardData.dp ~= nil and self.rewardData.dp ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithDreamPieceAddNum(self.rewardData.dp)
        self:InstantiateItemBox(itemModel, CurrencyType.DreamPiece)
    end

    -- 梦幻币
    if self.rewardData.dc ~= nil and self.rewardData.dc ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithDreamCoinAddNum(self.rewardData.dc)
        self:InstantiateItemBox(itemModel, CurrencyType.DreamCoin)
    end

    -- 争霸币
    if self.rewardData.wtc ~= nil and self.rewardData.wtc ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithWtcAddNum(self.rewardData.wtc)
        self:InstantiateItemBox(itemModel, CurrencyType.CompeteCoin)
    end

    -- 殿堂精华
    if self.rewardData.smd ~= nil and self.rewardData.smd ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithSmdAddNum(self.rewardData.smd)
        self:InstantiateItemBox(itemModel, CurrencyType.HeroHallSmd)
    end

    -- 殿堂升阶石
    if self.rewardData.smb ~= nil and self.rewardData.smb ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithSmbAddNum(self.rewardData.smb)
        self:InstantiateItemBox(itemModel, CurrencyType.HeroHallSmb)
    end

    --吉祥物亲密度道具
    if self.rewardData.jxw ~= nil and self.rewardData.jxw ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithJxwAddNum(self.rewardData.jxw)
        self:InstantiateItemBox(itemModel, CurrencyType.JiXiangWu)
    end

    -- 执教经验书
    if self.rewardData.ce ~= nil and self.rewardData.ce ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithCeAddNum(self.rewardData.ce)
        self:InstantiateItemBox(itemModel, CurrencyType.CredentialExp)
    end

    -- 教练天赋点
    if self.rewardData.ctp ~= nil and self.rewardData.ctp ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithCtpAddNum(self.rewardData.ctp)
        self:InstantiateItemBox(itemModel, CurrencyType.CoachTalentPoint)
    end

    -- 助理教练经验书
    if self.rewardData.ace ~= nil and self.rewardData.ace ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithAceAddNum(self.rewardData.ace)
        self:InstantiateItemBox(itemModel, CurrencyType.AssistantCoachExp)
    end

    -- [绿茵征途]士气
    if self.rewardData.morale ~= nil and self.rewardData.morale ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithMoraleAddNum(self.rewardData.morale)
        self:InstantiateItemBox(itemModel, CurrencyType.Morale)
    end

    -- [绿茵征途]斗志
    if self.rewardData.fight ~= nil and self.rewardData.fight ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithFightAddNum(self.rewardData.fight)
        self:InstantiateItemBox(itemModel, CurrencyType.Fight)
    end

    -- 阶梯商店购物券
    if self.rewardData.sst and type(self.rewardData.sst) == "table" then
        for i, v in ipairs(self.rewardData.sst) do
            local itemModel = ItemModel.new()
            itemModel:InitWithStageStoreTicket(v)
            self:InstantiateItemBox(itemModel, CurrencyType.StageStoreTicket)
        end
    end

    -- 多日礼盒积分
    if self.rewardData.dayGiftScore ~= nil and self.rewardData.dayGiftScore ~= 0 then
        local itemModel = ItemModel.new()
        local cacheData = {}
        cacheData.id = CommonConstants.DayGiftScore
        cacheData.add = self.rewardData.dayGiftScore
        itemModel:InitWithCache(cacheData)
        self:InstantiateItemBox(itemModel, CurrencyType.DayGiftScore)
    end

    -- 多日礼盒任选币
    if self.rewardData.dayGiftCoin ~= nil and self.rewardData.dayGiftCoin ~= 0 then
        local itemModel = ItemModel.new()
        local cacheData = {}
        cacheData.id = CommonConstants.DayGiftCoin
        cacheData.add = self.rewardData.dayGiftCoin
        itemModel:InitWithCache(cacheData)
        self:InstantiateItemBox(itemModel, CurrencyType.DayGiftCoin)
    end

    -- 信封？
    if self.rewardData.envelope and self.rewardData.envelope ~= 0 then
        self:InstantiateEnvelopeBox(self.rewardData.envelope, CurrencyType.Envelope)
    end

     -- 梦幻球魂
    if self.rewardData.fs ~= nil and self.rewardData.fs ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithFsAddNum(self.rewardData.fs)
        self:InstantiateItemBox(itemModel, CurrencyType.Fs)
    end

     -- 梦幻卡碎片
    if self.rewardData.fancyPiece ~= nil and self.rewardData.fancyPiece ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithFancyPieceAddNum(self.rewardData.fancyPiece)
        self:InstantiateFancyPieceBox(itemModel, CurrencyType.FancyPiece)
    end

    -- add other

    -----------------
    -- 查不到相关记录
    if self.rewardData.csp and self.rewardData.csp ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithCsp(self.rewardData.csp)
        self:InstantiateItemBox(itemModel)
    end
end

-- 构建公会红包奖励
function RewardDataCtrl:BuildRedPacketReward()
    if type(self.rewardData.redPacket) == "table" then
        local rpData = self.rewardData.redPacket
        for i, data in ipairs(rpData) do
            local itemModel = ItemModel.new()
            itemModel:InitWithRedPacket(data)
            self:InstantiateItemBox(itemModel, "redPacket")
        end
    end
end

--- 构建活动兑换道具
function RewardDataCtrl:BuildExchangeItemReward()
    if type(self.rewardData.exchangeItem) == "table" then
        local exchangeItemListData = self.rewardData.exchangeItem
        if self.isReceive then
            for i, exchangeItemData in ipairs(exchangeItemListData) do
                local exchangeItemModel = ExchangeItemModel.new()
                exchangeItemModel:InitWithCache(exchangeItemData)
                self:InstantiateExchangeItemBox(exchangeItemModel, MailRewardType.ExchangeItem)
            end
        else
            for i, exchangeItemData in ipairs(exchangeItemListData) do
                local exchangeItemModel = ExchangeItemModel.new()
                local newExchangeItemData = {id = exchangeItemData.id, add = exchangeItemData.num}
                exchangeItemModel:InitWithCache(newExchangeItemData)
                self:InstantiateExchangeItemBox(exchangeItemModel, MailRewardType.ExchangeItem)
            end
        end
    end
end

--- 构建道具奖励
function RewardDataCtrl:BuildItemReward()
    if type(self.rewardData.item) == "table" then
        local itemListData = self.rewardData.item
        if self.isReceive then
            for i, itemData in ipairs(itemListData) do
                local itemModel = ItemModel.new()
                itemModel:InitWithCache(itemData)
                self:InstantiateItemBox(itemModel, MailRewardType.Item)
            end
        else
            for i, itemData in ipairs(itemListData) do
                local itemModel = ItemModel.new()
                local newItemData = {id = itemData.id, add = itemData.num}
                itemModel:InitWithCache(newItemData)
                self:InstantiateItemBox(itemModel, MailRewardType.Item)
            end
        end
    end
end

--- 构建装备奖励
function RewardDataCtrl:BuildEquipReward()
    if type(self.rewardData.eqs) == "table" then
        local equipListData = self.rewardData.eqs
        if self.isReceive then
            for i, itemData in ipairs(equipListData) do
                local equipItemModel = EquipItemModel.new()
                equipItemModel:InitWithCache(itemData)
                self:InstantiateEquipBox(equipItemModel, false, MailRewardType.Equipment)
            end
        else
            for i, itemData in ipairs(equipListData) do
                local equipItemModel = EquipItemModel.new()
                local newItemData = {eid = itemData.id, add = itemData.num}
                equipItemModel:InitWithCache(newItemData)
                self:InstantiateEquipBox(equipItemModel, false, MailRewardType.Equipment)
            end
        end
    end
end

--- 构建装备碎片奖励
function RewardDataCtrl:BuildEquipPieceReward()
    if type(self.rewardData.equipPiece) == "table" then
        local equipPieceListData = self.rewardData.equipPiece
        if self.isReceive then
            for i, itemData in ipairs(equipPieceListData) do
                local equipPieceModel = EquipPieceModel.new()
                equipPieceModel:InitWithCache(itemData)
                self:InstantiateEquipBox(equipPieceModel, true, MailRewardType.EquipPiece)
            end
        else
            for i, itemData in ipairs(equipPieceListData) do
                local equipPieceModel = EquipPieceModel.new()
                local newItemData = {pid = itemData.id, add = itemData.num}
                equipPieceModel:InitWithCache(newItemData)
                self:InstantiateEquipBox(equipPieceModel, true, MailRewardType.EquipPiece)
            end
        end
    end
end

--- 构建球员碎片奖励
function RewardDataCtrl:BuildCardPieceReward()
    if type(self.rewardData.cardPiece) == "table" then
        local cardPieceListData = self.rewardData.cardPiece
        if self.isReceive then
            for i, cardData in ipairs(cardPieceListData) do
                local cardPieceModel = CardPieceModel.new()
                cardPieceModel:InitWithCache(cardData)
                self:InstantiateCardPieceBox(cardPieceModel, MailRewardType.CardPiece)
            end
        else
            for i, cardData in ipairs(cardPieceListData) do
                local cardPieceModel = CardPieceModel.new()
                local newData = {cid = cardData.id, add = cardData.num}
                cardPieceModel:InitWithCache(newData)
                self:InstantiateCardPieceBox(cardPieceModel, MailRewardType.CardPiece)
            end
        end
    end
end

--- 构建球员贴纸碎片奖励
function RewardDataCtrl:BuildPlayerPieceReward()
    if type(self.rewardData.pasterPiece) == "table" then
        local pasterPieceListData = self.rewardData.pasterPiece
        if self.isReceive then
            for i, pasterData in ipairs(pasterPieceListData) do
                local cardPasterPieceModel = CardPasterPieceModel.new()
                cardPasterPieceModel:InitWithCache(pasterData)
                self:InstantiateCardPasterPieceBox(cardPasterPieceModel, MailRewardType.PasterPiece)
            end
        else
            for i, pasterData in ipairs(pasterPieceListData) do
                local cardPasterPieceModel = CardPasterPieceModel.new()
                local newData = {type = pasterData.id, add = pasterData.num}
                cardPasterPieceModel:InitWithCache(newData)
                self:InstantiateCardPasterPieceBox(cardPasterPieceModel, MailRewardType.PasterPiece)
            end
        end
    end
end

--- 构建卡牌奖励
function RewardDataCtrl:BuildCardReward()
    if type(self.rewardData.card) == "table" then
        local cardListData = self.rewardData.card
        if self.isReceive then
            for i, cardData in ipairs(cardListData) do
                self:InstantiateAvatarBox(cardData.cid, cardData.num)
            end
        else
            for i, cardData in ipairs(cardListData) do
                self:InstantiateAvatarBox(cardData.id, cardData.num)
            end
        end
    end
end

-- 构建折扣券奖励
function RewardDataCtrl:BuildCouponReward()
    if type(self.rewardData.coupon) == "table" then
        local couponListData = self.rewardData.coupon
        for i, couponData in ipairs(couponListData) do
            local couponModel = CouponModel.new(couponData)
            self:InstantiateCouponBox(couponModel, "coupon")
        end
    end
end

--- 构建贴纸奖励
function RewardDataCtrl:BuildPasterReward()
    if type(self.rewardData.paster) == "table" then
        local pasterListData = self.rewardData.paster
        if self.isReceive then
            for i, pasterData in ipairs(pasterListData) do
                local cardPasterModel = CardPasterModel.new()
                cardPasterModel:InitWithCache(pasterData)
                self:InstantiatePasterBox(cardPasterModel, MailRewardType.Paster)
            end
        else
            for i, pasterData in ipairs(pasterListData) do
                local cardPasterModel = CardPasterModel.new()
                local newData = {ptcid = pasterData.id, add = pasterData.num}
                cardPasterModel:InitWithCache(newData)
                for index = 1, pasterData.num do
                    self:InstantiatePasterBox(cardPasterModel, MailRewardType.Paster)
                end
            end
        end
    end
end

--- 构建勋章奖励
function RewardDataCtrl:BuildMedalReward()
    if type(self.rewardData.medal) == "table" then
        local medalListData = self.rewardData.medal
        if self.isReceive then
            for i, medalData in ipairs(medalListData) do
                local medalModel = PlayerMedalModel.new()
                medalModel:InitWithCache(medalData)
                self:InstantiateMedalBox(medalModel, MailRewardType.Medal)
            end
        else
            for i, medalData in ipairs(medalListData) do
                local medalModel = PlayerMedalModel.new()
                local newMedalData = {medalId = medalData.id, add = medalData.num}
                medalModel:InitWithCache(newMedalData)
                self:InstantiateMedalBox(medalModel, MailRewardType.Medal)
            end
        end
    end
end

--- 构建教练物品的奖励
--- 原cti指阵型/战术物品，现指所有教练物品
function RewardDataCtrl:BuildCtiReward()
    if self.rewardData.cti ~= nil and type(self.rewardData.cti) == "table" and table.nums(self.rewardData.cti) > 0 then
        for i, reward in ipairs(self.rewardData.cti) do
            self:InstantiateCoachItem(reward, MailRewardType.CoachItem)
        end
    end
end

--- 构建绿茵征途道具
function RewardDataCtrl:BuildAdventureItemReward()
    if type(self.rewardData.advItem) == "table" then
        local adventureItemListData = self.rewardData.advItem
        if self.isReceive then
            for i, adventureItemData in ipairs(adventureItemListData) do
                local itemModel = GreenswardItemModel.new()
                itemModel:InitWithCache(adventureItemData)
                self:InstantiateAdventureItemBox(itemModel, MailRewardType.AdvItem)
            end
        else
            for i, adventureItemData in ipairs(adventureItemListData) do
                local itemModel = GreenswardItemModel.new()
                local newItemData = {id = adventureItemData.id, add = adventureItemData.num}
                itemModel:InitWithCache(newItemData)
                self:InstantiateAdventureItemBox(itemModel, MailRewardType.AdvItem)
            end
        end
    end
end

--- 构建弹球台兑换道具
function RewardDataCtrl:BuildMarblesItemReward()
    if type(self.rewardData.mei) == "table" then
        local marblesExchangeItemList = self.rewardData.mei
        if self.isReceive then
            for i, marblesExchangeItem in ipairs(marblesExchangeItemList) do
                local itemModel = MarblesItemModel.new()
                itemModel:InitWithCache(marblesExchangeItem)
                self:InstantiateMarblesItemBox(itemModel, MailRewardType.MarblesExchangeItem)
            end
        else
            for i, marblesExchangeItem in ipairs(marblesExchangeItemList) do
                local itemModel = MarblesItemModel.new()
                local newItemData = {id = marblesExchangeItem.id, add = marblesExchangeItem.num}
                itemModel:InitWithCache(newItemData)
                self:InstantiateMarblesItemBox(itemModel, MailRewardType.MarblesExchangeItem)
            end
        end
    end
end

--- 实例化道具框&货币
function RewardDataCtrl:InstantiateItemBox(itemModel, rType)
    local itemBoxObj, itemBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/ItemBox.prefab")
    itemBoxObj.transform:SetParent(self.parentTrans, false)
    itemBoxView:InitView(itemModel, itemModel:GetID(), self.isShowName, self.isShowCount, self.isShowDetail, ItemOriginType.OTHER)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            itemBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
        if self.itemParams.numFont ~= nil then
            itemBoxView:SetNumFont(self.itemParams.numFont)
        end
    end

    self:SaveItemModel(rType, itemModel)
end

function RewardDataCtrl:InstantiateCouponBox(couponModel, rType)
    local couponItemObj, couponItemView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/CouponItemBox.prefab")
    couponItemObj.transform:SetParent(self.parentTrans, false)
    couponItemView:InitView(couponModel, true, true, true)

    self:SaveItemModel(rType, couponModel)
end

--- 实例化活动兑换道具
function RewardDataCtrl:InstantiateExchangeItemBox(exchangeItemModel, rType)
    local exchangeItemBoxObj, exchangeItemBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/ExchangeItemBox.prefab")
    exchangeItemBoxObj.transform:SetParent(self.parentTrans, false)
    exchangeItemBoxView:InitView(exchangeItemModel, exchangeItemModel:GetID(), self.isShowName, self.isShowCount, self.isShowDetail, ItemOriginType.OTHER)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            exchangeItemBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
        if self.itemParams.numFont ~= nil then
            exchangeItemBoxView:SetNumFont(self.itemParams.numFont)
        end
    end

    self:SaveItemModel(rType, exchangeItemModel)
end

function RewardDataCtrl:InstantiateEnvelopeBox(envelopeData, rType)
    local itemModel = ItemModel.new()
    itemModel:InitWithEnvelope(envelopeData.id[1])
    local itemBoxObj, itemBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/ItemBox.prefab")
    itemBoxObj.transform:SetParent(self.parentTrans, false)
    itemBoxView:InitView(itemModel, itemModel:GetID(), self.isShowName, self.isShowCount, self.isShowDetail, ItemOriginType.OTHER)
    itemBoxView.btnClick:regOnButtonClick(function()
        local _, comp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Crusade/CrusadeMailDetail.prefab", "camera", true, true)
        comp.contentcomp:InitView(envelopeData)
    end)

    self:SaveItemModel(rType, itemModel)
end

--- 实例化装备框
function RewardDataCtrl:InstantiateEquipBox(equipModel, isShowPiece, rType)
    local equipBoxObj, equipBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/EquipBox.prefab")
    equipBoxObj.transform:SetParent(self.parentTrans, false)
    equipBoxView:InitView(equipModel, equipModel:GetEquipID(), self.isShowName, self.isShowCount, isShowPiece, self.isShowDetail, ItemOriginType.OTHER)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            equipBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
    end

    self:SaveItemModel(rType, equipModel)
end

--- 实例化球员头像框
function RewardDataCtrl:InstantiateAvatarBox(cardId, num)
    local avatarBoxObj, avatarBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/PlayerAvatarBox.prefab")
    avatarBoxObj.transform:SetParent(self.parentTrans, false)
    avatarBoxView:InitView(cardId, num, self.isShowDetail, self.isHideLvl, self.cardLv, self.isShowBg)
end

--- 实例化球员碎片
function RewardDataCtrl:InstantiateCardPieceBox(cardPieceModel, rType)
    local avatarBoxObj, avatarBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/CardPiece.prefab")
    avatarBoxObj.transform:SetParent(self.parentTrans, false)
    avatarBoxView:InitView(cardPieceModel, self.isShowName, self.isShowCount, self.isShowDetail)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            avatarBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
        if self.itemParams.numFont ~= nil then
            avatarBoxView:SetNumFont(self.itemParams.numFont)
        end
    end

    self:SaveItemModel(rType, cardPieceModel)
end

--- 实例化球员贴纸碎片
function RewardDataCtrl:InstantiateCardPasterPieceBox(cardPasterPieceModel, rType)
    local avatarBoxObj, avatarBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/CardPiece.prefab")
    avatarBoxObj.transform:SetParent(self.parentTrans, false)
    avatarBoxView:InitView(cardPasterPieceModel, self.isShowName, self.isShowCount, self.isShowDetail)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            avatarBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
        if self.itemParams.numFont ~= nil then
            avatarBoxView:SetNumFont(self.itemParams.numFont)
        end
    end

    self:SaveItemModel(rType, cardPasterPieceModel)
end

--- 实例化贴纸
function RewardDataCtrl:InstantiatePasterBox(cardPasterModel, rType)
    local pasterBoxObj, pasterBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/PasterBox.prefab")
    pasterBoxObj.transform:SetParent(self.parentTrans, false)
    pasterBoxView:InitView(cardPasterModel, self.isShowName, self.isShowDetail, self.isShowSymbol)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            pasterBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
        if self.itemParams.numFont ~= nil then
            pasterBoxView:SetNumFont(self.itemParams.numFont)
        end
    end

    self:SaveItemModel(rType, cardPasterModel)
end

--- 实例化勋章
function RewardDataCtrl:InstantiateMedalBox(medalModel, rType)
    local medalBoxObj, medalBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/MedalBox.prefab")
    medalBoxObj.transform:SetParent(self.parentTrans, false)
    medalBoxView:InitView(medalModel, self.isShowName, self.isShowCount, self.isShowDetail)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            medalBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
        if self.itemParams.numFont ~= nil then
            medalBoxView:SetNumFont(self.itemParams.numFont)
        end
    end

    self:SaveItemModel(rType, medalModel)
end

-- 实例化教练物品
function RewardDataCtrl:InstantiateCoachItem(reward, rType)
    local coachItemModel = self.coachItemMapModel:GetCoachItemModelById(reward.id)
    local objPath = self.coachItemMapModel:GetItemBoxPrefabPath(coachItemModel:GetId())
    local coachItemObj, coachItemSpt = res.Instantiate(objPath)
    coachItemObj.transform:SetParent(self.parentTrans, false)
    if self.isReceive then
        coachItemModel:InitWithReward(reward)
    else
        local newReward = clone(reward)
        newReward.id = reward.id
        newReward.add = reward.num
        coachItemModel:InitWithReward(newReward)
    end
    coachItemSpt:InitView(coachItemModel, self.isShowName, self.isShowCount, self.isShowCount, self.isShowDetail)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            coachItemSpt:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
        if self.itemParams.numFont ~= nil then
            coachItemSpt:SetNumFont(self.itemParams.numFont)
        end
    end

    self:SaveItemModel(rType, coachItemModel)
end

-- 实例化绿茵征途道具
function RewardDataCtrl:InstantiateAdventureItemBox(itemModel, rType)
    local objPath = self.greenswardItemMapModel:GetItemBoxPrefabPathByType(itemModel:GetItemType())
    local itemBoxObj, itemBoxView = res.Instantiate(objPath)
    itemBoxObj.transform:SetParent(self.parentTrans, false)
    itemBoxView:InitView(itemModel, itemModel:GetID(), self.isShowName, self.isShowCount, self.isShowDetail, ItemOriginType.OTHER)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            itemBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
        if self.itemParams.numFont ~= nil then
            itemBoxView:SetNumFont(self.itemParams.numFont)
        end
    end

    self:SaveItemModel(rType, itemModel)
end

--构建梦幻卡奖励
function RewardDataCtrl:BuildFancyCardReward()
    local fancyCardsMapModel = FancyCardsMapModel.new()
    local cardList = self.rewardData.fancyCard
    if cardList ~= nil and type(cardList) == "table" and table.nums(cardList) > 0 then
        for i, v in ipairs(cardList) do
            local card = FancyCardModel.new()
            card:InitData(v.id, fancyCardsMapModel)
            if self.isReceive then
                self.isShowCount = false
                self:InstantiateFancyCard(card, v.addNum)
            else
                self:InstantiateFancyCard(card, v.num)
            end
        end
    end
end

--实例化梦幻卡道具
function RewardDataCtrl:InstantiateFancyCard(card, count)
    local itemObj, itemSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Fancy/Prefab/FancyCardSmall.prefab")
    itemObj.transform:SetParent(self.parentTrans, false)
    local _param ={
        isShowName = self.isShowName,
        nameColor = Color(1, 1, 1),
        nameSize = 16,
        dontShowHaveCard = not self.isShowSymbol,
        count = count or 0,
        isShowCount = self.isShowCount, 
        scale = 1.1
    }
    if self.itemParams then
        if self.itemParams.nameColor then 
            _param.nameColor = self.itemParams.nameColor 
        end
        if self.itemParams.numFont then 
            _param.nameSize = self.itemParams.numFont 
        end
    end
    itemSpt:InitView(card, _param)
    if self.isShowDetail then
        itemSpt.OnBtnClick = function ()
            res.PushDialogImmediate("ui.controllers.fancy.fancyHome.FancyPreviewCtrl", 1, card)
        end
    end
    self:SaveItemModel(MailRewardType.FancyCard, card)
end

-- 实例化梦幻卡碎片
function RewardDataCtrl:InstantiateFancyPieceBox(fancyPieceModel, rType)
    local avatarBoxObj, avatarBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Fancy/Prefab/FancyPiece.prefab")
    avatarBoxObj.transform:SetParent(self.parentTrans, false)
    avatarBoxView:InitView(fancyPieceModel, self.isShowName, self.isShowCount, self.isShowDetail)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            avatarBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
        if self.itemParams.numFont ~= nil then
            avatarBoxView:SetNumFont(self.itemParams.numFont)
        end
    end

    self:SaveItemModel(rType, fancyPieceModel)
end

--- 实例化弹球台兑换道具
function RewardDataCtrl:InstantiateMarblesItemBox(marblesExchangeItemModel, rType)
    local exchangeItemBoxObj, exchangeItemBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/MarblesExchangeItemBox.prefab")
    exchangeItemBoxObj.transform:SetParent(self.parentTrans, false)
    exchangeItemBoxView:InitView(marblesExchangeItemModel, marblesExchangeItemModel:GetID(), self.isShowName, self.isShowCount, self.isShowDetail, ItemOriginType.OTHER)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            exchangeItemBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
        if self.itemParams.numFont ~= nil then
            exchangeItemBoxView:SetNumFont(self.itemParams.numFont)
        end
    end

    self:SaveItemModel(rType, marblesExchangeItemModel)
end

-- 保存生成的Model
function RewardDataCtrl:SaveItemModel(rType, itemModel)
    if self.isSavedItemModel and rType ~= nil then
        if not self.savedItemModels then self.savedItemModels = {} end
        rType = tostring(rType)
        local isTable = self:IsTable(rType)
        if table.isEmpty(self.savedItemModels[rType]) then
            if isTable then
                self.savedItemModels[rType] = {}
                table.insert(self.savedItemModels[rType], itemModel)
            else
                self.savedItemModels[rType] = itemModel
            end
        else
            if type(self.savedItemModels[rType]) == "table" then
                table.insert(self.savedItemModels[rType], itemModel)
            else
                self.savedItemModels[rType] = itemModel
            end
        end
    end
end

-- contents结构中该type是否是table结构
function RewardDataCtrl:IsTable(rType)
    local isTable = true
    for k, v in pairs(CurrencyType) do
        if v == rType then
            isTable = false
            break
        end
    end
    return isTable
end

-- 获得保存的物品Model
function RewardDataCtrl:GetSavedItemModels()
    return self.savedItemModels
end

-- 清空保存的物品的Model
function RewardDataCtrl:ClearSacedItemModels()
    self.savedItemModels = nil
end

function RewardDataCtrl.CombineReward(contents)
    local reward = {}
    for i, v in ipairs(contents) do
        local t = v.contents
        for key, value in pairs(t) do
            if type(value) == "number" then
                reward[key] = (reward[key] or 0) + value
            elseif type(value) == "table" then
                if not reward[key] then
                    reward[key] = {}
                end
                for rewardIndex, rewardValue in ipairs(value) do
                    table.insert(reward[key], rewardValue)
                end
            end
        end
    end
    return reward
end

return RewardDataCtrl

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local RectTransform = UnityEngine.RectTransform

local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local EquipItemModel = require("ui.models.cardDetail.EquipItemModel")
local ItemModel = require("ui.models.cardDetail.ItemModel")
local EquipPieceModel = require("ui.models.cardDetail.EquipPieceModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CouponModel = require("ui.models.activity.CouponModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CommonConstants = require("ui.common.CommonConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RedPacketModel = require("ui.models.RedPacketModel")
local ExchangeItemModel = require("ui.models.cardDetail.ExchangeItemModel")
local CoachItemMapModel = require("ui.models.coach.common.CoachItemMapModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")
local MarblesItemModel = require("ui.models.activity.marbles.MarblesItemModel")
local FancyCardModel = require("ui.models.fancy.FancyCardModel")

local RewardBoxView = class(unity.base)

function RewardBoxView:ctor()
    -- 奖励物品的父节点
    self.itemParent = self.___ex.itemParent
    -- 奖励物品的最外框
    self.itemParentBox = self.___ex.itemParentBox
    -- 卡牌的父节点
    self.cardParent = self.___ex.cardParent
    -- 名称
    self.nameTxt = self.___ex.name
    -- 画布组
    self.canvasGroup = self.___ex.canvasGroup
    -- 奖励物品框
    self.rewardBoxView = nil
    -- 奖励数据
    self.rewardData = nil
    -- 物品名称
    self.rewardName = nil
    -- 是否显示完了所有的奖励
    self.isShowAllRewards = false

    self.coachItemMapModel = CoachItemMapModel.new()

    self.greenswardItemMapModel = GreenswardItemMapModel.new()
end

function RewardBoxView:InitView(rewardData)
    self.rewardData = rewardData
    self.count = 0
    for k, v in pairs(self.rewardData) do
        if type(self.rewardData[k]) == "table" then
            self.count = self.count + table.nums(self.rewardData[k])
        else
            self.count = self.count + 1
        end
    end

    -- 金币有两个字段控制
    if self.rewardData.m ~= nil and self.rewardData.mDetail ~= nil then
        self.count = self.count - table.nums(self.rewardData.mDetail)
    end

    -- exp奖励有可能是个table
    if self.rewardData.exp ~= nil and type(self.rewardData.exp) == "table" then
        self.count = self.count - table.nums(self.rewardData.exp)
        self.count = self.count + 1
    end
end

function RewardBoxView:BuildView()
    local childItemBox = nil
    local childCardBox = nil
    if self.itemParent.childCount > 0 then
        childItemBox = self.itemParent:GetChild(0)
    end
    if self.cardParent.childCount > 0 then
        childCardBox = self.cardParent:GetChild(0)
    end

    -- 移除之前的object
    if not self.isShowAllRewards then
        if childItemBox ~= nil and childItemBox ~= clr.null then
            Object.Destroy(childItemBox.gameObject)
        end
        if childCardBox ~= nil and childCardBox ~= clr.null then
            Object.Destroy(childCardBox.gameObject)
        end
    end

    --吉祥物亲密度道具
    if self.rewardData.jxw ~= nil and self.rewardData.jxw ~= 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithJxwAddNum(self.rewardData.jxw)
        self:InstantiateItemBox(itemModel)
        self.rewardData.jxw = nil
        -- 钻石
    elseif self.rewardData.d ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithDiamondAddNum(self.rewardData.d)
        self:InstantiateItemBox(itemModel)
        self.rewardData.d = nil
        -- 欧元
    elseif self.rewardData.m ~= nil then
        if type(self.rewardData.mDetail) == "table" and #self.rewardData.mDetail > 0 then
            local itemModel = ItemModel.new()
            itemModel:InitWithMoneyAddNum(self.rewardData.mDetail[1])
            self:InstantiateItemBox(itemModel)
            table.remove(self.rewardData.mDetail, 1)
            if #self.rewardData.mDetail == 0 then
                self.rewardData.m = nil
            end
        else
            local itemModel = ItemModel.new()
            itemModel:InitWithMoneyAddNum(self.rewardData.m)
            self:InstantiateItemBox(itemModel)
            self.rewardData.m = nil
        end
        -- 体力
    elseif self.rewardData.sp ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithStrengthAddNum(self.rewardData.sp)
        self:InstantiateItemBox(itemModel)
        self.rewardData.sp = nil
        -- 友情点
    elseif self.rewardData.fp ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithFriendship(self.rewardData.fp)
        self:InstantiateItemBox(itemModel)
        self.rewardData.fp = nil
        -- 天梯荣誉
    elseif self.rewardData.lp ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithLadderHonorAddNum(self.rewardData.lp)
        self:InstantiateItemBox(itemModel)
        self.rewardData.lp = nil
        -- 梦幻币
    elseif self.rewardData.dc ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithDreamCoinAddNum(self.rewardData.dc)
        self:InstantiateItemBox(itemModel)
        self.rewardData.dc = nil
        -- 梦幻碎片
    elseif self.rewardData.dp ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithDreamPieceAddNum(self.rewardData.dp)
        self:InstantiateItemBox(itemModel)
        self.rewardData.dp = nil
        -- 经验
    elseif type(self.rewardData.exp) == "number" then
        local itemModel = ItemModel.new()
        itemModel:InitWithExpAddNum(self.rewardData.exp)
        self:InstantiateItemBox(itemModel)
        self.rewardData.exp = nil
    elseif type(self.rewardData.exp) == "table" and tonumber(self.rewardData.exp.addExp) > 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithExpAddNum(self.rewardData.exp.addExp)
        self:InstantiateItemBox(itemModel)
        self.rewardData.exp = nil
        -- 星辰
    elseif self.rewardData.sd ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithStardustAddNum(self.rewardData.sd)
        self:InstantiateItemBox(itemModel)
        self.rewardData.sd = nil
        -- 祝福
    elseif self.rewardData.bs ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithBenedictionAddNum(self.rewardData.bs)
        self:InstantiateItemBox(itemModel)
        self.rewardData.bs = nil
        -- 争霸币
    elseif self.rewardData.wtc ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithWtcAddNum(self.rewardData.wtc)
        self:InstantiateItemBox(itemModel)
        self.rewardData.wtc = nil
        -- 殿堂精华
    elseif self.rewardData.smd ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithSmdAddNum(self.rewardData.smd)
        self:InstantiateItemBox(itemModel)
        self.rewardData.smd = nil
    -- 球魂
    elseif self.rewardData.fs then
        local itemModel = ItemModel.new()
        itemModel:InitWithFsAddNum(self.rewardData.fs)
        self:InstantiateItemBox(itemModel)
        self.rewardData.fs = nil
    elseif self.rewardData.fancyPiece then
        local itemModel = ItemModel.new()
        itemModel:InitWithFancyPieceAddNum(self.rewardData.fancyPiece)
        self:InstantiateFancyPieceBox(itemModel)
        self.rewardData.fancyPiece = nil
    -- 殿堂升阶石
    elseif self.rewardData.smb ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithSmbAddNum(self.rewardData.smb)
        self:InstantiateItemBox(itemModel)
        self.rewardData.smb = nil
        -- 执教经验书
    elseif self.rewardData.ce ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithCeAddNum(self.rewardData.ce)
        self:InstantiateItemBox(itemModel)
        self.rewardData.ce = nil
        -- 教练天赋点
    elseif self.rewardData.ctp ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithCtpAddNum(self.rewardData.ctp)
        self:InstantiateItemBox(itemModel)
        self.rewardData.ctp = nil
        -- 助理教练经验书
    elseif self.rewardData.ace ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithAceAddNum(self.rewardData.ace)
        self:InstantiateItemBox(itemModel)
        self.rewardData.ace = nil
    -- [绿茵征途]士气
    elseif self.rewardData.morale ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithMoraleAddNum(self.rewardData.morale)
        self:InstantiateItemBox(itemModel)
        self.rewardData.morale = nil
    -- [绿茵征途]斗志
    elseif self.rewardData.fight ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithFightAddNum(self.rewardData.fight)
        self:InstantiateItemBox(itemModel)
        self.rewardData.fight = nil
    elseif self.rewardData.pp ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithPeakPointAddNum(self.rewardData.pp)
        self:InstantiateItemBox(itemModel)
        self.rewardData.pp = nil
    elseif type(self.rewardData.item) == "table" and #self.rewardData.item > 0 then
        local itemListData = self.rewardData.item
        local itemModel = ItemModel.new()
        itemModel:InitWithCache(itemListData[1])
        self:InstantiateItemBox(itemModel)
        table.remove(self.rewardData.item, 1)
        -- 装备
    elseif type(self.rewardData.eqs) == "table" and #self.rewardData.eqs > 0 then
        local equipListData = self.rewardData.eqs
        local equipItemModel = EquipItemModel.new()
        equipItemModel:InitWithCache(equipListData[1])
        self:InstantiateEquipBox(equipItemModel, false)
        table.remove(self.rewardData.eqs, 1)
        -- 装备碎片
    elseif type(self.rewardData.equipPiece) == "table" and #self.rewardData.equipPiece > 0 then
        local equipPieceListData = self.rewardData.equipPiece
        local equipPieceModel = EquipPieceModel.new()
        equipPieceModel:InitWithCache(equipPieceListData[1])
        self:InstantiateEquipBox(equipPieceModel, true)
        table.remove(self.rewardData.equipPiece, 1)
        -- 卡牌
    elseif type(self.rewardData.card) == "table" and #self.rewardData.card > 0 then
        local cardListData = self.rewardData.card
        local cardModel = PlayerCardModel.new(cardListData[1].pcid)
        self:InstantiateAvatarBox(cardModel)
        table.remove(self.rewardData.card, 1)
        -- 卡牌碎片
    elseif type(self.rewardData.cardPiece) == "table" and #self.rewardData.cardPiece > 0 then
        local cardPieceListData = self.rewardData.cardPiece
        local cardPieceModel = CardPieceModel.new()
        cardPieceModel:InitWithCache(cardPieceListData[1])
        self:InstantiateAvatarPieceBox(cardPieceModel)
        table.remove(self.rewardData.cardPiece, 1)
        -- 幸运转盘折扣券(暂时只出现在活动中)
    elseif type(self.rewardData.coupon) == "table" and #self.rewardData.coupon > 0 then
        local couponListData = self.rewardData.coupon
        local couponModel = CouponModel.new(couponListData[1])
        self:InstantiateCouponBox(couponModel)
        table.remove(self.rewardData.coupon, 1)
    elseif type(self.rewardData.paster) == "table" and #self.rewardData.paster > 0 then
        local pasterListData = self.rewardData.paster
        local cardPasterModel = CardPasterModel.new()
        cardPasterModel:InitWithCache(pasterListData[1])
        self:InstantiatePasterBox(cardPasterModel)
        table.remove(self.rewardData.paster, 1)
    elseif type(self.rewardData.pasterPiece) == "table" and #self.rewardData.pasterPiece > 0 then
        local pasterPieceListData = self.rewardData.pasterPiece
        local cardPasterPieceModel = CardPasterPieceModel.new()
        cardPasterPieceModel:InitWithCache(pasterPieceListData[1])
        self:InstantiatePasterPieceBox(cardPasterPieceModel)
        table.remove(self.rewardData.pasterPiece, 1)
    elseif type(self.rewardData.redPacket) == "table" and #self.rewardData.redPacket > 0 then
        local redPacketListData = self.rewardData.redPacket
        local itemModel = ItemModel.new()
        itemModel:InitWithRedPacket(redPacketListData[1])
        self:InstantiateItemBox(itemModel)
        table.remove(self.rewardData.redPacket, 1)
        -- 勋章
    elseif type(self.rewardData.medal) == "table" and #self.rewardData.medal > 0 then
        local medalListData = self.rewardData.medal
        local medalModel = PlayerMedalModel.new()
        local medalData = medalListData[1]
        medalModel:InitWithCache(medalData)
        self:InstantiateMedalBox(medalModel)
        table.remove(self.rewardData.medal, 1)
        -- 活动道具
    elseif type(self.rewardData.exchangeItem) == "table" and #self.rewardData.exchangeItem > 0 then
        local exchangeListData = self.rewardData.exchangeItem
        local exchangeItemModel = ExchangeItemModel.new()
        exchangeItemModel:InitWithCache(exchangeListData[1])
        self:InstantiateExchangeItemBox(exchangeItemModel)
        table.remove(self.rewardData.exchangeItem, 1)
        -- 教练阵型/战术升级物品
    elseif type(self.rewardData.cti) == "table" and #self.rewardData.cti > 0 then
        local coachItemData = self.rewardData.cti[1]
        local coachItemModel = self.coachItemMapModel:GetCoachItemModelById(coachItemData.id)
        coachItemModel:InitWithReward(coachItemData)
        self:InstantiateCoachItemBox(coachItemModel)
        table.remove(self.rewardData.cti, 1)
    -- 绿茵征途道具
    elseif type(self.rewardData.advItem) == "table" and #self.rewardData.advItem > 0 then
        local advItemData = self.rewardData.advItem[1]
        local greenswardItemModel = self.greenswardItemMapModel:GetItemModelById(advItemData.id)
        greenswardItemModel:InitWithReward(advItemData)
        self:InstantiateAdventureItemBox(greenswardItemModel)
        table.remove(self.rewardData.advItem, 1)
    -- 阶梯商店购物券
    elseif type(self.rewardData.sst) == "table" then
        local sstData = self.rewardData.sst[1]
        local itemModel = ItemModel.new()
        itemModel:InitWithStageStoreTicket(sstData)
        self:InstantiateItemBox(itemModel)
    -- 弹球活动兑换道具
    elseif type(self.rewardData.mei) == "table" then
        local meiData = self.rewardData.mei[1]
        local itemModel = MarblesItemModel.new()
        itemModel:InitWithCache(meiData)
        self:InstantiateMarblesItemBox(itemModel)
        table.remove(self.rewardData.mei, 1)
    -- 多日礼盒积分
    elseif self.rewardData.dayGiftScore ~= nil then
        local itemModel = ItemModel.new()
        local cacheData = {}
        cacheData.id = CommonConstants.DayGiftScore
        cacheData.add = self.rewardData.dayGiftScore
        itemModel:InitWithCache(cacheData)
        self:InstantiateItemBox(itemModel)
        self.rewardData.dayGiftScore = nil
    -- 多日礼盒任选币
    elseif self.rewardData.dayGiftCoin ~= nil then
        local itemModel = ItemModel.new()
        local cacheData = {}
        cacheData.id = CommonConstants.DayGiftCoin
        cacheData.add = self.rewardData.dayGiftCoin
        itemModel:InitWithCache(cacheData)
        self:InstantiateItemBox(itemModel)
        self.rewardData.dayGiftCoin = nil
    -- 梦幻卡
    elseif type(self.rewardData.fancyCard) == "table" and #self.rewardData.fancyCard > 0 then
        local cardListData = self.rewardData.fancyCard
        local card = FancyCardModel.new()
        card:InitData(cardListData[1].id)
        self:InstantiateFancyCard(card)
        table.remove(self.rewardData.fancyCard, 1)
    end
    
    self.count = self.count - 1

    self.isShowAllRewards = (self.count == 0)
end

--- 设置透明度
function RewardBoxView:SetAlpha(alpha)
    self.canvasGroup.alpha = alpha
end

--- 设置名称
function RewardBoxView:SetName()
    self.nameTxt.text = self.rewardName
end

--实例化梦幻卡道具
function RewardBoxView:InstantiateFancyCard(card)
    GameObjectHelper.FastSetActive(self.itemParentBox, false)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, true)
    local itemObj, itemSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Fancy/Prefab/FancyCardBig.prefab")
    itemObj.transform:SetParent(self.cardParent, false)
    itemSpt:InitView(card)
    self.rewardName = card:GetName()
    self:SetName()
end

-- 实例化梦幻卡碎片
function RewardBoxView:InstantiateFancyPieceBox(fancyPieceModel)
    GameObjectHelper.FastSetActive(self.itemParentBox, true)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, false)
    local fancyPieceObj, fancyPieceView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Fancy/Prefab/FancyPiece.prefab")
    fancyPieceObj.transform:SetParent(self.itemParent, false)
    fancyPieceObj.transform.sizeDelta = Vector2(110, 140)
    fancyPieceView:InitView(fancyPieceModel, false, true, false)
    self.rewardName = fancyPieceModel:GetName()
    self:SetName()
end

--- 实例化道具框
function RewardBoxView:InstantiateItemBox(itemModel)
    GameObjectHelper.FastSetActive(self.itemParentBox, true)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, false)
    local itemBoxObj, itemBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/ItemBox.prefab")
    local itemBoxRectTrans = itemBoxObj:GetComponent(RectTransform)
    itemBoxObj.transform:SetParent(self.itemParent, false)
    itemBoxRectTrans.sizeDelta = Vector2(110, 140)
    itemBoxView:InitView(itemModel, itemModel:GetID(), false, true, false)
    self.rewardName = itemModel:GetName()
    self:SetName()
end

--- 实例化活动兑换
function RewardBoxView:InstantiateExchangeItemBox(exchangeItemModel)
    GameObjectHelper.FastSetActive(self.itemParentBox, true)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, false)
    local exchangeItemBoxObj, exchangeItemBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/ExchangeItemBox.prefab")
    local exchangeItemBoxRectTrans = exchangeItemBoxObj:GetComponent(RectTransform)
    exchangeItemBoxObj.transform:SetParent(self.itemParent, false)
    exchangeItemBoxRectTrans.sizeDelta = Vector2(110, 140)
    exchangeItemBoxView:InitView(exchangeItemModel, exchangeItemModel:GetID(), false, true, false)
    self.rewardName = exchangeItemModel:GetName()
    self:SetName()
end

--- 实例化装备框
function RewardBoxView:InstantiateEquipBox(equipModel, isShowPiece)
    GameObjectHelper.FastSetActive(self.itemParentBox, true)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, false)
    local equipBoxObj, equipBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/EquipBox.prefab")
    local equipBoxRectTrans = equipBoxObj:GetComponent(RectTransform)
    equipBoxObj.transform:SetParent(self.itemParent, false)
    equipBoxRectTrans.sizeDelta = Vector2(110, 140)
    equipBoxView:InitView(equipModel, equipModel:GetEquipID(), false, true, isShowPiece, false)
    self.rewardName = equipModel:GetName()
    self:SetName()
end

--- 实例化球员卡牌
function RewardBoxView:InstantiateAvatarBox(cardModel)
    GameObjectHelper.FastSetActive(self.itemParentBox, false)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, true)
    local avatarBoxObj, avatarBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    avatarBoxObj.transform:SetParent(self.cardParent, false)
    avatarBoxView:InitView(cardModel)
    avatarBoxView:IsShowName(false)
    self.rewardName = cardModel:GetName()
    self:SetName()
end

--- 实例化球员碎片
function RewardBoxView:InstantiateAvatarPieceBox(cardPieceModel)
    GameObjectHelper.FastSetActive(self.itemParentBox, true)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, false)
    local cardPieceObj, cardPieceView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/CardPiece.prefab")
    cardPieceObj.transform:SetParent(self.itemParent, false)
    cardPieceObj.transform.sizeDelta = Vector2(110, 140)
    cardPieceView:InitView(cardPieceModel, false, true, false)
    self.rewardName = cardPieceModel:GetName() .. lang.transstr("piece")
    self:SetName()
end

-- 幸运转盘折扣券
function RewardBoxView:InstantiateCouponBox(couponModel)
    GameObjectHelper.FastSetActive(self.itemParentBox, true)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, false)
    local couponItemObj, couponItemView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/CouponItemBox.prefab")
    local itemBoxRectTrans = couponItemObj:GetComponent(RectTransform)
    couponItemObj.transform:SetParent(self.itemParent, false)
    itemBoxRectTrans.sizeDelta = Vector2(110, 140)
    couponItemView:InitView(couponModel, false, false, false)
    self.rewardName = couponModel:GetName()
    self:SetName()
end

--- 实例化贴纸
function RewardBoxView:InstantiatePasterBox(cardPasterModel)
    GameObjectHelper.FastSetActive(self.itemParentBox, true)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, false)
    local pasterBoxObj, pasterBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/PasterBox.prefab")
    pasterBoxObj.transform:SetParent(self.itemParent, false)
    pasterBoxObj.transform.sizeDelta = Vector2(110, 140)
    pasterBoxView:InitView(cardPasterModel, false, true)
    self.rewardName = cardPasterModel:GetName()
    self:SetName()
end

--- 实例化贴纸碎片
function RewardBoxView:InstantiatePasterPieceBox(cardPasterPieceModel)
    GameObjectHelper.FastSetActive(self.itemParentBox, true)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, false)
    local cardPieceObj, cardPieceView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/CardPiece.prefab")
    cardPieceObj.transform:SetParent(self.itemParent, false)
    cardPieceObj.transform.sizeDelta = Vector2(110, 140)
    cardPieceView:InitView(cardPasterPieceModel, false, true, false)
    self.rewardName = cardPasterPieceModel:GetName()
    self:SetName()
end

--- 实例化勋章框
function RewardBoxView:InstantiateMedalBox(medalModel)
    GameObjectHelper.FastSetActive(self.medalParentBox, true)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, false)
    local medalBoxObj, medalBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/MedalBox.prefab")
    local medalBoxRectTrans = medalBoxObj:GetComponent(RectTransform)
    medalBoxObj.transform:SetParent(self.itemParent, false)
    medalBoxRectTrans.sizeDelta = Vector2(110, 140)
    medalBoxView:InitView(medalModel, false, true, false)
    self.rewardName = medalModel:GetName()
    self:SetName()
end

-- 教练物品
function RewardBoxView:InstantiateCoachItemBox(coachItemModel)
    GameObjectHelper.FastSetActive(self.itemParentBox, true)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, false)
    local objPath = self.coachItemMapModel:GetItemBoxPrefabPath(coachItemModel:GetId())
    local coachItemObj, coachItemSpt = res.Instantiate(objPath)
    coachItemObj.transform:SetParent(self.itemParent, false)
    coachItemSpt:InitView(coachItemModel, false, true, true, false)
    self.rewardName = tostring(coachItemModel:GetName())
    self:SetName()
end

-- 绿茵征途道具
function RewardBoxView:InstantiateAdventureItemBox(greenswardItemModel)
    GameObjectHelper.FastSetActive(self.itemParentBox, true)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, false)
    local objPath = self.greenswardItemMapModel:GetItemBoxPrefabPathByType(greenswardItemModel:GetItemType())
    local obj, spt = res.Instantiate(objPath)
    obj.transform:SetParent(self.itemParent, false)
    spt:InitView(greenswardItemModel, greenswardItemModel:GetId(), false, true, true, false)
    self.rewardName = tostring(greenswardItemModel:GetName())
    self:SetName()
end

--- 实例化弹球活动兑换道具
function RewardBoxView:InstantiateMarblesItemBox(marblesItemModel)
    GameObjectHelper.FastSetActive(self.itemParentBox, true)
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, false)
    local exchangeItemBoxObj, exchangeItemBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/MarblesExchangeItemBox.prefab")
    local exchangeItemBoxRectTrans = exchangeItemBoxObj:GetComponent(RectTransform)
    exchangeItemBoxObj.transform:SetParent(self.itemParent, false)
    exchangeItemBoxRectTrans.sizeDelta = Vector2(110, 140)
    exchangeItemBoxView:InitView(marblesItemModel, marblesItemModel:GetID(), false, true, false)
    self.rewardName = marblesItemModel:GetName()
    self:SetName()
end

function RewardBoxView:GetName()
    return self.rewardName
end

function RewardBoxView:IsShowAll()
    return self.isShowAllRewards
end

return RewardBoxView

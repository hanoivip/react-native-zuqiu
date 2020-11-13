local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerLetterInsidePlayerModel = require("ui.models.playerLetter.PlayerLetterInsidePlayerModel")
local HeroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LetterCards = require("data.LetterCards")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local AidCardFrameView = class(unity.base)

function AidCardFrameView:ctor()
    self.cardParent = self.___ex.cardParent
    self.btnCard = self.___ex.btnCard
    self.btnBuy = self.___ex.btnBuy
    self.buyButton = self.___ex.buyButton
    self.buyText = self.___ex.buyText
    self.nameTxt = self.___ex.name
    self.cost = self.___ex.cost
    self.buyGradient = self.___ex.buyGradient
    self.message = self.___ex.message
    self.cardIDTxt = self.___ex.cardIDTxt
    self.chemical = self.___ex.chemical
	self.iconSign = self.___ex.iconSign
    self.bestPartner = self.___ex.bestPartner
    self.chemicalText = self.___ex.chemicalText
    self.bestPartnerText = self.___ex.bestPartnerText
end

function AidCardFrameView:start()
    self.btnCard:regOnButtonClick(function()
        if type(self.clickCard) == "function" then
            self.clickCard(self.cardModel:GetCid())
        end
    end)
    self.btnBuy:regOnButtonClick(function()
        if type(self.clickBuy) == "function" then
            self.clickBuy(self.index)
        end
    end)
end

-- "buySign": 0 --未购买，1：已购买
function AidCardFrameView:InitView(cardModel, cardData, index, cardResourceCache, flagData, customTagModel)
    -- Card
    self:HideAllSymbol()
    local buySign = cardData.buy
    self.index = index
    self.cardModel = cardModel
    if not self.cardView then
        local cardObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        self.cardView = cardObject:GetComponent(clr.CapsUnityLuaBehav)
        cardObject.transform:SetParent(self.cardParent.transform, false)
        self.cardView:SetCardResourceCache(cardResourceCache)
        self.cardView:InitView(cardModel)
        self.cardView:IsShowName(false)
    end
    self.cardView:InitView(cardModel)
    self.nameTxt.text = tostring(cardModel:GetName())
    if tonumber(buySign) == 0 then 
        self.buyButton.interactable = true
        self.buyText.text = lang.trans("buy_player")
        self.buyGradient.enabled = true
    elseif tonumber(buySign) == 1 then 
        self.buyButton.interactable = false
        self.buyText.text = lang.trans("be_buy_player")
        self.buyGradient.enabled = false
    end
    self.cost.text = "x" .. cardModel:GetMysteryPrice()

    local isBelongToLetter = PlayerLetterInsidePlayerModel.new():IsBelongToLetterCard(cardModel:GetCid())
    local isHave = PlayerCardsMapModel.new():IsExistCardID(cardModel:GetCid())
    local activityLetter = cardData.activityLetter == 1
    local isShowChemical = flagData.showChemical
	local isShowBestPartener = flagData.showBestPartener
    if self:CheckCustomTag(cardModel, customTagModel) then
        return
    end
	local isShow = false
    if isBelongToLetter and not isHave then
		isShow = true
		self.iconSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Images/PlayerLetter.png")
        self.cardIDTxt.text = lang.trans("transferMarket_letter", LetterCards[cardModel:GetCid()][1])
    elseif activityLetter then
		isShow = true
		self.iconSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Images/PlayerLetter.png")
        self.cardIDTxt.text = lang.trans("transferMarket_letter", lang.transstr("menu_activity"))
	elseif isShowChemical then 
		isShow = true
		self.iconSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Images/PlayerChemical.png")
		self.cardIDTxt.text = lang.trans("untranslated_2738")
	elseif isShowBestPartener then 
		isShow = true
		self.iconSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Images/PlayerBestPartner.png")
		self.cardIDTxt.text = lang.trans("untranslated_2739")
	else
		local isHeroHall = HeroHallMapModel.new():CheckCardIsInside(cardModel:GetBaseID())
		if isHeroHall then 
			isShow = true
			self.iconSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/HonorPalace/Images/Trophy.png")
			self.cardIDTxt.text = lang.trans("hero_hall_card")
		end
    end
	GameObjectHelper.FastSetActive(self.message, isShow)
end

function AidCardFrameView:HideAllSymbol()
    GameObjectHelper.FastSetActive(self.message, false)
end

-- 自定义标记
function AidCardFrameView:CheckCustomTag(cardModel, customTagModel)
    local state = false
    if customTagModel then
        local cid = cardModel:GetCid()
        state = customTagModel:GetStateByCid(cid)
        local tag = customTagModel:GetTagByCid(cid)
        if not self.obj then
            self.obj, self.spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/PlayerList/CustomTagBar.prefab")
            self.obj.transform:SetParent(self.transform, false)
        end
        self.spt:InitView(tag)
    end
    if self.obj then
        GameObjectHelper.FastSetActive(self.obj, tobool(state))
    end
    return state
end

function AidCardFrameView:ShowChemical()
    local flag = self.cardModel:GetIsHaveChemical()
    GameObjectHelper.FastSetActive(self.chemical, flag)
    return flag
end

function AidCardFrameView:ShowBestPartner()
    local flag = self.cardModel:GetIsHaveBestPartner()
    GameObjectHelper.FastSetActive(self.bestPartner, flag)
    return flag
end

return AidCardFrameView

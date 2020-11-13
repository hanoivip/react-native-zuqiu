local PlayerLetterInsidePlayerModel = require("ui.models.playerLetter.PlayerLetterInsidePlayerModel")
local HeroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LetterCards = require("data.LetterCards")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local TransferMarketPlayerView = class(unity.base)

function TransferMarketPlayerView:ctor()
    self.moneyValue = self.___ex.moneyValue
    self.cardArea = self.___ex.cardArea
    self.btnCard = self.___ex.btnCard
    self.btnBuy = self.___ex.btnBuy
    self.buyButton = self.___ex.buyButton
    self.buyText = self.___ex.buyText
    self.signText = self.___ex.signText
    self.cardClickImage = self.___ex.cardClickImage
    self.nameTxt = self.___ex.name
    self.animator = self.___ex.animator
    self.message = self.___ex.message
    self.cardIDTxt = self.___ex.cardIDTxt
    self.maskExLocked = self.___ex.maskExLocked
    self.btnArea = self.___ex.btnArea
    self.moneyBar = self.___ex.moneyBar
	self.iconSign = self.___ex.iconSign
    self.extraLockText = self.___ex.extraLockText
    self.extraLockDecs = self.___ex.extraLockDecs
end

function TransferMarketPlayerView:start()
    self.btnCard:regOnButtonClick(function()
        if self.onClickCard then
            self.onClickCard(self.pos)
        end
    end)
    self.btnCard:regOnButtonDown(function()
        self.cardClickImage:SetActive(true)
    end)
    self.btnCard:regOnButtonUp(function()
        self.cardClickImage:SetActive(false)
    end)
    self.btnBuy:regOnButtonClick(function()
        if self.onBuy then
            self.onBuy(self.pos, function() self:OnBuyCallBack() end)
        end
    end)
end

function TransferMarketPlayerView:InitView(pos, transferMarketModel, playerCardModel, flagData, customTagModel)
    self:HideAllSymbol()
    self.pos = pos
    if (transferMarketModel == nil and playerCardModel == nil) then
        GameObjectHelper.FastSetActive(self.message, false)
        GameObjectHelper.FastSetActive(self.btnBuy.gameObject, false)
        self.maskExLocked:SetActive(true)
        self.moneyBar:SetActive(false)
        self.btnArea:SetActive(false)
        self.extraLockText.text = lang.trans("transferMarket_extraSlot", self.pos-6)
        self.extraLockDecs.text = lang.trans("transferMarket_extraSlot_Desc", self.pos-5)
        return
    else
        GameObjectHelper.FastSetActive(self.message, true)
        GameObjectHelper.FastSetActive(self.btnBuy.gameObject, true)
        self.maskExLocked:SetActive(false)
        self.moneyBar:SetActive(true)
        self.btnArea:SetActive(true)
    end
    
    if transferMarketModel:GetPlayerCardSign(pos) then
        self.signText:SetActive(true)
        self.buyButton.interactable = false
        self.buyText:SetActive(false)
        self.btnBuy:onPointEventHandle(false)
    else
        self.signText:SetActive(false)
        self.buyButton.interactable = true
        self.buyText:SetActive(true)
        self.btnBuy:onPointEventHandle(true)
    end
    self.moneyValue.text = string.formatNumWithUnit(tostring(transferMarketModel:GetPlayerCardPrice(pos)))
    self.nameTxt.text = tostring(playerCardModel:GetName())
    local isBelongToLetter = PlayerLetterInsidePlayerModel.new():IsBelongToLetterCard(playerCardModel:GetCid())
    local isHave = PlayerCardsMapModel.new():IsExistCardID(playerCardModel:GetCid())
    local activityLetter = transferMarketModel:GetPlayerCardLetter(pos)
    local isShowChemical = flagData.showChemical
	local isShowBestPartener = flagData.showBestPartener
	local isShow = false
    if self:CheckCustomTag(playerCardModel, customTagModel) then
        return
    end
    if isBelongToLetter and not isHave then
		isShow = true
		self.iconSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Images/PlayerLetter.png")
        self.cardIDTxt.text = lang.trans("transferMarket_letter", LetterCards[playerCardModel:GetCid()][1])
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
		local isHeroHall = HeroHallMapModel.new():CheckCardIsInside(playerCardModel:GetBaseID())
		if isHeroHall then 
			isShow = true
			self.iconSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/HonorPalace/Images/Trophy.png")
			self.cardIDTxt.text = lang.trans("hero_hall_card")
		end
    end
	GameObjectHelper.FastSetActive(self.message, isShow)
end

function TransferMarketPlayerView:HideAllSymbol()
    GameObjectHelper.FastSetActive(self.message, false)
end

-- 自定义标记
function TransferMarketPlayerView:CheckCustomTag(playerCardModel, customTagModel)
    self:HideAllSymbol()
    local state = false
    if customTagModel then
        local cid = playerCardModel:GetCid()
        state = customTagModel:GetStateByCid(cid)
        local tag = customTagModel:GetTagByCid(cid)
        if not self.obj then
            self.obj, self.spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/PlayerList/CustomTagBar_Above.prefab")
            self.obj.transform:SetParent(self.transform, false)
        end
        self.spt:InitView(tag)
    end
    if self.obj then
        GameObjectHelper.FastSetActive(self.obj, tobool(state))
    end
    return state
end

function TransferMarketPlayerView:AddPlayerCard(playerCardObject)
    playerCardObject.transform:SetParent(self.cardArea, false)
end

function TransferMarketPlayerView:OnBuyCallBack()
    self.signText:SetActive(true)
    self.buyButton.interactable = false
    self.buyText:SetActive(false)
    self.btnBuy:onPointEventHandle(false)
end

function TransferMarketPlayerView:PlayLeaveAnimation()
    self.animator:Play("TransferPlayerLeave")
end

return TransferMarketPlayerView

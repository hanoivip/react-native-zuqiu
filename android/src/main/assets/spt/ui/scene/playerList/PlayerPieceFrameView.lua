local LetterCards = require("data.LetterCards")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerPieceFrameView = class(unity.base)

function PlayerPieceFrameView:ctor()
    self.cardParent = self.___ex.cardParent
    self.btnCard = self.___ex.btnCard
    self.btnBuy = self.___ex.btnBuy
    self.nameTxt = self.___ex.name
    self.cost = self.___ex.cost
    self.message = self.___ex.message
    self.cardIDTxt = self.___ex.cardIDTxt
    self.iconSign = self.___ex.iconSign
end

function PlayerPieceFrameView:start()
    self.btnCard:regOnButtonClick(function()
        if type(self.clickCard) == "function" then
            self.clickCard(self.cardModel:GetCid())
        end
    end)
    self.btnBuy:regOnButtonClick(function()
        if type(self.clickBuy) == "function" then
            self.clickBuy(self.cardModel)
        end
    end)
end

function PlayerPieceFrameView:InitView(cardModel, index, cardResourceCache, flagData, customTagModel)
    -- Card
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
    self.cost.text = "x" .. cardModel:GetUniversalPieceNeed()
    self:CheckTag(cardModel, flagData, customTagModel)
end

-- 自定义标记
function PlayerPieceFrameView:CheckCustomTag(cardModel, customTagModel)
    local state = false
    if customTagModel then
        local cid = cardModel:GetCid()
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

-- 检查标记
function PlayerPieceFrameView:CheckTag(cardModel, flagData, customTagModel)
    self:HideAllSymbol()
    if self:CheckCustomTag(cardModel, customTagModel) then return end
    if not flagData then return end
    local isBelongToLetter = flagData.showPlayerLetter
    local isActivityLetter = flagData.showActivityLetter
    local isShowChemical = flagData.showChemical
    local isShowBestPartener = flagData.showBestPartener
    local isShowHeroHall = flagData.showHeroHall
    local isShow = false
    if isBelongToLetter then
        isShow = true
        self.iconSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Images/PlayerLetter.png")
        self.cardIDTxt.text = lang.trans("transferMarket_letter", LetterCards[cardModel:GetCid()][1])
    elseif isActivityLetter then
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
    elseif isShowHeroHall then 
        isShow = true
        self.iconSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/HonorPalace/Images/Trophy.png")
        self.cardIDTxt.text = lang.trans("hero_hall_card")
    end
    GameObjectHelper.FastSetActive(self.message, isShow)
end

function PlayerPieceFrameView:HideAllSymbol()
    GameObjectHelper.FastSetActive(self.message, false)
end

return PlayerPieceFrameView

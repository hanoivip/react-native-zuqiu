local CardBuilder = require("ui.common.card.CardBuilder")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local DialogManager = require("ui.control.manager.DialogManager")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")

local CardView = class(LuaButton)

function CardView:ctor()
    CardView.super.ctor(self)
    self.cardParent = self.___ex.cardParent
    self.mustGet = self.___ex.mustGet
    self.probUp = self.___ex.probUp
    self.discontinued = self.___ex.discontinued
    self.discontinuedText = self.___ex.discontinuedText
    self.highestReborn = self.___ex.highestReborn
    self.message = self.___ex.message
    self.cardIDTxt = self.___ex.cardIDTxt
    self.iconSign = self.___ex.iconSign
    self.chemical = self.___ex.chemical
    self.bestPartner = self.___ex.bestPartner
    self.playerCardsMapModel = PlayerCardsMapModel:new()
    self:regOnButtonClick(function()       
        local currentModel = CardBuilder.GetBaseCardModel(self.data.cid)
        res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {self.data.cid}, 1, currentModel)
    end)
end

function CardView:Init(data, customTagModel)
    self.data = data
    self.isHighestReborn = self.playerCardsMapModel:IsHighestReborn(data.cid)
    local playerCardStaticModel = StaticCardModel.new(data.cid)
    if not self.cardView then
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        obj.transform:SetParent(self.cardParent.transform, false)
        self.cardView = spt
    end
    self.cardView:InitView(playerCardStaticModel)
    if data.mustGet then
        self.mustGet:SetActive(true)
        self.probUp:SetActive(false)
    elseif data.probUpQuality or data.probUpCard then
        self.mustGet:SetActive(false)
        self.probUp:SetActive(true)
    else
        self.mustGet:SetActive(false)
        self.probUp:SetActive(false)
    end
    if self.isHighestReborn then
        self.highestReborn:SetActive(true)
    else 
        self.highestReborn:SetActive(false)
    end
    if data.discontinued and data.discontinued ~= 0  then 
        self.discontinued:SetActive(true)
        local timeTable = string.convertSecondToTimeTable(data.discontinued)
        local timeText = ""
        if timeTable.day == 0 then 
            if timeTable.hour == 0 then 
                timeText = lang.trans("gacha_limit_minute", timeTable.minute)
            else
                if timeTable.minute == 0 then 
                    self.discontinued:SetActive(false)
                else
                    timeText = lang.trans("gacha_limit_hour", timeTable.hour, timeTable.minute)
                end
            end
        else
            timeText = lang.trans("gacha_limit_day", timeTable.day, timeTable.hour)
        end
        self.discontinuedText.text = timeText
    else
        self.discontinued:SetActive(false)
    end

    self:ShowSymbol(data.flagData, customTagModel)
end

function CardView:ShowSymbol(flagData, customTagModel)
    self:HideAllSymbol()
    if self:CheckCustomTag(customTagModel) then return end
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
        self.cardIDTxt.text = lang.trans("transferMarket_letter", flagData.showPlayerLetter or "")   
    elseif isActivityLetter then
        isShow = true
        self.iconSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Images/PlayerLetter.png")
        self.cardIDTxt.text = lang.trans("transferMarket_letter", lang.transstr("menu_activity"))
    elseif isShowChemical then
        GameObjectHelper.FastSetActive(self.chemical, true)
    elseif isShowBestPartener then
        GameObjectHelper.FastSetActive(self.bestPartner, true)
    elseif isShowHeroHall then
        isShow = true
        self.iconSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/HonorPalace/Images/Trophy.png")
        self.cardIDTxt.text = lang.trans("hero_hall_card")
    end
    GameObjectHelper.FastSetActive(self.message, isShow)
end

-- 自定义标记
function CardView:CheckCustomTag(customTagModel)
    local state = false
    if customTagModel then
        local cid = self.data.cid
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

function CardView:HideAllSymbol()
    GameObjectHelper.FastSetActive(self.bestPartner, false)
    GameObjectHelper.FastSetActive(self.chemical, false)
    GameObjectHelper.FastSetActive(self.message, false)
end

return CardView


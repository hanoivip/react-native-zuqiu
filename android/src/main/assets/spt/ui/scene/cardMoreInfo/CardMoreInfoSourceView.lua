local Text = clr.UnityEngine.UI.Text
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardMoreInfoSourceView = class(unity.base)

local path = "Assets/CapstonesRes/Game/UI/Scene/CardMoreInfo/GetPlayerPath.prefab"

function CardMoreInfoSourceView:ctor()
    self.transferLvlTxt = self.___ex.transferLvlTxt
    self.transferIsUnlock =self.___ex.transferIsUnlock
    self.transferLock = self.___ex.transferLock
    self.sourceRoot = self.___ex.sourceRoot
    self.extraUnlock = self.___ex.extraUnlock
    self.extraLock = self.___ex.extraLock
    self.transfer = self.___ex.transfer
    self.elseLock = self.___ex.elseLock
    self.scoutLock = self.___ex.scoutLock
end

function CardMoreInfoSourceView:InitView(cardModel, playerData)
    local isValid = cardModel:GetValid()
    local transferCondition = cardModel:GetTransferCondition()
    if not isValid or transferCondition == "none" then
        -- 均不显示
        self.transfer:SetActive(false)
    else
        local isScout = cardModel:IsCanByScoutGain()
        local isElse = cardModel:IsCanByElseGain()
        GameObjectHelper.FastSetActive(self.scoutLock, isScout)
        GameObjectHelper.FastSetActive(self.elseLock, isElse)
        self.transferLvlTxt.text = lang.trans("scout_player_level", transferCondition)
    end

    local isGacha = cardModel:IsCanByGachaGain()
    if isGacha then
        local obj = res.Instantiate(path)
        local txt = obj:GetComponentInChildren(Text)
        obj.transform:SetParent(self.sourceRoot, false)
        txt.text = lang.trans("card_get_style_gacha")
    end

    local cardAccess = cardModel:GetTheWayOfGainTheCard()
    if type(cardAccess) == "table" then
        for k, v in pairs(cardAccess) do
            local obj = res.Instantiate(path)
            local txt = obj:GetComponentInChildren(Text)
            obj.transform:SetParent(self.sourceRoot, false)
            txt.text = v
        end
    end

    GameObjectHelper.FastSetActive(self.transferIsUnlock, playerData.scoutUnlock)
    GameObjectHelper.FastSetActive(self.transferLock, not playerData.scoutUnlock)
    GameObjectHelper.FastSetActive(self.extraUnlock, playerData.extraUnlock)
    GameObjectHelper.FastSetActive(self.extraLock, not playerData.extraUnlock)
end

return CardMoreInfoSourceView

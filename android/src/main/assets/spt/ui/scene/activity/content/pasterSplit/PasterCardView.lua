local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local PasterCardView = class(LuaButton)

function PasterCardView:ctor()
    PasterCardView.super.ctor(self)
    self.cardParent = self.___ex.cardParent
    self.desc = self.___ex.desc
    self.nameTxt = self.___ex.name
    self.sign = self.___ex.sign
    self.imageObj = self.___ex.imageObj
end

function PasterCardView:start()
    self:regOnButtonClick(function()
        self:OnPasterClick()
    end)
end

function PasterCardView:OnPasterClick()
    if self.clickCardPaster then
        self.clickCardPaster(self.index, self.cardPasterModel)
    end
end

function PasterCardView:SetActiveSelectedTag(isSelected)
    GameObjectHelper.FastSetActive(self.selectedTag, isSelected)
end

function PasterCardView:InitView(cardPasterModel, cardResourceCache, pasterRes)
    -- Card
    self.cardPasterModel = cardPasterModel
    if not self.pasterView then
        local cardObject = Object.Instantiate(pasterRes)
        self.pasterView = res.GetLuaScript(cardObject)
        cardObject.transform:SetParent(self.cardParent.transform, false)
        self.pasterView:SetCardResourceCache(cardResourceCache)
    end
    self.pasterView:InitView(cardPasterModel)
    self.nameTxt.text = cardPasterModel:GetName()
    local pasterType = cardPasterModel:GetPasterType()
    self.sign.overrideSprite = AssetFinder.GetPasterIdentity(pasterType)
    self.sign:SetNativeSize()
end

function PasterCardView:UpdateItemIndex(index)
    self.index = index
end

function PasterCardView:SetImgeObjActive(isShow)
    GameObjectHelper.FastSetActive(self.imageObj, isShow)
end

return PasterCardView

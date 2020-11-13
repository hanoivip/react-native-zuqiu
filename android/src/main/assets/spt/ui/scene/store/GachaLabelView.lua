local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local CommonConstants = require("ui.common.CommonConstants")
local AssetFinder = require("ui.common.AssetFinder")
local GachaLabelView = class(LuaButton)

function GachaLabelView:ctor()
    GachaLabelView.super.ctor(self)
    self.title = self.___ex.title
    self.title1 = self.___ex.title1
    self.redPoint = self.___ex.redPoint
    self.recommand = self.___ex.recommand
    self.icon = self.___ex.icon
    self.gradientTextEffect = self.___ex.gradientTextEffect
    self.newLogo = self.___ex.newLogo
end

function GachaLabelView:Init(title, showRedPoint, tag, layout)
    self:InitButtonState()
    self.curTag = tag
    self.title.text = tostring(title)
    self.title1.text = tostring(title)
    self:SetRedPoint(showRedPoint)
    GameObjectHelper.FastSetActive(self.recommand, self.curTag == CommonConstants.GachaTimeLimitDiscountID)
    EventSystem.AddEvent("Change_Gacha_Label", self, self.ChangeState)
    self.newLogo:SetActive(self.curTag == "B2")
    self.icon.overrideSprite = AssetFinder.GetStoreGachaIconByLayout(layout)
end

function GachaLabelView:InitButtonState()
    self:unselectBtn()
    self:onPointEventHandle(true)
end

function GachaLabelView:SetRedPoint(showRedPoint)
    self.redPoint:SetActive(tobool(showRedPoint))
end

function GachaLabelView:ChangeState(tag)
    -- self.gradientTextEffect.enabled = (self.curTag == tag and self.curTag == CommonConstants.GachaTimeLimitDiscountID)
end

function GachaLabelView:onDestroy()
    EventSystem.RemoveEvent("Change_Gacha_Label", self, self.ChangeState)
end

return GachaLabelView


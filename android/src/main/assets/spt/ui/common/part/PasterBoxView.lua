local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local PasterMainType = require("ui.scene.paster.PasterMainType")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local PasterBoxView = class(unity.base)

function PasterBoxView:ctor()
    -- 图标
    self.icon = self.___ex.icon
    -- 品级框
    self.qualityBorder = self.___ex.qualityBorder
    -- 名称
    self.nameTxt = self.___ex.name
    self.nameShadow = self.___ex.nameShadow
    self.sign = self.___ex.sign
    self.pasterModel = nil
    -- 是否显示名称
    self.isShowName = false
    -- 是否要显示详情板
    self.isShowDetail = false
    self.btnClick = self.___ex.btnClick
    self.symbol = self.___ex.symbol
end

function PasterBoxView:InitView(pasterModel, isShowName, isShowDetail, isShowSymbol)
    self.pasterModel = pasterModel
    self.isShowName = isShowName or false
    self.isShowDetail = isShowDetail or false
    self.isShowSymbol = true
    if isShowSymbol == false then
     self.isShowSymbol = isShowSymbol
    end
    self:BuildPage()
end

function PasterBoxView:start()
    if self.isShowDetail then
        self.btnClick:regOnButtonClick(function()
            self:OnPasterClick()
        end)
    end
end

function PasterBoxView:BuildPage()
    self.icon.overrideSprite = AssetFinder.GetPlayerIcon(self.pasterModel:GetAvatar())
    local fixQuality = CardHelper.GetQualityFixed(self.pasterModel:GetPasterQuality(), self.pasterModel:GetPasterQualitySpecial())
    local mainType = self.pasterModel:GetPasterType()

    self.qualityBorder.overrideSprite = AssetFinder.GetPasterQualityOnType(fixQuality, mainType)
    self.nameTxt.text = self.pasterModel:GetName()
    GameObjectHelper.FastSetActive(self.nameTxt.gameObject, self.isShowName)

    self.sign.overrideSprite = AssetFinder.GetPasterIdentity(mainType)
    
    local cardPastersMapModel = CardPastersMapModel.new()
    local hasSamePaster = cardPastersMapModel:HasSamePaster(self.pasterModel) and self.isShowSymbol
    GameObjectHelper.FastSetActive(self.symbol, hasSamePaster)
end

--- 设置名称颜色
function PasterBoxView:SetNameColor(nameColor, nameShadowColor)
    self.nameTxt.color = nameColor
    self.nameShadow.effectColor = nameShadowColor
end

--- 设置名称字号
function PasterBoxView:SetNumFont(numFont)
    self.nameTxt.fontSize = numFont
end

function PasterBoxView:OnPasterClick()
    res.PushDialog("ui.controllers.paster.PasterDetailCtrl", self.pasterModel)
end

return PasterBoxView
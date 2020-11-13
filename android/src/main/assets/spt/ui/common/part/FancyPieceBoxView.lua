local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local FancyPieceBoxView = class(unity.base)

function FancyPieceBoxView:ctor()
--------Start_Auto_Generate--------
    self.fancyPieceTrans = self.___ex.fancyPieceTrans
    self.iconImg = self.___ex.iconImg
    self.nameTxt = self.___ex.nameTxt
    self.addNumTrans = self.___ex.addNumTrans
    self.addNumTxt = self.___ex.addNumTxt
    self.clickAreaBtn = self.___ex.clickAreaBtn
--------End_Auto_Generate----------
    self.nameShadow = self.___ex.nameShadow
end

function FancyPieceBoxView:InitView(fancyPieceModel, isShowName, isShowAddNum, isShowDetail)
    self.fancyPieceModel = fancyPieceModel 
    self.isShowName = isShowName or false
    self.isShowAddNum = isShowAddNum or false
    self.isShowDetail = isShowDetail or false
    self:BuildPage()
end

function FancyPieceBoxView:start()
    self:ResetAddNumSize()
    if self.isShowDetail then
        self.clickAreaBtn:regOnButtonClick(function()
            self:OnCardPieceBoxClick()
        end)
    end
end

function FancyPieceBoxView:BuildPage()
    self.iconImg.sprite = AssetFinder.GetItemIcon(self.fancyPieceModel:GetIconIndex())
    self.nameTxt.text = self.fancyPieceModel:GetName()
    GameObjectHelper.FastSetActive(self.nameTxt.gameObject, self.isShowName)

    if self.isShowAddNum then
        local addNum = self.fancyPieceModel:GetAddNum() or 0
        self.addNumTxt.text = "x" .. string.formatNumWithUnit(addNum)
    end
    GameObjectHelper.FastSetActive(self.addNumTrans.gameObject, self.isShowAddNum)
end

function FancyPieceBoxView:ResetAddNumSize()
    self:coroutine(function ()
        unity.waitForEndOfFrame()
        local boxRect = self.fancyPieceTrans.rect
        if boxRect.width ~= 82 then
            local scaleFactor = boxRect.width / 82
            scaleFactor = (scaleFactor - 1) / 2 + 1
            self.addNumTxt.fontSize = math.floor(16 * scaleFactor)
            local addNumSize = self.addNumTrans.sizeDelta
            self.addNumTrans.sizeDelta = Vector2(addNumSize.x, addNumSize.y * scaleFactor)
        end
    end)
end

--- 设置名称颜色
function FancyPieceBoxView:SetNameColor(nameColor, nameShadowColor)
    self.nameTxt.color = nameColor
    self.nameShadow.effectColor = nameShadowColor
end

--- 设置名称字号
function FancyPieceBoxView:SetNumFont(numFont)
    self.isFixNumFont = true
    self.addNumTxt.fontSize = numFont
    self.nameTxt.fontSize = numFont
end

function FancyPieceBoxView:OnCardPieceBoxClick()
    res.PushDialog("ui.controllers.fancy.fancyStore.FancyPieceDetailCtrl", self.fancyPieceModel)
end

return FancyPieceBoxView

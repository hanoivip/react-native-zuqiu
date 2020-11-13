local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2

local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local MarblesExchangeItemBoxView = class(unity.base)

function MarblesExchangeItemBoxView:ctor()
    -- 图标
    self.icon = self.___ex.icon
    -- 品级框
    self.qualityBorder = self.___ex.qualityBorder
    -- 名称
    self.nameTxt = self.___ex.name
    -- 名称阴影
    self.nameShadow = self.___ex.nameShadow
    -- 获得的数量
    self.addNum = self.___ex.addNum
    self.addNumText = self.___ex.addNumText
    self.rectTrans = self.___ex.rectTrans
    self.itemModel = nil
    -- 是否显示名称
    self.isShowName = false
    -- 是否显示获得的数量
    self.isShowAddNum = false
    -- 是否要显示详情板
    self.isShowDetail = false
    self.btnClick = self.___ex.btnClick
    self.isFixNumFont = false
end

function MarblesExchangeItemBoxView:InitView(marblesExchangeItemModel, id, isShowName, isShowAddNum, isShowDetail, itemOriginType)
    self.marblesExchangeItemModel = marblesExchangeItemModel
    self.id = id
    self.isShowName = isShowName or false
    self.isShowAddNum = isShowAddNum or false
    self.isShowDetail = isShowDetail or false
    self.itemOriginType = itemOriginType
    self:BuildPage()
end

function MarblesExchangeItemBoxView:start()
    self:ResetAddNumSize()
    if self.isShowDetail then
        self.btnClick:regOnButtonClick(function()
            self:OnItemClick()
        end)
    end
end

function MarblesExchangeItemBoxView:BuildPage()
    self.icon.sprite = AssetFinder.GetMarblesExchangeItemIcon(self.marblesExchangeItemModel:GetIconIndex())
    self.qualityBorder.sprite = AssetFinder.GetItemQualityBoard(self.marblesExchangeItemModel:GetQuality())

    self.nameTxt.text = self.marblesExchangeItemModel:GetName()
    GameObjectHelper.FastSetActive(self.nameTxt.gameObject, self.isShowName)

    if self.isShowAddNum then
        local addNum = self.marblesExchangeItemModel:GetAddNum() or 0
        self.addNumText.text = "x" .. string.formatNumWithUnit(addNum)
        GameObjectHelper.FastSetActive(self.addNum.gameObject, true)
    else
        GameObjectHelper.FastSetActive(self.addNum.gameObject, false)
    end
end

function MarblesExchangeItemBoxView:ResetAddNumSize()
    if self.isFixNumFont then return end
    clr.coroutine(function ()
        unity.waitForEndOfFrame()
        local boxRect = self.rectTrans.rect
        if boxRect.width ~= 82 then
            local scaleFactor = boxRect.width / 82
            scaleFactor = (scaleFactor - 1) / 2 + 1
            self.addNumText.fontSize = math.floor(16 * scaleFactor)
            local addNumSize = self.addNum.sizeDelta
            self.addNum.sizeDelta = Vector2(addNumSize.x, addNumSize.y * scaleFactor)
        end
    end)
end

--- 设置名称颜色
function MarblesExchangeItemBoxView:SetNameColor(nameColor, nameShadowColor)
    self.nameTxt.color = nameColor
    self.nameShadow.effectColor = nameShadowColor
end

--- 设置名称字号
function MarblesExchangeItemBoxView:SetNumFont(numFont)
    self.isFixNumFont = true
    self.addNumText.fontSize = numFont
end

function MarblesExchangeItemBoxView:OnItemClick()
    res.PushDialog("ui.controllers.activity.content.marbles.MarblesItemDetailCtrl", self.marblesExchangeItemModel)
end

return MarblesExchangeItemBoxView
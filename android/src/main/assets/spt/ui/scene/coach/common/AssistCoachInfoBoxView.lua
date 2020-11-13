local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2

local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")
local CommonConstants = require("ui.common.CommonConstants")

local AssistCoachInfoBoxView = class(unity.base)

function AssistCoachInfoBoxView:ctor()
    -- 自己的rectTransform
    self.rectTrans = self.___ex.rectTrans
    -- 图标
    self.imgIcon = self.___ex.imgIcon
    -- 品级框
    self.imgQualityBorder = self.___ex.imgQualityBorder
    -- 名称
    self.txtName = self.___ex.txtName
    -- 名称阴影
    self.nameShadow = self.___ex.nameShadow
    -- 获得的数量
    self.rctAddNum = self.___ex.rctAddNum
    self.txtAddNum = self.___ex.txtAddNum
    -- 点击区域
    self.btnClick = self.___ex.btnClick

    self.itemModel = nil
    -- 是否显示名称
    self.isShowName = false
    -- 是否显示右上角数量，默认为当前数量
    self.isShowNum = false
    -- 是否显示获得的数量
    self.isShowAddNum = false
    -- 是否要显示详情板
    self.isShowDetail = false
    self.isFixNumFont = false
end

function AssistCoachInfoBoxView:InitView(coachItemModel, isShowName, isShowNum, isShowAddNum, isShowDetail)
    self.itemModel = coachItemModel
    self.id = self.itemModel:GetId()
    self.isShowName = isShowName or false
    self.isShowNum = isShowNum or false
    self.isShowAddNum = isShowAddNum or false
    self.isShowDetail = isShowDetail or false
    self:BuildPage()
end

function AssistCoachInfoBoxView:start()
    self:ResetAddNumSize()
    if self.isShowDetail then
        self.btnClick:regOnButtonClick(function()
            self:OnItemClick()
        end)
    end
end

function AssistCoachInfoBoxView:BuildPage()
    self.imgIcon.sprite = AssetFinder.GetCoachItemIcon(self.itemModel:GetIconIndex(), self.itemModel:GetCoachItemType())
    self.imgQualityBorder.sprite = AssetFinder.GetItemQualityBoard(self.itemModel:GetQuality())

    GameObjectHelper.FastSetActive(self.txtName.gameObject, self.isShowName)
    self.txtName.text = self.itemModel:GetName()

    if self.isShowNum then
        GameObjectHelper.FastSetActive(self.rctAddNum.gameObject, true)
        if self.isShowAddNum then
            local addNum = self.itemModel:GetAddNum() or 0
            self.txtAddNum.text = "x" .. string.formatNumWithUnit(addNum)
        else
            local num = self.itemModel:GetSum() or 0
            self.txtAddNum.text = "x" .. string.formatNumWithUnit(num)
        end
    else
        GameObjectHelper.FastSetActive(self.rctAddNum.gameObject, false)
    end
end

function AssistCoachInfoBoxView:ResetAddNumSize()
    if self.isFixNumFont then return end
    clr.coroutine(function ()
        unity.waitForEndOfFrame()
        if self.rectTrans then
            local boxRect = self.rectTrans.rect
            if boxRect.width ~= 82 then
                local scaleFactor = boxRect.width / 82
                scaleFactor = (scaleFactor - 1) / 2 + 1
                self.txtAddNum.fontSize = math.floor(16 * scaleFactor)
                local addNumSize = self.rctAddNum.sizeDelta
                self.rctAddNum.sizeDelta = Vector2(addNumSize.x, addNumSize.y * scaleFactor)
            end
        end
    end)
end

--- 设置名称颜色
function AssistCoachInfoBoxView:SetNameColor(nameColor, nameShadowColor)
    self.txtName.color = nameColor
    self.nameShadow.effectColor = nameShadowColor
end

--- 设置名称字号
function AssistCoachInfoBoxView:SetNumFont(numFont)
    self.isFixNumFont = true
    self.txtAddNum.fontSize = numFont
end

function AssistCoachInfoBoxView:OnItemClick()
    -- local MenuType = require("ui.controllers.itemList.MenuType")
    -- res.PushDialog("ui.controllers.itemList.OtherItemDetailCtrl", MenuType.TACTIC, self.itemModel)
end

return AssistCoachInfoBoxView
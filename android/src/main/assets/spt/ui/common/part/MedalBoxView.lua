local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2

local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local MedalBoxView = class(unity.base)

function MedalBoxView:ctor()
    self.medalQuality = self.___ex.medalQuality
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
    self.medalModel = nil
    -- 是否显示名称
    self.isShowName = false
    -- 是否显示获得的数量
    self.isShowAddNum = false
    -- 是否要显示详情板
    self.isShowDetail = false
    self.btnClick = self.___ex.btnClick
    self.isFixNumFont = false
end

function MedalBoxView:InitView(medalModel, isShowName, isShowAddNum, isShowDetail)
    self.medalModel = medalModel
    self.isShowName = isShowName or false
    self.isShowAddNum = isShowAddNum or false
    self.isShowDetail = isShowDetail or false
    self:BuildPage()
end

function MedalBoxView:start()
    self:ResetAddNumSize()
    if self.isShowDetail then
        self.btnClick:regOnButtonClick(function()
            self:OnMedalClick()
        end)
    end
end

function MedalBoxView:BuildPage()
    local quality = self.medalModel:GetQuality()
    self.medalQuality.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/Medal_Quality" .. quality .. ".png")
    local boxQuality = self.medalModel:GetBoxQuality()
    self.qualityBorder.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/ItemQualityBoard/quality_board" .. boxQuality .. ".png")
    local picIndex = self.medalModel:GetPic()
    self.icon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex .. ".png")
    self.nameTxt.text = self.medalModel:GetName()

    GameObjectHelper.FastSetActive(self.nameTxt.gameObject, self.isShowName)

    if self.isShowAddNum then
        local addNum = self.medalModel:GetAddNum() or 0
        self.addNumText.text = "x" .. string.formatNumWithUnit(addNum)
        GameObjectHelper.FastSetActive(self.addNum.gameObject, true)
    else
        GameObjectHelper.FastSetActive(self.addNum.gameObject, false)
    end
end

function MedalBoxView:ResetAddNumSize()
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
function MedalBoxView:SetNameColor(nameColor, nameShadowColor)
    self.nameTxt.color = nameColor
    self.nameShadow.effectColor = nameShadowColor
end

--- 设置名称字号
function MedalBoxView:SetNumFont(numFont)
    self.isFixNumFont = true
    self.addNumText.fontSize = numFont
end

function MedalBoxView:OnMedalClick()
    res.PushDialog("ui.controllers.medal.MedalDetailCtrl", self.medalModel)
end

return MedalBoxView
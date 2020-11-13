local LuaButton = require("ui.control.button.LuaButton")
local Timer = require("ui.common.Timer")
local Object = clr.UnityEngine.Object
local Color = clr.UnityEngine.Color
local GiftBoxItemView = class(LuaButton)

local GameObjectHelper = require("ui.common.GameObjectHelper")

local Path = "Assets/CapstonesRes/Game/UI/Scene/Store/Images/%s.png"
local SupremeCardPath = "Assets/CapstonesRes/Game/UI/Scene/Charge/Image/MonthCardBig.png"

function GiftBoxItemView:ctor()
    GiftBoxItemView.super.ctor(self)

    self.activityTip = self.___ex.activityTip
    self.rewardType = self.___ex.rewardType
    self.goldenTitle = self.___ex.goldenTitle
    self.blueTitle = self.___ex.blueTitle
    self.oldPrice = self.___ex.oldPrice
    self.price = self.___ex.price
    self.bgImg = self.___ex.bgImg
    self.desc0Txt = self.___ex.desc0Txt
    self.animator = self.___ex.animator
    self.bayernTitle = self.___ex.bayernTitle
    self.realTitle = self.___ex.realTitle
    self.bdkPay = self.___ex.bdkPay
    self.bdkPriceTxt = self.___ex.bdkPriceTxt
    self.bdkPay1 = self.___ex.bdkPay1
    self.recommend = self.___ex.recommend
    self.timeLimit = self.___ex.timeLimit
    self.purchased = self.___ex.purchased
    self.supremeCardTitle =  self.___ex.supremeCardTitle
    self.residualTime = nil

    self.SupremeCardIndex = "m900_1"
end

function GiftBoxItemView:InitView(model, isBufeng, isClickShow)
    self.model = model
    self.isBufeng = isBufeng
    self:InitCommonElement(model)
    self:InitDifferenceElement(model)

    self:regOnButtonClick(function()
        self:RegOnButtonClick() end
    )

    if model:GetLastTime() then
        self:UpdateResidualTime()
    end

    if isBufeng then
        self.animator:Play("GiftBoxItemLightAnimation")
    end

    if isClickShow then
        self:RegOnButtonClick()
    end
end

function GiftBoxItemView:UpdateResidualTime()
    if self.residualTime ~= nil then
        self.residualTime:Destroy()
    end
    self.residualTime = Timer.new(self.model:GetLastTime(), function (time)
        self.model:SetLastTime(time)
    end)
end

function GiftBoxItemView:InitCommonElement(model)
    self.picIndex = model:GetRewardPicIndex()
    if self.picIndex ~= self.SupremeCardIndex then
    -- 奖励类型
        self.rewardType.overrideSprite = res.LoadRes(format(Path, model:GetRewardPicIndex()))
    else
        self.rewardType.overrideSprite = res.LoadRes(SupremeCardPath)
    end
    -- 左上角标
    local flagType = model:GetFlag()
    local isCanBuy = model:IsCanBuy()
    if flagType == 1 and isCanBuy then
        self.activityTip.overrideSprite = res.LoadRes(format(Path, "Time_limit"))
        self.timeLimit:SetActive(true)
    elseif flagType == 2 and isCanBuy then
        self.activityTip.overrideSprite = res.LoadRes(format(Path, "Command"))
        self.recommend:SetActive(true)
    elseif flagType == 0 and isCanBuy then
        GameObjectHelper.FastSetActive(self.activityTip.gameObject, false)
    else
        self.activityTip.overrideSprite = res.LoadRes(format(Path, "Purchased"))
        self.purchased:SetActive(true)
    end
    self.desc0Txt.text = model:GetDesc0()

    local isRMB = model:GetPayType()
    isRMB = tonumber(isRMB) == 1
    if isRMB then
        self.oldPrice.text = lang.transstr("discountStore_originPrice") .. "：¥ " .. model:GetOldPrice()
        GameObjectHelper.FastSetActive(self.bdkPay, false)
        self.price.text = "¥ " .. model:GetPrice()
        GameObjectHelper.FastSetActive(self.bdkPay1, false)
    else
        self.oldPrice.text = tostring(model:GetOldPrice())
        GameObjectHelper.FastSetActive(self.bdkPay, true)
        self.bdkPriceTxt.text = lang.transstr("discountStore_originPrice") .. "："

        self.price.text = tostring(model:GetPrice())
        GameObjectHelper.FastSetActive(self.bdkPay1, true)
    end
end

function GiftBoxItemView:InitDifferenceElement(model)
    local boardColor = model:GetBoard()
    local isCanBuy = model:IsCanBuy()
    if boardColor == 1 then
        self.bgImg.overrideSprite = res.LoadRes(format(Path, "BG_Golden"))
        self.goldenTitle.text = model:GetTitle()
        GameObjectHelper.FastSetActive(self.goldenTitle.gameObject, true)
        if self.isBufeng == nil then
            self.animator:Play("GiftBoxItemIdleGoldAnimation")
        end
    elseif boardColor == 2 then
        self.bgImg.overrideSprite = res.LoadRes(format(Path, "BG_Blue"))
        self.blueTitle.text = model:GetTitle()
        GameObjectHelper.FastSetActive(self.blueTitle.gameObject, true)
        if self.isBufeng == nil then
            self.animator:Play("GiftBoxItemIdleBlueAnimation")
        end
    elseif boardColor == 3 then
        self.bgImg.overrideSprite = res.LoadRes(format(Path, "BG_Bayern"))
        self.bayernTitle.text = model:GetTitle()
        GameObjectHelper.FastSetActive(self.bayernTitle.gameObject, true)
        if self.isBufeng == nil then
            self.animator:Play("GiftBoxItemIdleBlueAnimation")
        end
    elseif boardColor == 4 then
        self.bgImg.overrideSprite = res.LoadRes(format(Path, "BG_RealMadrid"))
        self.realTitle.text = model:GetTitle()
        GameObjectHelper.FastSetActive(self.realTitle.gameObject, true)
    elseif boardColor == 5 then
        self.bgImg.overrideSprite = res.LoadRes(format(Path, "BG_SupreCard"))
        self.supremeCardTitle.text = model:GetTitle()
        GameObjectHelper.FastSetActive(self.supremeCardTitle.gameObject, true)
    elseif boardColor == 6 then
        self.bgImg.overrideSprite = res.LoadRes(format(Path, "BG_Barcelona"))
        self.bayernTitle.text = model:GetTitle()
        GameObjectHelper.FastSetActive(self.bayernTitle.gameObject, true)
    end
    if not isCanBuy then
        self.bgImg.color = Color(0, 1, 1, 1)
    end
end

function GiftBoxItemView:RegOnButtonClick()
    if self.picIndex ~= self.SupremeCardIndex then
        res.PushDialog("ui.controllers.store.GiftBoxItemPopCtrl", self.model)
    else
        res.PushDialog("ui.controllers.store.SupremeMonthCardCtrl", self.model)
    end
end

function GiftBoxItemView:onDestroy()
    if self.residualTime ~= nil then
        self.residualTime:Destroy()
    end
end

return GiftBoxItemView

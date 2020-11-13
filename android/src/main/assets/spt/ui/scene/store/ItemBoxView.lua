local CommonConstants = require("ui.common.CommonConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local ItemBoxView = class(unity.base)

function ItemBoxView:ctor()
    self.nameTxt = self.___ex.name
    self.number = self.___ex.number
    self.diamond = self.___ex.diamond
    self.money = self.___ex.money
    self.strength = self.___ex.strength
    self.bagLimit = self.___ex.bagLimit
    self.train = self.___ex.train
    self.sweep = self.___ex.sweep
end

function ItemBoxView:InitView(itemModel, id)
    self.itemModel = itemModel
    self.id = id
    
    self:BuildPage()
end

function ItemBoxView:start()
end

function ItemBoxView:BuildPage()
    self.nameTxt.text = self.itemModel:GetName()

    local addNum = self.itemModel:GetAddNum() or 0
    addNum = string.formatNumWithUnit(addNum)

    if tonumber(self.id) == CommonConstants.MoneyItemId then
        -- money
        self.money:SetActive(true)
    elseif tonumber(self.id) == CommonConstants.DiamondItemId then
        -- diamond
        self.diamond:SetActive(true)
    elseif tonumber(self.id) == CommonConstants.StrengthItemId then
        -- strength
        self.strength:SetActive(true)
    elseif tonumber(self.id) == CommonConstants.BagLimitItemId then
        self.bagLimit:SetActive(true)
    elseif tonumber(self.id) == CommonConstants.TrainItemId then
        self.train:SetActive(true)
    elseif tonumber(self.id) == CommonConstants.SweepItemId then
        self.sweep:SetActive(true)
    end
    self.number.text = "x " .. addNum
end

return ItemBoxView


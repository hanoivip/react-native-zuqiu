local DialogManager = require("ui.control.manager.DialogManager")

local GiftBoxCounterView = class(unity.base, "GiftBoxCounterView")

function GiftBoxCounterView:ctor()
    self.txtTitle = self.___ex.txtTitle
    self.btnMinus = self.___ex.btnMinus
    self.txtNumber = self.___ex.txtNumber
    self.btnAdd = self.___ex.btnAdd
    self.btnMax = self.___ex.btnMax
end

--[[
data = {
    maxCount    -- 最大数量，默认不超过50，或item表配置
    configMaxCount    -- 配置的最大数量
}
]]
local Default_Max_Use_Num = 50 -- 默认批量使用最大值

function GiftBoxCounterView:InitView(data)
    self.data = data
    self:NormalizeMaxCount()

    self.currCount = 1
    self:UpdateNumberText()
end

function GiftBoxCounterView:start()
    local pressAddData = {
        acceleration = 1,   -- 加速度，执行的越来越快
        clickCallback = function()
            self:AddCount()
        end,
        durationCallback = function(count)
            self:AddCount()
        end,
    }
    self.btnAdd:regOnButtonPressing(pressAddData)
    self.btnAdd:regOnButtonUp(function()
        self.hasShownDiamondNotEnough = false
    end)

    local pressMinusData = {
        acceleration = 1,   -- 加速度，执行的越来越快
        clickCallback = function()
            self:MinusCount()
        end,
        durationCallback = function(count)
            self:MinusCount()
        end,
    }
    self.btnMinus:regOnButtonPressing(pressMinusData)

    self.btnMax:regOnButtonClick(function()
        self:OnClickMax()
    end)
end

function GiftBoxCounterView:UpdateNumberText()
    self.txtNumber.text = tostring(self.currCount)
end

function GiftBoxCounterView:AddCount()
    if self.currCount >= self.data.maxCount then
        DialogManager.ShowToastByLang("exchange_item_detail_multi_max")
    else
        self.currCount = self.currCount + 1
        self:UpdateNumberText()
    end
end

function GiftBoxCounterView:MinusCount()
    if self.currCount > 1 then
        self.currCount = self.currCount - 1
        self:UpdateNumberText()
    end
end

function GiftBoxCounterView:OnClickMax()
    self.currCount = self.data.maxCount
    self:UpdateNumberText()
end

function GiftBoxCounterView:GetCurrCount()
    return self.currCount
end

function GiftBoxCounterView:Refresh(data)
    self.data = data
    self:NormalizeMaxCount()

    if self.currCount > self.data.maxCount then self.currCount = self.data.maxCount end
    self:UpdateNumberText()
end

function GiftBoxCounterView:NormalizeMaxCount()
    if self.data.maxCount == nil or self.data.maxCount <= 0 then
        self.data.maxCount = 1
    end
    if self.data.configMaxCount == nil or self.data.configMaxCount <= 0 then
        self.data.configMaxCount = Default_Max_Use_Num
    end
    self.data.maxCount = math.clamp(self.data.maxCount, 1, self.data.configMaxCount)
end

return GiftBoxCounterView
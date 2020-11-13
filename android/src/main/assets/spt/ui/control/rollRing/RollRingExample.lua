local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local RollRingData = require("ui.control.rollRing.RollRingData")
local RollRingExample = class(unity.base)
--      3
--    4   2
--      1
-- 顺时针为正，但是 索引是以逆时针排序
function RollRingExample:ctor()
    self.rollRingCtrl = self.___ex.rollRingCtrl
    self.rollObjects = self.___ex.rollObjects
    self.nextButton = self.___ex.nextButton
    self.preButton = self.___ex.preButton
    self.scrollButton = self.___ex.scrollButton
    self.scrollImmediatelyButton = self.___ex.scrollImmediatelyButton
    self.scorllRandomIndex = 1
    self.scorllImmediatelyRandomIndex = 1
    self:Init()
end

local RollData =
{
    { key = "p1", positionX = 0, positionY = 0, scale = 0.95, alpha = 1, order = 3 },
    { key = "p2", positionX = 200, positionY = 0, scale = 0.8, alpha = 0.6, order = 2 },
    { key = "p3", positionX = 0, positionY = 0, scale = 0.6, alpha = 0, order = 1 },
    { key = "p4", positionX = - 200, positionY = 0, scale = 0.8, alpha = 0.6, order = 2 },
}

function RollRingExample:Init()
    for i, v in ipairs(RollData) do
        self.rollRingCtrl:AddRollRingData(RollRingData.new(v.positionX, v.positionY, v.scale, v.alpha, v.order, self.rollObjects[v.key]))
    end
    self.rollRingCtrl.ResetItem = function(selector, object, externalId)
        self:ResetItem(object, externalId)
    end

    self.rollRingCtrl:Init()
end

function RollRingExample:start()
    self.nextButton:regOnButtonClick(function()
        self.rollRingCtrl:RollNextItem()
    end)

    self.preButton:regOnButtonClick(function()
        self.rollRingCtrl:RollPreItem()
    end)

    self:ChangeScrollImmediatelyText()
    self.scrollImmediatelyButton:regOnButtonClick(function()
        self.rollRingCtrl:RollToItemImmediately(self.scorllImmediatelyRandomIndex)
        self:ChangeScrollImmediatelyText()
    end)

    self:ChangeScrollText()
    self.scrollButton:regOnButtonClick(function()
        self.rollRingCtrl:RollToItem(self.scorllRandomIndex)
        self:ChangeScrollText()
    end)
end

function RollRingExample:ChangeScrollImmediatelyText()
    self.scorllImmediatelyRandomIndex = math.random(1, self.rollRingCtrl.elementCount)
    self.scrollImmediatelyButton.transform:GetChild(0):GetComponent(Text).text = 'immediatelyScrollTo' .. self.scorllImmediatelyRandomIndex
end

function RollRingExample:ChangeScrollText()
    self.scorllRandomIndex = math.random(1, self.rollRingCtrl.elementCount)
    self.scrollButton.transform:GetChild(0):GetComponent(Text).text = 'ScrollTo' .. self.scorllRandomIndex
end

function RollRingExample:ResetItem(object, externalId)
    object.transform:GetChild(0):GetComponent(Text).text = externalId
end

return RollRingExample


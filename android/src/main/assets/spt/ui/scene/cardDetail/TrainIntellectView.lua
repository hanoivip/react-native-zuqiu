local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local TrainIntellectView = class(unity.base)

function TrainIntellectView:ctor()
    self.btnClose = self.___ex.btnClose
    self.potentNum = self.___ex.potentNum
    self.vitamin = self.___ex.vitamin
    self.attrMap = self.___ex.attrMap
    self.attrText = self.___ex.attrText
    self.useNum = self.___ex.useNum
    self.btnSub = self.___ex.btnSub
    self.btnPlus = self.___ex.btnPlus
    self.btnTrain = self.___ex.btnTrain
    self.subButton = self.___ex.subButton
    self.plusButton = self.___ex.plusButton
    self.costVitaminNum = 1
    self.selectAttrMap = {}
    self.pentagonOrder = {}
end

function TrainIntellectView:start()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnTrain:regOnButtonClick(function()
        self:OnBtnTrain()
    end)
    self.btnSub:regOnButtonClick(function()
        self:OnSubClick()
    end)
    self.btnSub:regOnButtonDown(function()
        self:OnSubDown()
    end)
    self.btnSub:regOnButtonUp(function()
        self:OnSubUp()
    end)
    self.btnPlus:regOnButtonClick(function()
        self:OnPlusClick()
    end)
    self.btnPlus:regOnButtonDown(function()
        self:OnPlusDown()
    end)
    self.btnPlus:regOnButtonUp(function()
        self:OnPlusUp()
    end)
    for key, v in pairs(self.attrMap) do
        local index = tonumber(string.sub(key, 2))
        v:regOnButtonClick(function()
            local abilityIndex = self.pentagonOrder[index]
            local currentState = not self.selectAttrMap[abilityIndex]
            self.selectAttrMap[abilityIndex] = currentState
            v:OnBtnSign(currentState)
            self:UpdateAttrText()
        end)
    end

    DialogAnimation.Appear(self.transform)
end

function TrainIntellectView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function TrainIntellectView:InitView(cardDetailModel, itemsMapModel)
    self.itemsMapModel = itemsMapModel
    self.cardModel = cardDetailModel:GetCardModel()
    local potent = self.cardModel:GetStaticPotential() - self.cardModel:GetConsumePotent() + self.cardModel:GetLegendPotentImprove()
    if potent < 0 then
        potent = 0
    end
    self.potentNum.text = tostring(potent)
    self.vitamin.text = "x" .. self.itemsMapModel:GetItemNum(1)
    self.attrText.text = lang.trans("train_intellect_introduce1")
    if self.cardModel:IsGKPlayer() then
        self.pentagonOrder = CardHelper.GoalKeeperOrder
    else
        self.pentagonOrder = CardHelper.NormalPlayerOrder
    end
    for key, v in pairs(self.attrMap) do
        local index = tonumber(string.sub(key, 2))
        local abilityIndex = self.pentagonOrder[tonumber(index)]
        local base, plus, train = self.cardModel:GetAbility(abilityIndex)
        v:InitView(abilityIndex, train)
        self.selectAttrMap[abilityIndex] = false
    end
    self:UpdateVitaminCost()
end

function TrainIntellectView:OnBtnTrain()
    if self.clickTrain then 
        self.clickTrain(self.selectAttrMap, self.costVitaminNum)
    end
end

function TrainIntellectView:OnSubClick()
    self.costVitaminNum = self.costVitaminNum - 1
    if self.costVitaminNum < 1 then
        self.costVitaminNum = 1
    end
    self:UpdateVitaminCost()
end

local WaitTime = 0.5
local WaitInterval = 0.5
local WaitInterval = 0.5
local IntervalTime = 0.08 -- 连续使用经验饮料时的间隔
local MinIntervalTime = 0.05 -- 连续使用经验饮料时的最小时间
function TrainIntellectView:OnSubDown()
    local waitInterval = WaitInterval
    self.isTouching = true
    self:coroutine(function()
        coroutine.yield(WaitForSeconds(WaitTime))
        while self.isTouching and self.costVitaminNum > 1 do
            self.costVitaminNum = self.costVitaminNum - 1
            if self.costVitaminNum < 1 then 
                self.costVitaminNum = 1
            end
            self:UpdateVitaminCost()
            coroutine.yield(UnityEngine.WaitForSeconds(waitInterval))
            waitInterval = waitInterval - IntervalTime
            if waitInterval < MinIntervalTime then
                waitInterval = MinIntervalTime
            end
        end
    end)
end

function TrainIntellectView:OnSubUp()
    self.isTouching = false
end

function TrainIntellectView:OnPlusClick()
    local vitaminNum = self.itemsMapModel:GetItemNum(1)
    self.costVitaminNum = self.costVitaminNum + 1
    if self.costVitaminNum > vitaminNum then
        self.costVitaminNum = vitaminNum
    end
    self:UpdateVitaminCost()
end

function TrainIntellectView:OnPlusDown()
    local vitaminNum = self.itemsMapModel:GetItemNum(1)
    local waitInterval = WaitInterval
    self.isTouching = true
    self:coroutine(function()
        coroutine.yield(WaitForSeconds(WaitTime))
        while self.isTouching and self.costVitaminNum < vitaminNum do
            self.costVitaminNum = self.costVitaminNum + 1
            if self.costVitaminNum > vitaminNum then 
                self.costVitaminNum = vitaminNum
            end
            self:UpdateVitaminCost()
            coroutine.yield(UnityEngine.WaitForSeconds(waitInterval))
            waitInterval = waitInterval - IntervalTime
            if waitInterval < MinIntervalTime then
                waitInterval = MinIntervalTime
            end
        end
    end)
end

function TrainIntellectView:OnPlusUp()
    self.isTouching = false
end

function TrainIntellectView:UpdateAttrText()
    local selectAttr = ""
    for abilityIndex, v in pairs(self.selectAttrMap) do
        if v then 
            if selectAttr ~= "" then 
                selectAttr = selectAttr .. "<color=#9CDC14>、</color>"
            end
            selectAttr = selectAttr .. "<color=#9CDC14>" .. lang.transstr(abilityIndex) .. "</color>"
        end
    end
    if selectAttr == "" then 
        self.attrText.text = lang.trans("train_intellect_introduce1")
    else
        self.attrText.text = lang.trans("train_intellect_introduce2", selectAttr) 
    end
end

function TrainIntellectView:UpdateVitaminCost()
    self.subButton.interactable = tobool(self.costVitaminNum > 1)
    self.plusButton.interactable = tobool(self.costVitaminNum < self.itemsMapModel:GetItemNum(1))
    if self.costVitaminNum == 0 then
        self.costVitaminNum = 1
    end
    self.useNum.text = tostring(self.costVitaminNum)
end

return TrainIntellectView
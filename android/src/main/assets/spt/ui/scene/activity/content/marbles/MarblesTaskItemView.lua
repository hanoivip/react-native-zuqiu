local GameObjectHelper = require("ui.common.GameObjectHelper")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local MarblesTaskItemView = class(unity.base)

function MarblesTaskItemView:ctor()
    self.btnReceive = self.___ex.btnReceive
    self.receiveButtonComponent = self.___ex.receiveButtonComponent
    self.buttonText = self.___ex.buttonText
    self.rewardDesc = self.___ex.rewardDesc
    self.gradientText = self.___ex.gradientText
    self.keyNumTxt = self.___ex.keyNumTxt
    self.recievedGo = self.___ex.recievedGo
    self.effectGo = self.___ex.effectGo
    self.nameTxt = self.___ex.nameTxt
end

function MarblesTaskItemView:start()
    self.btnReceive:regOnButtonClick(function()
        if self.clickReceive then
            self:OnClickBtn()
        end
    end)
end

function MarblesTaskItemView:SetButtonState(isOpen, canReceive)
    isOpen = isOpen or canReceive
    self.btnReceive:onPointEventHandle(isOpen)
    self.gradientText.enabled = isOpen
    self.receiveButtonComponent.interactable = isOpen
    local r, g, b 
    if isOpen then 
        r, g, b = 145, 125, 86
    else
        r, g, b = 125, 125, 125
    end
    local color = ColorConversionHelper.ConversionColor(r, g, b)
    self.buttonText.color = color
end

function MarblesTaskItemView:InitView(timeLimitStageShopTaskModel, receiveCallBack)
    self.model = timeLimitStageShopTaskModel
    self.clickReceive = receiveCallBack
    self.taskId = self.model:GetTaskId()
    local keysCount = self.model:GetKeyCount()
    local state = self.model:GetState()
    local desc = self.model:GetDesc()
    local btnState = self.model:GetButtonState()
    local isOpen = false
    local buttonDesc = lang.trans("collectReward")
    if btnState == -2 then
        isOpen = true
        buttonDesc = lang.trans("go_task")
    end
    self.buttonText.text = buttonDesc
    self.rewardDesc.text = desc
    self.keyNumTxt.text = "x" .. keysCount
    GameObjectHelper.FastSetActive(self.btnReceive.gameObject, state ~= 1)
    GameObjectHelper.FastSetActive(self.recievedGo, state == 1)
    GameObjectHelper.FastSetActive(self.effectGo, state == 0)
    self:SetButtonState(isOpen, tobool(state == 0))
end

function MarblesTaskItemView:OnClickBtn()
    local btnState = self.model:GetButtonState()
    if btnState == -2 then 
        res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
    else
        self.clickReceive(self.taskId)
    end
end

return MarblesTaskItemView

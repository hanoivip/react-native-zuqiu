local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local MGTaskItemView = class(unity.base)

function MGTaskItemView:ctor()
    self.btnReceive = self.___ex.btnReceive
    self.receiveButtonComponent = self.___ex.receiveButtonComponent
    self.buttonText = self.___ex.buttonText
    self.rewardDesc = self.___ex.rewardDesc
    self.gradientText = self.___ex.gradientText
    self.receivedGo = self.___ex.receivedGo
    self.effectGo = self.___ex.effectGo
    self.itemAreaTrans = self.___ex.itemAreaTrans
end

function MGTaskItemView:start()
    self.btnReceive:regOnButtonClick(function()
        if self.clickReceive then
            self:OnClickBtn()
        end
    end)
end

function MGTaskItemView:SetButtonState(isOpen, canReceive)
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

function MGTaskItemView:InitView(multiGetGiftTaskItemModel, receiveCallBack)
    self.model = multiGetGiftTaskItemModel
    self.activityModel = self.model:GetMultiGetGiftModel()
    self.clickReceive = receiveCallBack
    self.taskId = self.model:GetTaskId()
    self:RefreshContent()
    self:InitReward()
end

function MGTaskItemView:RefreshContent()
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
    GameObjectHelper.FastSetActive(self.btnReceive.gameObject, state ~= 1)
    GameObjectHelper.FastSetActive(self.receivedGo, state == 1)
    GameObjectHelper.FastSetActive(self.effectGo, state == 0)
    self:SetButtonState(isOpen, tobool(state == 0))
end

function MGTaskItemView:InitReward()
    local taskData = self.model:GetTaskData()
    res.ClearChildren(self.itemAreaTrans)
    local coinReward = taskData.coinReward
    local score = taskData.scoreReward
    taskData.contents = {}
    taskData.contents[CurrencyType.DayGiftCoin] = coinReward
    taskData.contents[CurrencyType.DayGiftScore] = score
    local rewardParams = {
        parentObj = self.itemAreaTrans,
        rewardData = taskData.contents,
        isShowName = true,
        isReceive = false,
        isShowSymbol = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        itemParams = {
            -- 名称颜色
            nameColor = Color.black,
            -- 名称阴影颜色
            nameShadowColor = Color.white,
            -- 个数字号
            numFont = 16,
        },
    }
    RewardDataCtrl.new(rewardParams)
end

function MGTaskItemView:OnClickBtn()
    local btnState = self.model:GetButtonState()
    if btnState == -2 then
        res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
    else
        local isTimeInActivity = self.activityModel:IsTimeInActivity()
        if not isTimeInActivity then
            return
        end
        local periodId = self.activityModel:GetPeriodId()
        self:coroutine(function()
            local response = req.multiGetGiftReceiveTask(periodId, self.taskId)
            if api.success(response) then
                local data = response.val
                local rewards = {}
                rewards[CurrencyType.DayGiftCoin] = data.coinReward
                rewards[CurrencyType.DayGiftScore] = data.scoreReward
                CongratulationsPageCtrl.new(rewards)
                self.model:RefreshData(data)
                --self:RefreshContent()
                self.clickReceive(data)
            end
        end)
    end
end

return MGTaskItemView

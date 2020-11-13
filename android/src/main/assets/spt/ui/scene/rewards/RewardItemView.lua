local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local VIP = require("data.VIP")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local RewardItemView = class(unity.base)

function RewardItemView:ctor()
    self.btnReceive = self.___ex.btnReceive
    self.receiveButtonComponent = self.___ex.receiveButtonComponent
    self.buttonText = self.___ex.buttonText
    self.rewardTitle = self.___ex.rewardTitle
    self.rewardDesc = self.___ex.rewardDesc
    self.itemArea = self.___ex.itemArea
    self.info = self.___ex.info
    self.gradientText = self.___ex.gradientText
    self.progressText = self.___ex.progressText
    self.progressGroup = self.___ex.progressGroup
    self.progressBar = self.___ex.progressBar
    self.border = self.___ex.border
end

function RewardItemView:start()
    self.btnReceive:regOnButtonClick(function()
        if self.clickReceive then
            self.clickReceive()
        end
    end)
end

function RewardItemView:SetButtonState(isOpen, canReceive)
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
    GameObjectHelper.FastSetActive(self.border.gameObject, canReceive)
end

local VipSweepTicket = 702 -- vip 扫荡券获取数量与vip对应
function RewardItemView:InitView(rewardItemModel)
    assert(rewardItemModel)

    local remainDays = rewardItemModel:GetRemainDays()
    local isOpen = false
    local additionalText = ""
    local buttonDesc = lang.trans("collectReward")
    if remainDays then
        -- （特殊处理）月卡需要开启按钮改变内容
        isOpen = true
        if remainDays > 0 then
            additionalText = lang.transstr("remain_time", remainDays)
        else
            buttonDesc = lang.trans("go_task")
        end
    elseif rewardItemModel:GetState() == -1 and rewardItemModel:IsJumpToAppointTask() then 
        isOpen = true
        buttonDesc = lang.trans("go_task")
    end
    self.buttonText.text = buttonDesc
    self.rewardTitle.text = tostring(rewardItemModel:GetTitle())
    self.rewardDesc.text = tostring(rewardItemModel:GetDesc()) .. additionalText
    self:SetButtonState(isOpen, tobool(rewardItemModel:GetState() == 0))
    if rewardItemModel:IsProgress() then
        GameObjectHelper.FastSetActive(self.progressGroup.gameObject, true)
        self.progressBar.value = tostring(rewardItemModel:GetValue() / rewardItemModel:GetCondition())
        self.progressText.text = tostring(rewardItemModel:GetValue()) .. "/" .. tostring(rewardItemModel:GetCondition())
    else
        GameObjectHelper.FastSetActive(self.progressGroup.gameObject, false)
    end

    local rewardContents = {}
    if rewardItemModel:GetRewardID() == VipSweepTicket then 
        rewardContents = { ["item"] = {} }
        local contents = rewardItemModel:GetRewardContents()
        local playerInfoModel = PlayerInfoModel.new()
        local vipLevel = playerInfoModel:GetVipLevel()
        for i, v in ipairs(contents.item) do
            local itemData = clone(v)
            itemData.num = VIP[vipLevel + 1].sweepItem
            table.insert(rewardContents.item, itemData)
        end
    else
        rewardContents = rewardItemModel:GetRewardContents()
    end

    self:Clear()
    local rewardParams = {
        parentObj = self.itemArea,
        rewardData = rewardContents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
    }
    RewardDataCtrl.new(rewardParams)
end

function RewardItemView:Clear()
    local contentTransform = self.itemArea.transform
    for i = contentTransform.childCount, 1, -1 do
        local childObject = contentTransform:GetChild(i - 1).gameObject
        Object.Destroy(childObject)
    end
end

return RewardItemView

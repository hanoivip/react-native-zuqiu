local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local Timer = require('ui.common.Timer')
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ItemType = require("ui.scene.itemList.ItemType")

local BelatedGiftView = class(ActivityParentView)

function BelatedGiftView:ctor()
    self.residualTime = self.___ex.residualTime
    self.dayTime = self.___ex.dayTime
    self.costGroup = self.___ex.costGroup
    self.diamondTexts = self.___ex.diamondTexts
    self.diamondImgs = self.___ex.diamondImgs
    self.infoText = self.___ex.infoText
    self.titleText = self.___ex.titleText
    self.tipText = self.___ex.tipText
    self.itemGroup = self.___ex.itemGroup
    self.mName = self.___ex.mName
    self.itemsSpt = {}
    self.residualTimer = nil

    self.seconds = 1
    self.secondsPerMinute = 60 * self.seconds
    self.secondsPerHour = 60 * self.secondsPerMinute
    self.secondsPerDay = 24 * self.secondsPerHour
end

function BelatedGiftView:start()

end

function BelatedGiftView:InitView(belatedGiftModel)
    self.belatedGiftModel = belatedGiftModel
    self.infoText.text = belatedGiftModel:GetActivityDesc()
    self.mName["1"].text = belatedGiftModel:GetName()
    self.mName["2"].text = belatedGiftModel:GetName()
    self.tipText.text = belatedGiftModel:GetDescTip()
    self:InitChangeData()
end

function BelatedGiftView:InitChangeData()
    local consumMoneyList = self.belatedGiftModel:GetCurrentConsumeList()
    for k,v in pairs(consumMoneyList) do
        k = tostring(k)
        self:InitIcon(v.rebateType, self.diamondImgs[k], v.rebateId)
        self.diamondTexts[k].text = tostring(v.rebateConsumeNum)
        if not self.itemsSpt[k] then
            self:CreateItems(k)
            self:AddOnRewardHandle(self.itemsSpt[k])
        end
        local itemData = {}
        itemData.contents = self.contents
        itemData.state = v.status
        itemData.rewardValue = string.formatNumWithUnit(math.ceil(v.rebateConsumeNum / v.rebateProportion))
        itemData.endTimes = self:GetLastTimeType(v.rebateBeginTime)
        itemData.isOverTime = (v.rebateEndTime - self.belatedGiftModel:GetCurrServerTime() < 0)
        --加一天
        itemData.subID = v.subID
        itemData.titleWord = v.titleWord
        self.itemsSpt[k]:InitView(itemData)
    end
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        self.costGroup:SetActive(false)
        unity.waitForNextEndOfFrame()
        self.costGroup:SetActive(true)
    end)
end

function BelatedGiftView:InitIcon(rewardType, rewardIcon, rewardId)
    local iconPath
    self.contents = {[rewardType] = 1}
    if rewardType == CurrencyType.Diamond then
        iconPath = "Assets/CapstonesRes/Game/UI/Common/Images/Common/Icon_Diamond.png"
    elseif rewardType == CurrencyType.Money then
        iconPath = "Assets/CapstonesRes/Game/UI/Common/Images/Common/Icon_Gold.png"
    elseif rewardType == CurrencyType.Strength then
        iconPath = "Assets/CapstonesRes/Game/UI/Common/Images/Common/Icon_Strength.png"
    else
        iconPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Image/Icon_Vitamin.png"
        self.contents = { item = {{id = rewardId, num = 1,}}}
    end
    rewardIcon.overrideSprite = res.LoadRes(iconPath)
end

function BelatedGiftView:AddOnRewardHandle(spt)
    spt.onRewardBtnClick = function (subId, stateCallBack)
        if self.onRewardBtnClick then
            self.onRewardBtnClick(subId, stateCallBack)
        end
    end
end

function BelatedGiftView:CreateItems(index)
    local obj,spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/BelatedGiftItem.prefab")
    obj.transform:SetParent(self.itemGroup.transform, true)
    obj.transform.localScale = Vector3.one
    obj.transform.localPosition = Vector3.zero
    obj.transform.localEulerAngles = Vector3.zero
    self.itemsSpt[index] = spt
end

function BelatedGiftView:RefreshContent()
    self.residualTime.text = self.belatedGiftModel:GetTime()
    self:InitChangeData()
end

function BelatedGiftView:GetTimes(time)
    if time <= 0 then
        return nil, nil
    end
    --求时间
    local day1 = math.modf(time / self.secondsPerDay)
    time = time - day1 * self.secondsPerDay
    local hour1 = math.modf(time / self.secondsPerHour)
    time = time - hour1 * self.secondsPerHour
    local minute1 = math.modf(time / self.secondsPerMinute)
    local second = time - minute1 * self.secondsPerMinute
   
    return day1, hour1
end

function BelatedGiftView:GetLastTimeType(timestamp)
    local month = os.date("%m", timestamp)
    local day = os.date("%d", timestamp)
    local hour = os.date("%H", timestamp)
    local minute = os.date("%M", timestamp)
    return lang.transstr("belatedGift_recv_end_time", tonumber(hour) .. ":" .. minute .. " " .. tonumber(day) .. "/" .. tonumber(month)) 
end

return BelatedGiftView

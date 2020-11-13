local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local EventSystem = require("EventSystem")
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local SignView = class(unity.base)

function SignView:ctor()
    self.btnSign = self.___ex.btnSign
    self.signButton = self.___ex.signButton
    self.leftContentRect = self.___ex.leftContentRect
    self.rightContentRect = self.___ex.rightContentRect
    self.lastContentRect = self.___ex.lastContentRect
    self.totalSign = self.___ex.totalSign
    self.signInfo = self.___ex.signInfo
    self.cardBg = self.___ex.cardBg
    self.normalBg = self.___ex.normalBg
    self.cardArea = self.___ex.cardArea
    self.normalArea = self.___ex.normalArea
    self.cardContent = self.___ex.cardContent
    self.normalContent = self.___ex.normalContent
    self.signText = self.___ex.signText
    self.signGradient = self.___ex.signGradient
    self.itemMap = { }
end

function SignView:start()
    self.btnSign:regOnButtonClick(function()
        self:OnBtnSign()
    end)
end

function SignView:OnEnterScene()
    EventSystem.AddEvent("SignDay_Change", self, self.EventSetLastDaySign)
end

function SignView:OnExitScene()
    EventSystem.RemoveEvent("SignDay_Change", self, self.EventSetLastDaySign)
end

function SignView:OnBtnClose()
    if self.clickClose then
        self.clickClose()
    end
end

function SignView:OnBtnSign()
    if self.clickSign then
        self.clickSign()
    end
end

function SignView:EventSetLastDaySign(activityModel)
    local lastDay = activityModel:GetSignLastDay()
    local lastItem = self.itemMap[tonumber(lastDay)]
    if lastItem then
        lastItem:HasSign(lastDay)
    end

    self:SetSignInfo(activityModel)
end

local leftItemMaxNum = 15
local rightItemMaxNum = 27
function SignView:InitView(activityModel)
    local lastDay = activityModel:GetSignLastDay()
    local sortDay = activityModel:GetSignSortData()
    local isSigned = activityModel:GetSign()
    self.itemMap = {}
    local dayItemRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/DayItem.prefab")
    for i, v in ipairs(sortDay) do
        local dayItem = Object.Instantiate(dayItemRes)
        local parentRect
        if i <= leftItemMaxNum then
            parentRect = self.leftContentRect
        elseif i <= rightItemMaxNum then
            parentRect = self.rightContentRect
        else
            parentRect = self.lastContentRect
        end
        dayItem.transform:SetParent(parentRect, false)
        local itemScript = res.GetLuaScript(dayItem)
        itemScript:InitView(v, lastDay, isSigned)
        self.itemMap[i] = itemScript
    end

    self:SetSignInfo(activityModel)
end

function SignView:ClearContent(content)
    for i = 1, content.childCount do
        Object.Destroy(content:GetChild(i - 1).gameObject)
    end
end

function SignView:SetSignInfo(activityModel)
    local lastDay = activityModel:GetSignLastDay()
    local isSigned = activityModel:GetSign()
    local isShowDay = lastDay + 1
    if isSigned then
        self.signInfo.text = lang.trans("tomorrow_reward")
        self.signText.text = lang.trans("be_sign")
        ButtonColorConfig.SetDisableGradientColor(self.signGradient)
    else
        self.signInfo.text = lang.trans("today_reward")
        self.signText.text = lang.trans("sign")
        ButtonColorConfig.SetNormalGradientColor(self.signGradient)
    end

    local contents = activityModel:GetNextDayRewardData()
    local isCard = contents and contents.card
    local rewardParams = {
        parentObj = nil,
        rewardData = contents,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
    }
    if isCard then
        self:ClearContent(self.cardContent)
        rewardParams.parentObj = self.cardContent
        RewardDataCtrl.new(rewardParams)
    else
        self:ClearContent(self.normalContent)
        rewardParams.parentObj = self.normalContent
        RewardDataCtrl.new(rewardParams)
    end
    GameObjectHelper.FastSetActive(self.cardBg, isCard)
    GameObjectHelper.FastSetActive(self.cardArea, isCard)
    GameObjectHelper.FastSetActive(self.normalBg, not isCard)
    GameObjectHelper.FastSetActive(self.normalArea, not isCard)

    self.totalSign.text = tostring(lastDay)
    self.signButton.interactable = not isSigned
    self.btnSign:onPointEventHandle(not isSigned)
end

function SignView:OnRefresh()

end

function SignView:onDestroy()
    if type(self.onEventDestroy) == "function" then
        self.onEventDestroy()
    end
end

return SignView

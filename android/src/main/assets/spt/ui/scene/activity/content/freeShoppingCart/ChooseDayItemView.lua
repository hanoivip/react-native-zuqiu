local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CartStateType = require("ui.models.activity.freeShoppingCart.CartStateType")
local ChooseDayItemView = class()

function ChooseDayItemView:ctor()
--------Start_Auto_Generate--------
    self.chooseDay6Spt = self.___ex.chooseDay6Spt
    self.missGo = self.___ex.missGo
    self.cartTime1Txt = self.___ex.cartTime1Txt
    self.itemGo = self.___ex.itemGo
    self.cartTime2Txt = self.___ex.cartTime2Txt
    self.itemTrans = self.___ex.itemTrans
    self.chooseGo = self.___ex.chooseGo
    self.chooseIconGo = self.___ex.chooseIconGo
    self.cartTime3Txt = self.___ex.cartTime3Txt
    self.chooseBtn = self.___ex.chooseBtn
    self.chooseTrans = self.___ex.chooseTrans
    self.notReadyGo = self.___ex.notReadyGo
    self.cartTime4Txt = self.___ex.cartTime4Txt
    self.rewardNameTxt = self.___ex.rewardNameTxt
--------End_Auto_Generate----------
    self.rewardNameShadow = self.___ex.rewardNameShadow
    self.cartTime = {self.cartTime1Txt, self.cartTime2Txt, self.cartTime3Txt, self.cartTime4Txt}
    self.choosePrefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/FreeShoppingCart/FreeShoppingCartChoose.prefab"
end

function ChooseDayItemView:start()
    self.chooseBtn:regOnButtonClick(function()
        self:ChooseClick()
    end)
end

function ChooseDayItemView:InitView(dayData)
    self.dayData = dayData
    local index, firstDayData = next(dayData)
    local dateTime = firstDayData.chooseRewardBeginTime
    dateTime = string.convertSecondToMonthAndDay(dateTime)
    dateTime = dateTime.month .. "." .. dateTime.day
    for i, v in ipairs(self.cartTime) do
        v.text = dateTime
    end
end

function ChooseDayItemView:InitState(groupState, contentData)
    GameObjectHelper.FastSetActive(self.missGo, groupState == CartStateType.Miss)
    GameObjectHelper.FastSetActive(self.itemGo, groupState == CartStateType.Selected)
    GameObjectHelper.FastSetActive(self.chooseTrans.gameObject, groupState == CartStateType.TodaySelected)
    GameObjectHelper.FastSetActive(self.chooseIconGo, groupState == CartStateType.CanSelect)
    GameObjectHelper.FastSetActive(self.chooseBtn.gameObject, groupState == CartStateType.CanSelect)
    GameObjectHelper.FastSetActive(self.chooseGo, groupState == CartStateType.CanSelect or groupState == CartStateType.TodaySelected)
    GameObjectHelper.FastSetActive(self.notReadyGo, groupState == CartStateType.Disable)
    GameObjectHelper.FastSetActive(self.rewardNameTxt.gameObject, tobool(contentData))
    if contentData then
        local rewardNameColor, rewardTrans
        if groupState == CartStateType.Selected then
            rewardNameColor = {
                nameColor = Color(65/255, 68/255, 88/255),
                nameShadowColor = Color.white,
                numFont = 18,
            }
            rewardTrans = self.itemTrans
        else
            rewardNameColor = {
                nameColor = Color.white,
                nameShadowColor = Color.black,
                numFont = 18,
            }
            rewardTrans = self.chooseTrans
        end
        local rewardParams = {
            parentObj = rewardTrans,
            rewardData = contentData.contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
            itemParams = rewardNameColor,
        }
        res.ClearChildren(rewardTrans)
        RewardDataCtrl.new(rewardParams)
        self:SetRewardName(rewardNameColor, contentData)
    end
end

function ChooseDayItemView:SetRewardName(rewardNameColor, contentData)
    local rewardNameStr = RewardNameHelper.GetSingleContentName(contentData.contents)
    rewardNameStr = string.gsub(rewardNameStr, " ", "")
    self.rewardNameTxt.text = rewardNameStr
    self.rewardNameTxt.color = rewardNameColor.nameColor
    self.rewardNameShadow.effectColor = rewardNameColor.nameShadowColor
end

function ChooseDayItemView:ChooseClick()
    local dialog, dialogcomp = res.ShowDialog(self.choosePrefabPath, "camera", true, true)
    local script = dialogcomp.contentcomp
    script:InitView(self.dayData)
end

return ChooseDayItemView

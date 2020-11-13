local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Button = UnityEngine.UI.Button
local Text = UnityEngine.UI.Text
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardBuilder = require("ui.common.card.CardBuilder")

local SevenDayLoginItemView = class(unity.base)

function SevenDayLoginItemView:ctor()
    self.rewardBtn = self.___ex.rewardBtn
    self.rewardBtnCompnent = self.___ex.rewardBtnCompnent
    self.rewardTxt = self.___ex.rewardTxt
    self.finishIcon = self.___ex.finishIcon
    self.dayValue = self.___ex.dayValue
    self.rewardBtnEffect = self.___ex.rewardBtnEffect
    self.gradientText = self.___ex.gradientText
    self.rewardArea = self.___ex.rewardArea
    self.dayValue = self.___ex.dayValue
    self.itemBgImg = self.___ex.itemBgImg
    self.rewardPasterArea = self.___ex.rewardPasterArea
    self.rewardCardArea = self.___ex.rewardCardArea
    self.clickCard = self.___ex.clickCard
end

function SevenDayLoginItemView:start()
    self.rewardBtn:regOnButtonClick(function()
        self:OnRewardBtnClick()
    end)
    self.clickCard:regOnButtonClick(function()
        self:OnCardClick()
    end)
end

local BgType = {
    CanRecv = "Assets/CapstonesRes/Game/UI/Scene/Activties/Image/SevenDayLogin/SevenDayCanRecvBg.png",
    NotCanRecv = "Assets/CapstonesRes/Game/UI/Scene/Activties/Image/SevenDayLogin/SevenDayItemBg.png"
}
function SevenDayLoginItemView:InitRewardButtonState()
    local state = self.itemData.status or 1
    if state == -1 then
        self:SetButtonState(false)
        self.itemBgImg.overrideSprite = res.LoadRes(BgType.NotCanRecv)
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, true)
        GameObjectHelper.FastSetActive(self.finishIcon, false)
    elseif state == 1 then
        self.itemBgImg.overrideSprite = res.LoadRes(BgType.NotCanRecv)
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.finishIcon, true)
    elseif state == 0 then
        self.itemBgImg.overrideSprite = res.LoadRes(BgType.CanRecv)
        self:SetButtonState(true)
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, true)
        GameObjectHelper.FastSetActive(self.finishIcon, false)
    end
end

function SevenDayLoginItemView:SetButtonState(isOpen)
    self.rewardBtn:onPointEventHandle(isOpen)
    self.rewardBtnCompnent.interactable = isOpen
    self.rewardBtnEffect:SetActive(isOpen)
    local r, g, b 
    self.gradientText.enabled = isOpen
    if isOpen then 
        r, g, b = 145, 125, 86
    else
        r, g, b = 125, 125, 125
    end
    local color = ColorConversionHelper.ConversionColor(r, g, b)
    self.rewardTxt.color = color
end

function SevenDayLoginItemView:OnRewardBtnClick()
    if self.onRewardBtnClick then
        self.onRewardBtnClick(self.itemData.subID, function ()
            self.itemData.status = 1
            self:InitRewardButtonState()
        end)
    end
end

function SevenDayLoginItemView:InitView(itemData)
    self.itemData = itemData
    self.dayValue.text = itemData.conditionDesc
    self.playerCardStaticModel = nil
    self:InitRewardButtonState()
    if itemData.contents.paster then
        res.ClearChildren(self.rewardPasterArea.transform)
        local rewardParams = {
            parentObj = self.rewardPasterArea,
            rewardData = itemData.contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
            hideCount = false,
        }
        RewardDataCtrl.new(rewardParams)
        self:SetAreaState(3)
    elseif itemData.contents.card then
        res.ClearChildren(self.rewardCardArea.transform)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        local currTr = obj.transform
        currTr:SetParent(self.rewardCardArea.transform, false)
        currTr.localEulerAngles = Vector3.zero
        currTr.localScale = Vector3.one
        currTr.localPosition = Vector3.zero
        self.playerCardStaticModel = StaticCardModel.new(itemData.contents.card[1].id)
        GameObjectHelper.FastSetActive(spt.cname.gameObject, false)
        spt:InitView(self.playerCardStaticModel)
        self:SetAreaState(2)
    else
        res.ClearChildren(self.rewardArea.transform)
        local rewardParams = {
            parentObj = self.rewardArea,
            rewardData = itemData.contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
            hideCount = false,
        }
        RewardDataCtrl.new(rewardParams)
        self:SetAreaState(1)
    end
end

function SevenDayLoginItemView:OnCardClick()
    if self.playerCardStaticModel then
        self:ShowCardDetail()
    end
end

function SevenDayLoginItemView:ShowCardDetail()
    -- 防止在恢复场景时没有弹板但是有模糊效果
    res.curSceneInfo.blur = nil
    local cid = self.playerCardStaticModel:GetCid()
    local currentModel = CardBuilder.GetBaseCardModel(cid)
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {cid}, 1, currentModel)
end

function SevenDayLoginItemView:SetAreaState(state)
    GameObjectHelper.FastSetActive(self.rewardArea.gameObject, state == 1)
    GameObjectHelper.FastSetActive(self.rewardCardArea.gameObject, state == 2)
    GameObjectHelper.FastSetActive(self.rewardPasterArea.gameObject, state == 3)
end

return SevenDayLoginItemView

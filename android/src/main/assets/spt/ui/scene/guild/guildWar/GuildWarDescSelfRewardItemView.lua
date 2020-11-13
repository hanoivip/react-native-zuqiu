local Object = clr.UnityEngine.Object
local ItemModel = require("ui.models.ItemModel")
local MenuType = require("ui.controllers.itemList.MenuType")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GuildWarDescSelfRewardItemView = class(unity.base)

function GuildWarDescSelfRewardItemView:ctor()
    self.bg = self.___ex.bg
    self.contentTrans = self.___ex.contentTrans
    self.giftboxTrans = self.___ex.giftboxTrans
    self.randomTxt = self.___ex.randomTxt
    self.scrollAtOnce = self.___ex.scrollAtOnce
end

function GuildWarDescSelfRewardItemView:InitView(levelData, parentTrans, parentRect)
    local itemID = levelData.itemId
    local effectName = levelData.effectName
    local path = "Assets/CapstonesRes/Game/UI/Scene/Guild/Image/GuildWar/%s.png"
    local effectPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWar/Effect%s.prefab"
    self.scrollAtOnce.scrollRectInParent = parentRect
    local fixedQuality = 5
    local quality = 1
    self.bg.overrideSprite = res.LoadRes(format(path, fixedQuality))
    if tonumber(quality) < 5 then
        self.randomTxt.gameObject:SetActive(false)
    end
    local itemModel = ItemModel.new(itemID)
    local rewardData = itemModel:GetItemContent()
    local contents = {}
    contents.item = {}
    local temp = {}
    temp.id = tostring(itemID)
    temp.num = 1
    table.insert(contents.item, temp)

    -- ��ʱ������������Ч���أ������������ã�
    if tonumber(quality) ~= 1 then
        local obj = res.Instantiate(format(effctPath, quality))
        obj.transform:SetParent(self.giftboxTrans, false)
    end

    local rewardParams = {
        parentObj = self.giftboxTrans,
        rewardData = contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = false,
        isShowCardReward = false,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)

    for k, v in pairs(rewardData) do
        local rewardParams = {
            parentObj = self.contentTrans,
            rewardData = v.contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
    self.transform:SetParent(parentTrans, false)
    self.transform:SetSiblingIndex(0)
    self.randomTxt.gameObject:SetActive(false)
end

return GuildWarDescSelfRewardItemView

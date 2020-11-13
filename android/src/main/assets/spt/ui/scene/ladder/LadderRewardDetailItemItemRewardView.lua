local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ItemModel = require("ui.models.ItemModel")

local LadderRewardDetailItemItemRewardView = class(unity.base, "LadderRewardDetailItemItemRewardView")


function LadderRewardDetailItemItemRewardView:ctor()
    self.iconArea = self.___ex.iconArea
    self.nameTxt = self.___ex.name
    self.number = self.___ex.number
end

function LadderRewardDetailItemItemRewardView:InitView(itemData)
    self:ClearItemBox()

    if itemData then
        self.itemData = itemData
        
        local itemId = tonumber(itemData.id)
        local itemModel = ItemModel.new(itemId)

        self.nameTxt.text = itemModel:GetName()
        self.number.text = "x" .. itemData.num
        self:FillItemArea()
    end
end

function LadderRewardDetailItemItemRewardView:FillItemArea()
    local rewardData = {}
    rewardData.item = {}
    table.insert(rewardData.item, self.itemData)
    local rewardParams = {
        parentObj = self.iconArea,
        rewardData = rewardData,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
end

function LadderRewardDetailItemItemRewardView:ClearItemBox()
    for i = 0, self.iconArea.childCount - 1 do
        Object.Destroy(self.iconArea:GetChild(i).gameObject)
    end
end

return LadderRewardDetailItemItemRewardView
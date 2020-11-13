local ActivityModel = require("ui.models.activity.ActivityModel")
local ItemModel = require("ui.models.ItemModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local EventSystem = require("EventSystem")
local CommonConstants = require("ui.common.CommonConstants")
local FanShopModel = class(ActivityModel)

function FanShopModel:InitWithProtocol()
    
end

function FanShopModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

function FanShopModel:GetBeginTime()
    return self:GetActivitySingleData().beginTime
end

function FanShopModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end

function FanShopModel:GetGiftBoxInfo()
    local info = self:GetActivitySingleData().store
    -- 购买限制0:不限制1:每日限制 2:整期活动限制3 :永久限制
    for k,v in pairs(info) do
        info[k].limitType = (tonumber(v.limitType) == 3) and 2 or v.limitType
    end
    return info
end

function FanShopModel:GetCoinCount()
    if not self.fanCoinModel then
        self.fanCoinModel = ItemModel.new(CommonConstants.FanCoin)
    end
    return self.fanCoinModel:GetItemNum()
end

function FanShopModel:GetPeriod()
    return self:GetActivitySingleData().ID
end

function FanShopModel:RefreshItemData(data, itemData)
    if data and data.cnt and data.cost then
        itemData.buyCount = data.cnt
        if next(data.cost) then
            ItemsMapModel.new():ResetItemNum(data.cost.id, data.cost.num)
        end
        EventSystem.SendEvent("RefreshFanCoin")
        return itemData
    end
    return nil
end

return FanShopModel
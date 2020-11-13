local Model = require("ui.models.Model")
local MailRewardType = require("ui.scene.mail.MailRewardType")
local ItemMapModel = require("ui.models.ItemsMapModel")
local Item = require("data.Item")
local ItemContent = require("data.ItemContent")

local ItemModel = class(Model, "ItemModel")

function ItemModel:ctor(id)
    ItemModel.super.ctor(self)
    self.itemMapModel = ItemMapModel.new()
    self.id = id
    --assert(Item[tostring(self.id)], "ID " .. self.id .. " not in Item")
    self.staticData = Item[tostring(self.id)] or {}
end

function ItemModel:GetId()
    return self.id
end

function ItemModel:GetItemNum()
    return self.itemMapModel:GetItemNum(self.id)
end

-- 是否无效
function ItemModel:HasValid()
    local isValid = self.staticData and next(self.staticData)
    return isValid
end

function ItemModel:GetName()
    return self.staticData.name
end

function ItemModel:GetQuality()
    return self.staticData.quality or 0
end

function ItemModel:GetIconIndex()
    return self.staticData.picIndex
end

function ItemModel:GetAddNum()
    return self:GetItemNum()
end

function ItemModel:GetDesc()
    return self.staticData.desc
end

function ItemModel:GetUsage()
    return self.staticData.usage
end

function ItemModel:GetAccess()
    return self.staticData.access
end

function ItemModel:GetBaseId()
    return self.staticData.baseID
end

function ItemModel:GetLetterId()
    return self.staticData.letterturnID
end

-- 概率类型
function ItemModel:GetProbability()
    return self.staticData.newItem
end

-- 批量使用时最大数量限制
function ItemModel:GetUseMaxCount()
    return self.staticData.useMaxCount or 0
end

-- 不是红包
function ItemModel:GetIsRedPacket()
    return false
end

-- 礼盒存放在背包的地方
function ItemModel:GetItemType()
    return self.staticData.itemType
end

function ItemModel:GetItemContent()
    if self.staticData.itemContent ~= "" then
        local contents = {}
        for i, v in ipairs(self.staticData.itemContent) do
            local itemContent = ItemContent[v]
            assert(ItemContent[v], "ID " .. v .. " not in ItemContent")
            itemContent.contentId = v
            table.insert(contents, itemContent)
        end
        return contents
    end
    return nil
end

-- 获得奖励类型，详见MailRewardType
-- 可构造contents
function ItemModel:GetRewardType()
    return MailRewardType.Item
end

return ItemModel
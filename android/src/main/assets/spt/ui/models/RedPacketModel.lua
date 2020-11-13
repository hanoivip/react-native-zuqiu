local ItemModel = require("ui.models.ItemModel")
local RedPacket = require("data.RedPacket")
local RedPacketMapModel = require("ui.models.RedPacketMapModel")

local RedPacketModel = class(ItemModel, RedPacketModel)

function RedPacketModel:ctor(id)
    RedPacketModel.super.ctor(self)
    self.redPacketMapModel = RedPacketMapModel.new()
    self.id = id
    self.staticData = RedPacket[tostring(self.id)] or {}
end

function RedPacketModel:GetId()
    return self.id
end

function RedPacketModel:GetItemNum()
    return self.redPacketMapModel:GetItemNum(self.id)
end

function RedPacketModel:GetName()
    return self.staticData.name
end

function RedPacketModel:GetQuality()
    return self.staticData.quality or 0
end

function RedPacketModel:GetIconIndex()
    return self.staticData.picIndex
end

function RedPacketModel:GetAddNum()
    return self:GetItemNum()
end

function RedPacketModel:GetDesc()
    return self.staticData.desc
end

function RedPacketModel:GetAccess()
    return self.staticData.access
end

function RedPacketModel:GetBaseId()
    return self.staticData.baseID
end

-- 可以直接使用
function RedPacketModel:GetUsage()
    return 1
end

-- 固定概率，肯定获得
function RedPacketModel:GetProbability()
    return 1
end

-- 批量使用时最大数量限制
function RedPacketModel:GetUseMaxCount()
    return self.staticData.useMaxCount or 0
end

function RedPacketModel:GetLetterId()
    return self.staticData.letterturnID
end

-- 用于区分和ItemModel
function RedPacketModel:GetIsRedPacket()
    return true
end

function RedPacketModel:GetContentAmount()
    return tostring(self.staticData.contentAmount)
end

function RedPacketModel:GetItemContent()
    local all = {}
    local subTable = {}
    subTable.contents = {}
    local rpType = self.staticData.contentType
    if rpType == "d" or rpType == "m" or rpType == "sp" then
        subTable.contents[rpType] = self.staticData.contentAmount
    elseif rpType == "equipPiece" or rpType == "cardPiece" or rpType == "pasterPiece" or rpType == "item" or rpType == "eqs" then
        subTable.contents[tostring(rpType)] = {}
        table.insert(subTable.contents[tostring(rpType)], {id = self.staticData.content, num = tonumber(self.staticData.contentAmount)})
    end
    table.insert(all, subTable)
    return all
end

return RedPacketModel
local Model = require("ui.models.Model")
local DiscussDetailModel = class(Model, "DiscussDetailModel")

function DiscussDetailModel:ctor(mainContent)
    self.mainContent = mainContent
end

function DiscussDetailModel:SetDiscussList(detailList)
    detailList = self:AddAllTimeData(detailList)
    table.sort(detailList, function(a, b) return a.c_t > b.c_t end)
    self.detailList = detailList
end

function DiscussDetailModel:GetDiscussList(detailList)
    return self.detailList
end

function DiscussDetailModel:AddDiscussList(detail)
    detail = self:AddSingleTimeData(detail)
    table.insert(self.detailList, detail)
    table.sort(self.detailList, function(a, b) return a.c_t > b.c_t end)
end

function DiscussDetailModel:GetMainDiscuss()
    return self.mainContent
end

-- 添加多条回复的时间
function DiscussDetailModel:AddAllTimeData(contents)
    for i,v in ipairs(contents) do
        v.sendTime = self:FormatTimestamp(v.c_t)
    end
    return contents
end

-- 添加单条回复的时间
function DiscussDetailModel:AddSingleTimeData(content)
    content.sendTime = self:FormatTimestamp(content.c_t)
    return content
end

-- 时间的转换
function DiscussDetailModel:FormatTimestamp(timestamp)
    local year = os.date("%Y", timestamp)
    local month = os.date("%m", timestamp)
    local day = os.date("%d", timestamp)
    local hour = os.date("%H", timestamp)
    local minute = os.date("%M", timestamp)
    return year.. "-" .. month .. "-" .. day .. "  " .. hour .. ":" .. minute
end

return DiscussDetailModel

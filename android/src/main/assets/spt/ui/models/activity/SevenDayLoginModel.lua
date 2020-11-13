local Model = require("ui.models.Model")
local SevenDayLoginModel = class(Model)

function SevenDayLoginModel:ctor(isBtnClick)
    self.isBtnClick = isBtnClick
    SevenDayLoginModel.super.ctor(self)
end

local function sortDataList(a, b)
    local aCompareNum = math.abs(tonumber(a.status) + 0.2)
    local bCompareNum = math.abs(tonumber(b.status) + 0.2)
    if aCompareNum < bCompareNum then
        return true
    end
    if aCompareNum > bCompareNum then
        return false
    end
    return tonumber(a.condition) < tonumber(b.condition)

end

function SevenDayLoginModel:InitWithProtocol(data)
    assert(data)
    self.data = data
    self.data.value = self.data.value > #self.data.list and #self.data.list or self.data.value
    self.isShow = self.data.list[self.data.value].status == 0 or self.isBtnClick
    self.data.oldList = clone(self.data.list)
    table.sort(self.data.list, sortDataList)
end

function SevenDayLoginModel:IsShowView()
    return self.isShow
end

function SevenDayLoginModel:GetGiftList()
    return self.data.list
end

function SevenDayLoginModel:GetDesc()
    return self.data.oldList[tonumber(self.data.value)].desc
end

function SevenDayLoginModel:GetTimeArea()
    return self.data.value
end

function SevenDayLoginModel:GetType()
   return self.data.type
end

function SevenDayLoginModel:GetName()
   return self.data.name
end

function SevenDayLoginModel:IsEnd(subId)
    local count = 0
    for k,v in pairs(self.data.list) do
        if v.status == 1 then
            count = count + 1
        elseif v.subID == subId then
            self.data.list[k].status = 1
            count = count + 1
        end
    end
    if count == #self.data.list then
        return true
    end
    return false
end

return SevenDayLoginModel
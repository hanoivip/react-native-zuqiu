local Model = require("ui.models.Model")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")

local WeakenOpponentModel = class(Model, "WeakenOpponentModel")

function WeakenOpponentModel:ctor()
    self.data = {}
    self.itemMapModel = GreenswardItemMapModel.new()
    self.selected = nil
    WeakenOpponentModel.super.ctor(self)
end

function WeakenOpponentModel:Init()
end

function WeakenOpponentModel:InitWithParent(eventModel)
    self.eventModel = eventModel
    self.impactItem = self.eventModel:GetImpactItem() or {}
    self.row = eventModel:GetRow()
    self.col = eventModel:GetCol()

    local items = self.itemMapModel:GetItemsData()
    if table.isEmpty(items) then return end

    for k, v in ipairs(self.impactItem or {}) do
        local rumorItemModel = self.itemMapModel:GetItemModelById(tostring(v.id))
        local num = rumorItemModel:GetOwnNum()
        rumorItemModel:SetOwnNum(1) -- 拆分显示，数量设置为1
        if num > 0 then
            for i = 1, num do
                table.insert(self.data, clone(rumorItemModel))
            end
        end
    end

    table.sort(self.data, function(a, b)
        return tonumber(a:GetId()) > tonumber(b:GetId())
    end)

    for k, itemModel in ipairs(self.data) do
        itemModel:SetSelected(false)
        itemModel:SetIdx(tonumber(k))
    end
end

function WeakenOpponentModel:GetDatas()
    return self.data
end

function WeakenOpponentModel:GetEventModel()
    return self.eventModel
end

function WeakenOpponentModel:GetSelectedIdx()
    return self.selectedIdx
end

function WeakenOpponentModel:SetSelectedIdx(idx)
    local oldIdx = self:GetSelectedIdx()
    local itemNum = #self.data
    if itemNum <= 0 then idx = nil end
    if oldIdx and oldIdx <= itemNum then
        self.data[oldIdx]:SetSelected(false)
    end
    self.selectedIdx = idx
    local newSelectedIdx = self:GetSelectedIdx()
    if newSelectedIdx and newSelectedIdx <= itemNum then
        self.data[newSelectedIdx]:SetSelected(true)
    end
end

-- 获得当前选中的道具的model
function WeakenOpponentModel:GetSelectedItemModel()
    local itemModel = nil
    local selectedIdx = self:GetSelectedIdx()
    if selectedIdx then
        itemModel = self.data[selectedIdx]
    end
    return itemModel
end

return WeakenOpponentModel

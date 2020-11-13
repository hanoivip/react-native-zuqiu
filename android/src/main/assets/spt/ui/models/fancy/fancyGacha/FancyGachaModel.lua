local FancyCardModel = require("ui.models.fancy.FancyCardModel")
local FancyGachaGroupModel = require("ui.models.fancy.fancyGacha.FancyGachaGroupModel")
local Model = require("ui.models.Model")
local FancyGachaModel = class(Model, "FancyGachaModel")

function FancyGachaModel:ctor()
    FancyGachaModel.super.ctor(self)
end

function FancyGachaModel:Init(data)
    self.data = data
end

function FancyGachaModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end


-- 获取当期招募数据
function FancyGachaModel:GetGachaData()
    local gachaData = {}
    for i, v in pairs(self.data) do
        local groupData = {id = i, detail = v}
        local fancyGachaGroupModel = FancyGachaGroupModel.new()
        fancyGachaGroupModel:InitData(groupData)
        table.insert(gachaData, fancyGachaGroupModel)
    end
    table.sort(gachaData, function(a, b)
        return a:GetSortId() < b:GetSortId()
    end)
    return gachaData
end

-- 获取选中招募卡组下标
function FancyGachaModel:GetCurGroup()
    return self.curGruop or 1
end

-- 设置选中招募卡组下标
function FancyGachaModel:SetCurGroup(group)
    self.curGruop = group
end

return FancyGachaModel

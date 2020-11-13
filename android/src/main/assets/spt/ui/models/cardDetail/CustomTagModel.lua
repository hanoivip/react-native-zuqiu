local Model = require("ui.models.Model")

local CustomTagModel = class(Model, "CardTabModel")

function CustomTagModel:ctor()
    CustomTagModel.super.ctor(self)
end

function CustomTagModel:Init(data)
    if not data then
        data = cache.GetCustomTagInfo()
    end
    self.data = data
end

function CustomTagModel:InitWithProtocol(data)
    if not data then
        data = {}
    end
    cache.SetCustomTagInfo(data)
    self:Init(data)
end

-- 通过cid获取标记开关状态
function CustomTagModel:GetStateByCid(cid)
    local state = false
    if self.data[cid] then
        state = self.data[cid].switch
    end
    return state
end

-- 通过cid获取设置标记开关状态
function CustomTagModel:SetStateByCid(cid, state)
    if self.data[cid] then
        self.data[cid].switch = state
    else
        self.data[cid] = {}
        self.data[cid].switch = state
    end
end

-- 通过cid获取标记名称
function CustomTagModel:GetTagByCid(cid)
    local tag = nil
    if self.data[cid] then
        tag = self.data[cid].tag
    end
    return tag
end

-- 通过cid设置标记名称
function CustomTagModel:SetTagByCid(cid, tag)
    if self.data[cid] then
        self.data[cid].tag = tag
    else
        self.data[cid] = {}
        self.data[cid].tag = tag
    end
end

return CustomTagModel

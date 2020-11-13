local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistCoachInformationGrooveView = class(unity.base, "AssistCoachInformationGrooveView")

local ItemPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/AssistCoachInformationGrooveItem.prefab"

function AssistCoachInformationGrooveView:ctor()
    -- 使用的助教情报
    self.rctContainer = self.___ex.rctContainer

    -- 物品脚本数组
    self.itemSpts = {}
end

function AssistCoachInformationGrooveView:start()
end

function AssistCoachInformationGrooveView:InitView(capacity)
    self.capacity = capacity or 3
    self.itemSpts = {}

    res.ClearChildren(self.rctContainer)
    for i = 1, self.capacity do
        self:InstantiateItem(i)
    end
end

function AssistCoachInformationGrooveView:InstantiateItem(idx)
    if table.nums(self.itemSpts) >= self.capacity then
        return
    end

    if idx == nil then idx = table.nums(self.itemSpts) + 1 end

    local obj, spt = res.Instantiate(ItemPath)
    if obj ~= nil and spt ~= nil then
        table.insert(self.itemSpts, idx, spt)
        obj.transform:SetParent(self.rctContainer.transform, false)
        obj.transform.localScale = Vector3.one
        obj.transform.localPosition = Vector3.zero
        spt.onGrooveItemCancel = function(aciModel)
            self:OnGrooveItemCancel(aciModel)
        end
        spt:InitView()
    end
end

function AssistCoachInformationGrooveView:PutGrooveItem(idx, aciModel)
    self:UpdateGrooveItem(idx, aciModel)
end

function AssistCoachInformationGrooveView:RemoveGrooveItem(idx, aciModel)
    self:UpdateGrooveItem(idx)
end

function AssistCoachInformationGrooveView:UpdateGrooveItem(idx, aciModel)
    idx = tonumber(idx)
    if idx > 0 and idx <= table.nums(self.itemSpts) then
        self.itemSpts[idx]:InitView(aciModel)
    end
end

function AssistCoachInformationGrooveView:RemoveAll()
    for idx, spt in pairs(self.itemSpts) do
        self:UpdateGrooveItem(idx)
    end
end

-- 点击槽位中情报取消放置
function AssistCoachInformationGrooveView:OnGrooveItemCancel(aciModel)
    if self.onGrooveItemCancel and type(self.onGrooveItemCancel) == "function" then
        self.onGrooveItemCancel(aciModel)
    end
end

return AssistCoachInformationGrooveView

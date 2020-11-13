local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")

local MedalListFilterBoxView = class(unity.base, "MedalListFilterBoxView")

local MedalListFilterBoxItemPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalListFilterBoxItem.prefab"

function MedalListFilterBoxView:ctor()
    self.itemSpts = {}
    self.currChooseID = 0
end

function MedalListFilterBoxView:start()
end

function MedalListFilterBoxView:InitView(filterDatas, filterType)
    res.ClearChildren(self.transform)
    self.itemSpts = {}
    -- the first one is the title, which means the player don't use this filter type
    for i = 2, table.nums(filterDatas) do
        local filterData = filterDatas[i]
        local obj, spt = res.Instantiate(MedalListFilterBoxItemPath)
        obj.transform:SetParent(self.transform, false)
        obj.transform.localScale = Vector3.one
        table.insert(self.itemSpts, spt)
        spt:InitView(filterData, filterType)
    end

    table.sort(self.itemSpts, function(a, b)
        return tonumber(a:GetID()) < tonumber(b:GetID())
    end)
end

function MedalListFilterBoxView:ChooseItem(id)
    if id == 1 then
        self.itemSpts[self.currChooseID]:SetChoose(false)
        self.currChooseID = 0
    else
        if self.currChooseID > 0 then
            self.itemSpts[self.currChooseID]:SetChoose(false)
        end
        self.currChooseID = id - 1
        self.itemSpts[self.currChooseID]:SetChoose(true)
    end
end

return MedalListFilterBoxView

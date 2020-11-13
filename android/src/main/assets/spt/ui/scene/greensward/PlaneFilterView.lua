local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local PlaneFilterView = class(unity.newscene)

function PlaneFilterView:ctor()
    self.filterClickMask = self.___ex.filterClickMask
    self.content = self.___ex.content
end

function PlaneFilterView:start()
    self.filterClickMask:regOnButtonClick(function()
        self:OnFilterClick()
    end)
end

function PlaneFilterView:GetFilterRes()
    if not self.filterRes then
        self.filterRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Main/FilterBoardItem.prefab")
    end
    return self.filterRes
end

function PlaneFilterView:InitView(greenswardBuildModel)
    self.greenswardBuildModel = greenswardBuildModel
    local totalFloor = greenswardBuildModel:GetTotalFloor()
    for i = 1, totalFloor do
        local obj = Object.Instantiate(self:GetFilterRes())
        local spt = res.GetLuaScript(obj)
        obj.transform:SetParent(self.content, false)
        spt:InitView(i, greenswardBuildModel)
    end
end

function PlaneFilterView:OnFilterClick()
    Object.Destroy(self.gameObject)
end

function PlaneFilterView:onDestroy()
    self.filterRes = nil
end

return PlaneFilterView

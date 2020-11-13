local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local FormationSelectScrollView = class(LuaScrollRectExSameSize)

function FormationSelectScrollView:ctor()
    self.super.ctor(self)
end

function FormationSelectScrollView:InitView(nowSelectFormationId, data)
    self.nowSelectFormationId = nowSelectFormationId
    self.itemDatas = data
end

function FormationSelectScrollView:BuildView()
    self:refresh()
end

function FormationSelectScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Formation/FormationItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    local itemData = self.itemDatas[index]
    spt:InitView(self.nowSelectFormationId, itemData.formationId, itemData.formationData)
    return obj
end

function FormationSelectScrollView:resetItem(spt, index)
    local itemData = self.itemDatas[index]
    spt:InitView(self.nowSelectFormationId, itemData.formationId, itemData.formationData)
    spt:BuildPage()
end

return FormationSelectScrollView
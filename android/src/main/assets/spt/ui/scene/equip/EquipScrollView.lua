local QuestJumpNodeCtrl = require("ui.controllers.quest.QuestJumpNodeCtrl")
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local EquipScrollView = class(LuaScrollRectExSameSize)

function EquipScrollView:ctor()
    EquipScrollView.super.ctor(self)
    self.content = self.___ex.content
end

function EquipScrollView:start()
end

function EquipScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/ItemDetail/QuestJumpNode.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function EquipScrollView:resetItem(spt, index)
    local id = self.data[index]
    QuestJumpNodeCtrl.new(id, self.content, false, self.isAllowChangeScene, self.itemDetailModel:GetEquipID(), spt)
    self:updateItemIndex(spt, index)
end

function EquipScrollView:InitView(itemDetailModel, isAllowChangeScene)
    self.isAllowChangeScene = isAllowChangeScene
    self.itemDetailModel = itemDetailModel
    self.data = itemDetailModel:GetEquipSource()
    self:refresh(self.data)
end

return EquipScrollView

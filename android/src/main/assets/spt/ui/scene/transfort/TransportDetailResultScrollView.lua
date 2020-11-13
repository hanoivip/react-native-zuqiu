local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local TransportDetailResultScrollView = class(LuaScrollRectExSameSize)

function TransportDetailResultScrollView:start()
end

function TransportDetailResultScrollView:InitView(data)
    self.itemDatas = data
    self:refresh()
end

function TransportDetailResultScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Transfort/TransportDetailResultItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function TransportDetailResultScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    spt:InitView(data)
end

return TransportDetailResultScrollView
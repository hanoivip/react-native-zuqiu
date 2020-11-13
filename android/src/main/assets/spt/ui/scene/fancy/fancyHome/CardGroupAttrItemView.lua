local GameObjectHelper = require("ui.common.GameObjectHelper")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3

local CardGroupAttrItemView = class(unity.base)

function CardGroupAttrItemView:ctor()
    self.itemName = self.___ex.itemName
    self.subAttr = self.___ex.subAttr
    self.attr = self.___ex.attr
end

function CardGroupAttrItemView:InitView(data)
    self.itemName.text = data.name
    GameObjectHelper.FastSetActive(self.subAttr, #data.attr < 2 and true or false)
    for i, v in ipairs(data.attr) do
        local obj = nil
        if i < 2 then
            obj = self.attr
        else
            obj = Object.Instantiate(self.attr)
            obj.transform.parent = self.attr.transform.parent
            obj.transform.localScale = Vector3(1, 1, 1)
            obj.transform.localPosition = Vector3(0, 0, 0)
        end
        res.GetLuaScript(obj):InitView(v)
    end
end

return CardGroupAttrItemView
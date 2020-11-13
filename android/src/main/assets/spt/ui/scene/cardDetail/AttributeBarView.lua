local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AttributeBarView = class(unity.base)

function AttributeBarView:ctor()
    self.nameTxt = self.___ex.name

    -- 两项属性值
    self.changeValue = self.___ex.changeValue
    self.trainValue = self.___ex.trainValue
end

function AttributeBarView:InitView(baseValue, train, abilityIndex, tmpChangeValue, symbol) 
    self.nameTxt.text = lang.trans(abilityIndex)
    self.trainValue.text = tostring(train)
    self.changeValue.text = ''
    if tmpChangeValue then 
        if symbol == 'add' then
            self.changeValue.text = '<color=#c5fbb8>+' .. tmpChangeValue .. '</color>'
        elseif symbol == 'dec' then
            self.changeValue.text = '<color=#e8b487>' .. tmpChangeValue .. '</color>'
        end
    end
end

return AttributeBarView
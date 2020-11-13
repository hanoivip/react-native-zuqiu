local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local CardIndexConstants = require("ui.scene.cardIndex.CardIndexConstants")

local CardIndexTextItemView = class(unity.base)

function CardIndexTextItemView:ctor()
    -- 文本
    self.nameTxt = self.___ex.name
    -- 按钮
    self.btn = self.___ex.btn
    -- 列表类型
    self.listType = nil
    -- 要显示的文本
    self.text = nil
end

function CardIndexTextItemView:InitView(text, listType)
    self.text = text
    self.listType = listType
    
    self:BuildPage()
end

function CardIndexTextItemView:start()
    self:BindAll()
end

function CardIndexTextItemView:BindAll()
    self.btn:regOnButtonClick(function ()
        EventSystem.SendEvent("CardIndex.UpdateInputField", self.listType, self.text)
    end)
end

function CardIndexTextItemView:BuildPage()
    self.nameTxt.text = self.text
end

return CardIndexTextItemView
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AttrItemView = class(unity.base)

function AttrItemView:ctor()
    self.text = self.___ex.text
    self.exText = self.___ex.exText
end

function AttrItemView:InitView(data)
    self.text.text = data.str
    if data.exStr then
    	GameObjectHelper.FastSetActive(self.exText.gameObject, true)
    	self.exText.text = data.exStr
    else
    	GameObjectHelper.FastSetActive(self.exText.gameObject, false)
    end
end

return AttrItemView
local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Text = UnityEngine.UI.Text
local LinkClick = class(unity.base)

function LinkClick:ctor()
	self.isDrawLine = self.___ex.isDrawLine
	self.inline = self.___ex.inline
    if self.inline then -- 外链是后加入的C#脚本
		self.inline._isDrawLine = self.isDrawLine
    	self.inline._linkColor = "<color=#4876FF>"
    	self.inline._underlineColor = Color(0.282, 0.463, 1)
    else
        self.inline = self.___ex.defualtText or {}
    end
end

function LinkClick:clickEvent(id, name)
	UnityEngine.Application.OpenURL(name)
end

return LinkClick
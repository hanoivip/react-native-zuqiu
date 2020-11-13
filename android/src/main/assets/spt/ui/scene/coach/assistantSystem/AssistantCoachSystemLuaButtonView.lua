local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local LuaButton = require("ui.control.button.LuaButton")

local AssistantCoachSystemLuaButtonView = class(LuaButton, "AssistantCoachSystemLuaButtonView")

function AssistantCoachSystemLuaButtonView:ctor()
    AssistantCoachSystemLuaButtonView.super.ctor(self)
    self.txtName = self.___ex.txtName
    self.img = self.___ex.img
end

function AssistantCoachSystemLuaButtonView:InitView(data)
    self.data = data
    self:SetName(data.name)
    self:SetDisable(data.isLocked)
end

function AssistantCoachSystemLuaButtonView:GetData()
    return self.data
end

function AssistantCoachSystemLuaButtonView:SetName(name)
    if self.txtName and type(self.txtName) == "table" then
        for k, txt in pairs(self.txtName) do
            txt.text = name
        end
    end
end

function AssistantCoachSystemLuaButtonView:SetDisable(isLock)
    self.img.color = isLock and Color(self.img.color.r, self.img.color.g, self.img.color.b, 0.5) or Color(1, 1, 1, 1)
end

function AssistantCoachSystemLuaButtonView:onPointerDown(eventData)
    self:clearDestroyedItemRecord()
    if self.multiClickEnabled or (self:clickSpeedValid() and not next(self.clickingItems)) and not self.data.isLocked then
        self.clickingItems[self] = true
        self:touchDown(true)
        self:exchangeTextColor()
        for k, v in pairs(self.onButtonDownCallBack) do
            if type(v) == 'function' then
                v(eventData)
            end
        end
    end
end

return AssistantCoachSystemLuaButtonView

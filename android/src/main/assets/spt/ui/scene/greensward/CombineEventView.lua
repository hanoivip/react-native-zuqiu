local CombineEventView = class(unity.base)

function CombineEventView:ctor()
    self.super.ctor(self)
    self.image = self.___ex.image
    self.icon = self.___ex.icon
    self.btnIcon = self.___ex.btnIcon
    self:Init()
end

function CombineEventView:Init()
    self.btnIcon:regOnButtonClick(function (eventData)
        if self.eventModel:IsShowDialog() then
            self.eventModel:TriggerEvent()
        end
    end)
end

function CombineEventView:InitView(eventModel, greenswardResourceCache)
    self.eventModel = eventModel
    local eventIcon = eventModel:GetEventIcon()
    local bg = eventIcon[1] or ""
    local icon = eventIcon[2] or ""
    self.image.overrideSprite = greenswardResourceCache:GetLogoRes(bg)
    self.icon.overrideSprite = greenswardResourceCache:GetLogoRes(icon)
    self.image:SetNativeSize()
    self.icon:SetNativeSize()
end

return CombineEventView
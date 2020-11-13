local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")

local TeamLogoIconView = class(LuaButton)

local ImagePaths = {
    icon = "Assets/CapstonesRes/Game/UI/Common/Team/Image/Icon/%s.png",
    empty = "Assets/CapstonesRes/Game/UI/Scene/TeamCreate/Image/Empty.png"
}

function TeamLogoIconView:ctor()
    TeamLogoIconView.super.ctor(self)
    self.icon = self.___ex.icon
    self.no = self.___ex.no
    self.selected = self.___ex.selected
    EventSystem.AddEvent("ClickLogoIcon",self, self.ShowSelected)
end

function TeamLogoIconView:InitView(model)
    self.model = model
    self:SetIcon(model:GetIconId())
end

function TeamLogoIconView:SetIcon(id)
    if type(id) == "string" and id ~= "" then
        self.icon.overrideSprite = res.LoadRes(format(ImagePaths.icon, id))
    end
    GameObjectHelper.FastSetActive(self.icon.gameObject, id)
    GameObjectHelper.FastSetActive(self.no, not id)
end

function TeamLogoIconView:ShowSelected(spt)
    GameObjectHelper.FastSetActive(self.selected, spt == self)
end

function TeamLogoIconView:onDestroy()
    EventSystem.RemoveEvent("ClickLogoIcon",self, self.ShowSelected)
end



return TeamLogoIconView
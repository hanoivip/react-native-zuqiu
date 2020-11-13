local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")

local TeamLogoRibbonView = class(LuaButton)

local ImagePaths = {
    ribbon = "Assets/CapstonesRes/Game/UI/Common/Team/Image/Ribbon/%s.png",
    empty = "Assets/CapstonesRes/Game/UI/Scene/TeamCreate/Image/Empty.png"
}

function TeamLogoRibbonView:ctor()
    TeamLogoRibbonView.super.ctor(self)
    self.ribbon = self.___ex.ribbon
    self.no = self.___ex.no
    self.selected = self.___ex.selected
    EventSystem.AddEvent("ClickLogoRibbon",self, self.ShowSelected)
end

function TeamLogoRibbonView:InitView(model)
    self.model = model
    self:SetRibbon(model:GetRibbonId())
end

function TeamLogoRibbonView:SetRibbon(id)
    if type(id) == "string" and id ~= "" then
        self.ribbon.overrideSprite = res.LoadRes(format(ImagePaths.ribbon, id))
    end
    GameObjectHelper.FastSetActive(self.ribbon.gameObject, id)
    GameObjectHelper.FastSetActive(self.no, not id)
end

function TeamLogoRibbonView:ShowSelected(spt)
    GameObjectHelper.FastSetActive(self.selected, spt == self)
end

function TeamLogoRibbonView:onDestroy()
    EventSystem.RemoveEvent("ClickLogoRibbon",self, self.ShowSelected)
end

return TeamLogoRibbonView
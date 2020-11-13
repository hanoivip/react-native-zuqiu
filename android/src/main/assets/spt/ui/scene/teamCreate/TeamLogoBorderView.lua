local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")

local TeamLogoBorderView = class(LuaButton)

local ImagePaths = {
    border = "Assets/CapstonesRes/Game/UI/Common/Team/Image/Border/%s.png",
}

function TeamLogoBorderView:ctor()
    TeamLogoBorderView.super.ctor(self)
    self.border = self.___ex.border
    self.selected = self.___ex.selected
    self.selectedEffect = self.___ex.selectedEffect
    EventSystem.AddEvent("ClickLogoBorder",self, self.ShowSelected)
    self.material = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Team/Material/TeamLogoBoard.mat"))
end

function TeamLogoBorderView:InitView(model)
    self.model = model
    self:SetBorder(model:GetBorderId())
end

function TeamLogoBorderView:SetBorder(id)
    if type(id) == "string" and id ~= "" then
        self.border.overrideSprite = res.LoadRes(format(ImagePaths.border, id))
    end
end

function TeamLogoBorderView:ShowSelected(spt)
    GameObjectHelper.FastSetActive(self.selected, spt == self)
end

function TeamLogoBorderView:onDestroy()
    EventSystem.RemoveEvent("ClickLogoBorder",self, self.ShowSelected)
end

return TeamLogoBorderView
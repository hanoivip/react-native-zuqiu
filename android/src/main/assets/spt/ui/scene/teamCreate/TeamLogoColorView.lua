local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")

local TeamLogoColorView = class(LuaButton)

local ImagePaths = {
    mask = "Assets/CapstonesRes/Game/UI/Common/Team/Image/Mask/%s.png",
    board = "Assets/CapstonesRes/Game/UI/Common/Team/Image/Board/%s.jpg",
    border = "Assets/CapstonesRes/Game/UI/Common/Team/Image/Border/%s.png",
}

function TeamLogoColorView:ctor()
    TeamLogoColorView.super.ctor(self)
    self.board = self.___ex.board
    self.maskImage = self.___ex.maskImage
    self.mask = self.___ex.mask
    self.border = self.___ex.border
    self.selectedEffect = self.___ex.selectedEffect
    self.selectedAnim = self.___ex.selectedAnim
    self.material = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Team/Material/TeamLogoBoard.mat"))
    EventSystem.AddEvent("ClickLogoColor",self, self.ShowSelected)
end

function TeamLogoColorView:InitView(model)
    self.model = model
    self:SetBoard(model:GetBoardId())
    self:SetBorder(model:GetBorderId())
    if model:GetBoardId() then
        self:SetBoardColor(model:GetBoardColorRed(), model:GetBoardColorGreen(), model:GetBoardColorBlue())
    end
end

function TeamLogoColorView:SetBoard(id)
    if type(id) == "string" and id ~= "" then
        self.board.overrideSprite = res.LoadRes(format(ImagePaths.board, id))
    end
end

function TeamLogoColorView:SetBorder(id)
    if type(id) == "string" and id ~= "" then
        self.border.overrideSprite = res.LoadRes(format(ImagePaths.border, id))
    end
end

function TeamLogoColorView:SetBoardColor(r, g, b)
    self.mask.enabled = false
    if r then
        self.material:SetColor("_RColor", r)
    end
    if g then
        self.material:SetColor("_GColor", g)
    end
    if b then
        self.material:SetColor("_BColor", b)
    end
    self.board.material = self.material
    self:coroutine(function ()
        unity.waitForNextEndOfFrame()
        self.mask.enabled = true
    end)
end

function TeamLogoColorView:ShowSelected(spt)
    GameObjectHelper.FastSetActive(self.selectedEffect, self == spt)
    self.selectedAnim.enabled = (self == spt)
end

function TeamLogoColorView:onDestroy()
    EventSystem.RemoveEvent("ClickLogoColor",self, self.ShowSelected)
end

return TeamLogoColorView

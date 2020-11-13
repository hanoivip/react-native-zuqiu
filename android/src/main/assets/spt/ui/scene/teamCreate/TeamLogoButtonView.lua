local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion

local ClickHandler = require("ui.control.button.LuaButton")
local TeamLogoButtonView = class(ClickHandler)

function TeamLogoButtonView:ctor()
    TeamLogoButtonView.super.ctor(self)
    self.empty = self.___ex.empty
    self.logoArea = self.___ex.logoArea
    self.selectEffect = self.___ex.selectEffect
    self.selectEffect1 = self.___ex.selectEffect1
    self.animator = self.___ex.animator
end

function TeamLogoButtonView:SetEmpty()
    self.empty:SetActive(true)
    if self.teamLogo then
        self.teamLogo.gameObject:SetActive(false)
    end
end

function TeamLogoButtonView:SetExist()
    self.empty:SetActive(false)
    self.teamLogo.gameObject:SetActive(true)
end

function TeamLogoButtonView:Init(teamLogo)
    self.teamLogo = teamLogo
    teamLogo.transform:SetParent(self.logoArea, false)
end

function TeamLogoButtonView:Hide()
    self.teamLogo.gameObject:SetActive(false)
end

function TeamLogoButtonView:PlayAppearAnimationWithImageOnly()
    self.teamLogo:PlayAppearAnimationWithImageOnly()
end

function TeamLogoButtonView:PlayAppearAnimation()
    self.teamLogo:PlayAppearAnimation()
end

function TeamLogoButtonView:PlayDisappearAnimation()
    self.teamLogo:PlayDisappearAnimation()
end

function TeamLogoButtonView:PlaySelectAnimation()
    self.selectEffect:SetActive(true)
    self.selectEffect1:SetActive(true)
    -- self.animator.enabled = true
    -- self.animator:Play("TeamLogoSelect")
end

function TeamLogoButtonView:StopAnimation()
    self.selectEffect:SetActive(false)
    self.selectEffect1:SetActive(false)
    -- self.animator.enabled = false
    self.logoArea.localRotation = Quaternion.Euler(Vector3.zero)
    self.logoArea.localScale = Vector3(1, 1, 1)
end

return TeamLogoButtonView

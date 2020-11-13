local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")

local GreenswardAvatarView = class(unity.base, "GreenswardAvatarView")

function GreenswardAvatarView:ctor()
    -- logo背景
    self.imgLogoBg = self.___ex.imgLogoBg
    -- logo
    self.imgLogo = self.___ex.imgLogo
    -- 默认边框
    self.imgDefaultFrame = self.___ex.imgDefaultFrame
    -- 边框
    self.imgFrame = self.___ex.imgFrame
    -- logo的RCT
    self.rctLogo = self.___ex.rctLogo
end

function GreenswardAvatarView:start()
end

function GreenswardAvatarView:InitView(logoId, frameId)
    local hasLogo = (logoId ~= nil)
    local hasFrame = (frameId ~= nil)

    GameObjectHelper.FastSetActive(self.imgLogo.gameObject, hasLogo)
    self:DisplayLogoBg(not hasLogo) -- 没有logo的时候显示logo背景
    GameObjectHelper.FastSetActive(self.imgFrame.gameObject, hasFrame)
    self:DisplayDefaultFrame(not hasFrame) -- 没有边框的时候显示默认边框

    if hasLogo then
        self.imgLogo.overrideSprite = AssetFinder.GetGreenswardAvatarLogo(logoId)
    end
    if hasFrame then
        self.imgFrame.overrideSprite = AssetFinder.GetGreenswardAvatarFrame(frameId)
    end
end

function GreenswardAvatarView:DisplayLogoBg(isShow)
    GameObjectHelper.FastSetActive(self.imgLogoBg.gameObject, isShow)
end

function GreenswardAvatarView:DisplayDefaultFrame(isShow)
    GameObjectHelper.FastSetActive(self.imgDefaultFrame.gameObject, isShow)
end

function GreenswardAvatarView:SetLogoScale(num)
    if num ~= nil then
        self.rctLogo.localScale = Vector3(num, num, 1)
    else
        self.rctLogo.localScale = Vector3(0.78, 0.78, 1)
    end
end

function GreenswardAvatarView:SetOwn(hasOwn)
    self.imgLogo.color = hasOwn and Color(1, 1, 1) or Color(0, 1, 1)
    self.imgFrame.color = hasOwn and Color(1, 1, 1) or Color(0, 1, 1)
end

return GreenswardAvatarView

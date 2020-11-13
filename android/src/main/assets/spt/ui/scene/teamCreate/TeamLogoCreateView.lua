local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3

local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease

local TeamLogoCreateView = class(unity.base)

local LogoAppearInterval = 0.05

function TeamLogoCreateView:ctor()
    self.randomLogoBtn = self.___ex.randomLogoBtn
    self.backBtn = self.___ex.backBtn
    self.logoContent = self.___ex.logoContent
    self.touchMask = self.___ex.touchMask
    self.contentMask = self.___ex.contentMask
    self.sceneAnimator = self.___ex.sceneAnimator
    self.confirmBtn = self.___ex.confirmBtn
end

function TeamLogoCreateView:ClearTeamLogoImmediate()
    for i = 1, self.logoContent.childCount do
        Object.Destroy(self.logoContent:GetChild(i - 1).gameObject)
    end
end

function TeamLogoCreateView:ClearTeamLogo(callback)
    if self.logoContent.childCount > 0 then
        self:coroutine(function()
            for i = 1, self.logoContent.childCount do
                self.logoContent:GetChild(i - 1):GetComponent(clr.CapsUnityLuaBehav):PlayDisappearAnimation()
                coroutine.yield(WaitForSeconds(LogoAppearInterval))
            end
            for i = 1, self.logoContent.childCount do
                Object.Destroy(self.logoContent:GetChild(i - 1).gameObject)
            end
            if type(callback) == "function" then
                callback()
            end
        end)
    else
        if type(callback) == "function" then
            callback()
        end
    end
end

function TeamLogoCreateView:SetTouchMask(mask)
    self.touchMask:SetActive(mask)
end

function TeamLogoCreateView:InitView(teamLogos)
    self.randomLogoBtn:onPointEventHandle(false)
    self.contentMask:SetActive(true)
    local function RealInit()
        self.contentMask:SetActive(false)
        if type(teamLogos) == "table" then
            self:coroutine(function()
                for i, v in ipairs(teamLogos) do
                    v.transform:SetParent(self.logoContent, false)
                    v:PlayAppearAnimationWithImageOnly()
                    coroutine.yield(WaitForSeconds(LogoAppearInterval))
                end
                teamLogos[#teamLogos].transform.localScale = Vector3(1.1, 1.1, 1.1)
                self.randomLogoBtn:onPointEventHandle(true)
            end)
        end
    end
    self:ClearTeamLogo(RealInit)
end

function TeamLogoCreateView:RegOnRandomLogoClick(func)
    if type(func) == "function" then
        self.randomLogoBtn:regOnButtonClick(func)
    end
end

function TeamLogoCreateView:RegOnBackBtnClick(func)
    if type(func) == "function" then
        self.backBtn:regOnButtonClick(func)
    end
end

function TeamLogoCreateView:RegOnConfirmBtnClick(func)
    if type(func) == "function" then
        self.confirmBtn:regOnButtonClick(func)
    end
end

function TeamLogoCreateView:RegOnExitScene(func)
    self.onExitScene = func
end

function TeamLogoCreateView:OnExitScene()
    self:ClearTeamLogoImmediate()
    if type(self.onExitScene) == "function" then
        self.onExitScene()
    end
end

function TeamLogoCreateView:DoEnterSceneAnimation()
    self.sceneAnimator:Play("TeamLogoCreate")
end

function TeamLogoCreateView:DoExitSceneAnimation()
    self.sceneAnimator:Play("TeamLogoCreateLeave")
end

return TeamLogoCreateView


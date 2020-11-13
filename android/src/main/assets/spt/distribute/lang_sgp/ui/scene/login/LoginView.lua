local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local LoopType = Tweening.LoopType
local LoginView = class(unity.base)

local UIBgmManager = require("ui.control.manager.UIBgmManager")

local shiningInterval = 0.8
local minScale = 0.9
local minAlpha = 0.5

function LoginView:StartButtonShining()
    -- start按钮闪烁
    local tweenerScale = ShortcutExtensions.DOScale(self.startButton.gameObject.transform, Vector3(minScale, minScale, 1), shiningInterval)
    TweenSettingsExtensions.SetLoops(tweenerScale, -1, LoopType.Yoyo)
    local startButtonImage = self.startButton:GetComponent(Image)
    local tweenerFade = ShortcutExtensions.DOFade(startButtonImage, minAlpha, shiningInterval)
    TweenSettingsExtensions.SetLoops(tweenerFade, -1, LoopType.Yoyo)
end

function LoginView:ctor()
    self.startButton = self.___ex.startButton
    self.noticeButton = self.___ex.noticeButton
    self.logoutButton = self.___ex.logoutButton
    self.touchArea = self.___ex.touchArea
    self.serverItem = self.___ex.serverItem
    self.selectServerButton = self.___ex.selectServerButton
    self.gameLogo = self.___ex.gameLogo
    self.gameInfo = self.___ex.gameInfo
    self.clearDataButton = self.___ex.clearDataButton
    self.switchLanguageButton = self.___ex.switchLanguageButton
    self.bgImage = self.___ex.bgImage

    res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Login/ClearDataView.prefab")
end

function LoginView:start()
    self:InitAppInfo()
    self.logoutButton.gameObject:SetActive(false)
end

function LoginView:InitAppInfo()
    local ver = _G["___resver"]
    local coreVersion = require("emulator.version").version
    local channel
    local appVer
    if clr.plat == "Android" then
        appVer = luaevt.trig("SDK_GetAppVerCode")
        channel = luaevt.trig('SDK_GetChannel')
    elseif clr.plat == "IPhonePlayer" then
        appVer = luaevt.trig("SDK_GetAppVerCode")
        channel = "ios"
    elseif clr.plat == "WindowsEditor" then
        appVer = "1"
        channel = "capstone"
    end
    self.gameInfo.text = "App:" .. tostring(appVer) .. " Res:" .. tostring(self:GetMaxVer(ver)) .. " Core:" .. tostring(coreVersion) .. " Channel:" .. tostring(channel)
end

function LoginView:ChangeLogoutButton(state)
    self.logoutButton.gameObject:SetActive(state)
end

function LoginView:GetMaxVer(ver)
    local maxVer = 0
    if type(ver) == "table" then
        for name, verNum in pairs(ver) do
            if verNum > maxVer then
                maxVer = verNum
            end
        end
    end
    return maxVer
end

function LoginView:SetCurrentServer(server)
    if type(server) == "table" then
        self.serverItem.gameObject:SetActive(true)
        self.serverItem:Init(server.displayId, server.name, server.state, type(server.player) == "table")
    else
        self.serverItem.gameObject:SetActive(false)
    end
end

function LoginView:PlayLogoAnim()
    self.gameLogo:Play("CNLogin")
    UIBgmManager.play("Login/logoMoveIn")
end

function LoginView:RegOnSelectServerClick(func)
    if type(func) == "function" then
        self.selectServerButton:regOnButtonClick(func)
    end
end

function LoginView:RegOnStartButtonClick(func)
    if type(func) == "function" then
        self.startFunc = func
        self.touchArea:regOnButtonClick(func)
    end
end

function LoginView:RegOnNoticeButtonClick(func)
    if type(func) == "function" then
        self.noticeButton:regOnButtonClick(func)
    end
end

function LoginView:RegOnLogoutButtonClick(func)
    if type(func) == "function" then
        self.logoutButton:regOnButtonClick(func)
    end
end

function LoginView:RegOnClearDataButtonClick(func)
    if type(func) == "function" then
        self.clearDataButton:regOnButtonClick(func)
    end
end

function LoginView:RegOnSwitchLanguageButtonClick(func)
    if type(func) == "function" then
        self.switchLanguageButton:regOnButtonClick(func)
    end
end

return LoginView

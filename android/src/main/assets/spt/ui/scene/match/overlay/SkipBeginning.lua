local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Button = UI.Button
local Animator = UnityEngine.Animator
local WaitForSeconds = UnityEngine.WaitForSeconds
local Setting = require('ui.setting.Setting')

local SkipBeginning = class(unity.base)

function SkipBeginning:ctor()
    self.skipBeginningOn = self.___ex.skipBeginningOn
    self.skipBeginningOff = self.___ex.skipBeginningOff
    self.tipsObject = self.___ex.tipsObject
end

function SkipBeginning:start()
    self.skipBeginningOn:GetComponent(clr.CapsUnityLuaBehav):regOnButtonClick(function ()
        Setting.ChangeSkipMatchOpening()
        self:setButton()
    end)
    self.skipBeginningOff:GetComponent(clr.CapsUnityLuaBehav):regOnButtonClick(function ()
        self:coroutine(function ()
            Setting.ChangeSkipMatchOpening()
            self:setButton()
            self.tipsObject:SetActive(true)
            coroutine.yield(WaitForSeconds(2))
            self.tipsObject:SetActive(false)
        end)
    end)
    self:setButton()
end

function SkipBeginning:setButton()
    local skip = cache.getSkipMatchOpening()
    if skip == true then
        self.skipBeginningOn:SetActive(true)
        self.skipBeginningOff:SetActive(false)
    else
        self.skipBeginningOff:SetActive(true)
        self.skipBeginningOn:SetActive(false)
    end
end

return SkipBeginning

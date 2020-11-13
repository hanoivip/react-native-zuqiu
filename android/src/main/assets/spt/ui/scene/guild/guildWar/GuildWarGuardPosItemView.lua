local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local GuildWarGuardPosItemView = class(unity.base)

function GuildWarGuardPosItemView:ctor()
    self.itemClickArea = self.___ex.itemClickArea
    self.bg = self.___ex.bg
    self.logoBg = self.___ex.logoBg
    self.logo = self.___ex.logo
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.capture = self.___ex.capture
    self.canvasGroup = self.___ex.canvasGroup
    self.areaTrans = self.___ex.areaTrans
    self.seize = self.___ex.seize
    self.animator = self.___ex.animator
    self.itemArea = self.___ex.itemArea
    self.bgCanvas = self.___ex.bgCanvas
    self.logoCanvas = self.___ex.logoCanvas
    self.captureCanvas = self.___ex.captureCanvas
    self.index = nil
end

function GuildWarGuardPosItemView:start()
    self.itemClickArea:regOnButtonClick(function()
        if type(self.guardItemClick) == "function" then
            self.guardItemClick(self.index)
        end
    end)
    self.itemArea:SetActive(false)
end

function GuildWarGuardPosItemView:Reset()
    self.animator.gameObject:SetActive(false)
    self.canvasGroup.alpha = 1
    self.bgCanvas.alpha = 1
    self.logoCanvas.alpha = 1
    self.captureCanvas.alpha = 0
    self.areaTrans.localScale = Vector3(1, 1, 1)
    self.areaTrans.localEulerAngles = Vector3(0, 0, 0)
    self.capture.gameObject.transform.localScale = Vector3(1, 1, 1)
    self.seize:SetActive(false)
end

function GuildWarGuardPosItemView:InitView(data, i, guardModel)
    self.guardModel = guardModel
    self.data = data 
    self.index = i
    self.seize:SetActive(data.state ~= "enroll")
    if data.name then
        self.logoBg:SetActive(true)
        TeamLogoCtrl.BuildTeamLogo(self.logo, data.logo)
        self.nameTxt.text = data.name
        self.level.text = "Lv" .. data.level
        self.seize.transform.anchoredPosition = Vector2(43, -15)
    else
        self.logoBg:SetActive(false)
        self.seize.transform.anchoredPosition = Vector2(48, -15)
    end
    
    if data.seizeCnt < 2 then
        self.seize.val.text = data.seizeCnt .. "/2" 
    else
        self.seize:SetActive(false)
    end

    self.animator.gameObject:SetActive(true)
    if data.state ~= "enroll" then
        self:coroutine(function()
            local rand = i * 0.05
            coroutine.yield(UnityEngine.WaitForSeconds(rand))
            self.itemArea:SetActive(true)
            self.animator:Play("GuardPosItem")
        end)
    else
        self:coroutine(function()
            coroutine.yield(UnityEngine.WaitForSeconds(0.01))
            self.itemArea:SetActive(true)
            self.animator:Play("GuardPosLogoGlow")
        end)
    end
end

function GuildWarGuardPosItemView:onAnimationLeave()
    if self.data.seizeCnt < 2 then
        self.animator:Play("GuardPosLogoGlow")
    end
    self.guardModel:AddTurnedCnt()
end

function GuildWarGuardPosItemView:PlaySeizeAnim()
    self.animator:Play("GuardPosItemCapture")
end

return GuildWarGuardPosItemView

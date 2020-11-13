local Introduce = require("data.Introduce")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FancyIntroduceView = class(unity.base)

local tabs = {}
tabs.playingDes = "playing"
tabs.starUpDes = "starUp"

function FancyIntroduceView:ctor()
--------Start_Auto_Generate--------
    self.buttonGroupSpt = self.___ex.buttonGroupSpt
    self.playingDescGo = self.___ex.playingDescGo
    self.playingDesTxt = self.___ex.playingDesTxt
    self.starUpDescGo = self.___ex.starUpDescGo
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
end

function FancyIntroduceView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self:InitView()
    self.buttonGroupSpt:selectMenuItem(tabs.playingDes)
    self:OnTabClick(tabs.playingDes)
end

function FancyIntroduceView:InitView()
    self:InitPlayingDes()
    for i, v in pairs(self.buttonGroupSpt.menu) do
        self.buttonGroupSpt:BindMenuItem(i, function()
            self:OnTabClick(i)
        end)
    end
end

function FancyIntroduceView:InitPlayingDes()
    if self.clickPlayingDes then return end
    local introduceStr = (Introduce["22"] and Introduce["22"].introduce) or ""
    self.playingDesTxt.text = introduceStr
end

function FancyIntroduceView:OnTabClick(tag)
    local isPlayingDes = tag == tabs.playingDes
    local isStarUpDes = tag == tabs.starUpDes
    if not self.clickPlayingDes and isPlayingDes then
        self.clickPlayingDes = true
    end
    if not self.clickStarUpDes and isStarUpDes then
        self.clickStarUpDes = true
    end
    GameObjectHelper.FastSetActive(self.playingDescGo, isPlayingDes)
    GameObjectHelper.FastSetActive(self.starUpDescGo, isStarUpDes)
end

function FancyIntroduceView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

return FancyIntroduceView

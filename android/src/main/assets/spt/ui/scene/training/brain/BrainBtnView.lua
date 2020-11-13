local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")

local BrainBtnView = class(LuaButton)

function BrainBtnView:ctor()
    self.super.ctor(self)
    self.text = self.___ex.text
    self.selected = self.___ex.selected
    self.rightLight = self.___ex.rightLight
    self.rightBg = self.___ex.rightBg
    self.wrongBg = self.___ex.wrongBg
    self.rightIcon = self.___ex.rightIcon
    self.answerIndex = self.___ex.answerIndex
end

function BrainBtnView:InitButton()
    GameObjectHelper.FastSetActive(self.rightLight, false)
    GameObjectHelper.FastSetActive(self.rightIcon, false)
    GameObjectHelper.FastSetActive(self.selected, false)
end

function BrainBtnView:SetButtonChosenView(isRightAnswer)
    GameObjectHelper.FastSetActive(self.selected, true) 
    GameObjectHelper.FastSetActive(self.rightBg, isRightAnswer)
    GameObjectHelper.FastSetActive(self.wrongBg, not isRightAnswer)
    GameObjectHelper.FastSetActive(self.rightIcon, isRightAnswer)
end

function BrainBtnView:SetButtonCorrectView()
    GameObjectHelper.FastSetActive(self.rightLight, true)
    GameObjectHelper.FastSetActive(self.rightIcon, true)
end

return BrainBtnView
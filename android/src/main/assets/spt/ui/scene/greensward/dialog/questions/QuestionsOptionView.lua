local LuaButton = require("ui.control.button.LuaButton")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local QuestionsOptionView = class(LuaButton)

function QuestionsOptionView:ctor()
    QuestionsOptionView.super.ctor(self)
--------Start_Auto_Generate--------
    self.normalGo = self.___ex.normalGo
    self.contentTxt = self.___ex.contentTxt
    self.falseGo = self.___ex.falseGo
    self.trueGo = self.___ex.trueGo
--------End_Auto_Generate----------
end

function QuestionsOptionView:start()
    self:regOnButtonClick(function()
        if self.onOptionClick then
            self.onOptionClick()
        end
    end)
end

function QuestionsOptionView:InitView(optionData)
    self.contentTxt.text = optionData
    GameObjectHelper.FastSetActive(self.trueGo, false)
    GameObjectHelper.FastSetActive(self.falseGo, false)
end

function QuestionsOptionView:start()
    self:regOnButtonClick(function()
        if self.onOptionClick then
            self.onOptionClick()
        end
    end)
end

function QuestionsOptionView:ChangeOptionState(state)
    GameObjectHelper.FastSetActive(self.trueGo, state)
    GameObjectHelper.FastSetActive(self.falseGo, not state)
end

return QuestionsOptionView

local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local LuaButton = require("ui.control.button.LuaButton")
local GradientTextButton = class(LuaButton)

function GradientTextButton:ctor()
    GradientTextButton.super.ctor(self)
    self.gradientText = self.___ex.gradientText
    self.gradientTextColor = self.___ex.gradientTextColor
end

function GradientTextButton:touchDown(isDown)
    GradientTextButton.super.touchDown(self, isDown)
    if type(self.gradientText) == "table" then
        for key, v in pairs(self.gradientText) do
            local gradientTextColor = self.gradientTextColor[key]

            local keyPoints = isDown and gradientTextColor.keyDownPointsColor or gradientTextColor.keyUpPointsColor
            local size = keyPoints.Length
            if size then 
                v:ResetPointColors(size)
                for i = 0, size - 1 do
                    v:AddPointColors(keyPoints[i].percent, keyPoints[i].color)
                end
            end
        end
    end
end

return GradientTextButton


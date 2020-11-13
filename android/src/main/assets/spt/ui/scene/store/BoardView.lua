local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color

local GameObjectHelper = require("ui.common.GameObjectHelper")

local BoardView = class(unity.base)

function BoardView:ctor()
    self.text1 = self.___ex.text1
    self.text2 = self.___ex.text2
    self.text3 = self.___ex.text3
    self.texth1 = self.___ex.texth1
    self.texth2 = self.___ex.texth2
    self.texth3 = self.___ex.texth3
    self.firstH = self.___ex.firstH
    self.secondH = self.___ex.secondH
    self.thirdH = self.___ex.thirdH
    self.firstStepDiamondText = self.___ex.firstStepDiamondText
    self.secondStepDiamondText = self.___ex.secondStepDiamondText
    self.thirdStepDiamondText = self.___ex.thirdStepDiamondText
end

function BoardView:Init(text1, text2, text3, curStep)
    if type(text1) == "string" then
        self.text1.text = text1
        if self.texth1 then
            self.texth1.text = text1
        end
    end
    if type(text2) == "string" then
        self.text2.text = text2
        if self.texth2 then
            self.texth2.text = text2
        end
    end
    if type(text3) == "string" and self.text3 then
        self.text3.text = text3
        if self.texth3 then
            self.texth3.text = text3
        end
    end
    
    if curStep then
        self:HighLightStep(curStep)
    end
end

function BoardView:HighLightStep(curStep)
    local stepName = nil
    if curStep == 1 then
        stepName = "FirstStepBG_H"
    elseif curStep == 2 then
        stepName = "SecondStepBG_H"
    elseif curStep == 3 then
        stepName = "ThirdStepBG_H"
    end

    GameObjectHelper.FastSetActive(self.firstH, stepName == self.firstH.name)
    GameObjectHelper.FastSetActive(self.secondH, stepName == self.secondH.name)
    GameObjectHelper.FastSetActive(self.thirdH, stepName == self.thirdH.name)
end

return BoardView

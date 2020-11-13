local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Regex = clr.System.Text.RegularExpressions.Regex

local TeamNameView = class(unity.base)

function TeamNameView:ctor()
    self.randomNameBtn = self.___ex.randomNameBtn
    self.backBtn = self.___ex.backBtn
    self.continueBtn = self.___ex.continueBtn
    self.teamName = self.___ex.teamName
end

function TeamNameView:Init(teamName)
    self:SetTeamName(teamName)
end

function TeamNameView:SetTeamName(teamName)
    self.teamName.text = tostring(teamName)
end

function TeamNameView:GetTeamName()
    local teamName = Regex.Replace(self.teamName.text, "\\p{Cs}", "")
    return teamName
end

function TeamNameView:RegOnRandomNameBtnClick(func)
    if type(func) == "function" then
        self.randomNameBtn:regOnButtonClick(func)
    end
end

function TeamNameView:RegOnBackBtnClick(func)
    if type(func) == "function" then
        self.backBtn:regOnButtonClick(func)
    end
end

function TeamNameView:RegOnContinueBtnClick(func)
    if type(func) == "function" then
        self.continueBtn:regOnButtonClick(func)
    end
end

function TeamNameView:RegOnExitScene(func)
    self.onExitScene = func
end

function TeamNameView:OnExitScene()
    if type(self.onExitScene) == "function" then
        self.onExitScene()
    end
end

return TeamNameView


local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local QuestTeam = require("data.QuestTeam") 
local TeamTotal = require("data.TeamTotal") 
local GameObjectHelper = require("ui.common.GameObjectHelper")
local QuestJumpNodeView = class(unity.base)
function QuestJumpNodeView:ctor()
    self.desc = self.___ex.desc
    self.jumpEnableButton = self.___ex.jumpEnableButton
    self.jumpDisableButton = self.___ex.jumpDisableButton
    self.btnJump = self.___ex.btnJump
    self.btnJumpCurrentQuest = self.___ex.btnJumpCurrentQuest
end

function QuestJumpNodeView:Init(id, isAllowChangeScene, isOpen)
    local title = QuestTeam[id].questNumber
    local teamID = QuestTeam[id].teamID
    local name = TeamTotal[teamID].teamName
    self.desc.text = title .. "  " .. name

    local isJump = isOpen and isAllowChangeScene
    GameObjectHelper.FastSetActive(self.jumpEnableButton.gameObject, isJump)
    GameObjectHelper.FastSetActive(self.jumpDisableButton.gameObject, not isOpen and isAllowChangeScene)
end

function QuestJumpNodeView:OnJumpBtnClick(func)
    self.btnJump:regOnButtonClick(function()
        if type(func) == "function" then
            func()
        end
    end)
end

function QuestJumpNodeView:OnJumpToCurrentQuest(func)
    self.btnJumpCurrentQuest:regOnButtonClick(function()
        if type(func) == "function" then
            func()
        end
    end)
end

return QuestJumpNodeView
local EventSystem = require ("EventSystem")
local BaseMenuBarModel = require("ui.models.menuBar.BaseMenuBarModel")
local QuestMenuBarModel = class(BaseMenuBarModel)

local resetState = true
function QuestMenuBarModel:ctor(state, teamType)
    QuestMenuBarModel.super.ctor(self, state, teamType)
    self.resetState = resetState
end


return QuestMenuBarModel

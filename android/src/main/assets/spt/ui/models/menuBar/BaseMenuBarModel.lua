local EventSystem = require ("EventSystem")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local Model = require("ui.models.Model")
local BaseMenuBarModel = class(Model)

-- menuBar 状态 分打开和收起,在主界面和关卡界面默认打开并共享状态,其余界面默认收起
local resetState = true -- 在主界面和关卡界面不会重置状态，其余界面则会选择初始状态
BaseMenuBarModel.MenuState = { Close = 1, Open = 2 }
function BaseMenuBarModel:ctor(state, teamType)
    BaseMenuBarModel.super.ctor(self)
    self.defaultState = state or BaseMenuBarModel.MenuState.Close
    self.resetState = resetState
    self.teamType = teamType
end

function BaseMenuBarModel:Init()
    self.data = {}
    self.data.menuState = self.defaultState
end

function BaseMenuBarModel:GetMenuBarData()
    return self.data
end

function BaseMenuBarModel:GetResetState()
    return self.resetState
end

-- 重置状态
function BaseMenuBarModel:ResetState()
    self.data.menuState = self.defaultState
end

-- 设置menuBar 状态
function BaseMenuBarModel:SetMenuBarState(menuState)
    self.data.menuState = menuState
end

function BaseMenuBarModel:GetMenuBarState()
    return self.data.menuState
end

function BaseMenuBarModel:GetTeamType()
    return self.teamType or FormationConstants.TeamType.NORMAL
end

return BaseMenuBarModel

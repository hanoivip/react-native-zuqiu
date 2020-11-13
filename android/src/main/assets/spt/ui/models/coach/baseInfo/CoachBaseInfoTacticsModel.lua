local Model = require("ui.models.Model")
local Formation = require("data.Formation")
local BoardType = require("ui.models.coach.baseInfo.CoachBaseInfoUpdateBoardType")
local FormationConstants = require("ui.scene.formation.FormationConstants")

local CoachBaseInfoTacticsModel = class(Model, "CoachBaseInfoTacticsModel")

function CoachBaseInfoTacticsModel:ctor()
    self.boardType = BoardType.Formation
    self.tacticsType = nil
    self.data = nil
end

function CoachBaseInfoTacticsModel:InitWithParent(parentData)
    assert(parentData ~= nil, "parent data is nil")

    self.data = parentData
    self.boardType = self.data.boardType
    self.tacticsType = self.data.tacticsType
end

function CoachBaseInfoTacticsModel:GetData()
    return self.data
end

function CoachBaseInfoTacticsModel:GetStatusData()
    return self
end

-- 获得当前战术类型
function CoachBaseInfoTacticsModel:GetTacticsType()
    return self.tacticsType
end

-- 获得面板标题
function CoachBaseInfoTacticsModel:GetBoardTitle()
    return self.data.tacticsStr .. lang.transstr("switch") -- XXXX切换
end

return CoachBaseInfoTacticsModel

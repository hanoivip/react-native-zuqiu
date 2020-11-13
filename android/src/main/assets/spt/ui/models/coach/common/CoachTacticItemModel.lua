local Model = require("ui.models.Model")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local CoachItemBaseModel = require("ui.models.coach.common.CoachItemBaseModel")
local CoachTacticsItem = require("data.CoachTacticsItem")

local CoachTacticItemModel = class(CoachItemBaseModel, "CoachTacticItemModel")

local DefaultCtiQuality = 6 -- 默认cti物品品质为6

function CoachTacticItemModel:ctor()
    CoachTacticItemModel.super.ctor(self)
    self.formationId = nil -- 阵型升级类物品的阵型id
    self.tacticType = nil -- 战术升级类物品的战术类别
    self.tacticKey = nil -- 对应FormationConstants中的key
end

function CoachTacticItemModel:ClearData()
    self.formationId = nil
    self.tacticType = nil
    self.tacticKey = nil
end

function CoachTacticItemModel:InitWithId(id)
    self:ClearData()
    CoachTacticItemModel.super.InitWithId(self, id)
end

function CoachTacticItemModel:InitWithReward(reward)
    self:ClearData()
    CoachTacticItemModel.super.InitWithReward(self, reward)
end

function CoachTacticItemModel:InitWithConfig(config)
    self:ClearData()

    self.staticData = config
    local itemType = self:GetType()
    if itemType == CoachItemType.TacticItemType.Formation then
        self.formationId = self.staticData.formationId
    elseif itemType == CoachItemType.TacticItemType.Tactic then
        for k, v in pairs(FormationConstants.FormationTacticsType) do
            if self.staticData[v] ~= nil and tonumber(self.staticData[v]) > 0 then
                self.tacticKey = k
                self.tacticType = v
                break
            end
        end
    else
        dump("wrong coach tactic item type!")
    end
    self.id = self.staticData.id
end

function CoachTacticItemModel:GetStaticConfig(id)
    return CoachTacticsItem[tostring(id)] or {}
end

-- 阵型升级用 or 战术升级用
function CoachTacticItemModel:GetType()
    return self.staticData.type
end

-- 获得适用的阵型的id，0表示不是阵型用物品
function CoachTacticItemModel:GetFormationId()
    return self.formationId
end

-- 获得适用的战术的类别
function CoachTacticItemModel:GetTacticType()
    return self.tacticType
end

-- 获得改战术类别中适用的战术档位，0表示不是这个战术所用的物品
function CoachTacticItemModel:GetTacticLevel()
    return self.staticData[self.tacticType]
end

function CoachTacticItemModel:GetDefaultCtiQuality()
    return DefaultCtiQuality
end

function CoachTacticItemModel:GetQuality()
    return DefaultCtiQuality
end

return CoachTacticItemModel

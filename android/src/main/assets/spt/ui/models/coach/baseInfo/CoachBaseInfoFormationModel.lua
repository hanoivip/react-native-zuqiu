local Model = require("ui.models.Model")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local FormationCacheDataModel = require("ui.models.formation.FormationCacheDataModel")
local Formation = require("data.Formation")
local FormationConstants = require("ui.scene.formation.FormationConstants")

local CoachBaseInfoFormationModel = class(Model, "CoachBaseInfoFormationModel")

CoachBaseInfoFormationModel.SelectedType = {
    Guard = 1,
    Forward = 2,
}

local FormationSelectedOffset = 3

function CoachBaseInfoFormationModel:ctor()
    self.data = nil
    self.nowUsedTeamId = nil
    self.nowUsedFormationId = nil -- 当前玩家使用的阵型ID，只读，本页面不允许修改
    self.selectedType = nil
    self.tempSelectedType = nil
    self.nowSelectFormationId = nil -- 当前选择的阵型ID
    self.nowSelectFormationIdx = nil
    self.nowFormationCategory = nil
    self.formationDatas = nil
end

function CoachBaseInfoFormationModel:InitWithParent(formations, parentData)
    assert(parentData ~= nil, "parent data is nil")

    self.formations = formations
    self.data = parentData
    self.playerTeamsModel = PlayerTeamsModel.new()
    self.formationCacheDataModel = FormationCacheDataModel.new(self.playerTeamsModel)

    self.nowUsedTeamId = self.playerTeamsModel:GetNowTeamId()
    self.nowUsedFormationId = self.playerTeamsModel:GetFormationId(self.nowUsedTeamId)
    self.nowSelectFormationId = self.data.formationId
    self.selectedType = self.data.selectedType
    self:SetFormationCategory()
    self:FilterFormationData()
end

function CoachBaseInfoFormationModel:GetData()
    return self.data
end

function CoachBaseInfoFormationModel:GetStatusData()
    return self
end

-- 设置当前目录
function CoachBaseInfoFormationModel:SetFormationCategory(category)
    if category then
        self.nowFormationCategory = category
    else
        self.nowFormationCategory = self.selectedType ~= CoachBaseInfoFormationModel.SelectedType.Forward 
                                   and Formation[tostring(self.nowSelectFormationId)].formationCategory 
                                   or Formation[tostring(self.nowSelectFormationId)].formationCategory2 + FormationSelectedOffset
    end
end

-- 获得页签的tag的前缀
function CoachBaseInfoFormationModel:GetSelectBtnGroupTagPrefix()
    return "category"
end

-- 获得当前目录
function CoachBaseInfoFormationModel:GetFormationCategory()
    return self.nowFormationCategory
end

function  CoachBaseInfoFormationModel:GetCurrSelectBtnTag()
    return self:GetSelectBtnGroupTagPrefix() .. self:GetFormationCategory()
end

-- 设置选中的临时的类别
function CoachBaseInfoFormationModel:SetTempSelectedType(selectedType)
    self.tempSelectedType = selectedType
end

function CoachBaseInfoFormationModel:GetTempSelectedType()
    return self.tempSelectedType
end

-- 设置选中的类别
function CoachBaseInfoFormationModel:SetSelectedType(selectedType)
    self.selectedType = selectedType
end

-- 获得当前玩家使用的阵型ID
function CoachBaseInfoFormationModel:GetUsedFormationId()
    return self.nowUsedFormationId
end

-- 获得当前选中的阵型索引
function CoachBaseInfoFormationModel:GetCurrFormationIdx()
    return self.nowSelectFormationIdx
end

-- 设置当前选中的阵型索引
function CoachBaseInfoFormationModel:SetCurrFormationIdx(index)
    self.nowSelectFormationIdx = index
end

-- 切换选择阵型
function CoachBaseInfoFormationModel:SwitchSelectedFormation(newIdx)
    if self.nowSelectFormationIdx then
        self.formationDatas[self.nowSelectFormationIdx].isSelected = false
    end
    self.nowSelectFormationIdx = newIdx
    self.formationDatas[self.nowSelectFormationIdx].isSelected = true
    self.nowSelectFormationId = self.formationDatas[self.nowSelectFormationIdx].formationId
end

-- 获得当前选择的阵型的数据
function CoachBaseInfoFormationModel:GetCurrSelectedFormationData()
    if self.nowSelectFormationIdx then
        local selectData = self.formationDatas[self.nowSelectFormationIdx]
        selectData.selectedType = self.selectedType
        return selectData
    end
    return nil
end

--- 筛选阵型数据
function CoachBaseInfoFormationModel:FilterFormationData()
    self.formationDatas = {}

    for formationId, formationData in pairs(Formation) do
        local filterCondition = self.nowFormationCategory <= FormationSelectedOffset 
                               and formationData.formationCategory == self.nowFormationCategory 
                               or formationData.formationCategory2 == self.nowFormationCategory - FormationSelectedOffset
        if filterCondition then
            local data = {
                formationId = formationId,
                formationData = formationData,
                isSelected = false,
                isChoosed = false,
                lvl = 1
            }
            if tonumber(formationId) == tonumber(self.nowUsedFormationId) then
                data.isChoosed = true
            end
            if tonumber(formationId) == tonumber(self.data.formationId) then
                data.isSelected = true
            end
            data.lvl = self.formations[tostring(formationId)].lvl
            table.insert(self.formationDatas, data)
        end
    end

    table.sort(self.formationDatas, function(a, b)
        return tonumber(a.formationId) < tonumber(b.formationId)
    end)

    self.nowSelectFormationIdx = nil

    for i = 1, #self.formationDatas do
        self.formationDatas[i].idx = i
        if tonumber(self.formationDatas[i].formationId) == tonumber(self.data.formationId) then
            self.nowSelectFormationIdx = i
        end
    end
end

function CoachBaseInfoFormationModel:GetScrollData()
    return self.formationDatas or {}
end

return CoachBaseInfoFormationModel

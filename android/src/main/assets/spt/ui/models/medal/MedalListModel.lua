local EventSystem = require ("EventSystem")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local MedalListFilterModel = require("ui.models.medal.MedalListFilterModel")
local Medal = require("data.Medal")
local Model = require("ui.models.Model")

local MedalListModel = class(Model, "MedalListModel")

function MedalListModel:ctor()
    MedalListModel.super.ctor(self)
    self.playerMedalsMapModel = PlayerMedalsMapModel.new()

    self.sortModel = nil -- 当前列表中勋章数据
    self.selectAttr = {} -- 勋章属性
    self.selectBody = nil -- 勋章形状
    self.selectQuality = nil -- 勋章品质
    self.selectSkill = {} -- 勋章技能，包括event和medal
    self.selectEquip = nil -- 勋章是否装备
    self.selectState = nil -- 勋章当前状态（破损or良好）
end

function MedalListModel:GetAllMedalMap()
    self.sortModel = self.playerMedalsMapModel:GetAllMedalMap()
    return self.sortModel
end

function MedalListModel:GetSingleMedalModel(pmid)
    local medalModel = self.playerMedalsMapModel:GetSingleMedalModel(pmid)
    return medalModel
end

-- 对应 C、B、A、S、SS(比品质框少一位)
local SplitQualityMap = {1, 2, 3, 4, 5, 6}
function MedalListModel:GetSplitQuality()
    return SplitQualityMap
end

function MedalListModel:GetSsQualityValue()
    local ssQuality = SplitQualityMap[5]
    return ssQuality
end

function MedalListModel:GetMedalByQuality(qualitys)
    local medalModels = self.playerMedalsMapModel:GetMedalByQuality(qualitys)
    return medalModels
end

function MedalListModel:GetAttrCache()
    return self.selectAttr or {}
end

function MedalListModel:GetSelectBodyCache()
    return self.selectBody
end

function MedalListModel:GetSelectQualityCache()
    return self.selectQuality
end

function MedalListModel:GetSelectSkillCache()
    return self.selectSkill or {}
end

function MedalListModel:GetBodyDropdownMap()
    local map = {}
    for k, v in pairs(Medal) do
        local bodyName = v.medalQualityName
        map[bodyName] = bodyName
    end
    return map
end

function MedalListModel:GetQualityDesc(quality)
    return CardHelper.GetQualitySign(tonumber(quality) + 1)
end

function MedalListModel:GetQualityDropdownMap()
    local qualitys = {}
    for k, v in pairs(Medal) do
        table.insert(qualitys, v.quality)
    end
    table.sort(qualitys, function(a, b) return a < b end)
    local map = {}
    for i, quality in ipairs(qualitys) do
        local qualityDesc = self:GetQualityDesc(quality)
        map[quality] = qualityDesc
    end
    return map
end

-- 第一个和第四个参数为勋章筛选界面获得
function MedalListModel:SearchSort(selectAttr, selectBody, selectQuality, selectSkill)
    self:FinalSearch(selectAttr, selectSkill, self.selectEquip, self.selectState, self.selectQuality, self.selectBody)
end

-- 后四个参数为勋章列表界面上方筛选tab获得
function MedalListModel:Filter(selectEquip, selectState, selectQuality, selectShape)
    self:FinalSearch(self.selectAttr, self.selectSkill, selectEquip, selectState, selectQuality, selectShape)
end

-- @parameter selectAttr: 勋章携带属性
-- @parameter selectSkill: 勋章技能，包括基础技能和祝福技能
-- @parameter selectEquip: 勋章当前是否装备
-- @parameter selectState: 勋章当前状态，良好or破碎
-- @parameter selectQuality: 勋章品质，C\B\A\S\SS
-- @parameter selectBody: 勋章形状，共十种，与配置表汇总medalType对应
function MedalListModel:FinalSearch(selectAttr, selectSkill, selectEquip, selectState, selectQuality, selectBody)
    self.selectAttr = selectAttr
    self.selectSkill = selectSkill
    self.selectEquip = selectEquip
    self.selectState = selectState
    self.selectQuality = selectQuality
    self.selectBody = selectBody
    local hasAttr = next(self.selectAttr)
    local sortModel = {}
    local allMedalMap = self.playerMedalsMapModel:GetAllMedalMap()
    for i, model in ipairs(allMedalMap) do
        local exAttr = model:GetExAttr() 
        local attr = next(exAttr)
        -- 普通技能
        local skills = model:GetSkill()
        local hasEventSkill = false
        if selectSkill.eventSkill then
            for k, v in pairs(skills) do
                if k == selectSkill.eventSkill then
                    hasEventSkill = true
                    break
                end
            end
        else
            hasEventSkill = true
        end
        -- 祝福技能
        local bless = model:GetBenediction()
        local hasModelSkill = false
        if selectSkill.medalSkill then
            for k, v in pairs(bless) do
                if k == selectSkill.medalSkill then
                    hasModelSkill = true
                    break
                end
            end
        else
            hasModelSkill = true
        end
        -- 是否装备
        local hasEquip = false
        if selectEquip then
            if selectEquip == MedalListFilterModel.EquipVar.Equip then
                hasEquip = model:HasEquiped()
            elseif selectEquip == MedalListFilterModel.EquipVar.NotEquip then
                hasEquip = not model:HasEquiped()
            end
        else
            hasEquip = true
        end
        -- 是否破损
        local broken = tonumber(model:GetBroken())
        -- 勋章类型
        local medalType = model:GetMedalType()
        -- 勋章品质
        local quality = model:GetQuality()
        if (not hasAttr or (hasAttr and selectAttr[attr])) and hasEventSkill and hasModelSkill and
            hasEquip and
            (selectState == nil or (selectState and selectState == broken)) and
            (selectBody == nil or (selectBody and selectBody == medalType)) and
            (selectQuality == nil or (selectQuality and selectQuality == quality)) then
            table.insert(sortModel, model)
        end
    end
    self.sortModel = sortModel
    EventSystem.SendEvent("MedalListModel_SearchSort", sortModel)
end

function MedalListModel:GetCurrSearchState()
    return self.selectAttr, self.selectSkill, self.selectEquip, self.selectState, self.selectQuality, self.selectBody
end

function MedalListModel:ResetSearchCache()
    self.selectAttr = {}
    self.selectBody = nil
    self.selectQuality = nil
    self.selectSkill = {}
    self:SearchSort(self.selectAttr, self.selectBody, self.selectQuality, self.selectSkill)
end

function MedalListModel:IsSearch()
    return next(self.selectAttr) or (table.nums(self.selectSkill) > 0)
end

function MedalListModel:GetCurrList()
    return self.sortModel
end

-- 退出勋章界面时取消所有new标记
function MedalListModel:CancelAllNewMedal()
    if not self.sortModel then
        return
    end
    for k, medalModel in pairs(self.sortModel) do
        if medalModel:IsNew() then
            medalModel:SetNew(false)
            self.playerMedalsMapModel:SetMedalNew(medalModel:GetPmid(), false)
        end
    end
end

return MedalListModel

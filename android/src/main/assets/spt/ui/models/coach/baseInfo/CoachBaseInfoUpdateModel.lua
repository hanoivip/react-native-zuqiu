local Model = require("ui.models.Model")
local Formation = require("data.Formation")
local CoachBaseLevel = require("data.CoachBaseLevel")
local CoachBaseTactics = require("data.CoachBaseTactics")
local BoardType = require("ui.models.coach.baseInfo.CoachBaseInfoUpdateBoardType")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CoachItemMapModel = require("ui.models.coach.common.CoachItemMapModel")

local CoachBaseInfoUpdateModel = class(Model, "CoachBaseInfoUpdateModel")

function CoachBaseInfoUpdateModel:ctor()
    self.boardType = BoardType.Formation
    self.formationDatas = nil -- 阵型数据
    self.formationStr = "" -- “偏好阵型”字符串

    self.tacticsDatas = nil -- 战术数据
    self.tacticsType = nil
    self.tacticsStr = "" -- 战术类型（e.g.“长传”）字符串
    self.maxUpdateLvl = 1 -- 阵型/战术升级最大等级

    self.data = nil
end

function CoachBaseInfoUpdateModel:InitWithParent(parentData)
    assert(parentData ~= nil, "parent data is nil")
    self.coachItemMapModel = CoachItemMapModel.new()
    self.playerInfoModel = PlayerInfoModel.new()

    self.data = parentData
    self.usedTacticIndex = parentData.usedTacticIndex
    self.coachLevelId = self.data.coachLevelId
    self.boardType = self.data.boardType
    self.tacticsType = self.data.tacticsType
    self.maxCoachLevel = tonumber(CoachBaseLevel[self.coachLevelId].tacticsMaxLevel) or 1
    for k, v in pairs(CoachBaseTactics) do
        if tonumber(k) > self.maxUpdateLvl then
            self.maxUpdateLvl = tonumber(k) -- coachTacticsLevel未导出，假设lvl既指id又指等级
        end
    end

    if self.boardType == BoardType.Formation then
        self:InitFormation()
    elseif self.boardType == BoardType.Tactics then
        self:InitTactics()
    else
        dump("wrong board type! " .. self.boardType)
    end
end

function CoachBaseInfoUpdateModel:InitFormation()
    self.formationId = self.data.formationId
    self.selectedType = self.data.selectedType
    self.formationStr = self.data.formationStr
    self.formationDatas = {}
    self:UpdateFormationDatas(self.formationId, self.selectedType)
end

function CoachBaseInfoUpdateModel:InitTactics()
    self.tacticsStr = self.data.tacticsStr
    self.tacticsDatas = {}
    self:UpdateTacticDatas()
end

function CoachBaseInfoUpdateModel:GetData()
    return self.data
end

function CoachBaseInfoUpdateModel:GetIdx()
    return self.data.idx
end

-- 获得各个阵型的等级
function CoachBaseInfoUpdateModel:GetFormations()
    return self.data.formations or {}
end

function CoachBaseInfoUpdateModel:GetStatusData()
    return self
end

-- 判断当前升级面板是否是阵型升级
function CoachBaseInfoUpdateModel:IsFormationBoard()
    return tobool(self.boardType == BoardType.Formation)
end

-- 判断当前升级面板是否是战术升级
function CoachBaseInfoUpdateModel:IsTacticsBoard()
    return tobool(self.boardType == BoardType.Tactics)
end

-- 获得当前面板的类型，阵型或战术
function CoachBaseInfoUpdateModel:GetBoardType()
    return self.boardType
end

-- 获得当前战术类型
function CoachBaseInfoUpdateModel:GetTacticsType()
    return self.tacticsType
end

-- 获得面板标题
function CoachBaseInfoUpdateModel:GetBoardTitle()
    if self.boardType == BoardType.Formation then
        return self.formationStr -- 偏好阵型升级
    elseif self.boardType == BoardType.Tactics then
        return self.tacticsStr -- XXXX升级
    else
        dump("wrong board type! " .. self.boardType)
        return lang.trans("levelUp")
    end
end

-- 获得阵型升级滑动框数据
function CoachBaseInfoUpdateModel:GetFormationScrollData()
    if self.boardType ~= BoardType.Formation then return {} end
    return self.formationDatas
end

-- 获得战术升级滑动框数据
function CoachBaseInfoUpdateModel:GetTacticsScrollData()
    if self.boardType ~= BoardType.Tactics then return {} end
    return self.tacticsDatas
end

-- 获得升级所需物品所拥有数量
function CoachBaseInfoUpdateModel:GetCtiAmount(id)
    return self.coachItemMapModel:GetTacticItem(id)
end

-- 获得当前拥有欧元数目
function CoachBaseInfoUpdateModel:GetMoney()
    return self.playerInfoModel:GetMoney()
end

-- 获得当前拥有钻石数目
function CoachBaseInfoUpdateModel:GetDiamond()
    return self.playerInfoModel:GetDiamond()
end

-- 获得当前使用的战术的索引
function CoachBaseInfoUpdateModel:GetUsedTacticIndex()
    return self.usedTacticIndex
end

-- 选择阵型后更新页面
-- 从cache数据中生成需要的数据的函数
function CoachBaseInfoUpdateModel:UpdateSelectedFormation(selectedFormationData)
    self.formationId = selectedFormationData.formationId
    self.selectedType = selectedFormationData.selectedType
    self.formationDatas = {}
    self:UpdateFormationDatas(self.formationId, self.selectedType)
end

function CoachBaseInfoUpdateModel:UpdateFormationDatas(id, selectedType)
    for k, formationData in pairs(self.data.formations or {}) do
        if tonumber(k) == tonumber(id) then
            formationData.boardType = self.boardType
            formationData.formationStr = self.formationStr
            formationData.teamId = self.data.teamId
            formationData.formationId = id
            formationData.formationName = Formation[tostring(id)].name
            formationData.selectedType = selectedType
            formationData.ctiId, formationData.ctiConfig = self:ParseFormationCtiConfig(id)
            self:ParseConfig(formationData)
            table.insert(self.formationDatas, formationData)
            formationData.currCurrencyNum = self:GetCtiAmount(formationData.ctiId)
            break -- 界面上只要一个
        end
    end
end

-- 从cache数据中生成需要的数据的函数
function CoachBaseInfoUpdateModel:UpdateTacticDatas()
    for k, tacticData in pairs(self.data.tactics or {}) do
        self:UpdateTacticData(tacticData)
        table.insert(self.tacticsDatas, tacticData)
    end

    table.sort(self.tacticsDatas, function(a, b)
        return a.id < b.id
    end)
end

-- 更新战术数据，传入只有id和lvl的战术数据即可
-- { id = 1, lvl = 1}
function CoachBaseInfoUpdateModel:UpdateTacticData(rawTacticData)
    local configUpdateData = CoachBaseTactics[tostring(rawTacticData.lvl)] or {}
    local nextConfigUpdateData = CoachBaseTactics[tostring(tonumber(rawTacticData.lvl) + 1)] or {}
    rawTacticData.boardType = self.boardType
    rawTacticData.tacticsType = self.tacticsType
    rawTacticData.tacticsStr = self.tacticsStr
    rawTacticData.ctiId, rawTacticData.ctiConfig = self:ParseTacticCtiConfig(self.tacticsType, rawTacticData.id)
    self:ParseConfig(rawTacticData)
    rawTacticData.currCurrencyNum = self:GetCtiAmount(rawTacticData.ctiId)
end

-- 配置的升级数据解析
function CoachBaseInfoUpdateModel:ParseConfig(rawTacticData)
    local configUpdateData = CoachBaseTactics[tostring(rawTacticData.lvl)] or {}
    local nextConfigUpdateData = CoachBaseTactics[tostring(tonumber(rawTacticData.lvl) + 1)] or {}
    rawTacticData.maxLvl = math.min(self.maxUpdateLvl, self.maxCoachLevel)
    rawTacticData.isMaxLvl = tonumber(rawTacticData.lvl) >= tonumber(self.maxUpdateLvl)
    rawTacticData.isCoachMaxLvl = tonumber(rawTacticData.lvl) >= tonumber(self.maxCoachLevel)
    rawTacticData.ctiAmount = configUpdateData.ctiAmount ~= nil and tonumber(configUpdateData.ctiAmount) > 0 and configUpdateData.ctiAmount or 0
    rawTacticData.m = configUpdateData.m ~= nil and tonumber(configUpdateData.m) > 0 and configUpdateData.m or 0
    rawTacticData.d = configUpdateData.d ~= nil and tonumber(configUpdateData.d) > 0 and configUpdateData.d or 0
    rawTacticData.currProp = configUpdateData.propertyImprove ~= nil and configUpdateData.propertyImprove or 0
    rawTacticData.nextProp = nextConfigUpdateData.propertyImprove ~= nil and nextConfigUpdateData.propertyImprove or 0
end

-- 升级所需cti物品解析
function CoachBaseInfoUpdateModel:ParseFormationCtiConfig(formationId)
    return self.coachItemMapModel:ParseFormationItemConfig(formationId)
end

function CoachBaseInfoUpdateModel:ParseTacticCtiConfig(tacticType, id)
    return self.coachItemMapModel:ParseTacticItemConfig(tacticType, id)
end

-- 升级阵型后更新
function CoachBaseInfoUpdateModel:UpdateAfterUpgradeFormation(newData)
    self:UpdateCurrency(newData.cost)
    self.formationDatas = {}
    self:UpdateFormationDatas(self.formationId, self.selectedType)
end

-- 升级战术后更新
function CoachBaseInfoUpdateModel:UpdateAfterUpgradeTactic(tacticType, id, newData)
    self:UpdateCurrency(newData.cost)
    self:UpdateTacticData(self.data.tactics[tostring(id)])
    self.tacticsDatas[tonumber(id)] = self.data.tactics[tostring(id)]
end

-- 升级后更新货币及物品
function CoachBaseInfoUpdateModel:UpdateCurrency(cost)
    if cost == nil then return end
    -- 管理物品
    self.coachItemMapModel:SetTacticItem(cost.cti.id, cost.cti.num)
    -- 消耗钻石或金币
    if cost.d ~= nil and cost.d > 0 then
        self.playerInfoModel:ReduceDiamond(cost.d)
    end
    if cost.m ~= nil and cost.m > 0 then
        self.playerInfoModel:SetMoney(self.playerInfoModel:GetMoney() - cost.m)
    end
end

return CoachBaseInfoUpdateModel

local Model = require("ui.models.Model")
local Formation = require("data.Formation")
local CoachBaseLevel = require("data.CoachBaseLevel")
local CoachTactics = require("data.CoachTactics")
local UpdateBoardType = require("ui.models.coach.baseInfo.CoachBaseInfoUpdateBoardType")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CoachMainModel = require("ui.models.coach.CoachMainModel")

local CoachBaseInfoModel = class(Model, "CoachBaseInfoModel")

function CoachBaseInfoModel:ctor()
    self.lvlId = nil -- 教练等级对应CoachBaseLevel中的id
    self.maxCoachLvl = 1
    self.isCoachMaxLevel = false
    self.exp = 0 -- 教练等级
    self.teamId = nil
    self.formationId = nil
    self.formationName = ""
    self.selectedType = nil -- 当前阵型的用于筛选的类别，后卫or前锋
    self.tacticsData = nil -- 各个战术选择的档位信息
    self.scrollData = nil

    self.tacticNameCache = nil -- 缓存各个战术各个档位的名字
end

function CoachBaseInfoModel:InitWithProtocol(cacheData, playerTeamsModel, formationCacheDataModel)
    self.cacheData = cacheData
    self.data = cacheData.coach
    self.playerTeamsModel = playerTeamsModel
    self.formationCacheDataModel = formationCacheDataModel
    self.playerInfoModel = PlayerInfoModel.new()
    self.coachMainModel = CoachMainModel.new()

    self.lvlId = tostring(self.data.lvl)
    for k, v in pairs(CoachBaseLevel) do
        if tonumber(k) > self.maxCoachLvl then
            self.maxCoachLvl = tonumber(k)
        end
    end
    if self.data.lvl >= self.maxCoachLvl then self.isCoachMaxLevel = true end
    self.exp = self.data.exp
    self.teamId = self.playerTeamsModel:GetNowTeamId()
    self.formationId = self.playerTeamsModel:GetFormationId(self.teamId)
    self.formationName = self.playerTeamsModel:GetNowFormationName()
    self.selectedType = self.playerTeamsModel:GetSelectedType()
    self.tacticsData = self.playerTeamsModel:GetNowTeamTacticsData()

    self.tacticNameCache = {}
    self:ParseData(self.data)
end

function CoachBaseInfoModel:GetData()
    return self.data
end

function CoachBaseInfoModel:GetStatusData()
    return self.cacheData
end

function CoachBaseInfoModel:GetCurrCoachLvl()
    return self.lvlId
end

-- 当前阶级
function CoachBaseInfoModel:GetCredentialLevel()
    return CoachBaseLevel[self.lvlId].coachCredentialLevel
end

-- 当前星级
function CoachBaseInfoModel:GetStarLevel()
    return CoachBaseLevel[self.lvlId].coachLevel
end

-- 配置最大的ID
function CoachBaseInfoModel:GetMaxCoachLvl()
    return self.maxCoachLvl
end

-- 是否是最大等级
function CoachBaseInfoModel:IsCoachMaxLevel()
    return self.isCoachMaxLevel
end

-- 下一阶级名称
function CoachBaseInfoModel:GetNextCredentialLevelName()
    if not self:IsCoachMaxLevel() then
        local nextLvl = tostring(self.data.lvl + 1)
        return lang.transstr("starLvl", CoachBaseLevel[nextLvl].coachLevel) .. CoachBaseLevel[nextLvl].coachName
    else
        return nil
    end
end

-- 升级所需执教经验书
function CoachBaseInfoModel:GetUpdateNeedCENum()
    return CoachBaseLevel[self.lvlId].ce
end

-- 玩家当前所拥有执教经验书数目
function CoachBaseInfoModel:GetCurrCENum()
    return self.playerInfoModel:GetCredentialExp()
end

-- 当前等级对应描述
function CoachBaseInfoModel:GetCoachDesc()
    return CoachBaseLevel[self.lvlId].coachDesc
end

-- 当前等级对应描述
function CoachBaseInfoModel:GetCoachUpgradeDesc()
    return CoachBaseLevel[self.lvlId].upgradeDesc
end

-- 升级教练后更新
function CoachBaseInfoModel:UpdateAfterUpgradeCoach(newData)
    self.data.lvl = newData.lvl
    self.data.exp = newData.exp
    local contents = newData.contents or {}
    self.lvlId = tostring(newData.lvl)
    if newData.lvl >= self.maxCoachLvl then self.isCoachMaxLevel = true end
    if self.playerInfoModel ~= nil then
        if newData.cost ~= nil and newData.cost.type == CurrencyType.CredentialExp then
            self.playerInfoModel:SetCredentialExp(tonumber(newData.cost.curr_num))
            self.playerInfoModel:AddCoachTalentPoint(contents.ctp or 0)
        end
    end

-- 更新cache
    self.coachMainModel:SetCoachLevel(self.data.lvl)
    self.coachMainModel:SetCoachExp(self.data.exp)
end

-- 滑动框数据
function CoachBaseInfoModel:GetScrollData()
    return self.scrollData
end

-- 阵型
function CoachBaseInfoModel:GetCurrFormationId()
    return self.formationId
end

function CoachBaseInfoModel:GetCurrFormationData()
    return Formation[tostring(self.formationId)]
end

-- 解析数据
function CoachBaseInfoModel:ParseData(cacheData)
    self.scrollData = {}
    -- 阵型数据
    local formationData = {
        idx = 1, -- 用于排序
        boardType = UpdateBoardType.Formation,
        formationStr = lang.transstr("favourite") .. lang.transstr("menu_formation"), -- 偏好阵型
        teamId = self.teamId,
        formationId = self.formationId,
        formationName = self.formationName,
        selectedType = self.selectedType,
        formations = self:ParseLvlArrayToTable(cacheData.formation)
    }
    for k, formationData in pairs(formationData.formations) do
        formationData.id = tonumber(k)
    end
    -- 传球策略
    local passTacticData = {
        idx = 2,
        boardType = UpdateBoardType.Tactics,
        tacticsType = FormationConstants.FormationTacticsType.PASSTACTIC,
        tacticsStr = lang.transstr("tactics_passTactic"),
        usedTacticIndex = self.tacticsData.passTactic,
        tactics = self:ParseLvlArrayToTable(cacheData.tactics.passTactic)
    }
    for k, tacticData in pairs(passTacticData.tactics) do
        tacticData.id = tonumber(k)
        tacticData.tacticName = self:ParseTacticsConfigToName(FormationConstants.FormationTacticsType.PASSTACTIC, k)
    end
    -- 战术节奏
    local attackRhythmData = {
        idx = 3,
        boardType = UpdateBoardType.Tactics,
        tacticsType = FormationConstants.FormationTacticsType.ATTACKRHYTHM,
        tacticsStr = lang.transstr("tactics_attackRhythm"),
        usedTacticIndex = self.tacticsData.attackRhythm,
        tactics = self:ParseLvlArrayToTable(cacheData.tactics.attackRhythm)
    }
    for k, tacticData in pairs(attackRhythmData.tactics) do
        tacticData.id = tonumber(k)
        tacticData.tacticName = self:ParseTacticsConfigToName(FormationConstants.FormationTacticsType.ATTACKRHYTHM, k)
    end
    -- 比赛心态
    local attackMentalityData = {
        idx = 4,
        boardType = UpdateBoardType.Tactics,
        tacticsType = FormationConstants.FormationTacticsType.ATTACKMENTALITY,
        tacticsStr = lang.transstr("tactics_attackMentality"),
        usedTacticIndex = self.tacticsData.attackMentality,
        tactics = self:ParseLvlArrayToTable(cacheData.tactics.attackMentality)
    }
    for k, tacticData in pairs(attackMentalityData.tactics) do
        tacticData.id = tonumber(k)
        tacticData.tacticName = self:ParseTacticsConfigToName(FormationConstants.FormationTacticsType.ATTACKMENTALITY, k)
    end
    -- 防守策略
    local defenseMentalityData = {
        idx = 5,
        boardType = UpdateBoardType.Tactics,
        tacticsType = FormationConstants.FormationTacticsType.DEFENSEMENTALITY,
        tacticsStr = lang.transstr("tactics_defenseStrategy"),
        usedTacticIndex = self.tacticsData.defenseMentality,
        tactics = self:ParseLvlArrayToTable(cacheData.tactics.defenseMentality)
    }
    for k, tacticData in pairs(defenseMentalityData.tactics) do
        tacticData.id = tonumber(k)
        tacticData.tacticName = self:ParseTacticsConfigToName(FormationConstants.FormationTacticsType.DEFENSEMENTALITY, k)
    end
    -- 进攻偏好
    local attackEmphasisData = {
        idx = 6,
        boardType = UpdateBoardType.Tactics,
        tacticsType = FormationConstants.FormationTacticsType.ATTACKEMPHASIS,
        tacticsStr = lang.transstr("tactics_attackEmphasis"),
        usedTacticIndex = self.tacticsData.attackEmphasis,
        tactics = self:ParseLvlArrayToTable(cacheData.tactics.attackEmphasis)
    }
    for k, tacticData in pairs(attackEmphasisData.tactics) do
        tacticData.id = tonumber(k)
        tacticData.tacticName = self:ParseTacticsConfigToName(FormationConstants.FormationTacticsType.ATTACKEMPHASIS, k)
    end
    table.insert(self.scrollData, formationData)
    table.insert(self.scrollData, passTacticData)
    table.insert(self.scrollData, attackRhythmData)
    table.insert(self.scrollData, attackMentalityData)
    table.insert(self.scrollData, defenseMentalityData)
    table.insert(self.scrollData, attackEmphasisData)

    table.sort(self.scrollData, function(a, b)
        return a.idx < b.idx
    end)
end

-- 服务器下发的只有等级数据，如下
-- formation = {
--     1 = 1,
--     2 = 2
-- }
-- 本函数将数据转换为
-- formation = {
--     1 = { lvl = 1},
--     2 = { lvl = 2},
-- }
function CoachBaseInfoModel:ParseLvlArrayToTable(lvlData)
    local tableData = {}
    for k, v in pairs(lvlData) do
        tableData[k] = {}
        tableData[k].lvl = tonumber(v)
    end
    return tableData
end

-- 获得每个战术的名字，制作缓存
function CoachBaseInfoModel:ParseTacticsConfigToName(tacticType, currTactic)
    currTactic = tostring(currTactic)
    if not self.tacticNameCache[tacticType] then
        self.tacticNameCache[tacticType] = {}
    end
    if self.tacticNameCache[tacticType][currTactic] then
        return self.tacticNameCache[tacticType][currTactic]
    else
        for k, config in pairs(CoachTactics) do
            if config[tacticType] > 0 and tonumber(config[tacticType]) == tonumber(currTactic) then
                self.tacticNameCache[tacticType][currTactic] = config.name
                return config.name
            end
        end
    end
    return ""
end

-- 阵型升级后更新
function CoachBaseInfoModel:UpdateAfterFormationUpgrade(idx, formationId, newData)
    self.data.formation[tostring(formationId)] = newData.coach.formation[tostring(formationId)]
    self.scrollData[idx].formations[tostring(formationId)].lvl = newData.coach.formation[tostring(formationId)]
end

-- 战术升级后更新
function CoachBaseInfoModel:UpdateAfterTacticUpgrade(idx, tacticType, id, newData)
    self.data.tactics[tacticType][tostring(id)] = newData.coach.tactics[tacticType][tostring(id)]
    self.scrollData[idx].tactics[tostring(id)].lvl = newData.coach.tactics[tacticType][tostring(id)]
end

return CoachBaseInfoModel

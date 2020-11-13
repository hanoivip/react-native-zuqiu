local Model = require("ui.models.Model")
local QuestTeam = require("data.QuestTeam")
local TeamTotal = require("data.TeamTotal")

-- 主线副本单独关卡数据模型
local StageInfoModel = class(Model, "StageInfoModel")
-- 今日剩余挑战次数最大值
local MAX_CHALLENGE_TIMES = 5

function StageInfoModel:ctor()
    StageInfoModel.super.ctor(self)
    -- 关卡数据
    self.data = nil
end

function StageInfoModel:InitWithProtocol(stageId, data)
    if type(data) == "table" then
        self.data = data

        if tonumber(self.data.remainCnt) == -1 then
            self.data.remainCnt = 5
        end
    else
        self.data = {
            -- 剩余挑战次数
            remainCnt = MAX_CHALLENGE_TIMES,
            -- 星级
            star = 0,
            -- 重置次数
            reset = 0,
            read = 0,
        }
    end

    self.data.staticData = QuestTeam[stageId]
    self.data.stageId = stageId
end

function StageInfoModel:GetData()
    return self.data
end

--- 获取关卡ID
-- @return string
function StageInfoModel:GetStageId()
    return self.data.stageId
end

--- 获取关卡索引
-- @return number
function StageInfoModel:GetStageIndex()
    return tonumber(string.sub(self:GetStageId(), -2))
end

--- 获取章节ID
-- @return string
function StageInfoModel:GetChapterId()
    return self.data.staticData.journeyID
end

--- 获取章节索引
-- @return number
function StageInfoModel:GetChapterIndex()
    return tonumber(string.sub(self:GetChapterId(), 2))
end

--- 获取星级
-- @return number
function StageInfoModel:GetStar()
    return tonumber(self.data.star)
end

--- 检测关卡是否已通关
-- @return boolean
function StageInfoModel:CheckStageCleared()
    return self:GetStar() > 0
end

--- 获取关卡名称
function StageInfoModel:GetStageName()
    return self.data.staticData.questName
end

--- 获取敌人的队徽
function StageInfoModel:GetTeamLogo()
    local teamId = self.data.staticData.teamID
    return TeamTotal[teamId].teamLogo
end

--- 获取球队名称
function StageInfoModel:GetTeamName()
    local teamId = self.data.staticData.teamID
    return TeamTotal[teamId].teamName
end

--- 获取球队战力
function StageInfoModel:GetTeamPower()
    return self.data.staticData.power
end

--- 获取通关条件列表
function StageInfoModel:GetConditionList()
    local list = nil
    if not self:HasSpecialConditions() then
        list = {lang.transstr("quest_winMatch"), lang.transstr("quest_normal_condition", 2), lang.transstr("quest_normal_condition", 3)}
    else
        list = {self.data.staticData.specialPass}
    end
    return list
end

--- 获取剧情显示状态
-- @return number
function StageInfoModel:GetRead()
    return tonumber(self.data.read)
end

--- 设置剧情显示状态
function StageInfoModel:SetRead(read)
    self.data.read = read
end

--- 获取奖杯类型
function StageInfoModel:GetCupType()
    return self.data.staticData.questNature
end

--- 获取编号
function StageInfoModel:GetSerialNumber()
    return self.data.staticData.questNumber or ""
end

--- 获取花费的体力
function StageInfoModel:GetCostStrength()
    return self.data.staticData.passEnergy
end

--- 是否有特殊条件
function StageInfoModel:HasSpecialConditions()
    return self.data.staticData.special == 1
end

return StageInfoModel
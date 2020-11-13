local ArenaGrade = require("data.ArenaGrade")
local Model = require("ui.models.Model")
local ArenaRankConstants = require("ui.scene.arena.rank.ArenaRankConstants")

local ArenaRankModel = class(Model, "ArenaRankModel")

function ArenaRankModel:ctor()
    ArenaRankModel.super.ctor(self)
end

function ArenaRankModel:InitPlayerRankInfo(arenaModel)
    local arenaModel = arenaModel
    self.playerRankInfo = {}
    table.insert(self.playerRankInfo, arenaModel.arena.silver)
    table.insert(self.playerRankInfo, arenaModel.arena.gold)
    table.insert(self.playerRankInfo, arenaModel.arena.black)
    table.insert(self.playerRankInfo, arenaModel.arena.platinum)
    table.insert(self.playerRankInfo, arenaModel.arena.red)
    table.insert(self.playerRankInfo, arenaModel.arena.anniversary)
    table.insert(self.playerRankInfo, arenaModel.arena.arenaPeak)
end

function ArenaRankModel:InitWithProtocol(data)
    if data ~= nil then
        self.rankData = clone(data)
    end
    self.selfRank = tonumber(self.rankData.self)
    self.totalNum = tonumber(self.rankData.cnt)
    self:RefreshRankModelInfo()
end

function ArenaRankModel:RefreshRankModelInfo()
    if self.zoneList ~= nil then
        for k, v in pairs(self.zoneList) do
            v.type = self.type
        end
    else
        self.zoneList = {}
        table.insert(self.zoneList, {
            name = lang.trans("arena_silver_rankName"),
            zone = ArenaRankConstants.Zone.Silver,
            type = self.type,
        })
        table.insert(self.zoneList, {
            name = lang.trans("arena_gold_rankName"),
            zone = ArenaRankConstants.Zone.Gold,
            type = self.type,
        })
        table.insert(self.zoneList, {
            name = lang.trans("arena_black_rankName"),
            zone = ArenaRankConstants.Zone.Black,
            type = self.type,
        })
        table.insert(self.zoneList, {
            name = lang.trans("arena_platinum_rankName"),
            zone = ArenaRankConstants.Zone.Platinum,
            type = self.type,
        })
        table.insert(self.zoneList, {
            name = lang.trans("arena_red_rankName"),
            zone = ArenaRankConstants.Zone.Red,
            type = self.type,
        })
        table.insert(self.zoneList, {
            name = lang.trans("arena_yellow_rankName"),
            zone = ArenaRankConstants.Zone.Yellow,
            type = self.type,
        })
        table.insert(self.zoneList, {
            name = lang.trans("arena_blue_rankName"),
            zone = ArenaRankConstants.Zone.Blue,
            type = self.type,
        })
    end

    self.selectIndex = self.curSelectIndex or 1
    self.zone = self.zoneList[self.selectIndex].zone or ArenaRankConstants.Zone.Silver
    self.type = self.curType or ArenaRankConstants.Type.Server
    self.curStageScore = self.playerRankInfo[self.selectIndex].score
    self.curStageHScore = self.playerRankInfo[self.selectIndex].h_score
    self.curStage = self:GetAreaState(self.curStageScore)
    self.curStageName = self:GetGradeName(self.curStage)
    self.curHStage = self:GetAreaState(self.curStageHScore)
    self.curHStageName = self:GetGradeName(self.curHStage)
    self.curAreaState = self:GetAreaState(self.curStageScore)
    self.curSeasons = self.playerRankInfo[self.selectIndex].seasons

    for i, v in ipairs(self.zoneList) do
        if i == self.selectIndex then
            v.isSelect = true
        else 
            v.isSelect = false
        end
    end
end

function ArenaRankModel:SetSelectType(type)
    self.curType = type
    self:RefreshRankModelInfo()
end

function ArenaRankModel:SetSelectIndex(selectIndex)
    self.curSelectIndex = selectIndex
    self:RefreshRankModelInfo()
end

-- 当前竞技场所在等级
function ArenaRankModel:GetCurAreaState()
    return self.curAreaState
end

-- 竞技场列表
function ArenaRankModel:GetZoneList()
    return self.zoneList
end

-- 当前竞技场显示数据
function ArenaRankModel:GetCurRankDataList()
    table.sort(self.rankData.list, function(a, b) return a.rank < b.rank end)
    return self.rankData.list
end

-- Player 当前榜内的段位名、最高段位名、赛季数
function ArenaRankModel:GetPlayerGradeInfo()
    return self.curStage, self.curStageName, self.curHStage, self.curHStageName, self.curSeasons
end

-- stage 段位
-- 用段位反推段位名
function ArenaRankModel:GetGradeName(stage)
    local name = ""
    for k, v in pairs(ArenaGrade) do
        if stage == v.stage then
            name = v.gradeName
            break
        end
    end
    return name
end

-- 用积分反推竞技场等级及星级
function ArenaRankModel:GetAreaState(score)
    local stage, star, openStar, minStage = 0, 0, 0, 0
    for k, v in pairs(ArenaGrade) do
        if v.minScore <= score and v.maxScore >= score then 
            stage = v.stage
            minStage = v.miniStage
            star = score - v.minScore + 1
            openStar = v.maxScore - v.minScore + 1
        end
    end
    return stage, star, openStar, minStage
end

function ArenaRankModel:GetArenaType()
    return self.zone
end


return ArenaRankModel
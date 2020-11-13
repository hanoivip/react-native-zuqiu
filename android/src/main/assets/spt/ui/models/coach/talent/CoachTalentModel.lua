local Model = require("ui.models.Model")
local Tree = require("ui.models.coach.talent.tree.Tree")
local TreeNode = require("ui.models.coach.talent.tree.TreeNode")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CoachTalent = require("data.CoachTalent")

local CoachTalentModel = class(Model, "CoachTalentModel")

CoachTalentModel.RoundType = {
    type_1 = 1, -- 树形14444
    type_2 = 2  -- 并列33333
}

function CoachTalentModel:ctor()
    self.playerInfoModel = nil
    self.cacheData = nil
    self.roundDatas = nil
    self.currScrollIdx = 1 -- 滑动框当前展示的索引
    self.scrollData = nil

    self.resetCost = 0 -- 重置天赋点消耗
end

function CoachTalentModel:InitWithProtocol(cacheData)
    self.cacheData = cacheData -- talent
    self.playerInfoModel = PlayerInfoModel.new()
    self:ParseConfigData(self.cacheData)
end

function CoachTalentModel:GetData()
    return self.cacheData
end

function CoachTalentModel:GetStatusData()
    return self.cacheData
end

-- 解析配置数据
function CoachTalentModel:ParseConfigData(cacheData)
    self.roundDatas = {}
    self.scrollData = {}
    local tempConfigData = {}
    for skillId, skillData in pairs(CoachTalent or {}) do
        skillData.id = tostring(skillId)
        table.insert(tempConfigData, skillData)
    end
    table.sort(tempConfigData, function(a, b)
        return tonumber(a.id) < tonumber(b.id)
    end) -- 保证按序插入

    for k, skillData in pairs(tempConfigData or {}) do
        skillData.lvl = cacheData[tostring(skillData.id)] or 0 -- 当前等级
        skillData.maxLvl = #skillData.talentPoint -- 最大等级
        skillData.usedPoint = self:RecalcUsedPoint(skillData) -- 反推使用的天赋点
        local aNode = TreeNode.new(tostring(skillData.id), skillData)
        local roundId = tostring(skillData.roundID)
        local roundData = {}
        if not self.roundDatas[roundId] then
            -- 初始化一个round，即一个大关
            roundData.roundId = roundId
            roundData.roundType = tonumber(skillData.roundType)
            roundData.roundUnlockCondition = tonumber(skillData.roundUnlockCondition) -- 大关开启需要在前一大关卡投入的天赋点
            roundData.roundName = skillData.tabName
            roundData.roundPicIndex = skillData.roundPicIndex
            roundData.usedPoint = 0

            if roundData.roundType == self.RoundType.type_1 then
                roundData.talentTree = Tree.new(aNode) -- 建立一个实根
            elseif roundData.roundType == self.RoundType.type_2 then
                roundData.talentTree = Tree.new() -- 建立一个虚根，id为“root”
                roundData.talentTree:InsertNode("root", aNode)
            else
                dump("wrong talent tree type!")
            end
            self.roundDatas[roundId] = roundData
        else
            roundData = self.roundDatas[roundId]
            local preId = skillData.preID
            local parentId = "root" -- 默认为虚根子结点
            if preId ~= nil and tonumber(preId) > 0 then
                parentId = tostring(preId)
            end
            roundData.talentTree:InsertNode(parentId, aNode)
        end
        roundData.usedPoint = roundData.usedPoint + skillData.usedPoint
    end
    local roundNum = table.nums(self.roundDatas)
    for roundId, roundData in pairs(self.roundDatas) do
        roundData.roundNum = roundNum
        roundData.talentTree:DepthFirstTraversingCus(function(result, node)
            -- 解析技能状态
            self:ParseSkillState(node)
        end)
        table.insert(self.scrollData, roundData)
    end
    table.sort(self.scrollData, function(a, b)
        return tonumber(a.roundId) < tonumber(b.roundId)
    end)
end

-- 判断当前技能的解锁状态、是否达到最大等级
function CoachTalentModel:ParseSkillState(node)
    local skillData = node:GetContent()
    if not skillData then return end

    local parentNode = node:GetParent()
    local preRoundId = tostring(tonumber(skillData.roundID or 0) - 1)
    local preRoundData = self.roundDatas[preRoundId]

    skillData.isLocked = tobool(not (skillData.lvl > 0))
    skillData.isMaxLvl = tobool(skillData.lvl >= skillData.maxLvl)
    skillData.canUnlock = false

    if not skillData.isLocked then return end -- 已解锁，无需进行canUnlock判断

    local preId = tonumber(skillData.preID) -- 前置技能
    local unlockCondition = tonumber(skillData.unlockCondition) -- 前置技能解锁条件：前置技能等级
    local roundUnlockCondition = tonumber(skillData.roundUnlockCondition) -- 前置关卡解锁条件：投入技能点
    local parentData = nil
    if parentNode ~= nil then
        parentData = parentNode:GetContent()
    end

    if preId > 0 and roundUnlockCondition > 0 then
        -- 两个条件都要看
        if parentData ~= nil and preRoundData ~= nil then
            skillData.canUnlock = tonumber(parentData.lvl) >= unlockCondition and preRoundData.usedPoint >= roundUnlockCondition
        end
        if not skillData.canUnlock then
            skillData.unlockContidionStr = lang.transstr("coach_talent_skill_unlcok_condition", unlockCondition)
        end
    elseif preId > 0 and roundUnlockCondition <= 0 then
        -- 上一个技能达到条件，本skill才可解锁
        if parentData ~= nil then
            skillData.canUnlock = tonumber(parentData.lvl) >= unlockCondition
        end
        if not skillData.canUnlock then
            skillData.unlockContidionStr = lang.transstr("coach_talent_skill_unlcok_condition", unlockCondition)
        end
    elseif preId <= 0 and roundUnlockCondition > 0 then
        -- 上一关达到条件，本skill才可解锁
        if preRoundData ~= nil then
            skillData.canUnlock = preRoundData.usedPoint >= roundUnlockCondition
        end
        if not skillData.canUnlock then
            skillData.unlockContidionStr = lang.transstr("coach_talent_skill_unlcok_round_condition", preRoundData.roundName, roundUnlockCondition)
        end
    else
        -- 无条件，直接解锁
        skillData.canUnlock = true
    end
end

-- 反向计算当前已消耗的天赋点
function CoachTalentModel:RecalcUsedPoint(skillData)
    local usedPoint = 0
    local lvl = skillData.lvl
    if lvl > 0 then
        for i = 1, lvl do
            usedPoint = usedPoint + skillData.talentPoint[i]
        end
    end
    return usedPoint
end

-- 获得滑动列表数据
function CoachTalentModel:GetScrollData()
    return self.scrollData
end

-- 滑动框索引
function CoachTalentModel:SetScrollViewIndex(index)
    self.currScrollIdx = index
end

function CoachTalentModel:GetScrollViewIndex()
    return self.currScrollIdx
end

-- 获得教练天赋点数目
function CoachTalentModel:GetCtp()
    return self.playerInfoModel:GetCoachTalentPoint()
end

-- 获得欧元
function CoachTalentModel:GetMoney()
    return self.playerInfoModel:GetMoney()
end

-- 获得当前round已使用天赋点
function CoachTalentModel:GetCurrRoundUsedPoint()
    local roundData = self.scrollData[self.currScrollIdx]
    return roundData.usedPoint
end

-- 获得重置天赋所需钻石
function CoachTalentModel:SetResetTalentPointCost(cost)
    self.resetCost = cost
end

-- 获得重置天赋所需钻石
function CoachTalentModel:GetResetTalentPointCost()
    if self.resetCost > 0 then
        return self.resetCost
    else
        return 500
    end
end

-- 解锁后更新数据
function CoachTalentModel:UpdateAfterUnlock(skillData, talent, cost)
    self:UpdateAfterUpgrade(skillData, talent, cost)
end

-- 升级后更新数据
function CoachTalentModel:UpdateAfterUpgrade(skillData, talent, cost)
    local id = tostring(skillData.id)
    local roundId = tostring(skillData.roundID)
    self.cacheData[id] = talent[id]
    if self.roundDatas[roundId] ~= nil then
        local roundData = self.roundDatas[roundId]
        local node = roundData.talentTree:GetNode(id)
        if node ~= nil then
            local oldData = node:GetContent()
            oldData.lvl = tonumber(talent[id])
            roundData.usedPoint = roundData.usedPoint - oldData.usedPoint
            oldData.usedPoint = self:RecalcUsedPoint(oldData)
            roundData.usedPoint = roundData.usedPoint + oldData.usedPoint
            self:ParseSkillState(node)

            local childs = node:GetChilds()
            for k, child in pairs(childs) do
                self:ParseSkillState(child)
            end
        end
    end

    if self.playerInfoModel then
        -- 欧元
        if cost.m ~= nil and tonumber(cost.m) > 0 then
            self.playerInfoModel:SetMoney(self.playerInfoModel:GetMoney() - tonumber(cost.m))
        end
        -- 钻石
        if cost.d ~= nil and tonumber(cost.d) > 0 then
            self.playerInfoModel:SetDiamond(self.playerInfoModel:GetDiamond() - tonumber(cost.d))
        end
        -- 教练天赋点
        if cost.ctp ~= nil and tonumber(cost.ctp) > 0 then
            self.playerInfoModel:SetCoachTalentPoint(self.playerInfoModel:GetCoachTalentPoint() - tonumber(cost.ctp))
        end
    end

    -- 下一个round检查
    local nextId = tostring(skillData.roundID + 1)
    if self.roundDatas[nextId] ~= nil then
        local roundData = self.roundDatas[nextId]
        local root = roundData.talentTree:GetRoot()
        if root ~= nil then
            self:ParseSkillState(root)
            local childs = root:GetChilds()
            for k, child in pairs(childs) do
                self:ParseSkillState(child)
            end
        end
    end
end

-- 获得所使用的所有天赋点
function CoachTalentModel:GetSumUsedPoint()
    local sumUsedPoint = 0
    for k, roundData in pairs(self.scrollData) do
        sumUsedPoint = sumUsedPoint + roundData.usedPoint or 0
    end
    return sumUsedPoint
end

-- 重置后更新数据
function CoachTalentModel:UpdateAfterReset(talent, cost, contents)
    self.cacheData = talent
    self:ParseConfigData(self.cacheData)

    if cost ~=nil and cost.type ~= nil and tostring(cost.type) == CurrencyType.Diamond then
        self.playerInfoModel:SetDiamond(cost.curr_num)
    end

    if contents ~=nil and contents.ctp ~= nil and tonumber(contents.ctp) > 0 then
        self.playerInfoModel:AddCoachTalentPoint(contents.ctp)
    end
end

return CoachTalentModel

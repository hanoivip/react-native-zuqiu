local Model = require("ui.models.Model")
local AssistantCoachModel = require("ui.models.coach.assistantSystem.AssistantCoachModel")
local AssistantCoachConstants = require("ui.models.coach.assistantSystem.AssistantCoachConstants")
local CoachItemMapModel = require("ui.models.coach.common.CoachItemMapModel")
local AssistantCoachInformationCompose = require("data.AssistantCoachInformationCompose")
local CoachMainPageConfig = require("ui.scene.coach.coachMainPage.CoachMainPageConfig")
local GetOpenStateByTag = CoachMainPageConfig.GetOpenStateByTag
local Tag = CoachMainPageConfig.Tag

local AssistCoachInformationModel = class(Model, "AssistCoachInformationModel")

AssistCoachInformationModel.TabTags = {
    star = "star", -- 星级/品质
}

AssistCoachInformationModel.MaxUsedItemNum = 3

function AssistCoachInformationModel:ctor()
    self.coachItemMapModel = nil

    self.aciModelDic = nil -- 从coachItemMapModel获得的所有助教情报model，{fixId = aciModel, fixId = aciModel}
    self.aciModelList = nil -- 筛选后的助教情报列表
    self.chooseState = {} -- 左侧列表选中状态，{ fixId = aciModel, fixId = aciModel }
    self.grooveState = {} -- 右侧槽位使用状态，{ index = aciModel, index = aciModel }
    self.tabTag = nil -- 当前选中的页签
    self.tabOrder = true -- 选中页签的排序方式，true升序，false降序
    self.preStar = 0 -- 预期星级

    -- 筛选参数
    self.fiQuality = nil
    self.fiType = nil
    self.fiRarity = nil
end

function AssistCoachInformationModel:Init()
    self.coachItemMapModel = CoachItemMapModel.new()
    if self.tabTag == nil then
        self:SetTabTag(self.TabTags.star)
    end
    self.preStar = 0

    self.chooseState = {}
    self.grooveState = {}
    self.fiQuality = nil
    self.fiType = nil
    self.fiRarity = nil

    self:RefreshAciModelDic()
    self:RefreshAciModelList()
    self:SortAciModelList()
end

function AssistCoachInformationModel:RefreshAciModelDic()
    self.aciModelDic = self.coachItemMapModel:GetExpandAssistCoachInfoModels()
    self.hasInformation = table.nums(self.aciModelDic) > 0
end

function AssistCoachInformationModel:IsPlayerHasInformation()
    return self.hasInformation
end

function AssistCoachInformationModel:RefreshAciModelList()
    self.aciModelList = {}
    local flagQuality, flagType, flagRarity
    for fixId, aciModel in pairs(self.aciModelDic) do
        -- 蕴含式
        flagQuality = (not (self.fiQuality ~= nil)) or tonumber(aciModel:GetAssistantInfoQuailty()) == tonumber(self.fiQuality)
        flagType = (not (self.fiType ~= nil)) or tonumber(aciModel:GetAssistantInfoType()) == tonumber(self.fiType)
        flagRarity = (not (self.fiRarity ~= nil)) or tonumber(aciModel:GetSuperInformation()) == tonumber(self.fiRarity)
        if flagQuality and flagType and flagRarity then
            table.insert(self.aciModelList, aciModel)
        end
    end
end

function AssistCoachInformationModel:GetStatusData()
    return self:GetTabTag(), self:GetTabOrder()
end

function AssistCoachInformationModel:GetAciModelList()
    return self.aciModelList
end

function AssistCoachInformationModel:GetAciModelById(id)
    for k, aciModel in pairs(self.aciModelList) do
        if tostring(id) == tostring(aciModel:GetId()) then
            return aciModel
        end
    end
    return nil
end

-- 获得当前页签的tag
function AssistCoachInformationModel:GetTabTag()
    return self.tabTag
end

-- 设置当前选中的排序的页签
function AssistCoachInformationModel:SetTabTag(tag)
    self.tabTag = tag
end
    
-- 获得当前排序的方式，true升序，false降序
function AssistCoachInformationModel:GetTabOrder()
    return self.tabOrder
end

-- 设置当前排序的方式
function AssistCoachInformationModel:SetTabOrder(order)
    self.tabOrder = order
end

-- 获得左侧列表选中状态
function AssistCoachInformationModel:GetChooseState()
    return self.chooseState
end

-- 设置左侧列表选中状态
function AssistCoachInformationModel:SetChooseState(chooseState)
    self.chooseState = chooseState
end

-- 更新左侧列表选中状态
function AssistCoachInformationModel:UpdateItemChoosedState(aciModel)
    if self.chooseState[aciModel.fixId] then
        self.chooseState[aciModel.fixId] = nil
    else
        self.chooseState[aciModel.fixId] = aciModel
    end
end

-- 获得预期星级
function AssistCoachInformationModel:GetPreStar()
    return self.preStar
end

-- 设置预期星级
function AssistCoachInformationModel:SetPreStar(star)
    self.preStar = star
end

-- 获得右侧槽位使用状态
function AssistCoachInformationModel:GetGrooveState()
    return self.grooveState
end

-- 设置右侧槽位使用状态
function AssistCoachInformationModel:SetGrooveState(grooveState)
    self.grooveState = grooveState
end

-- 判断某个槽位是否有情报书
function AssistCoachInformationModel:CheckGroovePuttingState(idx)
    return tobool(self.grooveState[tonumber(idx)] ~= nil)
end

-- 更新右侧槽位使用状态
function AssistCoachInformationModel:UpdateGrooveItem(idx, aciModel)
    idx = tonumber(idx)
    if idx > 0 and idx <= self.MaxUsedItemNum then
        self.grooveState[idx] = aciModel
    end
    self:UpdateRecruit()
end

-- 使用一个槽位
function AssistCoachInformationModel:PutGrooveItem(idx, aciModel)
    self:UpdateGrooveItem(idx, aciModel)
    aciModel.grooveIdx = idx
end

-- 置空一个槽位
function AssistCoachInformationModel:RemoveGrooveItem(idx, aciModel)
    self:UpdateGrooveItem(idx)
    aciModel.grooveIdx = nil
end

-- 获得一个可使用的槽位
function AssistCoachInformationModel:GetAvailableGroove()
    for idx = 1, self.MaxUsedItemNum do
        if self.grooveState[idx] == nil then
            return idx
        end
    end
    return nil
end

-- 根据当前槽位计算生效百分比及预期星级
function AssistCoachInformationModel:UpdateRecruit()
    if table.nums(self.grooveState) <= 0 then
        self.preStar = 0
        return
    end

    local tempMax = tonumber(AssistantCoachConstants.MaxQuality + 1)
    self.preStar = tempMax
    local minAciModel = nil
    local minInfoQuality = tempMax
    -- 获得有阶级情报中最小的aciModel
    for idx = 1, self.MaxUsedItemNum do
        local aciModel = self.grooveState[idx]
        if aciModel ~= nil then
            local star = tonumber(aciModel:GetAssistantInfoQuailty())
            minInfoQuality = math.min(minInfoQuality, star)
            if not aciModel:IsSuperInformation() then
                if self.preStar > star then
                    self.preStar = star
                    minAciModel = aciModel
                end
            end
        end
    end
    if minAciModel == nil then -- 都是无阶级情报
        self.preStar = minInfoQuality -- 无阶级情报中最小的
        -- 都设置为100%
        for idx = 1, self.MaxUsedItemNum do
            local aciModel = self.grooveState[idx]
            if aciModel ~= nil then
                aciModel:SetComposeEfxProbability(100)
            end
        end
    else
        -- 无阶级情报查表，有阶级情报100%
        for idx = 1, self.MaxUsedItemNum do
            local aciModel = self.grooveState[idx]
            if aciModel ~= nil then
                aciModel:SetComposeEfxProbability(100)
                if aciModel:IsSuperInformation() then -- 无阶级情报查表
                    aciModel:SetComposeEfxProbability(self:GetConfigEfxProbability(self.preStar, aciModel:GetAssistantInfoQuailty()))
                else -- 有阶级情报100%
                    aciModel:SetComposeEfxProbability(100)
                end
            end
        end
    end
end

function AssistCoachInformationModel:GetConfigEfxProbability(main, special)
    for k, config in pairs(AssistantCoachInformationCompose) do
        if tonumber(config.MainInformationLevel) == main and tonumber(config.specialInformationLevel) == special then
            return config.effecProbability
        end
    end
    return 0
end

-- 排序所有助理教练情报的model列表
function AssistCoachInformationModel:SortAciModelList()
    if table.nums(self.aciModelList) <= 0 then
        return
    end

    local sortFunc = function(a, b)
        local sortByTagFunc = self[format("SortByTag%s", self.tabTag)]
        return sortByTagFunc(self, a, b)
    end
    table.sort(self.aciModelList, function(a, b)
        return sortFunc(a, b)
    end)

    for idx, acModel in ipairs(self.aciModelList) do
        acModel.idx = tonumber(idx)
    end
end

-- 根据星级排序
function AssistCoachInformationModel:SortByTagstar(a, b)
    a_quality = tonumber(a:GetAssistantInfoQuailty())
    b_quality = tonumber(b:GetAssistantInfoQuailty())
    if self.tabOrder then
        if a.grooveIdx ~= nil and b.grooveIdx ~= nil then
            return tonumber(a.grooveIdx) < tonumber(b.grooveIdx)
        elseif a.grooveIdx ~= nil and b.grooveIdx == nil then
            return true
        elseif a.grooveIdx == nil and b.grooveIdx ~= nil then
            return false
        else
            if a_quality < b_quality then
                return true
            elseif a_quality > b_quality then
                return false
            else
                return tonumber(a.fixId) < tonumber(b.fixId)
            end
        end
    else
        if a.grooveIdx ~= nil and b.grooveIdx ~= nil then
            return tonumber(a.grooveIdx) < tonumber(b.grooveIdx)
        elseif a.grooveIdx ~= nil and b.grooveIdx == nil then
            return true
        elseif a.grooveIdx == nil and b.grooveIdx ~= nil then
            return false
        else
            if a_quality < b_quality then
                return false
            elseif a_quality > b_quality then
                return true
            else
                return tonumber(a.fixId) < tonumber(b.fixId)
            end
        end
    end
end

-- 获取出售功能的开放状态
function AssistCoachInformationModel:GetMarketOpenState()
    return GetOpenStateByTag(Tag.Market)
end

-- 获取需要分解的数据格式
function AssistCoachInformationModel:GetDecomposeItems()
    local items = {}
    for fixId, aciModel in pairs(self.chooseState) do
        local aciid = tostring(aciModel:GetId())
        if items[aciid] == nil then
            items[aciid] = 1
        else
            items[aciid] = items[aciid] + 1
        end
    end
    return items
end

-- 获取合成的数据格式
function AssistCoachInformationModel:GetComposeItems()
    local items = {}
    for idx, aciModel in pairs(self.grooveState) do
        if aciModel ~= nil then
            table.insert(items, aciModel:GetId())
        end
    end
    return items
end

-- 分解后更新
function AssistCoachInformationModel:UpdateAfterDecompose(data)
    local cost = data.cost or {}
    for k, v in pairs(cost) do
        self.coachItemMapModel:ReduceAssistCoachInfo(v.id, v.reduce)
    end
    -- 选中的都被分解
    for fixId, aciModel in pairs(self.chooseState) do
        self.aciModelDic[fixId] = nil
    end

    for idx = 1, self.MaxUsedItemNum do
        local aciModel = self.grooveState[idx]
        if aciModel ~= nil then
            if self.chooseState[aciModel.fixId] ~= nil then
                -- 已经添加到右侧槽位的被分解，右侧槽位置空
                self.grooveState[idx] = nil
            end
        end
    end
    self.chooseState = {}
    self:RefreshAciModelList()
    self:SortAciModelList()
    self.preStar = 0
    self:UpdateRecruit()
end

-- 招募后更新
function AssistCoachInformationModel:UpdateAfterRecruit(data)
    local cost = data.cost or {}
    for k, v in pairs(cost) do
        self.coachItemMapModel:ReduceAssistCoachInfo(v.id, v.reduce)
    end
    self:RefreshAciModelDic()

    self.grooveState = {}
    self.chooseState = {}
    self:RefreshAciModelList()
    self:SortAciModelList()
    self.preStar = 0
    self:UpdateRecruit()
end

-- 获得当前筛选状态
function AssistCoachInformationModel:GetCurrFilterState()
    return self.fiQuality, self.fiType, self.fiRarity
end

-- 执行筛选
function AssistCoachInformationModel:Filter(fiQuality, fiType, fiRarity)
    self.fiQuality = fiQuality
    self.fiType = fiType
    self.fiRarity = fiRarity
    self:RefreshAciModelList()
    self:SortAciModelList()
end

return AssistCoachInformationModel

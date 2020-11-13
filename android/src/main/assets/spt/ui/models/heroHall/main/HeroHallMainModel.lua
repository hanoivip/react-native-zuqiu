local Model = require("ui.models.Model")
local HeroHallDataModel = require("ui.models.heroHall.main.HeroHallDataModel")
local HeroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel")

local HeroHallMainModel = class(Model, "HeroHallMainModel")

local default_cluster_num = 4       -- 一组显示四个殿堂

function HeroHallMainModel:ctor()
    self.data = nil
    self.count = 0          -- 殿堂总数
    self.groupNum = 0       -- 按4个一组，分组数
    self.currGroupId = 1
    self.totalScore = 0     -- 总评分

    self.heroHallDataModel = HeroHallDataModel.new()
    self.heroHallMapModel = HeroHallMapModel.new()
end

function HeroHallMainModel:InitWithProtocol(data)
    self.data = data
    self.count = table.nums(self.data)
    self.groupNum = math.ceil(self.count / default_cluster_num)
    self.totalScore = 0

    self.heroHallMapModel:UpdateCacheAfterEnter(data)

    local tempData = {}
    for hallId, hallData in pairs(self.data) do
        local hallConfigData = self.heroHallDataModel:GetHallConfigDataById(hallId)
        hallData.id = hallId
        hallData.name = hallConfigData.name
        hallData.openDesc = hallConfigData.openDesc
        hallData.desc = hallConfigData.desc
        hallData.attributeType = hallConfigData.improveType
        hallData.order = hallConfigData.order
        self:UpdateAttributeData(hallId, hallData.list)
        self:UpdateSkillImprove(hallData.list)
        self.totalScore = self.totalScore + hallData.score
        hallData.hallPicRes = self.heroHallDataModel:GetHallPicResByScore(hallData.score)
        table.insert(tempData, hallData)
    end

    table.sort(tempData, function(a, b)
        return tonumber(a.order) < tonumber(b.order)
    end)

    local counter = 1
    local groupId = 1
    for k, hallData in ipairs(tempData) do
        hallData.groupId = groupId
        hallData.idx = counter
        if counter % default_cluster_num <= 0 then
            groupId = groupId + 1
            counter = 0
        end
        counter = counter + 1
    end
end

function HeroHallMainModel:GetData()
    return self.data
end

function HeroHallMainModel:GetHeroHallDataModel()
    return self.heroHallDataModel
end

-- 激活殿堂后更新，返回数据和info接口一致
function HeroHallMainModel:UpdateData(hallID, newData)
    self:InitWithProtocol(newData)
end

function HeroHallMainModel:UpdateAttributeData(hallId, statueList)
    for i, statueData in pairs(statueList) do
        statueData.attributes, statueData.fixAttribute, statueData.basicAttribute, statueData.multiAttribute = self.heroHallDataModel:GetAttributesByStatueData(hallId, statueData)
    end
end

function HeroHallMainModel:UpdateSkillImprove(statueList)
    for i, statueData in pairs(statueList) do
        statueData.hlvl = self.heroHallDataModel:GetSkillImprove(statueData.level)
    end
end

function HeroHallMainModel:GetHallDataById(id)
    return self.data[tostring(id)]
end

function HeroHallMainModel:GetGroupNum()
    return self.groupNum
end

function HeroHallMainModel:GetCurrGroup()
    return self.currGroupId
end

function HeroHallMainModel:SetCurrGroup(index)
    self.currGroupId = index
end

function HeroHallMainModel:PreviousGroup()
    if self.currGroupId == 1 then
        return false
    end

    self.currGroupId = self.currGroupId - 1
    return true
end

function HeroHallMainModel:NextGroup()
    if self.currGroupId == self.groupNum then
        return false
    end

    self.currGroupId = self.currGroupId + 1
    return true
end

-- 获得当前组内的殿堂数，四个一组最后一组可能没排满
function HeroHallMainModel:GetMaxCountInCurrGroup()
    if self.currGroupId == self.groupNum then   -- 最后一组
        local tempCount = self.count
        while tempCount > default_cluster_num do
            tempCount = tempCount - default_cluster_num
        end
        return tempCount
    else
        return default_cluster_num
    end
end

function HeroHallMainModel:GetCurrGroupItemDatas()
    return self:GetItemDataByGroup(self.currGroupId)
end

function HeroHallMainModel:GetItemDataByGroup(groupId)
    local itemDatas = {}
    for k, v in pairs(self.data) do
        if v.groupId == groupId then
            table.insert(itemDatas, v)
        end
        if table.nums(itemDatas) == default_cluster_num then
            break
        end
    end
    -- 根据hallID排序
    table.sort(itemDatas, function(a, b)
        return tonumber(a.order) < tonumber(b.order)
    end)
    return itemDatas
end

function HeroHallMainModel:GetSkillImprove(hallID)
    return self.data[tostring(hallID)].hlvl
end

function HeroHallMainModel:GetTotalScore()
    return self.totalScore
end

function HeroHallMainModel:GetDefaultClusterNum()
    return default_cluster_num
end

-- 根据殿堂ID获得当前组中的索引顺序
function HeroHallMainModel:GetHallIndexByHallID(hallID)
    return self:GetHallDataById(hallID).idx
end

return HeroHallMainModel
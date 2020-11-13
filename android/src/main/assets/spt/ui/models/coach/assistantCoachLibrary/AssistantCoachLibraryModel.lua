local Model = require("ui.models.Model")
local CoachMainModel = require("ui.models.coach.CoachMainModel")
local CoachBaseLevel = require("data.CoachBaseLevel")
local AssistantCoachModel = require("ui.models.coach.assistantSystem.AssistantCoachModel")
local AssistantCoachConstants = require("ui.models.coach.assistantSystem.AssistantCoachConstants")
local CoachMainPageConfig = require("ui.scene.coach.coachMainPage.CoachMainPageConfig")
local GetOpenStateByTag = CoachMainPageConfig.GetOpenStateByTag
local Tag = CoachMainPageConfig.Tag

local AssistantCoachLibraryModel = class(Model, "AssistantCoachLibraryModel")

AssistantCoachLibraryModel.TabTags = {
    star = "star", -- 星级/品质
    date = "date", -- 入手顺序
    level = "level", -- 等级
}

function AssistantCoachLibraryModel:ctor()
    self.cacheData = nil
    self.acModels = {} -- 所有助理教练数组

    self.choosedTeamIdx = nil -- AssistantCoachSystem传下来的将要更换的助教团队的idx
    self.tabTag = nil -- 当前选中的页签
    self.tabOrder = true -- 选中页签的排序方式，true升序，false降序
    self.choosedAcid = nil -- 当前选中的助理教练的Acid

    self.coachMainModel = CoachMainModel.new()
end

function AssistantCoachLibraryModel:InitWithProtocol(cacheData)
    self.cacheData = cacheData or {}

    -- 上阵情况
    self:ParseTeamInfo(cacheData.ac_list or {}, cacheData.ac_teamlist or {})
    -- 生成model
    self:ParesListToModel(cacheData.ac_list or {})

    self:SetChoosedTeamIdx(nil)
    self:SetTabTag(self.TabTags.date)
    self:SetTabOrder(true)
    self:SetChoosedAcid(nil)
end

-- 解析上阵情况
function AssistantCoachLibraryModel:ParseTeamInfo(ac_list, ac_teamlist)
    for idx, acData in pairs(ac_teamlist) do
        ac_list[tostring(acData.ac_id)].ac_teamIdx = idx
    end
end

-- 将数据列表转换成acModel数组
function AssistantCoachLibraryModel:ParesListToModel(ac_list)
    self.acModels = {}
    for acid, acData in pairs(ac_list) do
        local acModel = AssistantCoachModel.new()
        acModel:InitWithProtocol(acData)
        table.insert(self.acModels, acModel)
        acData.ac_model = acModel
    end
end


function AssistantCoachLibraryModel:GetStatusData()
    return self:GetChoosedTeamIdx(), self:GetTabTag(), self:GetTabOrder(), self:GetChoosedAcid()
end

-- 获得服务器下发的原始数据
function AssistantCoachLibraryModel:GetCacheData()
    return self.cacheData
end

-- 获得将要更换的助教团队的idx
-- 为空表示无将要更换的
function AssistantCoachLibraryModel:GetChoosedTeamIdx()
    return self.choosedTeamIdx
end

-- 设置将更换的助教团队的idx
function AssistantCoachLibraryModel:SetChoosedTeamIdx(idx)
    self.choosedTeamIdx = idx
end

-- 获得当前页签的tag
function AssistantCoachLibraryModel:GetTabTag()
    return self.tabTag
end

-- 设置当前选中的排序的页签
function AssistantCoachLibraryModel:SetTabTag(tag)
    self.tabTag = tag
end

-- 获得当前排序的方式，true升序，false降序
function AssistantCoachLibraryModel:GetTabOrder()
    return self.tabOrder
end

-- 设置当前排序的方式
function AssistantCoachLibraryModel:SetTabOrder(order)
    self.tabOrder = order
end

-- 获得当前选中的助理教练的Acid
function AssistantCoachLibraryModel:GetChoosedAcid()
    return self.choosedAcid
end

-- 设置选中的助理教练的Acid
function AssistantCoachLibraryModel:SetChoosedAcid(acid)
    self.choosedAcid = acid
end

-- 获得所有助理教练model列表
function AssistantCoachLibraryModel:GetAssistantCoachModels()
    return self.acModels or {}
end

-- 排序所有助理教练的model列表
function AssistantCoachLibraryModel:SortAcModels()
    if table.nums(self.acModels) <= 0 then
        return
    end

    local sortFunc = function(a, b)
        local sortByTagFunc = self[format("SortByTag%s", self.tabTag)]
        return sortByTagFunc(self, a, b)
    end
    table.sort(self.acModels, function(a, b)
        return sortFunc(a, b)
    end)

    -- 默认选中列表中第一个
    if not self.choosedAcid then
        if self.acModels and table.nums(self.acModels) > 0 then
            self:SetChoosedAcid(self.acModels[1]:GetId())
        end
    end

    for idx, acModel in ipairs(self.acModels) do
        acModel.idx = tonumber(idx)
    end
end

-- 根据星级排序
function AssistantCoachLibraryModel:SortByTagstar(a, b)
    a_quality = tonumber(a:GetQuality())
    b_quality = tonumber(b:GetQuality())
    if self.tabOrder then
        if a_quality < b_quality then
            return true
        elseif a_quality > b_quality then
            return false
        else
            return tonumber(a:GetId()) < tonumber(b:GetId())
        end
    else
        if a_quality < b_quality then
            return false
        elseif a_quality > b_quality then
            return true
        else
            return tonumber(a:GetId()) < tonumber(b:GetId())
        end
    end
end

-- 根据入手顺序排序
function AssistantCoachLibraryModel:SortByTagdate(a, b)
    if self.tabOrder then
        return tonumber(a:GetId()) < tonumber(b:GetId())
    else
        return tonumber(a:GetId()) > tonumber(b:GetId())
    end
end

-- 根据等级排序
function AssistantCoachLibraryModel:SortByTaglevel(a, b)
    a_lvl = tonumber(a:GetLvl())
    b_lvl = tonumber(b:GetLvl())
    if self.tabOrder then
        if a_lvl < b_lvl then
            return true
        elseif a_lvl > b_lvl then
            return false
        else
            return tonumber(a:GetId()) < tonumber(b:GetId())
        end
    else
        if a_lvl < b_lvl then
            return false
        elseif a_lvl > b_lvl then
            return true
        else
            return tonumber(a:GetId()) < tonumber(b:GetId())
        end
    end
end

-- 通过id获得acModel
function AssistantCoachLibraryModel:GetAcModelByAcid(acid)
    if acid ~= nil and self.cacheData.ac_list then
        if self.cacheData.ac_list[tostring(acid)] then
            return self.cacheData.ac_list[tostring(acid)].ac_model
        else
            return nil
        end
    else
        return nil
    end
end

-- 获得当前选中的acModel
function AssistantCoachLibraryModel:GetCurrAcModel()
    return self:GetAcModelByAcid(self:GetChoosedAcid())
end

-- 获取出售功能的开放状态
function AssistantCoachLibraryModel:GetMarketOpenState()
    return GetOpenStateByTag(Tag.Market)
end

-- 获取当前选中的ac的上阵情况
function AssistantCoachLibraryModel:CheckCurrACInTeam()
    return (self:GetCurrAcModel()):IsInTeam()
end

-- 根据teamIdx获得助理教练的名称
function AssistantCoachLibraryModel:GetAcnameByTeamIdx(teamIdx)
    teamIdx = tostring(teamIdx)
    if self.cacheData ~= nil and self.cacheData.ac_teamlist ~= nil and table.nums(self.cacheData.ac_teamlist) > 0 and
        self.cacheData.ac_teamlist[teamIdx] ~= nil then
        return self.cacheData.ac_teamlist[teamIdx].ac_name
    else
        return nil
    end
end

-- 根据teamIdx获得助理教练的acid
function AssistantCoachLibraryModel:GetAcidByTeamIdx(teamIdx)
    teamIdx = tostring(teamIdx)
    if self.cacheData ~= nil and self.cacheData.ac_teamlist ~= nil and table.nums(self.cacheData.ac_teamlist) > 0 and
        self.cacheData.ac_teamlist[teamIdx] ~= nil then
        return self.cacheData.ac_teamlist[teamIdx].ac_id
    else
        return nil
    end
end

-- 换阵后更新
function AssistantCoachLibraryModel:UpdateAfterSwitch(data)
    local teamIdx = tostring(data.teamid)
    local oldAcModel = self:GetAcModelByAcid(self:GetAcidByTeamIdx(teamIdx))
    if oldAcModel ~= nil then
        oldAcModel:SetTeamIdx(0)
    end
    local currAcModel = self:GetCurrAcModel()
    if currAcModel ~= nil then
        currAcModel:SetTeamIdx(teamIdx)
    end
    self.cacheData.ac_teamlist[teamIdx] = data.ac_info
    self.cacheData.ac_teamlist[teamIdx].ac_teamIdx = tonumber(teamIdx)
    self.coachMainModel:RefreshAssistantData(teamIdx, data.ac_info)
end

-- 解雇后更新
function AssistantCoachLibraryModel:UpdateAfterFire(data)
    local currAcModel = self:GetCurrAcModel()
    local acid = currAcModel:GetId()
    self.cacheData.ac_list[tostring(acid)] = nil
    table.remove(self.acModels, tonumber(currAcModel.idx))
    self.choosedAcid = nil
    -- 解雇后选中列表第一个
    self:SortAcModels()
end

-- 当前教练等级下可携带最大助理教练数目
function AssistantCoachLibraryModel:GetMaxTeams()
    return CoachBaseLevel[tostring(self.coachMainModel:GetCoachLevel())].assistantCoachAmount
end

return AssistantCoachLibraryModel

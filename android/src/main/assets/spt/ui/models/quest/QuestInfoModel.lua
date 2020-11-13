local Model = require("ui.models.Model")
local QuestBase = require("data.QuestBase")
local QuestTeam = require("data.QuestTeam")
local StageInfoModel = require("ui.models.quest.StageInfoModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local QuestConstants = require("ui.scene.quest.QuestConstants")

-- 主线副本数据模型
local QuestInfoModel = class(Model, "QuestInfoModel")

function QuestInfoModel:ctor()
    -- 副本通讯协议数据
    self.protocolData = nil
    -- 副本数据
    self.questData = nil
    -- 章节总数
    self.chapterSum = nil
    self.super.ctor(self)
end

function QuestInfoModel:Init(data)
    if not data then
        data = cache.getQuestInfo()
    end
    self.protocolData = data
    if self.protocolData then
        self:InitQuestData()
    end
end

function QuestInfoModel:InitWithProtocol(data)
    cache.setQuestInfo(data)
    self:Init(data)
end

-- 在有些情况会重新初始化进度造成进度变成1-1（原因暂时不明，初步怀疑第二天时间刷新“spanDay”造成, 无法复现）
function QuestInfoModel:CheckInfoEmptyData()
    local isPostAgain = false
    local data = self.protocolData
    if not data then 
        isPostAgain = true
    elseif data.list and table.nums(data.list) <= 0 then 
        isPostAgain = true
    end

    if isPostAgain then 
        EventSystem.SendEvent("QuestInfo_PostAgain")
    end
end

--- 初始化副本数据
function QuestInfoModel:InitQuestData()
    self.questData = {}
    self.chapterSum = 0

    for chapterId, chapterStaticData in pairs(QuestBase) do
        local chapterData = {}
        local chapterIndex = tonumber(string.sub(chapterId, 2))
        chapterData.chapterId = chapterId
        chapterData.staticData = chapterStaticData
        chapterData.stageList = {}
        self.questData[chapterIndex] = chapterData

        -- TODO: 因为目前地图不全，地图齐全后可以去掉判断
        if chapterIndex > QuestConstants.ChapterSum then
            self.questData[chapterIndex] = nil
        end

        if type(chapterData.staticData.questList) == "table" then
            self.chapterSum = self.chapterSum + 1
            for i, stageId in ipairs(chapterData.staticData.questList) do
                local stageInfoModel = StageInfoModel.new()
                stageInfoModel:InitWithProtocol(stageId, self.protocolData.list[stageId])
                table.insert(chapterData.stageList, stageInfoModel)
            end
        end
    end

    -- TODO: 因为目前地图不全，地图齐全后可以去掉判断
    if self.chapterSum > QuestConstants.ChapterSum then
        self.chapterSum = QuestConstants.ChapterSum
    end
end

--- 获取副本数据
-- @return table
function QuestInfoModel:GetQuestData()
    return self.questData
end

--- 获取已开启的章节数据列表
-- @return table
function QuestInfoModel:GetOpenedChapterDataList()
    local list = {}

    for i, chapterData in ipairs(self.questData) do
        if self:CheckChapterOpenedByIndex(i) then
            table.insert(list, chapterData)
        end
    end

    return list
end

--- 根据index获取章节数据
-- @param index 章节索引，从1开始
-- @return table
function QuestInfoModel:GetChapterDataByIndex(index)
    return self.questData[index]
end

--- 根据id获取章节数据
-- @param chapterId 章节Id
-- @return table
function QuestInfoModel:GetChapterDataById(chapterId)
    local chapterIndex = self:GetChapterIdByIndex(chapterId)
    return self:GetChapterDataByIndex(chapterIndex)
end

--- 获取章节总数
-- @return number
function QuestInfoModel:GetChapterSum()
    return self.chapterSum
end

--- 获取最新章节的索引
-- @return number
function QuestInfoModel:GetLastChapterIndex()
    local index = 1

    for i = #self.questData, 1, -1 do
        if self:CheckChapterOpenedByIndex(i) then
            index = i
            break
        end
    end

    -- TODO: 因为目前地图不全，地图齐全后可以去掉判断
    if index > QuestConstants.ChapterSum then
        index = QuestConstants.ChapterSum
    end

    return index
end

--- 获取最新章节的Id
-- @return string
function QuestInfoModel:GetLastChapterId()
    local lastChapterIndex = self:GetLastChapterIndex()
    return self:GetChapterIdByIndex(lastChapterIndex)
end

--- 获取章节中第一个关卡Id
-- @param chapterIndex 章节索引
-- @return string
function QuestInfoModel:GetFirstStageIdByChapterIndex(chapterIndex)
    local chapterData = self:GetChapterDataByIndex(chapterIndex)
    local firstStageInfoModel = chapterData.stageList[1]
    return firstStageInfoModel:GetStageId()
end

--- 获取章节中第一个关卡Id
-- @param chapterId 章节Id
-- @return string
function QuestInfoModel:GetFirstStageIdByChapterId(chapterId)
    local chapterIndex = self:GetChapterIndexById(chapterId)
    return GetFirstStageIdByChapterIndex(chapterIndex)
end

--- 获取章节中最新关卡的索引
-- @param chapterIndex 章节索引
-- @return number
function QuestInfoModel:GetLastStageIndexByChapterIndex(chapterIndex)
    local chapterData = self:GetChapterDataByIndex(chapterIndex)
    local lastStageIndex = 0
    for i, stageInfoModel in ipairs(chapterData.stageList) do
        local isCleared = stageInfoModel:CheckStageCleared()
        if isCleared then
            lastStageIndex = i
        else
            lastStageIndex = i
            break
        end
    end
    return lastStageIndex
end

--- 获取章节中最新关卡Id
-- @param chapterId 章节Id
-- @return string
function QuestInfoModel:GetLastStageIdByChapterId(chapterId)
    local chapterIndex = self:GetChapterIndexById(chapterId)
    local chapterData = self:GetChapterDataByIndex(chapterIndex)
    local lastStageIndex = self:GetLastStageIndexByChapterIndex(chapterIndex)
    local lastStageInfoModel = chapterData.stageList[lastStageIndex]
    return lastStageInfoModel:GetStageId()
end

--- 根据章节Id获取章节索引
-- @param chapterId 章节Id
-- @return number
function QuestInfoModel:GetChapterIndexById(chapterId)
    local chapterIndex = nil
    for i, chapterData in ipairs(self.questData) do
        if chapterData.chapterId == chapterId then
            chapterIndex = i
            break
        end
    end

    -- TODO: 因为目前地图不全，地图齐全后可以去掉判断
    if chapterIndex == nil then
        chapterIndex = QuestConstants.ChapterSum + 1
    end

    return chapterIndex
end

--- 根据章节索引获取章节Id
-- @param chapterIndex 章节索引
-- @return string
function QuestInfoModel:GetChapterIdByIndex(chapterIndex)
    return self.questData[chapterIndex].chapterId
end

--- 根据关卡Id获取章节Id
-- @param stageId 关卡Id
-- @return string
function QuestInfoModel:GetChapterIdByStageId(stageId)
    local stageData = QuestTeam[stageId]
    return stageData.journeyID
end

--- 根据关卡Id获取关卡索引
-- @param stageId 关卡Id
-- @return number
function QuestInfoModel:GetStageIndexById(stageId)
    local chapterId = self:GetChapterIdByStageId(stageId)
    local chapterIndex = self:GetChapterIndexById(chapterId)
    local chapterData = self:GetChapterDataByIndex(chapterIndex)
    for i, v in ipairs(chapterData.staticData.questList) do
        if v == stageId then
            return i
        end
    end
end

--- 根据关卡Id获取StageInfoModel
-- @param stageId 关卡Id
-- @return StageInfoModel
function QuestInfoModel:GetStageInfoModelById(stageId)
    local chapterId = self:GetChapterIdByStageId(stageId)
    local chapterIndex = self:GetChapterIndexById(chapterId)
    local chapterData = self:GetChapterDataByIndex(chapterIndex)
    for i, stageInfoModel in ipairs(chapterData.stageList) do
        if stageInfoModel:GetStageId() == stageId then
            return stageInfoModel
        end
    end
end

--- 检测章节是否已通关
-- @param index 章节索引，从1开始
-- @return boolean
function QuestInfoModel:CheckChapterClearedByIndex(index)
    -- TODO: 因为目前地图不全，地图齐全后可以去掉判断
    if index > QuestConstants.ChapterSum then
        return false
    end
    local chapterData = self:GetChapterDataByIndex(index)
    local isCleared = true

    if chapterData ~= nil and next(chapterData.stageList) then
        for i, stageInfoModel in ipairs(chapterData.stageList) do
            if not stageInfoModel:CheckStageCleared() then
                isCleared = false
                break
            end
        end
    else
        isCleared = false
    end

    return isCleared
end

--- 检测章节是否已通关
-- @param chapterId 章节id
-- @return boolean
function QuestInfoModel:CheckChapterClearedById(chapterId)
    local chapterIndex = self:GetChapterIndexById(chapterId)
    return self:CheckChapterClearedByIndex(chapterIndex)
end

--- 检测章节是否已开启
-- @param index 章节索引，从1开始
-- @return boolean
function QuestInfoModel:CheckChapterOpenedByIndex(index)
    -- TODO: 因为目前地图不全，地图齐全后可以去掉判断
    if index > QuestConstants.ChapterSum then
        return false
    end
    local playerInfoModel = PlayerInfoModel.new()
    local playerLevel = playerInfoModel:GetLevel()

    if index == 1 then
        return true
    else
        local chapterData = self:GetChapterDataByIndex(index)

        if self:CheckChapterClearedByIndex(index - 1) and playerLevel > chapterData.staticData.condition1 and chapterData.staticData.questList ~= nil then
            return true
        else
            return false
        end
    end
end

--- 检测章节是否已开启
-- @param chapterId 章节id
-- @return boolean
function QuestInfoModel:CheckChapterOpenedById(chapterId)
    local chapterIndex = self:GetChapterIndexById(chapterId)
    -- TODO: 因为目前地图不全，地图齐全后可以去掉判断
    if chapterIndex > QuestConstants.ChapterSum then
        return false
    end
    return self:CheckChapterOpenedByIndex(chapterIndex)
end

--- 检测关卡是否已开启
-- @param chapterIndex 章节索引
-- @param stageIndex 关卡索引
-- @return boolean
function QuestInfoModel:CheckStageOpenedByIndex(chapterIndex, stageIndex)
    -- TODO: 因为目前地图不全，地图齐全后可以去掉判断
    if chapterIndex > QuestConstants.ChapterSum then
        return false
    end
    local nowChapterData = self:GetChapterDataByIndex(chapterIndex)
    local nowStageInfoModel = nowChapterData.stageList[stageIndex]

    if not self:CheckChapterOpenedByIndex(chapterIndex) then
        return false
    end

    if nowStageInfoModel:CheckStageCleared() then
        return true
    else
        if stageIndex == 1 then
            return true
        else
            local previousStageInfoModel = nowChapterData.stageList[stageIndex - 1]
            if previousStageInfoModel:CheckStageCleared() then
                return true
            else
                return false
            end
        end
    end
end

--- 检测关卡是否已开启
-- @param chapterId 章节id
-- @param stageId 关卡Id
-- @return boolean
function QuestInfoModel:CheckStageOpenedById(stageId)
    local chapterId = self:GetChapterIdByStageId(stageId)
    local chapterIndex = self:GetChapterIndexById(chapterId)
    -- TODO: 因为目前地图不全，地图齐全后可以去掉判断
    if chapterIndex > QuestConstants.ChapterSum then
        return false
    end
    local stageIndex = self:GetStageIndexById(stageId)
    return self:CheckStageOpenedByIndex(chapterIndex, stageIndex)
end

function QuestInfoModel:GetIndexByStageId(stageId)
    local chapterId = self:GetChapterIdByStageId(stageId)
    local questList = QuestBase[chapterId].questList

    for i, id in ipairs(questList) do
        if tostring(id) == tostring(stageId) then
            return i
        end
    end
    return 0
end

--- 比较指定关卡ID与当前通关的最后一个关卡ID之间间隔多少关卡
-- @param stageId 关卡Id
function QuestInfoModel:MacthStageLongthToLastStageId(stageId)
    local lastChapterId = self:GetLastChapterId()
    local lastStateId = self:GetLastStageIdByChapterId(lastChapterId)

    local longth = 0
    local selelctChapterId = self:GetChapterIdByStageId(stageId)
    local lastChapterIndex = tonumber(string.sub(lastChapterId, 2))
    local selectChapterIndex = tonumber(string.sub(selelctChapterId, 2))
    if selelctChapterId == lastChapterId then
        local lastStateIndex = tonumber(string.sub(lastStateId, 2))
        local selelctStateIndex = tonumber(string.sub(stageId, 2))
        if selelctStateIndex > lastStateIndex then
            longth = selelctStateIndex - lastStateIndex
        end
    elseif selectChapterIndex > lastChapterIndex then
        local lastQuestList = QuestBase[lastChapterId].questList
        local lastQuestNum = table.nums(lastQuestList)
        local index = self:GetIndexByStageId(lastStateId)

        longth = lastQuestNum - index
        for i = lastChapterIndex + 1, selectChapterIndex - 1 do
            local key = "Q" .. i
            local QuestList = QuestBase[key].questList
            local QuestNum = table.nums(QuestList)
            longth = longth + QuestNum
        end
        local index = self:GetIndexByStageId(stageId)
        longth = longth + index
    end
    return longth
end

--- 更新通信数据
-- @param updateData 更新数据
function QuestInfoModel:UpdateProtocolData(updateData)
    for stageId, stageData in pairs(updateData) do
        local oldStageData = self.protocolData.list[stageId]
        if oldStageData == nil then
            self.protocolData.list[stageId] = stageData
        else
            for k, v in pairs(stageData) do
                oldStageData[k] = stageData[k]
            end
        end
        cache.setQuestInfo(self.protocolData)
    end
end

return QuestInfoModel
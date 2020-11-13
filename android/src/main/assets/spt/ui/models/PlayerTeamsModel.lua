local Model = require("ui.models.Model")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local Formation = require("data.Formation")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local FormationType = require("ui.common.enum.FormationType")
local Num2LetterPos = require("data.Num2LetterPos")

local PlayerTeamsModel = class(Model, "PlayerTeamsModel")

-- 非对应位置球员的战力衰减百分比
PlayerTeamsModel.POS_MISMATCH_DISCOUNT = 99

-- 临时存储战力数据
local tempPowerData = {}

function PlayerTeamsModel:ctor()
    -- 队伍数据
    self.data = nil
    -- 当前展示阵容数据
    self.nowTeamData = nil
    -- 当前展示阵容Id，从0开始
    self.nowTeamId = nil
    -- 当前阵型Id
    self.nowFormationId = nil
    -- 所有卡牌数据
    self.allCardsData = nil
     -- 三个阵容中所有球员cid(.init)
    self.allTeamCardsCidData = nil
    self.formationType = FormationType.DEFAULT
    PlayerTeamsModel.super.ctor(self)
end

function PlayerTeamsModel:Init(data)
    if not data then
        data = cache.getPlayerTeams()
    end

    if data ~= nil then
        self.data = clone(data)
        self:SetNowTeamData(self:GetNowTeamId())
        self:SetSelectedType(self:GetSelectedType())
    end
end

function PlayerTeamsModel:InitWithProtocol(data)
    local teamsCacheData = clone(data)
    local teamsMap = data and data.teams or {}
    teamsCacheData.teams = {}
    for k, teamData in pairs(teamsMap) do
        teamsCacheData.teams[tostring(teamData.tid)] = teamData
    end
    
    self:Init(teamsCacheData)

    self:CacheInitAndRep()
    self:OnTeamsInfoChanged()
end

function PlayerTeamsModel:SetFormationType(formationType)
    self.formationType = formationType
end

function PlayerTeamsModel:GetFormationType()
    return self.formationType
end

function PlayerTeamsModel:IsHomeCourt()
    return self.formationType == FormationType.HOME
end

-- 记录首发和替补，直接获取值(默认没有人的时候会用0记录)
function PlayerTeamsModel:CacheInitAndRep()
    if self.nowTeamData then 
        self.nowTeamData.initPcids = {}
        local initData = self.nowTeamData.init or {}
        for pos, pcid in pairs(initData) do
            if tonumber(pcid) ~= 0 then
                self.nowTeamData.initPcids[tostring(pcid)] = pos
            end
        end
        self.nowTeamData.repPcids = {}
        local repData = self.nowTeamData.rep or {}
        for pos, pcid in pairs(repData) do
            if tonumber(pcid) ~= 0 then
                self.nowTeamData.repPcids[tostring(pcid)] = pos
            end
        end
    end
end

--- 保存数据
-- @param data 队伍数据
function PlayerTeamsModel:SaveData(data)
    if type(data) == 'table' then
        cache.setPlayerTeams(data)
    else
        cache.setPlayerTeams(self.data)
    end
end

--- 设置当前展示阵容数据
-- @param nowTeamId 当前展示阵容Id
-- @param index 有些玩法阵型只有1套从索引1开始
-- @param FormationId 没有数据默认从阵型10开始
local DefaultFormationIndex = 1
local DefaultFormationId = 10
function PlayerTeamsModel:SetNowTeamData(nowTeamId)
    self.nowTeamId = tonumber(nowTeamId)
    self.nowTeamData = self.data.teams[tostring(nowTeamId)]
    if self.nowTeamData == nil then
        self.nowTeamData = {}
        self.data.teams[tostring(nowTeamId)] = self.nowTeamData
        self.nowFormationId = self.nowFormationId or DefaultFormationId
        self.nowTeamData.formationID = self.nowFormationId
        self.nowTeamData.tid = self.nowTeamId
    else
        self.nowFormationId = self.nowTeamData.formationID
    end
end

-- 获取阵型首发数据
function PlayerTeamsModel:GetInitPlayerCacheData()
    return self.nowTeamData.init
end

-- 获取阵型替补数据
function PlayerTeamsModel:GetReplacePlayerCacheData()
    return self.nowTeamData.rep
end

--- 获取当前展示阵容数据
-- @return table
function PlayerTeamsModel:GetNowTeamData()
    return clone(self.nowTeamData)
end

--- 获取当前展示阵容名称
-- @return formationName
function PlayerTeamsModel:GetNowFormationName()
    local formationId = self:GetFormationId(self:GetNowTeamId())
    return Formation[tostring(formationId)].name
end

--- 获取当前展示阵容名称
-- @return formationName
function PlayerTeamsModel:GetFormationNameById(formationId)
    return Formation[tostring(formationId)].name
end

--- 设置首发球员数据
-- @param nowTeamId 当前展示阵容Id
-- @param initPlayersData 首发球员数据
function PlayerTeamsModel:SetInitPlayersData(nowTeamId, initPlayersData)
    if self.nowTeamId ~= tonumber(nowTeamId) then
        self:SetNowTeamData(nowTeamId)
    end

    self.nowTeamData.init = clone(initPlayersData)
    self.nowTeamData.initPcids = {}
    for pos, pcid in pairs(initPlayersData) do
        self.nowTeamData.initPcids[tostring(pcid)] = pos
    end
    self:SaveData()
end

--- 获取首发球员数据
-- @param nowTeamId 当前展示阵容Id
-- @return table
function PlayerTeamsModel:GetInitPlayersData(nowTeamId)
    return clone(self:_GetInitPlayersData(nowTeamId))
end

--- 获取首发球员数据
-- @param nowTeamId 当前展示阵容Id
-- @return table
function PlayerTeamsModel:_GetInitPlayersData(nowTeamId)
    if self.nowTeamId ~= tonumber(nowTeamId) then
        self:SetNowTeamData(nowTeamId)
    end
    if self.nowTeamData.init == nil then
        self.nowTeamData.init = {}
        local posArray = Formation[tostring(self:GetFormationId(nowTeamId))].posArray
        for i, pos in ipairs(posArray) do
            self.nowTeamData.init[pos] = 0
        end
    end

    return self.nowTeamData.init
end

--- 设置替补球员数据
-- @param nowTeamId 当前展示阵容Id
-- @param initPlayersData 首发球员数据
function PlayerTeamsModel:SetReplacePlayersData(nowTeamId, replacePlayersData)
    if self.nowTeamId ~= tonumber(nowTeamId) then
        self:SetNowTeamData(nowTeamId)
    end

    self.nowTeamData.rep = clone(replacePlayersData)
    self.nowTeamData.repPcids = {}
    for pos, pcid in pairs(replacePlayersData) do
        self.nowTeamData.repPcids[pcid] = pos
    end
    self:SaveData()
end

--- 获取替补球员数据
-- @param nowTeamId 当前展示阵容Id
-- @return table
function PlayerTeamsModel:GetReplacePlayersData(nowTeamId)
    return clone(self:_GetReplacePlayersData(nowTeamId))
end

--- 获取替补球员数据
-- @param nowTeamId 当前展示阵容Id
-- @return table
function PlayerTeamsModel:_GetReplacePlayersData(nowTeamId)
    if self.nowTeamId ~= tonumber(nowTeamId) then
        self:SetNowTeamData(nowTeamId)
    end

    if self.nowTeamData.rep == nil then
        self.nowTeamData.rep = {}
        for i, pos in ipairs(FormationConstants.ReplacePlayersPosArr) do
            self.nowTeamData.rep[pos] = 0
        end
    else
        for i, pos in ipairs(FormationConstants.ReplacePlayersPosArr) do
            if self.nowTeamData.rep[pos] == nil then
                self.nowTeamData.rep[pos] = 0
            end
        end
    end

    return clone(self.nowTeamData.rep)
end

--- 获取候补球员数据
-- @param nowTeamId 当前展示阵容Id
-- @param sortType 排序类型，参考FormationConstants.SortType
-- @return waitPlayersNoRepeatList：不重复的候补球员列表，waitPlayersRepeatList：重复的候补球员列表，数据单元是PlayerCardModel
function PlayerTeamsModel:GetWaitPlayersData(nowTeamId, sortType)
    local initPlayersData = self:_GetInitPlayersData(nowTeamId)
    local replacePlayersData = self:_GetReplacePlayersData(nowTeamId)
    return self:GetWaitPlayersDataByOuterData(initPlayersData, replacePlayersData, sortType)
end

--- 获取候补球员数据
-- @param initPlayersData 首发球员数据
-- @param replacePlayersData 替补球员数据
-- @param sortType 排序类型，参考FormationConstants.SortType
-- @return waitPlayersNoRepeatList：不重复的候补球员列表，waitPlayersRepeatList：重复的候补球员列表，数据单元是PlayerCardModel
function PlayerTeamsModel:GetWaitPlayersDataByOuterData(initPlayersData, replacePlayersData, sortType)
    tempPowerData = {}
    -- 在队伍中的球员列表
    local playersInTeamList = {}
    -- 在队伍中的球员的cid
    local playersCIdInTeamList = {}
    -- 重复的候补球员列表
    local waitPlayersRepeatList = {}
    -- 不重复的候补球员列表
    local waitPlayersNoRepeatList = {}

    -- 获取卡牌背包中的数据
    self:SetAllCardsData()

    for pos, pcId in pairs(initPlayersData) do
        if pcId ~= nil and pcId ~= 0 then
            local playerCardModel = self:GetCardModelWithPcid(pcId)
            if playerCardModel then
                playersInTeamList[pcId] = playerCardModel:GetCid()
            end
        end
    end

    for pos, pcId in pairs(replacePlayersData) do
        if pcId ~= nil and pcId ~= 0 then
            local playerCardModel = self:GetCardModelWithPcid(pcId)
            if playerCardModel then
                playersInTeamList[pcId] = playerCardModel:GetCid()
            end
        end
    end

    for k, v in pairs(playersInTeamList) do
        playersCIdInTeamList[v] = true
    end

    -- 记录cid
    local cidRecordData = {}

    -- 筛选出候补球员
    for k, v in pairs(self.allCardsData) do
        local playerCIdInTeam = playersInTeamList[v.pcid]

        if playerCIdInTeam == nil then
            local playerCardModel = self:GetCardModelWithPcid(v.pcid)

            -- 在候补中有跟首发和替补球员重复的球员
            if playerCardModel:IsSupportOtherCard() then
                -- 助阵他人的球员不出现在候补列表
            elseif playersCIdInTeamList[v.cid] then
                table.insert(waitPlayersRepeatList, playerCardModel)
            else
                if cidRecordData[v.cid] ~= true then
                    cidRecordData[v.cid] = true
                    table.insert(waitPlayersNoRepeatList, playerCardModel)
                else
                    local isRepeat = false
                    for i, cardModel in ipairs(waitPlayersNoRepeatList) do
                        if cardModel:GetCid() == v.cid then
                            if cardModel:GetPower() < playerCardModel:GetPower() then
                                table.insert(waitPlayersRepeatList, cardModel)
                                waitPlayersNoRepeatList[i] = playerCardModel
                            else
                                table.insert(waitPlayersRepeatList, playerCardModel)
                            end
                            isRepeat = true
                        end
                    end
                    if not isRepeat then
                        table.insert(waitPlayersRepeatList, playerCardModel)
                    end
                end
            end
        end
    end

    if sortType == nil then
        sortType = FormationConstants.SortType.POWER
    end

    if sortType == FormationConstants.SortType.POWER then
        table.sort(waitPlayersNoRepeatList, PlayerTeamsModel.SortCardOrderByPower)
        table.sort(waitPlayersRepeatList, PlayerTeamsModel.SortCardOrderByPower)
    elseif sortType == FormationConstants.SortType.QUALITY then
        table.sort(waitPlayersNoRepeatList, PlayerTeamsModel.SortCardOrderByQuality)
        table.sort(waitPlayersRepeatList, PlayerTeamsModel.SortCardOrderByQuality)
    elseif sortType == FormationConstants.SortType.GET_TIME then
        table.sort(waitPlayersNoRepeatList, PlayerTeamsModel.SortCardOrderByGetTime)
        table.sort(waitPlayersRepeatList, PlayerTeamsModel.SortCardOrderByGetTime)
    elseif sortType == FormationConstants.SortType.NAME then
        table.sort(waitPlayersNoRepeatList, PlayerTeamsModel.SortCardOrderByName)
        table.sort(waitPlayersRepeatList, PlayerTeamsModel.SortCardOrderByName)
    end

    tempPowerData = {}
    return waitPlayersNoRepeatList, waitPlayersRepeatList
end

--- 设置当前阵型Id
-- @param nowTeamId 当前展示阵容Id
-- @param nowFormationId 当前阵型Id
function PlayerTeamsModel:SetFormationId(nowTeamId, nowFormationId)
    if self.nowTeamId ~= tonumber(nowTeamId) then
        self:SetNowTeamData(nowTeamId)
    end
    self.nowTeamData.formationID = tonumber(nowFormationId)
    self.nowFormationId = self.nowTeamData.formationID
    self:SaveData()
end

--- 获取当前阵型Id
-- @param nowTeamId 当前展示阵容Id
-- @return number
function PlayerTeamsModel:GetFormationId(nowTeamId)
    if self.nowTeamId ~= tonumber(nowTeamId) then
        self:SetNowTeamData(nowTeamId)
    end

    return self.nowFormationId
end

--- 设置当前使用阵容Id
-- @param nowTeamId 当前阵容Id
function PlayerTeamsModel:SetNowTeamId(nowTeamId)
    self.data.currTid = tonumber(nowTeamId)
    self:SaveData()
end

--- 获取当前阵容Id
-- @return number
function PlayerTeamsModel:GetNowTeamId()
    return self.data.currTid or 0
end

--- 设置阵容排序方式
function PlayerTeamsModel:SetSelectedType(selectedType)
    local teams = self.data.teams[DefaultFormationIndex] or self.data.teams[tostring(self:GetNowTeamId())]
    teams.selectedType = tonumber(selectedType)
    self:SaveData()
end

--- 获取阵容排序方式
function PlayerTeamsModel:GetSelectedType()
    local teams = self.data.teams[DefaultFormationIndex] or self.data.teams[tostring(self:GetNowTeamId())]
    return teams.selectedType
end

--- 获取PlayerCardModel
-- @param pcId 球员卡牌Id
-- @return PlayerCardModel
function PlayerTeamsModel:GetCardModelWithPcid(pcId)
    return PlayerCardModel.new(pcId, self)
end

--- 根据战力对卡牌进行降序排序
-- @param playerCardModel1
-- @param playerCardModel2
function PlayerTeamsModel.SortCardOrderByPower(playerCardModel1, playerCardModel2)
    local power1, power2 = PlayerTeamsModel.GetTwoPlayersPower(playerCardModel1, playerCardModel2)

    if power1 == power2 then
        local level1 = playerCardModel1:GetLevel()
        local level2 = playerCardModel2:GetLevel()

        if level1 == level2 then
            local quality1 = playerCardModel1:GetCardQuality()
            local quality2 = playerCardModel2:GetCardQuality()

            if quality1 == quality2 then
                local pcID1 = playerCardModel1:GetPcid()
                local pcID2 = playerCardModel2:GetPcid()

                return pcID1 > pcID2
            else
                return quality1 > quality2
            end
        else
            return level1 > level2
        end
    else
        return power1 > power2
    end
end

--- 根据品质对卡牌进行降序排序
-- @param playerCardModel1
-- @param playerCardModel2
function PlayerTeamsModel.SortCardOrderByQuality(playerCardModel1, playerCardModel2)
    local quality1 = playerCardModel1:GetCardFixQualityNum()
    local quality2 = playerCardModel2:GetCardFixQualityNum()

    if quality1 == quality2 then
        local power1, power2 = PlayerTeamsModel.GetTwoPlayersPower(playerCardModel1, playerCardModel2)

        if power1 == power2 then
            local level1 = playerCardModel1:GetLevel()
            local level2 = playerCardModel2:GetLevel()

            if level1 == level2 then
                local pcID1 = playerCardModel1:GetPcid()
                local pcID2 = playerCardModel2:GetPcid()

                return pcID1 > pcID2
            else
                return level1 > level2
            end
        else
            return power1 > power2
        end
    else
        return quality1 > quality2
    end
end

--- 根据获取时间对卡牌进行降序排序
-- @param playerCardModel1
-- @param playerCardModel2
function PlayerTeamsModel.SortCardOrderByGetTime(playerCardModel1, playerCardModel2)
    local getTime1 = playerCardModel1:GetObtainTime()
    local getTime2 = playerCardModel2:GetObtainTime()

    if getTime1 == getTime2 then
        local power1, power2 = PlayerTeamsModel.GetTwoPlayersPower(playerCardModel1, playerCardModel2)

        if power1 == power2 then
            local level1 = playerCardModel1:GetLevel()
            local level2 = playerCardModel2:GetLevel()

            if level1 == level2 then
                local quality1 = playerCardModel1:GetCardQuality()
                local quality2 = playerCardModel2:GetCardQuality()

                if quality1 == quality2 then
                    local pcID1 = playerCardModel1:GetPcid()
                    local pcID2 = playerCardModel2:GetPcid()

                    return pcID1 > pcID2
                else
                    return quality1 > quality2
                end
            else
                return level1 > level2
            end
        else
            return power1 > power2
        end
    else
        return getTime1 > getTime2
    end
end

--- 根据名字对卡牌进行降序排序
-- @param playerCardModel1
-- @param playerCardModel2
function PlayerTeamsModel.SortCardOrderByName(playerCardModel1, playerCardModel2)
    local baseId1 = playerCardModel1:GetBaseID()
    local baseId2 = playerCardModel2:GetBaseID()

    if baseId1 == baseId2 then
        local power1, power2 = PlayerTeamsModel.GetTwoPlayersPower(playerCardModel1, playerCardModel2)

        if power1 == power2 then
            local level1 = playerCardModel1:GetLevel()
            local level2 = playerCardModel2:GetLevel()

            if level1 == level2 then
                local quality1 = playerCardModel1:GetCardQuality()
                local quality2 = playerCardModel2:GetCardQuality()

                if quality1 == quality2 then
                    local pcID1 = playerCardModel1:GetPcid()
                    local pcID2 = playerCardModel2:GetPcid()

                    return pcID1 > pcID2
                else
                    return quality1 > quality2
                end
            else
                return level1 > level2
            end
        else
            return power1 > power2
        end
    else
        return string.lower(baseId1) < string.lower(baseId2)
    end
end

--- 对一键上阵的位置根据优先遍历顺序进行排序
-- @param pos1
-- @param pos2
function PlayerTeamsModel.SortRecommendPositionOrder(pos1, pos2)
    local t = FormationConstants.FormationRecommendOrderPosition
    return t[pos1] < t[pos2]
end

--- 根据门将五维属性计算的战力对卡牌进行降序排序
-- @param playerCardModel1
-- @param playerCardModel2
function PlayerTeamsModel.SortCardOrderByGkPower(playerCardModel1, playerCardModel2)
    local power1 = playerCardModel1:GetPowerWithGk()
    local power2 = playerCardModel2:GetPowerWithGk()

    if power1 == power2 then
        local level1 = playerCardModel1:GetLevel()
        local level2 = playerCardModel2:GetLevel()

        if level1 == level2 then
            local quality1 = playerCardModel1:GetCardQuality()
            local quality2 = playerCardModel2:GetCardQuality()

            if quality1 == quality2 then
                return playerCardModel1:GetPcid() > playerCardModel2:GetPcid()
            else
                return quality1 > quality2
            end
        else
            return level1 > level2
        end
    else
        return power1 > power2
    end
end

--- 根据非门将五维属性计算的战力对卡牌进行降序排序
-- @param playerCardModel1
-- @param playerCardModel2
function PlayerTeamsModel.SortCardOrderByNotGkPower(playerCardModel1, playerCardModel2)
    local power1 = playerCardModel1:GetPowerWithNotGk()
    local power2 = playerCardModel2:GetPowerWithNotGk()

    if power1 == power2 then
        local level1 = playerCardModel1:GetLevel()
        local level2 = playerCardModel2:GetLevel()

        if level1 == level2 then
            local quality1 = playerCardModel1:GetCardQuality()
            local quality2 = playerCardModel2:GetCardQuality()

            if quality1 == quality2 then
                return playerCardModel1:GetPcid() > playerCardModel2:GetPcid()
            else
                return quality1 > quality2
            end
        else
            return level1 > level2
        end
    else
        return power1 > power2
    end
end

--- 判断首发球员是否已修改
-- @param nowTeamId 当前展示阵容Id
-- @param newInitPlayersData 新的首发球员数据
-- @return boolean
function PlayerTeamsModel:CheckInitPlayersChanged(nowTeamId, newInitPlayersData)
    local oldInitPlayersData = self:_GetInitPlayersData(nowTeamId)

    for pos, pcId in pairs(oldInitPlayersData) do
        if pcId ~= tonumber(newInitPlayersData[pos]) then
            return true
        end
    end

    for pos, pcId in pairs(newInitPlayersData) do
        if tonumber(pcId) ~= oldInitPlayersData[pos] then
            return true
        end
    end

    return false
end

--- 判断替补球员是否已修改
-- @param nowTeamId 当前展示阵容Id
-- @param newReplacePlayersData 新的替补球员数据
-- @return boolean
function PlayerTeamsModel:CheckReplacePlayersChanged(nowTeamId, newReplacePlayersData)
    local oldReplacePlayersData = self:_GetReplacePlayersData(nowTeamId)

    for pos, pcId in pairs(oldReplacePlayersData) do
        if pcId ~= tonumber(newReplacePlayersData[pos]) then
            return true
        end
    end

    for pos, pcId in pairs(newReplacePlayersData) do
        if tonumber(pcId) ~= oldReplacePlayersData[pos] then
            return true
        end
    end

    return false
end

--- 判断当前使用的阵容Id是否已修改
-- @param nowUseTeamId 当前正在使用的阵容Id
-- @return boolean
function PlayerTeamsModel:CheckUseTeamIdChanged(nowUseTeamId)
    return self.data.currTid ~= tonumber(nowUseTeamId)
end

--- 判断阵型Id是否已修改
-- @param nowTeamId 当前展示阵容Id
-- @param nowFormationId 当前阵型Id
-- @param boolean
function PlayerTeamsModel:CheckFormationIdChanged(nowTeamId, newFormationId)
    local oldFormationId = self:GetFormationId(nowTeamId)
    return oldFormationId ~= tonumber(newFormationId)
end

--- 获取推荐阵容
-- @param nowFormationId 当前阵型Id
-- @param sortType 排序类型，参考FormationConstants.SortType
-- @return initPlayersData, replacePlayersData, waitPlayersNoRepeatList, waitPlayersRepeatList
function PlayerTeamsModel:GetRecommendTeam(nowFormationId, sortType)
    tempPowerData = {}
    -- 获取卡牌背包中的数据
    self:SetAllCardsData()
    local playerCardModelList = {}
    local initPlayersData = {}
    local replacePlayersData = {}
    local playersBaseIdData = {}
    local playersCIdData = {}
    local posArray = clone(Formation[tostring(nowFormationId)].posArray)
    table.sort(posArray, self.SortRecommendPositionOrder)

    -- 构建卡牌模型列表
    for k, v in pairs(self.allCardsData) do
        local model = self:GetCardModelWithPcid(v.pcid)
        local isSupportOtherCard = model:IsSupportOtherCard()
        if not isSupportOtherCard then
            table.insert(playerCardModelList, model)
        end
    end

    table.sort(playerCardModelList, self.SortCardOrderByPower)

    -- 构建首发阵容，符合pos的战力最高的两个球员作为候选，从候选球员中选中擅长位置数量少的，如果擅长位置相等，则选中战力最高的球员
    for i, pos in ipairs(posArray) do
        -- 遍历Model列表，找出符合pos的战力最高的两个Model
        local candidatePlayerCardModels = {}
        for j, model in ipairs(playerCardModelList) do
            local baseId = model:GetBaseID()
            if playersBaseIdData[baseId] == nil and self.CheckPosIsMatch(pos, model:GetPosition()) then
                local candidateModelData = {}
                candidateModelData.index = j
                candidateModelData.model = model
                table.insert(candidatePlayerCardModels, candidateModelData)
            end
            if #candidatePlayerCardModels >= 2 then
                break
            end
        end

        -- 根据满足条件的Model的数量分别处理
        local removeIndex = nil
        local baseId = nil
        local cId = nil
        local candidateModelCount = #candidatePlayerCardModels
        if candidateModelCount == 1 then
            initPlayersData[pos] = candidatePlayerCardModels[1].model:GetPcid()
            removeIndex = candidatePlayerCardModels[1].index
            baseId = candidatePlayerCardModels[1].model:GetBaseID()
            cId = candidatePlayerCardModels[1].model:GetCid()
            playersBaseIdData[baseId] = 1
            playersCIdData[cId] = 1
        -- 如果擅长位置数量不等，取擅长位置数量少的，否则取战力高的
        elseif candidateModelCount == 2 then
            local posListNum1 = 0
            local posListNum2 = 0

            for k, pos in ipairs(posArray) do
                if self.CheckPosIsMatch(pos, candidatePlayerCardModels[1].model:GetPosition()) then
                    posListNum1 = posListNum1 + 1
                end

                if self.CheckPosIsMatch(pos, candidatePlayerCardModels[2].model:GetPosition()) then
                    posListNum2 = posListNum2 + 1
                end
            end

            if posListNum1 ~= posListNum2 then
                local index = posListNum1 > posListNum2 and 2 or 1
                initPlayersData[pos] = candidatePlayerCardModels[index].model:GetPcid()
                removeIndex = candidatePlayerCardModels[index].index
                baseId = candidatePlayerCardModels[index].model:GetBaseID()
                cId = candidatePlayerCardModels[index].model:GetCid()
            else
                initPlayersData[pos] = candidatePlayerCardModels[1].model:GetPcid()
                removeIndex = candidatePlayerCardModels[1].index
                baseId = candidatePlayerCardModels[1].model:GetBaseID()
                cId = candidatePlayerCardModels[1].model:GetCid()
            end
            playersBaseIdData[baseId] = 1
            playersCIdData[cId] = 1
        end
        if initPlayersData[pos] ~= nil then
            table.remove(playerCardModelList, removeIndex)
        else
            initPlayersData[pos] = 0
        end
    end

    -- 如果首发阵容的某些位置没有对应的球员，则非门将位置直接采用战力最高的球员，门将位置直接采用门将五维属性计算的战力最高的球员
    for i, pos in ipairs(posArray) do
        if initPlayersData[pos] == 0 then
            if tonumber(pos) == 26 then
                table.sort(playerCardModelList, self.SortCardOrderByGkPower)
            else
                table.sort(playerCardModelList, self.SortCardOrderByNotGkPower)
            end
            for j, model in ipairs(playerCardModelList) do
                local baseId = model:GetBaseID()
                local cId = model:GetCid()
                if playersBaseIdData[baseId] == nil then
                    initPlayersData[pos] = model:GetPcid()
                    playersBaseIdData[baseId] = 1
                    playersCIdData[cId] = 1
                    table.remove(playerCardModelList, j)
                    break
                end
            end
        end
    end

    -- 构建替补阵容
    table.sort(playerCardModelList, self.SortCardOrderByPower)
    for i, pos in ipairs(FormationConstants.ReplacePlayersPosArr) do
        for j, model in ipairs(playerCardModelList) do
            local cid = model:GetCid()
            if playersCIdData[cid] == nil then
                replacePlayersData[pos] = model:GetPcid()
                playersCIdData[cid] = 1
                table.remove(playerCardModelList, j)
                break
            end
        end
        if replacePlayersData[pos] == nil then
            replacePlayersData[pos] = 0
        end
    end

    tempPowerData = {}

    local waitPlayersNoRepeatList, waitPlayersRepeatList = self:GetWaitPlayersDataByOuterData(initPlayersData, replacePlayersData, sortType)
    return initPlayersData, replacePlayersData, waitPlayersNoRepeatList, waitPlayersRepeatList
end

function PlayerTeamsModel:GetClearStartersData()
    local initData = self.nowTeamData.init or { }
    for pos, v in pairs(initData) do
        self.nowTeamData.init[pos] = 0
    end
    self.nowTeamData.initPcids = {}
    return initData
end

function PlayerTeamsModel:GetClearCurrentTeamStartersData(nowTeamId)
    local initData = {}
    local nowTeamData = self.data.teams[tostring(nowTeamId)] 
    if nowTeamData then
        initData = nowTeamData.init or { }
        for pos, v in pairs(initData) do
            initData[pos] = 0
        end
        nowTeamData.initPcids = {}
    end
    return initData
end


function PlayerTeamsModel:GetClearBenchData()
    local repData = self.nowTeamData.rep or { }
    for pos, v in pairs(repData) do
        self.nowTeamData.rep[pos] = 0
    end
    self.nowTeamData.repPcids = {}
    return repData
end

--- 检测球员当前的位置和自身擅长的位置是否匹配
-- @param pos 球员在球场上的位置
-- @param positionList 球员自身擅长的位置名称缩写列表
-- @return boolean
function PlayerTeamsModel.CheckPosIsMatch(pos, positionList)
    pos = tostring(pos)

    for i, positionName in ipairs(positionList) do
        local posList = FormationConstants.PositionToNumber[positionName]
        for j, pos2 in ipairs(posList) do
            if pos == pos2 then
                return true
            end
        end
    end

    return false
end

--- 球员是否在首发阵容中
-- @param pcId 球员卡牌Id
-- @return boolean
function PlayerTeamsModel:IsPlayerInInitTeam(pcId, teamId)
    if not teamId then
        teamId = self.nowTeamId
    end

    if self.nowTeamData and self.nowTeamData.initPcids then 
        return tobool(self.nowTeamData.initPcids[tostring(pcId)])
    else
        local initPlayersData = self:_GetInitPlayersData(teamId)
        for k, v in pairs(initPlayersData) do
            if tostring(pcId) == tostring(v) then
                return true
            end
        end
    end
    return false
end

--- 球员在首发阵容中的位置
-- @param pcId 球员卡牌Id
-- @return pos or false
function PlayerTeamsModel:GetPlayerInInitTeamPos(pcId, teamId)
    if not teamId then
        teamId = self.nowTeamId
    end

    pcId = tonumber(pcId)
    local initPlayersData = self:_GetInitPlayersData(teamId)

    for k, v in pairs(initPlayersData) do
        if pcId == v then
            return k
        end
    end

    return false
end

-- 根据pcid 获取当前球员所处首发阵型位置(服务器数据roleId)
function PlayerTeamsModel:GetStarterPlayerInTeamPos(pcId, teamId)
    if not teamId then
        teamId = self.nowTeamId
    end
    if self.nowTeamData and self.nowTeamData.initPcids then
        return self.nowTeamData.initPcids[tostring(pcId)]
    else
        local initPlayersData = self:_GetInitPlayersData(teamId)
        for pos, v in pairs(initPlayersData) do
            if tostring(pcId) == tostring(v) then
                return pos
            end
        end
    end
    return -1
end

function PlayerTeamsModel:IsExistCardIDInInitTeam(cid, teamId)
    if not teamId then
        teamId = self.nowTeamId
    end
    local initPlayersData = self:_GetInitPlayersData(teamId)

    for k, v in pairs(initPlayersData) do
        if v ~= 0 then
            local tmpCardModel = SimpleCardModel.new(v)
            if tostring(cid) == tostring(tmpCardModel:GetCid()) then
                return true
            end
        end
    end
    
    return false        
end

function PlayerTeamsModel:IsExistCardIDInReplaceTeam(cid, teamId)
    if not teamId then
        teamId = self.nowTeamId
    end
    local replacePlayersData = self:_GetReplacePlayersData(teamId)

    for k, v in pairs(replacePlayersData) do
        if v ~= 0 then
            local tmpCardModel = SimpleCardModel.new(v)
            if tostring(cid) == tostring(tmpCardModel:GetCid()) then
                return true
            end
        end
    end
    
    return false      
end

--- 球员是否在替补阵容中
-- @param pcId 球员卡牌Id
-- @return boolean
function PlayerTeamsModel:IsPlayerInReplaceTeam(pcId, teamId)
    if not teamId then
        teamId = self.nowTeamId
    end

    if self.nowTeamData and self.nowTeamData.repPcids then 
        return tobool(self.nowTeamData.repPcids[tostring(pcId)])
    else
        local replacePlayersData = self:_GetReplacePlayersData(teamId)

        for k, v in pairs(replacePlayersData) do
            if tostring(pcId) == tostring(v) then
                return true
            end
        end
    end

    return false
end

--- 更换阵型
-- @param formationId 阵型Id
-- @param initPlayersData 首发球员数据
-- @return newInitPlayersData 新首发球员数据
function PlayerTeamsModel:ChangeFormation(formationId, initPlayersData)
    local newFormationPosArray = clone(Formation[tostring(formationId)].posArray)
    local newInitPlayersData = {}

    -- 如果新阵型的posArray中包含球员的pos，则该球员位置不变
    local remainInitPlayersData = {}
    for oldPlayerPos, pcId in pairs(initPlayersData) do
        local hasPlayerNumPos = false
        local existNewFormationPosIndex = 0
        for newFormationPosIndex, newFormationPos in ipairs(newFormationPosArray) do
            if oldPlayerPos == newFormationPos then
                hasPlayerNumPos = true
                existNewFormationPosIndex = newFormationPosIndex
                break
            end
        end
        if hasPlayerNumPos then
            newInitPlayersData[oldPlayerPos] = pcId
            table.remove(newFormationPosArray, tonumber(existNewFormationPosIndex))
        else
            remainInitPlayersData[oldPlayerPos] = pcId
        end
    end

    -- 根据球员擅长位置在新阵型中布局球员的位置
    local oldInitPlayersData = clone(remainInitPlayersData)
    remainInitPlayersData = {}
    for oldPlayerPos, pcId in pairs(oldInitPlayersData) do
        if pcId ~= 0 then
            local cardModel = self:GetCardModelWithPcid(pcId)
            local playerPositionList = cardModel:GetPosition()
            local hasPlayerLetterPos = false
            local newPlayerPos = 0
            local existNewFormationPosIndex = 0
            for i, playerPositionName in ipairs(playerPositionList) do
                for newFormationPosIndex, newFormationPos in ipairs(newFormationPosArray) do
                    if playerPositionName == Num2LetterPos[newFormationPos] then
                        hasPlayerLetterPos = true
                        newPlayerPos = newFormationPos
                        existNewFormationPosIndex = newFormationPosIndex
                        break
                    end
                end
                if hasPlayerLetterPos then
                    break
                end
            end
            if hasPlayerLetterPos then
                newInitPlayersData[newPlayerPos] = pcId
                table.remove(newFormationPosArray, tonumber(existNewFormationPosIndex))
            else
                remainInitPlayersData[oldPlayerPos] = pcId
            end
        else
            remainInitPlayersData[oldPlayerPos] = pcId
        end
    end

    -- 安排剩余的位置
    for newFormationPosIndex, newFormationPos in ipairs(newFormationPosArray) do
        local removePos = 0
        for oldPlayerPos, pcId in pairs(remainInitPlayersData) do
            newInitPlayersData[newFormationPos] = pcId
            removePos = oldPlayerPos
            break
        end
        remainInitPlayersData[removePos] = nil
    end

    return newInitPlayersData
end

--- 获取新替换的替补球员的数据列表
-- @param nowTeamId 当前展示阵容Id
-- @param newReplacePlayersData 新的替补球员数据
-- @return table
function PlayerTeamsModel:GetNewReplacedPlayersList(nowTeamId, newReplacePlayersData)
    local newReplacedPlayersList = {}
    local oldReplacePlayersData = self:_GetReplacePlayersData(nowTeamId)
    for pos, pcId in pairs(newReplacePlayersData) do
        local isChange = true
        local newPcId = tonumber(pcId)
        for oldPos, oldPcId in pairs(oldReplacePlayersData) do
            if newPcId == oldPcId then
                isChange = false
                break
            end
        end
        if isChange then
            table.insert(newReplacedPlayersList, newPcId)
        end
    end
    return newReplacedPlayersList
end

--- 获取比赛中推荐阵容
-- @param nowFormationId 当前阵型Id
-- @param sortType 排序类型，参考FormationConstants.SortType
-- @return initPlayersData, replacePlayersData, waitPlayersNoRepeatList, waitPlayersRepeatList
function PlayerTeamsModel:GetMatchRecommendTeam(nowFormationId, substitutedPlayersData)
    -- 获取卡牌背包中的数据
    local allCardsData = {}
    local playerCardModelList = {}
    local initPlayersData = {}
    local replacePlayersData = {}
    local posArray = clone(Formation[tostring(nowFormationId)].posArray)
    local oldInitPlayersData = self:GetInitPlayersData()
    local oldReplacePlayersData = self:GetReplacePlayersData()
    table.sort(posArray, self.SortRecommendPositionOrder)

    for pos, pcId in pairs(oldInitPlayersData) do
        table.insert(allCardsData, pcId)
    end
    for pos, pcId in pairs(oldReplacePlayersData) do
        local newPcId = tonumber(pcId)
        if newPcId ~= 0 then
            local isChange = false
            for i, oldPcId in ipairs(substitutedPlayersData) do
                if newPcId == oldPcId then
                    isChange = true
                    break
                end
            end
            if not isChange then
                table.insert(allCardsData, newPcId)
            else
                replacePlayersData[pos] = newPcId
            end
        end
    end

    -- 构建卡牌模型列表
    for i, pcId in ipairs(allCardsData) do
        local model = self:GetCardModelWithPcid(pcId)
        model.posList = {}
        local positionList = model:GetPosition()

        for i, positionName in ipairs(positionList) do
            table.imerge(model.posList, FormationConstants.PositionToNumber[positionName])
        end

        table.insert(playerCardModelList, model)
    end

    table.sort(playerCardModelList, self.SortCardOrderByPower)

    -- 构建首发阵容，找到相应位置战力最高的球员
    for i, pos in ipairs(posArray) do
        for j, model in ipairs(playerCardModelList) do
            for k, posNum in ipairs(model.posList) do
                if pos == posNum then
                    initPlayersData[pos] = model:GetPcid()
                    break
                end
            end

            if initPlayersData[pos] ~= nil then
                table.remove(playerCardModelList, j)
                break
            end
        end

        if initPlayersData[pos] == nil then
            initPlayersData[pos] = 0
        end
    end

    -- 如果首发阵容的某些位置没有对应的球员，则非门将位置直接采用战力最高的球员，门将位置直接采用门将五维属性计算的战力最高的球员
    for i, pos in ipairs(posArray) do
        if initPlayersData[pos] == 0 then
            if tonumber(pos) == 26 then
                table.sort(playerCardModelList, self.SortCardOrderByGkPower)
            else
                table.sort(playerCardModelList, self.SortCardOrderByNotGkPower)
            end
            local model = playerCardModelList[1]
            if model ~= nil then
                initPlayersData[pos] = model:GetPcid()
                table.remove(playerCardModelList, 1)
            else
                break
            end
        end
    end

    -- 构建替补阵容
    table.sort(playerCardModelList, self.SortCardOrderByPower)
    for i, pos in ipairs(FormationConstants.ReplacePlayersPosArr) do
        if replacePlayersData[pos] == nil or replacePlayersData[pos] == 0 then
            local model = playerCardModelList[1]
            if model ~= nil then
                replacePlayersData[pos] = model:GetPcid()
                table.remove(playerCardModelList, 1)
            else
                replacePlayersData[pos] = 0
            end
        end
    end

    return initPlayersData, replacePlayersData
end

--- 获取玩家总战力
-- @return number
function PlayerTeamsModel:GetTotalPower()
    local totalPower = 0
    local initPlayersData = self:_GetInitPlayersData(self:GetNowTeamId())
    for pos, pcId in pairs(initPlayersData) do
        local playerCardModel = PlayerCardModel.new(pcId, self)
        local posIsMatch = PlayerTeamsModel.CheckPosIsMatch(pos, playerCardModel:GetPosition())
        local playerPower = playerCardModel:GetPower()
        if posIsMatch then
            totalPower = totalPower + math.floor(playerPower)
        else
            totalPower = totalPower + math.floor(math.floor(playerPower) * (1 - PlayerTeamsModel.POS_MISMATCH_DISCOUNT * 0.01))
        end
    end
    return totalPower
end

--- 设置当前阵容的战术数据
-- @param tactics 当前阵容战术数据
function PlayerTeamsModel:SetNowTeamTacticsData(tacticsData)
    self.nowTeamData.tactics = clone(tacticsData)
    self:SaveData()
end

--- 获取当前阵容的战术数据
function PlayerTeamsModel:GetNowTeamTacticsData()
    local tacticsData = {}
    tacticsData.sideTactic = {}
    tacticsData.sideGuardTactic = {}
    tacticsData.sideMidFieldTactic = {}

    local nowTactics = self.nowTeamData.tactics
    if not nowTactics then
        nowTactics = {}
        nowTactics.attackEmphasis = FormationConstants.TacticsDefault.ATTACKEMPHASIS
        nowTactics.attackMentality = FormationConstants.TacticsDefault.ATTACKMENTALITY
        nowTactics.defenseMentality = FormationConstants.TacticsDefault.DEFENSEMENTALITY
        nowTactics.passTactic = FormationConstants.TacticsDefault.PASSTACTIC
        nowTactics.attackRhythm = FormationConstants.TacticsDefault.ATTACKRHYTHM
        nowTactics.attackEmphasisDetail = FormationConstants.TacticsDefault.ATTACKEMPHASISDETAIL
    end
    if not nowTactics.sideTactic then 
        nowTactics.sideTactic = {}
        nowTactics.sideTactic.left = FormationConstants.TacticsDefault.SIDETACTICSLEFT
        nowTactics.sideTactic.right = FormationConstants.TacticsDefault.SIDETACTICSRIGHT
    end
    if not nowTactics.sideGuardTactic then 
        nowTactics.sideGuardTactic = {}
        nowTactics.sideGuardTactic.left = FormationConstants.TacticsDefault.SIDEGUARDTACTICSLEFT
        nowTactics.sideGuardTactic.right = FormationConstants.TacticsDefault.SIDEGUARDTACTICSRIGHT
    end
    if not nowTactics.sideMidFieldTactic then
        nowTactics.sideMidFieldTactic = {}
        nowTactics.sideMidFieldTactic.left = FormationConstants.TacticsDefault.SIDEMIDFIELDTACTICSLEFT
        nowTactics.sideMidFieldTactic.right = FormationConstants.TacticsDefault.SIDEMIDFIELDTACTICSRIGHT
    end

    tacticsData.attackEmphasis = nowTactics.attackEmphasis
    tacticsData.attackMentality = nowTactics.attackMentality
    tacticsData.defenseMentality = nowTactics.defenseMentality
    tacticsData.passTactic = nowTactics.passTactic
    tacticsData.attackRhythm = nowTactics.attackRhythm
    tacticsData.attackEmphasisDetail = nowTactics.attackEmphasisDetail
    tacticsData.sideTactic.left = nowTactics.sideTactic.left
    tacticsData.sideTactic.right = nowTactics.sideTactic.right
    tacticsData.sideGuardTactic.left = nowTactics.sideGuardTactic.left
    tacticsData.sideGuardTactic.right = nowTactics.sideGuardTactic.right
    tacticsData.sideMidFieldTactic.left = nowTactics.sideMidFieldTactic.left
    tacticsData.sideMidFieldTactic.right = nowTactics.sideMidFieldTactic.right
    self.nowTeamData.tactics = nowTactics
    return clone(tacticsData)
end

--- 判断战术是否已修改
function PlayerTeamsModel:CheckTacticsChanged(tacticsData)
    if not tacticsData.sideTactic then
        tacticsData.sideTactic = {}
    end
    if not tacticsData.sideGuardTactic then
        tacticsData.sideGuardTactic = {}
    end
    if not tacticsData.sideMidFieldTactic then
        tacticsData.sideMidFieldTactic = {}
    end
    local nowTactics = self.nowTeamData.tactics
    return nowTactics.attackEmphasis ~= tacticsData.attackEmphasis
        or nowTactics.attackMentality ~= tacticsData.attackMentality
        or nowTactics.defenseMentality ~= tacticsData.defenseMentality
        or nowTactics.passTactic ~= tacticsData.passTactic
        or nowTactics.attackRhythm ~= tacticsData.attackRhythm
        or nowTactics.attackEmphasisDetail ~= tacticsData.attackEmphasisDetail
        or nowTactics.sideTactic.left ~= tacticsData.sideTactic.left
        or nowTactics.sideTactic.right ~= tacticsData.sideTactic.right
        or nowTactics.sideGuardTactic.left ~= tacticsData.sideGuardTactic.left
        or nowTactics.sideGuardTactic.right ~= tacticsData.sideGuardTactic.right
        or nowTactics.sideMidFieldTactic.left ~= tacticsData.sideMidFieldTactic.left
        or nowTactics.sideMidFieldTactic.right ~= tacticsData.sideMidFieldTactic.right
end

--- 获取当前阵容ID
function PlayerTeamsModel:GetNowEditTeamId()
    return self.nowTeamId
end

--- 设置当前阵容的关键球员数据
-- @param keyPlayer 当前阵容关键球员数据
function PlayerTeamsModel:SetNowTeamKeyPlayersData(keyPlayersData)
    self.nowTeamData.captain = keyPlayersData.captain
    self.nowTeamData.freeKickShoot = keyPlayersData.freeKickShoot
    self.nowTeamData.freeKickPass = keyPlayersData.freeKickPass
    self.nowTeamData.spotKick = keyPlayersData.spotKick
    self.nowTeamData.corner = keyPlayersData.corner
    self:SaveData()
end

--- 获取当前阵容的关键球员数据
function PlayerTeamsModel:GetNowTeamKeyPlayersData()
    local keyPlayersData = {}
    if not self.nowTeamData.captain then
        self.nowTeamData.captain = 0
    end
    if not self.nowTeamData.freeKickShoot then
        self.nowTeamData.freeKickShoot = 0
    end
    if not self.nowTeamData.freeKickPass then
        self.nowTeamData.freeKickPass = 0
    end
    if not self.nowTeamData.spotKick then
        self.nowTeamData.spotKick = 0
    end
    if not self.nowTeamData.corner then
        self.nowTeamData.corner = 0
    end
    keyPlayersData.captain = self.nowTeamData.captain
    keyPlayersData.freeKickShoot = self.nowTeamData.freeKickShoot
    keyPlayersData.freeKickPass = self.nowTeamData.freeKickPass
    keyPlayersData.spotKick = self.nowTeamData.spotKick
    keyPlayersData.corner = self.nowTeamData.corner
    return clone(keyPlayersData)
end

local function GetFixKeyPlayerPcid(initData, selectPcid)
    local minRolePlayer = math.max_int32
    local fixPcid = 0
    for pos, pcid in pairs(initData) do
        if tonumber(selectPcid) == tonumber(pcid) then
            fixPcid = selectPcid
            break
        else
            if tonumber(pos) < minRolePlayer then
                minRolePlayer = tonumber(pos)
                fixPcid = tonumber(pcid)
            end
        end
    end
    return fixPcid
end

-- 关键球员在服务器数据错误的情况下更新为首发球员中位置最小的球员id
function PlayerTeamsModel:FixKeyPlayersData(keyPlayersData, initData)
    keyPlayersData = keyPlayersData or {}
    initData = initData or {}
    keyPlayersData.captain = GetFixKeyPlayerPcid(initData, keyPlayersData.captain)
    keyPlayersData.corner = GetFixKeyPlayerPcid(initData, keyPlayersData.corner)
    keyPlayersData.freeKickPass = GetFixKeyPlayerPcid(initData, keyPlayersData.freeKickPass)
    keyPlayersData.freeKickShoot = GetFixKeyPlayerPcid(initData, keyPlayersData.freeKickShoot)
    keyPlayersData.spotKick = GetFixKeyPlayerPcid(initData, keyPlayersData.spotKick)
    return keyPlayersData
end

--- 判断关键球员是否已修改
function PlayerTeamsModel:CheckKeyPlayersChanged(keyPlayersData)
    return self.nowTeamData.captain ~= keyPlayersData.captain
        or self.nowTeamData.freeKickShoot ~= keyPlayersData.freeKickShoot
        or self.nowTeamData.freeKickPass ~= keyPlayersData.freeKickPass
        or self.nowTeamData.spotKick ~= keyPlayersData.spotKick
        or self.nowTeamData.corner ~= keyPlayersData.corner
end

function PlayerTeamsModel:SetAllCardsData()
    -- 获取卡牌背包中的数据
    self.allCardsData = cache.getPlayerCardsMap()
end

-- 获取背包中数据
function PlayerTeamsModel:GetAllCardsData()
    self:SetAllCardsData()
    return self.allCardsData
end

--- 根据两个球员的Model获取战力，用于排序算法
function PlayerTeamsModel.GetTwoPlayersPower(playerCardModel1, playerCardModel2)
    local pcID1 = playerCardModel1:GetPcid()
    local pcID2 = playerCardModel2:GetPcid()
    local power1 = nil
    local power2 = nil

    if tempPowerData[pcID1] ~= nil then
        power1 = tempPowerData[pcID1]
    else
        power1 = playerCardModel1:GetPower()
        tempPowerData[pcID1] = power1
    end

    if tempPowerData[pcID2] ~= nil then
        power2 = tempPowerData[pcID2]
    else
        power2 = playerCardModel2:GetPower()
        tempPowerData[pcID2] = power2
    end

    return power1, power2
end

function PlayerTeamsModel:OnTeamsInfoChanged()
    EventSystem.SendEvent("TeamsInfo", self)
end

--三个阵容中首发所有的cid
function PlayerTeamsModel:GetTeamsCidList()
    local allTeamCardsCidData = {}
    allTeamCardsCidData.init = {}
    allTeamCardsCidData.rep = {}
    local cardMap = cache.getPlayerCardsMap()
    if not cache.getPlayerTeams().teams then return allTeamCardsCidData end
    for _,teamData in pairs(cache.getPlayerTeams().teams) do
        -- 暂时先看首发阵容
        if teamData.init and next(teamData.init) then
            for __, initPcid in pairs(teamData.init) do
                if cardMap[tostring(initPcid)] and cardMap[tostring(initPcid)].cid then
                    table.insert(allTeamCardsCidData.init, cardMap[tostring(initPcid)].cid)
                end
            end
        end
    end
    return allTeamCardsCidData
end

-- 阵型类型 FormationConstants.TeamType
function PlayerTeamsModel:SetTeamType(teamType)
    self.teamType = teamType
end

function PlayerTeamsModel:GetTeamType()
    return self.teamType or FormationConstants.TeamType.NORMAL
end

-- 阵型类型 FormationConstants.TeamType
function PlayerTeamsModel:SetCourtTeamType(courtTeamType)
    self.courtTeamType = courtTeamType
end

function PlayerTeamsModel:GetCourtTeamType()
	local teamType = self:GetTeamType()
    return self.courtTeamType or teamType
end

return PlayerTeamsModel

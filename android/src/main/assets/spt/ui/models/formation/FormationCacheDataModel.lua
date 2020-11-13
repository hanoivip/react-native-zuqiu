local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local LegendCardsMapModel = require("ui.models.legendRoad.LegendCardsMapModel")
local CardBuilder = require("ui.common.card.CardBuilder")

local FormationCacheDataModel = class()

function FormationCacheDataModel:ctor(playerTeamsModel)
    self.playerTeamsModel = playerTeamsModel
    self.initPlayerCacheDataWithKeyPlayers = {}
    self.keyPlayersCacheData = {}
    self.tacticsCacheData = {}
    self.initPlayerCacheData = {}
    self.replacePlayerCacheData = {}
    self.waitPlayerFilterPosData = {}
    self.formationId = 0
    self.currTeamId = 0
    self.formationDataChanged = false
    self.initPlayersChanged = false
    self.replacePlayersChanged = false
    self.formationIdChanged = false
    self.keyPlayersChanged = false
    self.tacticsChanged = false
    self.currTeamIdChanged = false
    self.sortType = FormationConstants.SortType.POWER
    self.cardShowType = FormationConstants.CardShowType.MAIN_INFO
    self.coupleState = FormationConstants.CoupleState.HIDE
    self.initPcids = {}
    self.repPcids = {}
    self.legendCardsMapModel = LegendCardsMapModel.new()
    self:InitCacheData()
end

-- 传奇之路根据阵型更新数据影响
function FormationCacheDataModel:BuildTeamLegendInfo()
    self.legendCardsMapModel:BuildTeamLegendInfo(self)
end

function FormationCacheDataModel:InitPlayerTeamsModel(playerTeamsModel)
    self.playerTeamsModel = playerTeamsModel
end

function FormationCacheDataModel:InitCacheData()
    self:SetInitPlayersCacheDataWithKeyPlayers()
    self:SetKeyPlayersCacheData()
    self:SetTacticsCacheData()
    self:SetInitPlayerCacheData()
    self:SetReplacePlayerCacheData()
    self:SetFormationIdCacheData()
    self:SetWaitPlayerFilterPosData()
    self:SetInitCurrTeamId()
end

function FormationCacheDataModel:SetFormationType(formationType)
    self.playerTeamsModel:SetFormationType(formationType)
end

function FormationCacheDataModel:GetFormationType()
    return self.playerTeamsModel:GetFormationType()
end

function FormationCacheDataModel:IsHomeCourt()
    return self.playerTeamsModel:IsHomeCourt()
end

-- 设置默认阵容ID
function FormationCacheDataModel:SetInitCurrTeamId(nowTeamId)
    self.currTeamIdChanged = false
    if nowTeamId then
        self.currTeamId = nowTeamId
        if self:CheckNowTeamIdChanged() then
            self.currTeamIdChanged = true
        end
    else
        self.currTeamId = self.playerTeamsModel:GetNowTeamId()
    end
    self:OnFormationDataChanged()
end

-- 获取默认阵容ID
function FormationCacheDataModel:GetInitCurrTeamId()
    return self.currTeamId
end

function FormationCacheDataModel:AllotTeamPcids(playerTeamData)
    local pcidsMap = {}
    for pos, pcid in pairs(playerTeamData) do
        if tonumber(pcid) ~= 0 then
            pcidsMap[tostring(pcid)] = pos
        end
    end
    return pcidsMap
end

-- 缓存首发球员数据
function FormationCacheDataModel:SetInitPlayerCacheData(initPlayersData)
    self.initPlayersChanged = false
    if initPlayersData then
        self.initPlayerCacheData = clone(initPlayersData)
        if self:CheckInitPlayersChanged() then
            self.initPlayersChanged = true
        end
    else
        self.initPlayerCacheData = self.playerTeamsModel:GetInitPlayersData(self.playerTeamsModel:GetNowEditTeamId())
    end
    self.initPcids = self:AllotTeamPcids(self.initPlayerCacheData)
    self:OnFormationDataChanged()
end

function FormationCacheDataModel:GetInitPlayerCacheData()
    return self.initPlayerCacheData
end

-- 缓存替补球员数据
function FormationCacheDataModel:SetReplacePlayerCacheData(replacePlayersData)
    self.replacePlayersChanged = false
    if replacePlayersData then
        self.replacePlayerCacheData = clone(replacePlayersData)
        if self:CheckReplacePlayersChanged() then
            self.replacePlayersChanged = true
        end
    else
        self.replacePlayerCacheData = self.playerTeamsModel:GetReplacePlayersData(self.playerTeamsModel:GetNowEditTeamId())
    end
    self.repPcids = self:AllotTeamPcids(self.replacePlayerCacheData)
    self:OnFormationDataChanged()
end

function FormationCacheDataModel:GetReplacePlayerCacheData()
    return self.replacePlayerCacheData
end

-- 获取候补球员数据，是经过筛选的数据
function FormationCacheDataModel:GetWaitPlayerCacheData(sortType)
    local waitPlayersNoRepeatList, waitPlayersRepeatList = self:GetWaitPlayersDataByOuterData(self.initPlayerCacheData, self.replacePlayerCacheData, sortType)
    if table.nums(self.waitPlayerFilterPosData) ~= 0 then
        local filterWaitPlayersNoRepeatList = {}
        local filterWaitPlayersRepeatList = {}
        for _, playerCardModel in ipairs(waitPlayersNoRepeatList) do
            local posList = playerCardModel:GetPosition()
            for _, posLetter in ipairs(posList) do
                if self:CheckWaitPlayerPosIsMatch(posLetter) then
                    table.insert(filterWaitPlayersNoRepeatList, playerCardModel)
                    break
                end
            end
        end

        for _, playerCardModel in ipairs(waitPlayersRepeatList) do
            local posList = playerCardModel:GetPosition()
            for _, posLetter in ipairs(posList) do
                if self:CheckWaitPlayerPosIsMatch(posLetter) then
                    table.insert(filterWaitPlayersRepeatList, playerCardModel)
                    break
                end
            end
        end
        return filterWaitPlayersNoRepeatList, filterWaitPlayersRepeatList
    else
        return waitPlayersNoRepeatList, waitPlayersRepeatList
    end
end


--- 获取候补球员数据
-- @param initPlayersData 首发球员数据
-- @param replacePlayersData 替补球员数据
-- @param sortType 排序类型，参考FormationConstants.SortType
-- @return waitPlayersNoRepeatList：不重复的候补球员列表，waitPlayersRepeatList：重复的候补球员列表，数据单元是PlayerCardModel
function FormationCacheDataModel:GetWaitPlayersDataByOuterData(initPlayersData, replacePlayersData, sortType)
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
    local allCardsData = self.playerTeamsModel:GetAllCardsData()

    for pos, pcId in pairs(initPlayersData) do
        if pcId ~= nil and pcId ~= 0 then
            
            local playerCardModel = SimpleCardModel.new(pcId)--self:GetCardModelWithPcid(pcId, self)
            if playerCardModel then
                playersInTeamList[pcId] = playerCardModel:GetCid()
            end
        end
    end

    for pos, pcId in pairs(replacePlayersData) do
        if pcId ~= nil and pcId ~= 0 then
            --local playerCardModel = self:GetCardModelWithPcid(pcId, self)
            local playerCardModel = SimpleCardModel.new(pcId)         
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
    for k, v in pairs(allCardsData) do
        local playerCIdInTeam = playersInTeamList[v.pcid]

        if playerCIdInTeam == nil then
            --local playerCardModel = self:GetCardModelWithPcid(v.pcid, self)
            local playerCardModel = CardBuilder.GetFormationCardModel(v.pcid, self)--self:GetCardModelWithPcid(pcId, self)

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
        table.sort(waitPlayersNoRepeatList, self.playerTeamsModel.SortCardOrderByPower)
        table.sort(waitPlayersRepeatList, self.playerTeamsModel.SortCardOrderByPower)
    elseif sortType == FormationConstants.SortType.QUALITY then
        table.sort(waitPlayersNoRepeatList, self.playerTeamsModel.SortCardOrderByQuality)
        table.sort(waitPlayersRepeatList, self.playerTeamsModel.SortCardOrderByQuality)
    elseif sortType == FormationConstants.SortType.GET_TIME then
        table.sort(waitPlayersNoRepeatList, self.playerTeamsModel.SortCardOrderByGetTime)
        table.sort(waitPlayersRepeatList, self.playerTeamsModel.SortCardOrderByGetTime)
    elseif sortType == FormationConstants.SortType.NAME then
        table.sort(waitPlayersNoRepeatList, self.playerTeamsModel.SortCardOrderByName)
        table.sort(waitPlayersRepeatList, self.playerTeamsModel.SortCardOrderByName)
    end

    tempPowerData = {}
    return waitPlayersNoRepeatList, waitPlayersRepeatList
end




-- 检查某一位置是否是筛选的位置
function FormationCacheDataModel:CheckWaitPlayerPosIsMatch(posLetter)
    for index, filterPosLetter in pairs(self.waitPlayerFilterPosData) do
        if filterPosLetter == posLetter then
            return true
        end
    end
    return false
end

-- 设置候补筛选位置数据
function FormationCacheDataModel:SetWaitPlayerFilterPosData(waitPlayerFilterPosData)
    if waitPlayerFilterPosData then
        self.waitPlayerFilterPosData = clone(waitPlayerFilterPosData)
    else
        self.waitPlayerFilterPosData = {}
    end
end

-- 获取候补筛选位置数据
function FormationCacheDataModel:GetWaitPlayerFilterPosData()
    return self.waitPlayerFilterPosData
end

-- 设置阵型Id缓存数据
function FormationCacheDataModel:SetFormationIdCacheData(formationId)
    self.formationIdChanged = false
    if formationId then
        self.formationId = formationId
        if self:CheckFormationIdChanged() then
            self.formationIdChanged = true
        end
    else
        self.formationId = self.playerTeamsModel:GetFormationId(self.playerTeamsModel:GetNowEditTeamId())
    end
    self:OnFormationDataChanged()
end

function FormationCacheDataModel:GetFormationIdCacheData()
    return self.formationId
end

-- 缓存每次设置关键球员时的首发球员缓存数据
function FormationCacheDataModel:SetInitPlayersCacheDataWithKeyPlayers(initPlayersData)
    if initPlayersData then
        self.initPlayerCacheDataWithKeyPlayers = clone(initPlayersData)
    else
        self.initPlayerCacheDataWithKeyPlayers = self.playerTeamsModel:GetInitPlayersData(self.playerTeamsModel:GetNowEditTeamId())
    end
end

function FormationCacheDataModel:GetInitPlayersCacheDataWithKeyPlayers()
    return self.initPlayerCacheDataWithKeyPlayers
end

-- 设置操作关键球员设置后的关键球员缓存数据
function FormationCacheDataModel:SetKeyPlayersCacheData(keyPlayersData)
    self.keyPlayersChanged = false
    if keyPlayersData then
        self.keyPlayersCacheData = clone(keyPlayersData)
        if self:CheckKeyPlayersChanged() then
            self.keyPlayersChanged = true
        end
    else
        self.keyPlayersCacheData = self.playerTeamsModel:GetNowTeamKeyPlayersData()
    end
    self:OnFormationDataChanged()
end

function FormationCacheDataModel:GetKeyPlayersCacheData()
    return clone(self.keyPlayersCacheData)
end

-- 设置操作战术设置后的关键球员缓存数据
function FormationCacheDataModel:SetTacticsCacheData(tacticsData)
    self.tacticsChanged = false
    if tacticsData then
        self.tacticsCacheData = clone(tacticsData)
        if self:CheckTacticsChanged() then
            self.tacticsChanged = true
        end
    else
        self.tacticsCacheData = self.playerTeamsModel:GetNowTeamTacticsData()
    end
    self:OnFormationDataChanged()
end

function FormationCacheDataModel:GetTacticsCacheData()
    return clone(self.tacticsCacheData)
end

-- 判断自从上次设置关键球员后首发球员是否发生变化
function FormationCacheDataModel:CheckInitPlayersChangedWithKeyPlayers(newInitPlayersData)
    local oldInitPlayersData = self:GetInitPlayersCacheDataWithKeyPlayers()

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

function FormationCacheDataModel:GetCardModelWithPcid(pcid)
    return PlayerCardModel.new(pcid, self)
end

-- 设置关键球员默认数据
function FormationCacheDataModel:SetKeyPlayersDefaultData()
    local maxCaptainAttrTable = {
        powerAttr = 0,
        pcid = 0,
        skillId = "F01",
        skillLevel = 0,
    }
    local maxFreeKickShootAttrTable = {
        normalAttr = 0,
        pcid = 0,
        skillId = "F02",
    }
    local maxFreeKickPassAttrTable = {
        normalAttr = 0,
        pcid = 0,
        skillId = "F02",
    }
    local maxSpotKickAttrTable = {
        normalAttr = 0,
        pcid = 0,
        skillId = "F03",
    }
    local maxCornerAttrTable = {
        normalAttr = 0,
        pcid = 0,
        skillId = "F04",
    }

    local isCaptainKeep, isFreeKickShootKeep, isFreeKickPassKeep, isSpotKickKeep, isCornerKeep  = false, false, false, false, false
    local keyPlayersCacheData = self:GetKeyPlayersCacheData()
    for pis, pcid in pairs(self.initPlayerCacheDataWithKeyPlayers) do
        if pcid == keyPlayersCacheData.captain then 
            maxCaptainAttrTable.pcid = pcid
            isCaptainKeep = true
        end
        if pcid == keyPlayersCacheData.freeKickShoot then 
            maxFreeKickShootAttrTable.pcid = pcid
            isFreeKickShootKeep = true
        end
        if pcid == keyPlayersCacheData.freeKickPass then 
            maxFreeKickPassAttrTable.pcid = pcid
            isFreeKickPassKeep = true
        end
        if pcid == keyPlayersCacheData.spotKick then 
            maxSpotKickAttrTable.pcid = pcid
            isSpotKickKeep = true
        end
        if pcid == keyPlayersCacheData.corner then 
            maxCornerAttrTable.pcid = pcid
            isCornerKeep = true
        end
    end

    local isCaptainSkillExisted, isCaptainSkillLevelSame = self:CheckCaptainSkillExisted()
    for pis, pcid in pairs(self.initPlayerCacheDataWithKeyPlayers) do
        if pcid ~= 0 then
            local cardModel = self:GetCardModelWithPcid(pcid)
            local baseNum, plusNum, trainNum, shootAttr, passAttr
            baseNum, plusNum, trainNum, shootAttr = cardModel:GetAbility("shoot")
            baseNum, plusNum, trainNum, passAttr = cardModel:GetAbility("pass")
            local isSkillExisted
            -- 直接任意球属性
            if not isFreeKickShootKeep then 
                isSkillExisted = self:CheckKeyPlayerSkillExisted(cardModel, maxFreeKickShootAttrTable.skillId)
                if isSkillExisted then
                    shootAttr = self:GetKeyPlayerMaxAttrWithSkill(cardModel)
                end
                if shootAttr > maxFreeKickShootAttrTable.normalAttr then
                    maxFreeKickShootAttrTable.normalAttr = shootAttr
                    maxFreeKickShootAttrTable.pcid = pcid
                end
            end

            -- 间接任意球属性
            if not isFreeKickPassKeep then 
                isSkillExisted = self:CheckKeyPlayerSkillExisted(cardModel, maxFreeKickPassAttrTable.skillId)
                if isSkillExisted then
                    passAttr = self:GetKeyPlayerMaxAttrWithSkill(cardModel)
                end
                if passAttr > maxFreeKickPassAttrTable.normalAttr then
                    maxFreeKickPassAttrTable.normalAttr = passAttr
                    maxFreeKickPassAttrTable.pcid = pcid
                end
            end

            -- 点球属性
            if not isSpotKickKeep then
                isSkillExisted = self:CheckKeyPlayerSkillExisted(cardModel, maxSpotKickAttrTable.skillId)
                if isSkillExisted then
                    shootAttr = self:GetKeyPlayerMaxAttrWithSkill(cardModel)
                end
                if shootAttr > maxSpotKickAttrTable.normalAttr then
                    maxSpotKickAttrTable.normalAttr = shootAttr
                    maxSpotKickAttrTable.pcid = pcid
                end
            end

            -- 角球属性
            if not isCornerKeep then 
                isSkillExisted = self:CheckKeyPlayerSkillExisted(cardModel, maxCornerAttrTable.skillId)
                if isSkillExisted then
                    passAttr = self:GetKeyPlayerMaxAttrWithSkill(cardModel)
                end
                if passAttr > maxCornerAttrTable.normalAttr then
                    maxCornerAttrTable.normalAttr = passAttr
                    maxCornerAttrTable.pcid = pcid
                end
            end

            -- 队长属性
            -- 队长技能存在时，选择技能等级最高的球员，如果等级相同，则选择战力最高的球员
            if not isCaptainKeep then 
                if isCaptainSkillExisted then
                    local skillItemModel = self:CheckKeyPlayerSkillExisted(cardModel, maxCaptainAttrTable.skillId)
                    if skillItemModel then
                        if isCaptainSkillLevelSame then
                            local powerAttr = cardModel:GetPower()
                            if powerAttr > maxCaptainAttrTable.powerAttr then
                                maxCaptainAttrTable.powerAttr = powerAttr
                                maxCaptainAttrTable.pcid = pcid
                            end
                        else
                            local cardSkillLevel = skillItemModel:GetLevel()
                            if cardSkillLevel > maxCaptainAttrTable.skillLevel then
                                maxCaptainAttrTable.skillLevel = cardSkillLevel
                                maxCaptainAttrTable.pcid = pcid
                            end
                        end
                    end
                -- 队长技能不存在时，则选择战力最高的球员
                else
                    local powerAttr = cardModel:GetPower()
                    if powerAttr > maxCaptainAttrTable.powerAttr then
                        maxCaptainAttrTable.powerAttr = powerAttr
                        maxCaptainAttrTable.pcid = pcid
                    end
                end
            end
        end
    end

    local keyPlayersData = {}
    if self:HasInitPlayers(self.initPlayerCacheDataWithKeyPlayers) then
        keyPlayersData.captain = maxCaptainAttrTable.pcid
        keyPlayersData.freeKickShoot = maxFreeKickShootAttrTable.pcid
        keyPlayersData.freeKickPass = maxFreeKickPassAttrTable.pcid
        keyPlayersData.spotKick = maxSpotKickAttrTable.pcid
        keyPlayersData.corner = maxCornerAttrTable.pcid
    else
        keyPlayersData.captain = 0
        keyPlayersData.freeKickShoot = 0
        keyPlayersData.freeKickPass = 0
        keyPlayersData.spotKick = 0
        keyPlayersData.corner = 0
    end
    self:SetKeyPlayersCacheData(keyPlayersData)
end

function FormationCacheDataModel:HasInitPlayers(playersData)
    for pos, pcid in pairs(playersData) do
        if pcid ~= 0 then
            return true
        end
    end
    return false
end

-- 当关键球员技能存在时，获得关键球员的五维属性中最大的属性
function FormationCacheDataModel:GetKeyPlayerMaxAttrWithSkill(playerCardModel)
    local baseNum, plusNum, trainNum
    local shootAttr, passAttr, dribbleAttr, interceptAttr, stealAttr
    baseNum, plusNum, trainNum, shootAttr = playerCardModel:GetAbility("shoot")
    baseNum, plusNum, trainNum, passAttr = playerCardModel:GetAbility("pass")
    baseNum, plusNum, trainNum, dribbleAttr = playerCardModel:GetAbility("dribble")
    baseNum, plusNum, trainNum, interceptAttr = playerCardModel:GetAbility("intercept")
    baseNum, plusNum, trainNum, stealAttr = playerCardModel:GetAbility("steal")
    return math.max(shootAttr, passAttr, dribbleAttr, interceptAttr, stealAttr)
end

-- 检查关键球员技能是否存在并且激活
function FormationCacheDataModel:CheckKeyPlayerSkillExisted(playerCardModel, skillId)
    local skillCount = playerCardModel:GetSkillAmount()
    for slot = 1, skillCount do
        local skillItemModel = playerCardModel:GetSkillItemModelBySlot(slot)
        if skillItemModel and skillItemModel:GetSkillID() == skillId and skillItemModel:IsOpen() then
            return skillItemModel
        end
    end
    return nil
end

-- 检查首发球员中是否有球员有队长技能,如果有是否等级相同
function FormationCacheDataModel:CheckCaptainSkillExisted()
    local isSkillExisted = false
    local isSkillLevelSame = true
    local skillLevel = 0
    for pis, pcid in pairs(self.initPlayerCacheDataWithKeyPlayers) do
        if pcid ~= 0 then
            local cardModel = self:GetCardModelWithPcid(pcid)
            local skillItemModel = self:CheckKeyPlayerSkillExisted(cardModel, "F01")
            if skillItemModel then
                isSkillExisted = true
                local cardSkillLevel = skillItemModel:GetLevel()
                if skillLevel == 0 then
                    skillLevel = cardSkillLevel
                end
                if cardSkillLevel ~= skillLevel then
                    isSkillLevelSame = false
                    break
                end
            end
        end
    end
    return isSkillExisted, isSkillLevelSame
end

-- 判断默认阵容是否已经修改
function FormationCacheDataModel:CheckNowTeamIdChanged() 
    if self.playerTeamsModel:GetNowTeamId() ~= tonumber(self.currTeamId) then
        return true
    end
    return false
end

-- 判断阵型Id是否已修改
function FormationCacheDataModel:CheckFormationIdChanged()
    if self.playerTeamsModel:CheckFormationIdChanged(self.playerTeamsModel:GetNowEditTeamId(), self.formationId) then
        return true
    end
    return false
end

-- 判断首发球员是否已修改
function FormationCacheDataModel:CheckInitPlayersChanged()
    if self.playerTeamsModel:CheckInitPlayersChanged(self.playerTeamsModel:GetNowEditTeamId(), self.initPlayerCacheData) then
        return true
    end
    return false
end

-- 判断替补球员是否已修改
function FormationCacheDataModel:CheckReplacePlayersChanged()
    if self.playerTeamsModel:CheckReplacePlayersChanged(self.playerTeamsModel:GetNowEditTeamId(), self.replacePlayerCacheData) then
        return true
    end
    return false
end

-- 判断关键球员是否已修改
function FormationCacheDataModel:CheckKeyPlayersChanged()
    if self.playerTeamsModel:CheckKeyPlayersChanged(self.keyPlayersCacheData) then
        return true
    end
    return false
end

-- 判断战术是否已修改
function FormationCacheDataModel:CheckTacticsChanged()
    if self.playerTeamsModel:CheckTacticsChanged(self.tacticsCacheData) then
        return true
    end
    return false
end

function FormationCacheDataModel:OnFormationDataChanged()
    self.formationDataChanged = self.initPlayersChanged or self.replacePlayersChanged or self.formationIdChanged or self.keyPlayersChanged or self.tacticsChanged or self.currTeamIdChanged
    EventSystem.SendEvent("FormationDataChange", self.formationDataChanged)
end

function FormationCacheDataModel:GetFormationDataChanged()
    return self.formationDataChanged
end

--- 球员是否在首发阵容中
-- @param pcId 球员卡牌Id
-- @return boolean
function FormationCacheDataModel:IsPlayerInInitTeam(pcId, teamId)
    pcId = tonumber(pcId)
    if next(self.initPcids) then
        return tobool(self.initPcids[tostring(pcId)])
    else
        local initPlayersData = self:GetInitPlayerCacheData()
        for k, v in pairs(initPlayersData) do
            if pcId == v then
                return true
            end
        end
    end
    return false
end

--- 球员在首发阵容中的位置
-- @param pcId 球员卡牌Id
-- @return pos or false
function FormationCacheDataModel:GetPlayerInInitTeamPos(pcId, teamId)
    pcId = tonumber(pcId)
    if next(self.initPcids) then
        return self.initPcids[tostring(pcId)]
    else
        local initPlayersData = self:GetInitPlayerCacheData()
        for k, v in pairs(initPlayersData) do
            if pcId == v then
                return k
            end
        end
    end
    return false
end

-- 根据pcid 获取当前球员所处首发阵型位置(服务器数据roleId)
function FormationCacheDataModel:GetStarterPlayerInTeamPos(pcId, teamId)
    pcId = tonumber(pcId)
    if next(self.initPcids) then
        return self.initPcids[tostring(pcId)]
    else
        local initPlayersData = self:GetInitPlayerCacheData()
        for pos, v in pairs(initPlayersData) do
            if pcId == v then
                return pos
            end
        end
    end
    return -1
end

function FormationCacheDataModel:IsExistCardIDInInitTeam(cid, teamId)
    local initPlayersData = self:GetInitPlayerCacheData()
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

function FormationCacheDataModel:IsExistCardIDInReplaceTeam(cid, teamId)
    local replacePlayersData = self:GetReplacePlayerCacheData()
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
function FormationCacheDataModel:IsPlayerInReplaceTeam(pcId, teamId)
    pcId = tonumber(pcId)
    if next(self.repPcids) then
        return tobool(self.repPcids[tostring(pcId)])
    else
        local replacePlayersData = self:GetReplacePlayerCacheData()
        for k, v in pairs(replacePlayersData) do
            if pcId == v then
                return true
            end
        end
    end
    return false
end

function FormationCacheDataModel:GetNowTeamId()
    return self.playerTeamsModel:GetNowEditTeamId()
end

function FormationCacheDataModel:GetSortType()
    return self.sortType
end

function FormationCacheDataModel:SetSortType(sortType)
    self.sortType = sortType
end

function FormationCacheDataModel:GetCardShowType()
    return self.cardShowType
end

function FormationCacheDataModel:SetCardShowType(cardShowType)
    self.cardShowType = cardShowType
end

function FormationCacheDataModel:SetCoupleState(coupleState)
    self.coupleState = coupleState
end

function FormationCacheDataModel:GetCoupleState()
    return self.coupleState
end

function FormationCacheDataModel:GetTeamType()
    return self.playerTeamsModel:GetTeamType()
end

function FormationCacheDataModel:GetFormationId()
    return self.formationId
end

function FormationCacheDataModel:GetNowTeamTacticsData()
    return clone(self.tacticsCacheData) or {}
end

function FormationCacheDataModel:GetCacheTeamId()
    return self.cacheTeamId
end

function FormationCacheDataModel:SetCacheTeamId(teamId)
    self.cacheTeamId = teamId
end

return FormationCacheDataModel

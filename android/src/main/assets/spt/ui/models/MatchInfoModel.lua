local UnityEngine = clr.UnityEngine
local Application = UnityEngine.Application
local MatchConstants = require("ui.scene.match.MatchConstants")
local Model = require("ui.models.Model")
local TeamTotal = require("data.TeamTotal")
local Card = require("data.Card")
local NPCCard = require("data.NPCCard")
local CardModel = require("data.CardModel")
local QuestPageViewModel = require("ui.models.quest.QuestPageViewModel")
local SpecificTeamData = require("cloth.SpecificTeamData")

local HomeShirt = require("data.HomeShirt")
local AwayShirt = require("data.AwayShirt")
local GKShirt = require("data.GKShirt")
local ShirtMask = require("data.ShirtMask")
local InitTeam = require("data.InitTeam")
local InitShirt = require("data.InitShirt")

local ClothUtils = require("cloth.ClothUtils")
local MatchUseShirtType = require("coregame.MatchUseShirtType")

local function isStringNilOrEmpty(str)
    if str == nil or (type(str) == "string" and string.len(str) == 0) then
        return true
    end
end

local MatchMainLaunch = false

local MatchInfoModel = class(Model, "MatchInfoModel")
local Instance = nil

--- 获取实例
function MatchInfoModel.GetInstance()  --Lua assist checked flag
    if Instance == nil then
        Instance = MatchInfoModel.new()
    end

    return Instance
end

--- 清除实例
function MatchInfoModel.ClearInstance()
    Instance = nil
end

function MatchInfoModel:ctor()
    -- 战斗数据
    self.data = nil
    -- 被替换下的球员数据
    self.substitutedPlayersData = nil
    -- 比赛队伍数据
    self.matchTeamData = nil
    MatchInfoModel.super.ctor(self)
end

function MatchInfoModel:Init(data)
    if not data and cache then
        data = cache.getMatchInfo()
    end

    if data ~= nil then
        self.data = data
    end

    -- 用于直接启动战斗场景的情况
    if self.data == nil and (Application.loadedLevelName == "match_main") then
        MatchMainLaunch = true
        Initializer = require("emulator.Initializer")
        self:InitWithProtocol(Initializer)
        self:SetConstShirtColor()

        -- test
        local opponentTeamData = self:GetOpponentTeamData()
        opponentTeamData.specificTeam = "Bayern"
        opponentTeamData.useShirtType = MatchUseShirtType.HOME
        self:SetSpecificTeamShirt(opponentTeamData, opponentTeamData.specificTeam)
        self:CheckShirt()
    end
end

function MatchInfoModel:SetSpecificTeamShirt(teamDataTable, specificTeam)
    local specificTeamData = SpecificTeamData[specificTeam]
    if specificTeamData then
        teamDataTable.logo = specificTeamData.logo
        teamDataTable.homeShirt = specificTeamData.homeShirt
        teamDataTable.awayShirt = specificTeamData.awayShirt
        teamDataTable.spectators = specificTeamData.spectators
        teamDataTable.nameNumType = specificTeamData.nameNumType
        teamDataTable.printingStyle = specificTeamData.printingStyle
    end
end

-- 没有使用服务端发挥的数据时调用给这个函数设置队服颜色
function MatchInfoModel:SetConstShirtColor()
    local playerTeamData = self:GetPlayerTeamData()
    local opponentTeamData = self:GetOpponentTeamData()

    if playerTeamData.logo == nil then
        playerTeamData.logo = "RealmadridPlayer"
    end
    if opponentTeamData.logo == nil then
        opponentTeamData.logo = "AcmilanPlayer"
    end

    if playerTeamData.homeShirt == nil then
        playerTeamData.homeShirt = {
            mask = "Mask_31",
            maskRedChannel = "0.067, 0.102, 0.169, 1.000",
            maskGreenChannel = "0.449, 0.013, 0.183, 1.000",
            maskBlueChannel = "0.067, 0.102, 0.169, 1.000",
            backNumColor = "1.000, 1.000, 1.000, 1.000",
            trouNumColor = "1.000, 1.000, 1.000, 1.000",
            chestAd = "emirateswhite",
        }
    end
    if playerTeamData.awayShirt == nil then
        playerTeamData.awayShirt = {
            mask = "1",
            maskRedChannel = "0.7,0.7,0.7,1",
            maskGreenChannel = "0.7,0.7,0.7,1",
            maskBlueChannel = "0.7,0.7,0.7,1",
            backNumColor = "0,0,0,1",
            trouNumColor = "0,0,0,1",
        }
    end
    if playerTeamData.homeGkShirt == nil then
        playerTeamData.homeGkShirt = {
            mask = "1",
            maskRedChannel = "0,0,0,1",
            maskGreenChannel = "0,0,0,1",
            maskBlueChannel = "0,0,0,1",
            backNumColor = "0.7,0.7,0.7,1",
            trouNumColor = "0.7,0.7,0.7,1",
            chestAd = "emirateswhite",
        }
    end

    if opponentTeamData.homeShirt == nil then
        opponentTeamData.homeShirt = {
            mask = "1",
            maskRedChannel = "0.596,0.092,0.165,0.000",
            maskGreenChannel = "0.162,0.201,0.596,0.000",
            maskBlueChannel = "0.592,0.090,0.165,0.000",
            backNumColor = "1.000, 1.000, 1.000, 1.000",
            trouNumColor = "1.000, 1.000, 1.000, 1.000",
        }
    end
    if opponentTeamData.awayShirt == nil then
        opponentTeamData.awayShirt = {
            mask = "1",
            maskRedChannel = "0,0,0,1",
            maskGreenChannel = "0,0,0,1",
            maskBlueChannel = "0,0,0,1",
            backNumColor = "0.7,0.7,0.7,1",
            trouNumColor = "0.7,0.7,0.7,1",
        }
    end
    if opponentTeamData.homeGkShirt == nil then
        opponentTeamData.homeGkShirt = {
            mask = "1",
            maskRedChannel = "0.7,0.7,0.7,1",
            maskGreenChannel = "0.7,0.7,0.7,1",
            maskBlueChannel = "0.7,0.7,0.7,1",
            backNumColor = "0,0,0,1",
            trouNumColor = "0,0,0,1",
        }
    end

    playerTeamData.currentUseShirt = playerTeamData.homeShirt
    playerTeamData.currentUseGKShirt = playerTeamData.homeGkShirt
    opponentTeamData.currentUseShirt = opponentTeamData.homeShirt
    opponentTeamData.currentUseGKShirt = opponentTeamData.homeGkShirt

    if playerTeamData.spectators == nil then
        playerTeamData.spectators = {
            firstColor = playerTeamData.currentUseShirt.maskRedChannel,
            secondColor = playerTeamData.currentUseShirt.maskGreenChannel,
            maskTex = "SpectatorsMask1"
        }
    end
    if opponentTeamData.spectators == nil then
        opponentTeamData.spectators = {
            firstColor = opponentTeamData.currentUseShirt.maskRedChannel,
            secondColor = opponentTeamData.currentUseShirt.maskGreenChannel,
            maskTex = "SpectatorsMask1"
        }
    end

    self:SaveData()
end

-- 计算color1和color2之间的颜色差异值
local function CalcColorDiffValue(color1, color2)
    local h1 = ClothUtils.getHsvFromRgb(color1)
    local h2 = ClothUtils.getHsvFromRgb(color2)
    local diff = math.abs(h1 - h2)
    if diff > 180 then
        diff = 360 - diff
    end
    return diff
end

local function IsCloseShirtColor(aShirt, aIsBigAssistColor, bShirt, bIsBigAssistColor)
    if aIsBigAssistColor and bIsBigAssistColor then
        -- 均为大辅色球衣
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(aShirt.maskRedChannel), ClothUtils.parseColorString(bShirt.maskRedChannel)) then
            return true
        end
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(aShirt.maskRedChannel), ClothUtils.parseColorString(bShirt.maskGreenChannel)) then
            return true
        end
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(aShirt.maskGreenChannel), ClothUtils.parseColorString(bShirt.maskRedChannel)) then
            return true
        end
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(aShirt.maskGreenChannel), ClothUtils.parseColorString(bShirt.maskGreenChannel)) then
            return true
        end

        return false
    elseif aIsBigAssistColor or bIsBigAssistColor then
        -- 只有一方为大辅色，另一方为小辅色
        local tmpBigAssistShirt
        local tmpAnotherShirt
        if aIsBigAssistColor then
            tmpBigAssistShirt = aShirt
            tmpAnotherShirt = bShirt
        else
            tmpBigAssistShirt = bShirt
            tmpAnotherShirt = aShirt
        end
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(tmpBigAssistShirt.maskRedChannel), ClothUtils.parseColorString(tmpAnotherShirt.maskRedChannel)) then
            return true
        end
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(tmpBigAssistShirt.maskGreenChannel), ClothUtils.parseColorString(tmpAnotherShirt.maskRedChannel)) then
            return true
        end

        return false
    elseif not aIsBigAssistColor and not bIsBigAssistColor then
        -- 均为小辅色
        if ClothUtils.isCloseColor(ClothUtils.parseColorString(aShirt.maskRedChannel), ClothUtils.parseColorString(bShirt.maskRedChannel)) then
            return true
        end

        return false
    end
end

-- 判断mask遮罩是否为大辅色
local function IsMaskBigAssistColor(mask)
    assert(type(mask) == "string")
    local maskTable = ShirtMask[mask]
    return maskTable and (tonumber(maskTable.assistColour) == 1) or false
end

function MatchInfoModel:CheckShirt()
    -- 默认情况下,两队都用主场队服
    -- 如果撞衫,那么客场球队应该换用客场队服
    local isPlayerHome = (self.data.baseInfo.home == 1)
    local oppHomeShirt
    local oppHomeGKShirt
    local oppAwayShirt
    local oppAwayGKShirt

    local playerTeamData = self:GetPlayerTeamData()
    local opponentTeamData = self:GetOpponentTeamData()

    local isOpponentRobot = false
    local robotHomeShirtID = nil
    if opponentTeamData.teamType == MatchConstants.TeamType.ROBOT and opponentTeamData.robotID then
        isOpponentRobot = true
        local initTeamData = InitTeam[opponentTeamData.robotID]
        opponentTeamData.logo = initTeamData.logo
        robotHomeShirtID = initTeamData.homeKit
        oppHomeShirt = InitShirt[initTeamData.homeKit]
        oppAwayShirt = InitShirt[initTeamData.awayKit]
    end

    local isOpponentNpc = false
    if not isOpponentRobot then
        if type(opponentTeamData.homeShirt) ~= "table" or next(opponentTeamData.homeShirt) == nil then
            oppHomeShirt = HomeShirt[opponentTeamData.homeShirt]
            isOpponentNpc = true
        else
            oppHomeShirt = opponentTeamData.homeShirt
        end
        if not oppHomeShirt then
            oppHomeShirt = AwayShirt["AwayWhite"]
        end
    end

    -- 主场门将（取与主场队服颜色最不接近的GKShirt）
    local maxDiffValue = 0
    for shirtID, shirtTable in pairs(GKShirt) do
        local diff = CalcColorDiffValue(ClothUtils.parseColorString(shirtTable.maskRedChannel), ClothUtils.parseColorString(oppHomeShirt.maskRedChannel))
        if maxDiffValue < diff then
            maxDiffValue = diff
            oppHomeGKShirt = shirtTable
        end
    end

    -- 客场队服（与主场队服最不接近的AwayShirt）
    if not isOpponentRobot then
        if isOpponentNpc then
            maxDiffValue = 0
            for shirtID, shirtTable in pairs(AwayShirt) do
                local diff = CalcColorDiffValue(ClothUtils.parseColorString(shirtTable.maskRedChannel), ClothUtils.parseColorString(oppHomeShirt.maskRedChannel))
                if maxDiffValue < diff then
                    maxDiffValue = diff
                    oppAwayShirt = shirtTable
                end
            end
        else
            oppAwayShirt = opponentTeamData.awayShirt
        end
    end

    -- 客场门将（与客场队服最不接近的GKShirt）
    maxDiffValue = 0
    for shirtID, shirtTable in pairs(GKShirt) do
        local diff = CalcColorDiffValue(ClothUtils.parseColorString(shirtTable.maskRedChannel), ClothUtils.parseColorString(oppAwayShirt.maskRedChannel))
        if maxDiffValue < diff then
            maxDiffValue = diff
            oppAwayGKShirt = shirtTable
        end
    end

    local playerShirt = playerTeamData.homeShirt
    local playerGKShirt = playerTeamData.homeGkShirt
    local opponentShirt = oppHomeShirt
    local opponentGKShirt = oppHomeGKShirt

    -- 最后确认一遍队服颜色
    repeat
        -- 球衣是否是大小辅色需要从表中读取
        local isPlayerShirtBigAssistColor = IsMaskBigAssistColor(playerShirt.mask)
        local isOpponentBigAssistColor = IsMaskBigAssistColor(opponentShirt.mask)
        local isCloseColorCloth = IsCloseShirtColor(playerShirt, isPlayerShirtBigAssistColor, opponentShirt, isOpponentBigAssistColor)
        if not isCloseColorCloth then
            dump("use default shirt")
            playerTeamData.useShirtType = MatchUseShirtType.HOME
            opponentTeamData.useShirtType = MatchUseShirtType.HOME
            break
        end

        -- 优先级A：主场球队不变，客场球队换为该球队客场球衣。
        if not isPlayerHome then
            playerShirt = playerTeamData.awayShirt
            playerGKShirt = playerTeamData.awayGkShirt
            opponentShirt = oppHomeShirt
            opponentGKShirt = oppHomeGKShirt
        else
            playerShirt = playerTeamData.homeShirt
            playerGKShirt = playerTeamData.homeGkShirt
            opponentShirt = oppAwayShirt
            opponentGKShirt = oppAwayGKShirt
        end
        isPlayerShirtBigAssistColor = IsMaskBigAssistColor(playerShirt.mask)
        isOpponentBigAssistColor = IsMaskBigAssistColor(opponentShirt.mask)
        isCloseColorCloth = IsCloseShirtColor(playerShirt, isPlayerShirtBigAssistColor, opponentShirt, isOpponentBigAssistColor)
        if not isCloseColorCloth then
            dump("优先级A")
            if isPlayerHome then
                playerTeamData.useShirtType = MatchUseShirtType.HOME
                opponentTeamData.useShirtType = MatchUseShirtType.AWAY
            else
                playerTeamData.useShirtType = MatchUseShirtType.AWAY
                opponentTeamData.useShirtType = MatchUseShirtType.HOME
            end
            break
        end
        -- 优先级B：主场球队换为该球队客场球衣，客场球队不变。
        if not isPlayerHome then
            playerShirt = playerTeamData.homeShirt
            playerGKShirt = playerTeamData.homeGkShirt
            opponentShirt = oppAwayShirt
            opponentGKShirt = oppAwayGKShirt
        else
            playerShirt = playerTeamData.awayShirt
            playerGKShirt = playerTeamData.awayGkShirt
            opponentShirt = oppHomeShirt
            opponentGKShirt = oppHomeGKShirt
        end
        isPlayerShirtBigAssistColor = IsMaskBigAssistColor(playerShirt.mask)
        isOpponentBigAssistColor = IsMaskBigAssistColor(opponentShirt.mask)
        isCloseColorCloth = IsCloseShirtColor(playerShirt, isPlayerShirtBigAssistColor, opponentShirt, isOpponentBigAssistColor)
        if not isCloseColorCloth then
            dump("优先级B")
            if isPlayerHome then
                playerTeamData.useShirtType = MatchUseShirtType.AWAY
                opponentTeamData.useShirtType = MatchUseShirtType.HOME
            else
                playerTeamData.useShirtType = MatchUseShirtType.HOME
                opponentTeamData.useShirtType = MatchUseShirtType.AWAY
            end
            break
        end
        -- 优先级C：主客场球队均换为该球队客场球衣
        playerShirt = playerTeamData.awayShirt
        playerGKShirt = playerTeamData.awayGkShirt
        opponentShirt = oppAwayShirt
        opponentGKShirt = oppAwayGKShirt
        isPlayerShirtBigAssistColor = IsMaskBigAssistColor(playerShirt.mask)
        isOpponentBigAssistColor = IsMaskBigAssistColor(opponentShirt.mask)
        isCloseColorCloth = IsCloseShirtColor(playerShirt, isPlayerShirtBigAssistColor, opponentShirt, isOpponentBigAssistColor)
        if not isCloseColorCloth then
            dump("优先级C")
            playerTeamData.useShirtType = MatchUseShirtType.AWAY
            opponentTeamData.useShirtType = MatchUseShirtType.AWAY
            break
        end
        -- 优先级D：主场球队直接读取白色预设客场球衣，客场球队直接读取蓝色预设客场球衣，此为最终方案，可保证必不撞色。
        if isPlayerHome then
            playerShirt = AwayShirt["AwayWhite"]
            playerGKShirt = GKShirt["menjiang1"]
            opponentShirt = AwayShirt["AwayBlue"]
            opponentGKShirt = GKShirt["menjiang2"]
        else
            playerShirt = AwayShirt["AwayBlue"]
            playerGKShirt = GKShirt["menjiang2"]
            opponentShirt = AwayShirt["AwayWhite"]
            opponentGKShirt = GKShirt["menjiang1"]
        end
        dump("优先级D")
        playerTeamData.useShirtType = MatchUseShirtType.BACKUP
        opponentTeamData.useShirtType = MatchUseShirtType.BACKUP
        break
    until(true)

    -- 处理门将队服配色与对方球员队服撞色的情况
    -- 门将撞色的判断默认使用大辅色模式判断，否则会出现无解的情况
    -- 如果己方的门将与对方球员颜色撞色，就使用一个与己方球员和对方球员颜色都不相同的GKShirt
    if IsCloseShirtColor(playerGKShirt, false, opponentShirt, false) then
        dump("playerGKShirt isCloseColorCloth to opponentShirt")
        for shirtID, tmpGKShirt in pairs(GKShirt) do
            local isCloseToHomeGkShirt = IsCloseShirtColor(tmpGKShirt, false, playerShirt, false)
            local isCloseToAwayGKShirt = IsCloseShirtColor(tmpGKShirt, false, opponentShirt, false)
            if not isCloseToHomeGkShirt and not isCloseToAwayGKShirt then
                playerGKShirt = tmpGKShirt
                break
            end
        end
    end
    -- 如果对方门将与己方球员颜色撞色，就使用一个与己方球员、对方球员、己方门将都不相同的GKShirt
    if IsCloseShirtColor(opponentGKShirt, false, playerShirt, false) then
        dump("opponentGKShirt isCloseColorCloth to playerShirt")
        for shirtID, tmpGKShirt in pairs(GKShirt) do
            local isCloseToHomeGkShirt = IsCloseShirtColor(tmpGKShirt, false, playerShirt, false)
            local isCloseToAwayGKShirt = IsCloseShirtColor(tmpGKShirt, false, opponentShirt, false)
            local isCloseToPlayerGKShirt = IsCloseShirtColor(tmpGKShirt, false, playerGKShirt, false)
            if not isCloseToHomeGkShirt and not isCloseToAwayGKShirt and not isCloseToPlayerGKShirt then
                opponentGKShirt = tmpGKShirt
                break
            end
        end
    -- 不与己方球员撞色，而是和己方门将撞色
    elseif IsCloseShirtColor(opponentGKShirt, false, playerGKShirt, false) then
        dump("opponentGKShirt isCloseColorCloth to playerGKShirt")
        for shirtID, tmpGKShirt in pairs(GKShirt) do
            local isCloseToHomeGkShirt = IsCloseShirtColor(tmpGKShirt, false, playerShirt, false)
            local isCloseToAwayGKShirt = IsCloseShirtColor(tmpGKShirt, false, opponentShirt, false)
            local isCloseToPlayerGKShirt = IsCloseShirtColor(tmpGKShirt, false, playerGKShirt, false)
            if not isCloseToHomeGkShirt and not isCloseToAwayGKShirt and not isCloseToPlayerGKShirt then
                opponentGKShirt = tmpGKShirt
                break
            end
        end
    end

    playerTeamData.currentUseShirt = playerShirt
    playerTeamData.currentUseGKShirt = playerGKShirt
    opponentTeamData.currentUseShirt = opponentShirt
    opponentTeamData.currentUseGKShirt = opponentGKShirt

    -- 处理一下老账号没有观众席配色的情况
    if type(playerTeamData.spectators) ~= "table" or next(playerTeamData.spectators) == nil then
        playerTeamData.spectators = {
            firstColor = playerTeamData.homeShirt.maskRedChannel,
            secondColor = playerTeamData.homeShirt.maskGreenChannel,
            maskTex = "SpectatorsMask1",
        }
    end

    if isOpponentNpc then
        local tmpShirtTable = oppHomeShirt
        opponentTeamData.spectators = {
            firstColor = tmpShirtTable.FirstColor,
            secondColor = tmpShirtTable.SecondColor,
            maskTex = tmpShirtTable.maskTex,
        }
    end
    if isOpponentRobot then
        local tmpShirtTable = InitShirt[robotHomeShirtID]
        opponentTeamData.spectators = {
            firstColor = tmpShirtTable.FirstColor,
            secondColor = tmpShirtTable.SecondColor,
            maskTex = tmpShirtTable.maskTex,
        }
    end
    if type(opponentTeamData.spectators) ~= "table" or next(opponentTeamData.spectators) == nil then
        opponentTeamData.spectators = {
            firstColor = oppHomeShirt.maskRedChannel,
            secondColor = oppHomeShirt.maskGreenChannel,
            maskTex = "SpectatorsMask1",
        }
    end
end

function MatchInfoModel:InitWithProtocol(data)
    self:Init(data)
    local playerTeamData = self:GetPlayerTeamData()
    local opponentTeamData = self:GetOpponentTeamData()
    local startId = 1
    self:_InitTeamData(playerTeamData)
    self:_InitTeamData(opponentTeamData)
    startId = self:_InitAthletesData(playerTeamData, startId, 1)
    startId = self:_InitAthletesData(opponentTeamData, startId, MatchConstants.PlayersNumOnField + 1)
    playerTeamData.role = 'Attack'
    playerTeamData.field = 'north'
    opponentTeamData.role = 'Defend'
    opponentTeamData.field = 'south'

    -- test
    -- playerTeamData.specificTeam = "Bayern"

    if type(playerTeamData.specificTeam) == "string" then
        self:SetSpecificTeamShirt(playerTeamData, playerTeamData.specificTeam)
    end
    if type(opponentTeamData.specificTeam) == "string" then
        self:SetSpecificTeamShirt(opponentTeamData, opponentTeamData.specificTeam)
    end

    if self.isDemoMatch == true then
        self:SetConstShirtColor()
    end

    if not MatchMainLaunch and self.isDemoMatch ~= true then
        self:CheckShirt()
    end

    self:SaveData()
end

--- 保存数据
-- @param data 战斗数据
function MatchInfoModel:SaveData(data)
    if cache == nil then
        return
    end

    if type(data) == 'table' then
        cache.setMatchInfo(data)
    else
        cache.setMatchInfo(self.data)
    end
end

--- 获取战斗数据
-- @return table
function MatchInfoModel:GetData()
    return self.data
end

--- 获取己方队伍数据
-- @return table
function MatchInfoModel:GetPlayerTeamData()
    return self.data.player
end

--- 获取对方队伍数据
-- @return table
function MatchInfoModel:GetOpponentTeamData()
    return self.data.opponent
end

--- 获取基础信息
-- @return table
function MatchInfoModel:GetBaseInfo()
    return self.data.baseInfo
end

--- 获取比赛类型
function MatchInfoModel:GetMatchType()
    local baseInfo = self.data.baseInfo
    return baseInfo.matchType
end

-- 比赛是否使用了天气和草皮科技
function MatchInfoModel:IsUseWeatherGrassTech()
    return self:GetMatchType() ~= MatchConstants.MatchType.QUEST
end

--- 获取比赛结果(比赛录像)
function MatchInfoModel:GetResult()
    return self.data.result
end

--- 设置是否跳过比赛
function MatchInfoModel:SetIsSkipMatch(isSkipMatch)
    self.data.isSkipMatch = isSkipMatch
end

--- 是否跳过比赛
function MatchInfoModel:IsSkipMatch()
    return self.data.isSkipMatch or false
end

--- 设置是否放弃比赛
function MatchInfoModel:SetIsGiveUpMatch(isGiveUpMatch)
    self.data.isGiveUpMatch = isGiveUpMatch
end

--- 是否放弃比赛
function MatchInfoModel:IsGiveUpMatch()
    return self.data.isGiveUpMatch or false
end

--- 设置是否自动操作
function MatchInfoModel:SetIsAuto(isAuto)
    self.data.isAuto = isAuto
end

--- 是否自动操作
function MatchInfoModel:IsAuto()
    return self.data.isAuto or false
end

--- 是否录像回放
function MatchInfoModel:IsReplay()
    return self.data.baseInfo.isReplay
end

-- 比赛是否需要消耗扫荡券
function MatchInfoModel:IsCostSweepCupon()
    return not self:IsFriendMatch()
        and not self:IsReplay()
end

-- 是否禁用换人功能
function MatchInfoModel:IsChangeAthleteDisabled()
    return self:GetMatchType() == "worldTournament" or self:GetMatchType() == "serverWorldTournament" or self:GetMatchType() == "penaltyWorldTournament"
end

--- 根据队伍数据获取阵型信息
-- @param teamData 队伍数据
-- @return table
function MatchInfoModel:_GetFormationInfo(teamData)
    local formationInfo = {
        formation = teamData.formation,
        athletes = {},
        captain = teamData.captain,
        cornerKicker = teamData.cornerKicker,
        freeKickPasser = teamData.freeKickPasser,
        freeKickShooter = teamData.freeKickShooter,
        penaltyKicker = teamData.penaltyKicker,
    }

    for i, athleteData in ipairs(teamData.athletes) do
        local newAthleteData = {
            name = athleteData.name,
            number = athleteData.number,
            role = athleteData.role,
        }
        table.insert(formationInfo.athletes, newAthleteData)
    end

    return formationInfo
end

--- 获取玩家阵型信息
-- @return table
function MatchInfoModel:GetPlayerFormationInfo()
    return self:_GetFormationInfo(self:GetPlayerTeamData())
end

--- 获取对手阵型信息
-- @return table
function MatchInfoModel:GetOpponentFormationInfo()
    return self:_GetFormationInfo(self:GetOpponentTeamData())
end

--- 比赛换人后更新玩家队伍信息
-- @param nowFormationId 当前阵型Id
-- @param oldInitPlayersData 旧的首发球员数据
-- @param newInitPlayersData 首发球员数据
-- @param oldReplacePlayersData 旧的替补球员数据
-- @param newReplacePlayersData 替补球员数据
function MatchInfoModel:UpdatePlayerTeamDataAfterSubstitution(nowFormationId, oldInitPlayersData, newInitPlayersData, oldReplacePlayersData, newReplacePlayersData)
    local playerTeamData = self:GetPlayerTeamData()
    playerTeamData.formation = nowFormationId
    local newPlayersData = {}
    for pos, pcId in pairs(newInitPlayersData) do
        newPlayersData[pcId] = pos
    end
    for pos, pcId in pairs(newReplacePlayersData) do
        newPlayersData[pcId] = pos
    end
    local oldPlayersData = {}
    table.merge(oldPlayersData, oldInitPlayersData)
    table.merge(oldPlayersData, oldReplacePlayersData)

    for i, athleteData in ipairs(playerTeamData.athletes) do
        local pcId = oldPlayersData[tostring(athleteData.role)]
        athleteData.role = tonumber(newPlayersData[tonumber(pcId)])
    end

    self:UpdatePlayerOnFieldIdsAfterSubstitution(playerTeamData.athletes)
end

function MatchInfoModel:UpdatePlayerOnFieldIdsAfterSubstitution(playerAthletes)
    for i, v in ipairs(playerAthletes) do
        if v.role == 26 then
            local upAthlete = playerAthletes[i]
            for idx, downAthlete in ipairs(playerAthletes) do
                if downAthlete.role == 26 and upAthlete ~= downAthlete then
                    upAthlete.onfieldId = downAthlete.onfieldId
                    downAthlete.onfieldIdDuplicated = true
                    break
                end
            end
            break
        end
    end

    for i, v in ipairs(playerAthletes) do
        local upAthlete = playerAthletes[i]
        if 1 <= v.role and v.role <= 26 and not upAthlete.onfieldId then
            for idx, downAthlete in ipairs(playerAthletes) do
                if downAthlete.onfieldId and not downAthlete.onfieldIdDuplicated and (1 > playerAthletes[idx].role or playerAthletes[idx].role > 26) then
                    upAthlete.onfieldId = downAthlete.onfieldId
                    downAthlete.onfieldIdDuplicated = true
                    break
                end
            end
        end
    end
end

-- 关键球员数据更新
function MatchInfoModel:UpdatePlayerKeyPlayersData(keyPlayersData)
    local playerTeamData = self:GetPlayerTeamData()
    playerTeamData.captain = keyPlayersData.captain
    playerTeamData.cornerKicker = keyPlayersData.cornerKicker
    playerTeamData.freeKickPasser = keyPlayersData.freeKickPasser
    playerTeamData.freeKickShooter = keyPlayersData.freeKickShooter
    playerTeamData.penaltyKicker = keyPlayersData.penaltyKicker
end

--- 获取队伍的展示名称
-- @param teamData 队伍数据
-- @return string
function MatchInfoModel:_GetTeamDisplayName(teamData)
    local teamName = nil
    if teamData.name == nil or string.len(teamData.name) == 0 then
        teamName = teamData.teamName
    else
        teamName = teamData.teamName .. " - " .. teamData.name
    end
    return teamName
end

--- 获取队伍的展示名称
-- @return string
function MatchInfoModel:GetPlayerTeamDisplayName()
    return self:_GetTeamDisplayName(self:GetPlayerTeamData())
end

--- 获取队伍的展示名称
-- @return string
function MatchInfoModel:GetOpponentTeamDisplayName()
    return self:_GetTeamDisplayName(self:GetOpponentTeamData())
end

--- 获取首发阵容数据
-- @return table
function MatchInfoModel:_GetInitTeamData(teamData)
    local initTeamData = {}
    for i, athleteData in ipairs(teamData.athletes) do
        if athleteData.role >= MatchConstants.SpecificPosNum.MIN_POS and athleteData.role <= MatchConstants.SpecificPosNum.GOALKEEPER_POS then
            table.insert(initTeamData, athleteData)
        end
    end
    table.sort(initTeamData, function (a, b)
        return tonumber(a.role) < tonumber(b.role)
    end)
    return initTeamData
end

--- 获取玩家首发阵容
-- @return table
function MatchInfoModel:GetPlayerInitTeamData()
    return self:_GetInitTeamData(self:GetPlayerTeamData())
end

--- 获取对手首发阵容
-- @return table
function MatchInfoModel:GetOpponentInitTeamData()
    return self:_GetInitTeamData(self:GetOpponentTeamData())
end

--- 获取所有球员的音频数据
-- @return table
function MatchInfoModel:GetPlayerNameAudios()
    local playerTeamData = self:GetPlayerTeamData()
    local opponentTeamData = self:GetOpponentTeamData()
    local playerAudioMap = self:_GetTeamPlayerNameAudios(playerTeamData, true)
    local opponentAudioMap = self:_GetTeamPlayerNameAudios(opponentTeamData, false)
    table.merge(playerAudioMap.normal, opponentAudioMap.normal)
    table.merge(playerAudioMap.passion, opponentAudioMap.passion)
    return playerAudioMap
end

--- 获取球员音频数据
-- @param teamData 队伍数据
-- @return table
function MatchInfoModel:_GetTeamPlayerNameAudios(teamData, isPlayerTeam)
    local audioMap = {
        normal = {},
        passion = {},
    }
    for i, athleteData in ipairs(teamData.athletes) do
        local cardData = Card[tostring(athleteData.cid)]
        if cardData then
            audioMap.normal[athleteData.id] = cardData.commentNormal
            audioMap.passion[athleteData.id] = cardData.commentPassion
        else
            if isPlayerTeam then
                math.randomseed(tostring(os.time()):reverse():sub(1, 7))
                local audioTable = {"13_001", "13_003"}
                audioMap.normal[athleteData.id] = audioTable[math.random(#audioTable)]
            end
            audioMap.passion[athleteData.id] = ""
        end
    end
    return audioMap
end

--- 获取球队名和球场音频数据
-- @return table
function MatchInfoModel:GetTeamNameAndCourtAudios()
    local teamAudioMap = {}
    local playerTeamData = self:GetPlayerTeamData()
    local opponentTeamData = self:GetOpponentTeamData()
    local playerTeamStatic = TeamTotal[tostring(playerTeamData.tid)]
    local opponentTeamStatic = TeamTotal[tostring(opponentTeamData.tid)]
    -- TODO: 等TeamTotal表中添加音频文件项，改为从表中读取
    -- teamAudioMap.homeTeam = playerTeamStatic.teamAudio
    -- teamAudioMap.homeCourt = playerTeamStatic.courtAudio
    -- teamAudioMap.awayTeam = opponentTeamStatic.teamAudio
    -- teamAudioMap.awayCourt = opponentTeamStatic.courtAudio
    teamAudioMap.homeTeam = "homeTeam"
    teamAudioMap.homeCourt = "courtName"
    teamAudioMap.awayTeam = "awayTeam"
    teamAudioMap.awayCourt = "courtName"
    return teamAudioMap
end

--- 更新战术数据
-- @param teamData 队伍数据
-- @param newTacticsData 新的战术数据
function MatchInfoModel:_UpdateTacticsData(teamData, newTacticsData)
    for k, v in pairs(newTacticsData) do
        if teamData.tactics[k] ~= nil then
            teamData.tactics[k] = v
        end
    end
    self:SaveData()
end

--- 更新己方队伍战术数据
-- @param newTacticsData 新的战术数据
function MatchInfoModel:UpdatePlayerTacticsData(newTacticsData)
    self:_UpdateTacticsData(self:GetPlayerTeamData(), newTacticsData)
end

--- 更新对方队伍战术数据
-- @param newTacticsData 新的战术数据
function MatchInfoModel:UpdateOpponentTacticsData(newTacticsData)
    self:_UpdateTacticsData(self:GetOpponentTeamData(), newTacticsData)
end

--- 更新统计数据
function MatchInfoModel:_UpdateStatisticsData(teamData, newTeamData)
    teamData.stats = newTeamData.stats
end

--- 更新己方队伍统计数据
function MatchInfoModel:UpdatePlayerStatisticsData(newTeamData)
    self:_UpdateStatisticsData(self:GetPlayerTeamData(), newTeamData)
end

--- 更新对方队伍战术数据
function MatchInfoModel:UpdateOpponentStatisticsData(newTeamData)
    self:_UpdateStatisticsData(self:GetOpponentTeamData(), newTeamData)
end

--- 添加操作数据
function MatchInfoModel:AddOperationData(operationData)
    self.data.ops = operationData
end

--- 获取被替换下的球员数据
-- @param table
function MatchInfoModel:GetSubstitutedPlayersData()
    if not self.substitutedPlayersData then
        self.substitutedPlayersData = {}
    end
    return self.substitutedPlayersData
end

--- 设置被替换下的球员数据
function MatchInfoModel:SetSubstitutedPlayersData(substitutingPlayersData)
    table.imerge(self.substitutedPlayersData, substitutingPlayersData)
end

--- 是否是被替换下的球员
-- @param pcId 球员Id
-- @return boolean
function MatchInfoModel:IsSubstitutedPlayer(pcId)
    if self.substitutedPlayersData == nil then
        return false
    end
    pcId = tonumber(pcId)
    for i, v in ipairs(self.substitutedPlayersData) do
        if tonumber(v) == pcId then
            return true
        end
    end
    return false
end

--- 获取比赛用阵容数据
-- @param table
function MatchInfoModel:GetMatchTeamData()
    if self.matchTeamData == nil then
        self.matchTeamData = cache.getPlayerTeams()
    end
    return self.matchTeamData
end

--- 设置比赛用阵容数据
function MatchInfoModel:SetMatchTeamData(data)
    self.matchTeamData = data
end

-- 转换成阵型所需格式
function MatchInfoModel:ConvertMatchTeamData(data)
	if data then 
		local convertData = {}
		local teamData = {}
		local playerData = data.player or {}
		teamData.captain = playerData.captain
		teamData.corner = playerData.corner
		teamData.formationID = playerData.formation
		teamData.freeKickPass = playerData.freeKickPass
		teamData.freeKickShoot = playerData.freeKickShoot 
		teamData.spotKick = playerData.spotKick
		teamData.tactics = playerData.tactics
		teamData.ptid = playerData.tid
		teamData.tid = 0 -- 为了符合格式

		local athletes = playerData.athletes
		local init = {}
		local rep = {}
		for i, v in ipairs(athletes) do
			local role = tonumber(v.role)
			local pcid = v.pcid
			if role <= 26 then -- 26以上是替补
				init[tostring(role)] = pcid
			else
				rep[tostring(role)] = pcid
			end
		end
		teamData.init = init
		teamData.rep = rep
		convertData.teams = {}
		convertData.teams[1] = teamData
		convertData.currTid = teamData.tid
		
		self.matchTeamData = convertData
	end
end

--- 初始化队伍数据
-- @param teamData 队伍数据
function MatchInfoModel:_InitTeamData(teamData)
    if teamData.tactics == nil then
        teamData.tactics = {
            attackEmphasis = 3,
            attackMentality = 3,
            defenseMentality = 3,
            passTactic = 3,
            attackRhythm = 3,
        }
    end

    teamData.cornerKicker = teamData.corner
    teamData.freeKickPasser = teamData.freeKickPass
    teamData.freeKickShooter = teamData.freeKickShoot
    teamData.penaltyKicker = teamData.spotKick

    local teamStatic = teamData.teamStatic

    if teamStatic == nil then
        teamStatic = TeamTotal[tostring(teamData.tid)]
    end
end

--- 初始化球员数据
-- @param teamData 队伍数据
-- @param startId 球员起始id
-- @param startOnfieldId 球员在球场上的起始id
-- @return number
function MatchInfoModel:_InitAthletesData(teamData, startId, startOnfieldId)
    teamData.startId = startId
    local athletesData = teamData.athletes

    -- 用于直接启动比赛场景的情况
    local defaultCid = nil
    if teamData.role == "Attack" then
        defaultCid = "Cronaldo7"
        teamData.teamType = teamData.teamType or MatchConstants.TeamType.PLAYER
        if teamData.tid == nil then
            teamData.tid = "Self"
        end
    elseif teamData.role == "Defend" then
        defaultCid = "Rioave01"
        teamData.teamType = teamData.teamType or MatchConstants.TeamType.NPC
        if teamData.tid == nil then
            teamData.tid = "Rioave"
        end
    end

    local memberTable = nil
    if self.isDemoMatch then
        memberTable = NPCCard
    else
        if teamData.teamType == MatchConstants.TeamType.PLAYER then
            memberTable = Card
        elseif teamData.teamType == MatchConstants.TeamType.NPC then
            memberTable = NPCCard
        elseif teamData.teamType ==  MatchConstants.TeamType.ROBOT then
            memberTable = Card
        end
    end

    local onfieldId = startOnfieldId

    for i, athlete in ipairs(athletesData) do
        athlete.id = startId
        startId = startId + 1

        local pos = tonumber(athlete.role)
        if pos >= MatchConstants.SpecificPosNum.MIN_POS and pos <= MatchConstants.SpecificPosNum.MAX_POS_EXCEPT_GOALKEEPER then
            onfieldId = onfieldId + 1
            athlete.onfieldId = onfieldId
        elseif pos == MatchConstants.SpecificPosNum.GOALKEEPER_POS then
            athlete.onfieldId = startOnfieldId
        end

        -- 用于直接启动比赛场景的情况
        if athlete.cid == nil then
            athlete.cid = defaultCid
        end
        if athlete.number == nil then
            athlete.number = i
        end

        local staticCardInfo = athlete.static
        if staticCardInfo == nil then
            staticCardInfo = memberTable[tostring(athlete.cid)]
        end
        athlete.name = staticCardInfo.name2
        athlete.picIndex = staticCardInfo.picIndex
        local modelID = tostring(staticCardInfo.modelID)
        modelID = CardModel[modelID] and modelID or "MArsenal01"
        athlete.modelID = modelID
        athlete.bodyTextureID = CardModel[modelID].bodyTextureID
        athlete.faceID = CardModel[modelID].faceID
        athlete.faceTextureID = CardModel[modelID].faceTextureID
        athlete.hairID = CardModel[modelID].hairID
        athlete.beardID = CardModel[modelID].beardID
        athlete.hairColor = CardModel[modelID].hairColor
        athlete.height = math.clamp(CardModel[modelID].height, 160, 210)
        athlete.somatotype = math.clamp(CardModel[modelID].somatotype, 1, 3)
        athlete.kitName = CardModel[modelID].kitName
        athlete.markedSkillSet = {}
    end

    return startId
end

function MatchInfoModel:SetAsDemoMatch()
    self.isDemoMatch = true
end

function MatchInfoModel:SetAsNormalMatch()
    self.isDemoMatch = false
end

function MatchInfoModel:IsDemoMatch()
    return self.isDemoMatch
end

function MatchInfoModel:GetPlayerCaptain()
    for i, athlete in ipairs(self.data.player.athletes) do
        if athlete.role == self.data.player.captain then
            return athlete.id
        end
    end
end

function MatchInfoModel:GetOpponentCaptain()
    for i, athlete in ipairs(self.data.opponent.athletes) do
        if athlete.role == self.data.opponent.captain then
            return athlete.id
        end
    end
end

-- 比赛场地（可能为空）
function MatchInfoModel:GetStadiumName()
    return self.data.baseInfo.stadiumName
end

-- 比赛时间（可能为空）
function MatchInfoModel:GetKickoffTime()
    return self.data.baseInfo.kickoffTime
end

function MatchInfoModel:NotStartFromBeginnig()
    local questCondition = self.data.baseInfo.questCondition
    return questCondition
        and questCondition.beginTime
        and questCondition.beginTime > 1
end

function MatchInfoModel:IsEndByCondition()
    local questCondition = self.data.baseInfo.questCondition
    if questCondition then
        return questCondition.winGap
            or questCondition.loseGap
            or questCondition.winGoal
            or questCondition.loseGoal
    end
    return false
end

function MatchInfoModel:IsFriendMatch()
    return self:GetMatchType() == MatchConstants.MatchType.FRIEND
end

--- 获得比赛结果
-- @return number 1:胜利，0:平局，-1:失败
function MatchInfoModel:GetMatchResult()
    local resultStatus = 0
    local matchResultData = cache.getMatchResult() or {}
    local settlementData = matchResultData.settlement
    if self:IsGiveUpMatch() then
        resultStatus = -1
    else
        if matchResultData.matchType == MatchConstants.MatchType.QUEST then
            local questPageViewModel = QuestPageViewModel.new()
            local matchStageId, matchStageIsCleared, matchStageIsSpecial = questPageViewModel:GetMatchStageId()
            -- 有特殊通关条件
            if matchStageIsSpecial then
                if settlementData.isPass then
                    resultStatus = 1
                else
                    resultStatus = -1
                end
            else
                resultStatus = self:GetMatchResultByScore()
            end
        else
            resultStatus = self:GetMatchResultByScore()
        end
    end

    return resultStatus
end

--- 根据比分获得比赛结果
-- @return number 1:胜利，0:平局，-1:失败
function MatchInfoModel:GetMatchResultByScore()
    local playerTeamData = self:GetPlayerTeamData()
    local opponentTeamData = self:GetOpponentTeamData()
    local playerStats = playerTeamData.stats
    local opponentStats = opponentTeamData.stats

    --如果有点球大战，则直接按照点球大战的比分判定胜负
    if playerStats.penaltyScore and opponentStats.penaltyScore and (playerStats.penaltyScore > 0 or opponentStats.penaltyScore > 0) then
        if playerStats.penaltyScore > opponentStats.penaltyScore then
            resultStatus = 1
        else
            resultStatus = -1
        end
    else--加时赛进球不计入主客场进球
        local playerScore = playerStats.score
        local opponentScore = opponentStats.score
        --主客场淘汰赛先根据总分判定胜负，平分则根据客场进球判定
        if self.data.baseInfo.preRace then
            local playerPreScore = self.data.baseInfo.preRace.player or 0
            local opponentPreScore = self.data.baseInfo.preRace.opponent or 0
            playerScore = playerScore + playerPreScore
            opponentScore = opponentScore + opponentPreScore
            if playerScore > opponentScore then
                resultStatus = 1
            elseif playerScore < opponentScore then
                resultStatus = -1
            else--总分相同根据客场进球多少判定胜负
                local playerAwayScore = self.data.baseInfo.home == 0 and playerStats.score or playerPreScore
                local opponentAwayScore = self.data.baseInfo.home == 0 and opponentPreScore or opponentStats.score
                if playerAwayScore > opponentAwayScore then
                    resultStatus = 1
                elseif playerAwayScore < opponentAwayScore then
                    resultStatus = -1
                else
                    resultStatus = 0
                end
            end
        else
            if playerScore > opponentScore then
                resultStatus = 1
            elseif playerScore < opponentScore then
                resultStatus = -1
            else
                resultStatus = 0
            end
        end
    end

    return resultStatus
end

function MatchInfoModel:GetSkillExistStatus(skillIds)
    local skillIdStatusData = {}
    local playerTeamData = self:GetPlayerTeamData()
    local opponentTeamData = self:GetOpponentTeamData()

    for i, skillId in ipairs(skillIds) do
        skillIdStatusData[skillId] = false
    end

    for i, athlete in ipairs(playerTeamData.athletes) do
        for skillId, skillLevel in pairs(athlete.skills) do
            if skillIdStatusData[skillId] == false then
                skillIdStatusData[skillId] = true
            end
            if string.len(skillId) > 5 then
                local tempSkillId = string.sub(skillId, 1, 5)
                if skillIdStatusData[tempSkillId] == false then
                    skillIdStatusData[tempSkillId] = true
                end
            end
        end
    end

    for i, athlete in ipairs(opponentTeamData.athletes) do
        for skillId, skillLevel in pairs(athlete.skills) do
            if skillIdStatusData[skillId] == false then
                skillIdStatusData[skillId] = true
            end
            if string.len(skillId) > 5 then
                local tempSkillId = string.sub(skillId, 1, 5)
                if skillIdStatusData[tempSkillId] == false then
                    skillIdStatusData[tempSkillId] = true
                end
            end
        end
    end

    return skillIdStatusData
end

function MatchInfoModel:isPlayerHome()
    local isPlayerHome = (self.data.baseInfo.home == 1)
    return isPlayerHome
end

return MatchInfoModel

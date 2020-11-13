local PlayerChemical = require("data.PlayerChemical")
local PlayerCorrelation = require("data.PlayerCorrelation")
local CardQuality = require("data.CardQuality")
local CardLevel = require("data.CardLevel")
local Upgrade = require("data.Upgrade")
local Grid = require("data.Grid")
local Letter = require("data.Letter")
local Letter2NumPos = require("data.Letter2NumPos")
local CardAccess = require("data.CardAccess")
local Card = require("data.Card")
local Skills = require("data.Skills")
local LegendRoadPlayer = require("data.LegendRoadPlayer")
local LockHelper = require("ui.common.lock.LockHelper")
local SkillItemModel = require("ui.models.common.SkillItemModel")
local SkillType = require("ui.common.enum.SkillType")
local PlayerBindingEquipModel = require("ui.models.cardDetail.PlayerBindingEquipModel")
local CardOwnershipType = require("ui.controllers.cardDetail.CardOwnershipType")
local CardAppendPasterModel = require("ui.models.cardDetail.CardAppendPasterModel")
local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local CardMedalModel = require("ui.models.cardDetail.CardMedalModel")
local CardFeatureModel = require("ui.models.cardDetail.CardFeatureModel")
local MedalSkillModel = require("ui.models.common.MedalSkillModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local LockType = require("ui.common.lock.LockType")
local TrainingCard = require("data.TrainingCard")
local PasterMainType = require("ui.scene.paster.PasterMainType")
local PasterSortPriority = require("ui.scene.paster.PasterSortPriority")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local CommonConstants = require("ui.common.CommonConstants")
local MemoryItemModel = require("ui.models.cardDetail.memory.MemoryItemModel")
local SupporterType = require("ui.models.cardDetail.supporter.SupporterType")
local LockTypeFilter = require("ui.common.lock.LockTypeFilter")
local Model = require("ui.models.Model")
local BaseCardModel = class(Model, "BaseCardModel")

-- 修改为十维属性
BaseCardModel.NormalPlayerAttribute = {
    "pass",         -- 带
    "dribble",      -- 传
    "shoot",        -- 射
    "intercept",    -- 拦
    "steal",        -- 抢
}
BaseCardModel.GoalKeeperAttribute = {
    "goalkeeping",  -- 门线技术
    "anticipation", -- 球路判断
    "commanding",   -- 防线指挥
    "composure",    -- 心理素质
    "launching"     -- 发起进攻
}
-- 概括位置对应
BaseCardModel.BriefPositionMap = {
    FL = "F",
    ML = "M",
    DL = "D",
    FR = "F",
    MR = "M",
    DR = "D",
    FC = "F",
    AMC = "M",
    MC = "M",
    DMC = "M",
    DC = "D",
    GK = "GK",
}
--Card表里grouthType列，有A和D两种(表示卡牌升级系数加成)
--A型成长：盘带2，射门2，抢断0，拦截0，其他六项各1
--D型成长：盘带0，射门0，抢断2，拦截2，其他六项各1
BaseCardModel.CardGrouthType =
{
    ["A"] =
    {
        ["dribble"] = 2,
        ["shoot"] = 2,
        ["steal"] = 0,
        ["intercept"] = 0,
        ["pass"] = 1,
        ["goalkeeping"] = 1,
        ["anticipation"] = 1,
        ["commanding"] = 1,
        ["composure"] = 1,
        ["launching"] = 1
    },
    ["D"] =
    {
        ["dribble"] = 0,
        ["shoot"] = 0,
        ["steal"] = 2,
        ["intercept"] = 2,
        ["pass"] = 1,
        ["goalkeeping"] = 1,
        ["anticipation"] = 1,
        ["commanding"] = 1,
        ["composure"] = 1,
        ["launching"] = 1
    }
}
function BaseCardModel:IsLockByType(lockList, lockType)
    local lockNum = self.lockHelper:GetLockNum(lockList, lockType)
    local lockValue = self.lockHelper:GetLockValue(lockType)
    if math.floor(lockNum / (2 * lockValue)) == math.floor((lockNum + lockValue) / (2 * lockValue)) then
        return false
    else
        return true
    end
end

function BaseCardModel:ctor()
    BaseCardModel.super.ctor(self)
    self.lockHelper = LockHelper.new()
    self.staticData = {} -- 静态数据
    self.cacheData = {} -- 服务器数据
    self.cardsMap = {} -- 卡牌库
    self.cardPastersModelMap = {} -- 球员身上贴纸
    self.ownershipType = CardOwnershipType.NONE
    self:InitMemoryData()
end

function BaseCardModel:SetOwnershipType(ownershipType)
    self.ownershipType = ownershipType
end

function BaseCardModel:GetOwnershipType()
    return self.ownershipType
end

function BaseCardModel:SetFormationType(formationType)
    self.formationType = formationType
end

function BaseCardModel:GetFormationType()
    return self.formationType
end

function BaseCardModel:GetCardsMap()
    return self.cardsMap
end

-- 设置大卡返回相关回调
function BaseCardModel:SetCardPopCallback(callback)
    self.popCallback = callback
end

function BaseCardModel:GetCardPopCallback()
    return self.popCallback
end

------------
-- 基础属性 :
------------
function BaseCardModel:GetCacheData()
    return self.cacheData
end

function BaseCardModel:GetPcid()
    return self.cacheData.pcid
end

function BaseCardModel:GetCid()
    return self.staticData.ID
end

function BaseCardModel:GetBaseID()
    return self.staticData.baseID
end

function BaseCardModel:GetCardQuality()
    return self.staticData.quality
end

function BaseCardModel:GetCardQualitySpecial()
    return self.staticData.qualitySpecial or 0
end

function BaseCardModel:GetIsCardPlusQuality()
    if self:IsPlusCard() then
        return self.staticData.quality + 0.5
    else
        return self.staticData.quality
    end
end

-- 助阵球员
function BaseCardModel:GetSpcid()
    return self.cacheData.spcid or 0
end

-- 参与助阵
function BaseCardModel:GetSppcid()
    return self.cacheData.sppcid or 0
end

-- 是否助阵其他球员
function BaseCardModel:IsSupportOtherCard()
    local sppcid = self:GetSppcid()
    return sppcid ~= 0
end

-- 是否有其他球员助阵
function BaseCardModel:IsHasSupportCard()
    local spcid = self:GetSpcid()
    return spcid ~= 0
end

-- 使用助阵卡牌特训进度状态
function BaseCardModel:GetStType()
    return self.cacheData.stType or 0
end

-- 是否使用自己的特训进度
function BaseCardModel:IsTrainingUseSelf()
    local stType = self:GetStType()
    local selfType = SupporterType.StType.SelfCard
    return stType == selfType or stType == -1
end

-- 使用助阵卡牌传奇之路进度
function BaseCardModel:GetSlrType()
    return self.cacheData.slrType or 0
end

-- 是否使用自己的传奇之路进度
function BaseCardModel:IsLegendRoadUseSelf()
    local slrType = self:GetSlrType()
    local selfType = SupporterType.SlrType.SelfCard
    return slrType == selfType
end

-- 将Plus卡、周年卡、传奇卡品质映射成数字以排序
function BaseCardModel:GetCardFixQualityNum()
    return tonumber(self:GetCardQuality()) + tonumber(self:GetCardQualitySpecial() / 10)
end

function BaseCardModel:GetCardFixQuality()
    local qualitySpecial = self:GetCardQualitySpecial()
    if qualitySpecial == 0 then
        return tostring(self.staticData.quality)
    elseif qualitySpecial == 1 then
        return self.staticData.quality .. "_Plus"
    elseif qualitySpecial == 2 then
        return self.staticData.quality .. "_Annual"
    elseif qualitySpecial == 3 then
        return self.staticData.quality .. "_Legend"
    elseif qualitySpecial == 4 then
        return self.staticData.quality .. "_SL"
    end
end

function BaseCardModel:IsPlusCard()
    return tobool(self:GetCardQualitySpecial() == 1)
end

-- 是否是周年纪念卡
function BaseCardModel:IsAnnualCard()
    return tobool(self:GetCardQualitySpecial() == 2)
end

-- 是否传奇卡
function BaseCardModel:IsLegendCard()
    return tobool(self:GetCardQualitySpecial() == 3)
end

-- 是否是SL卡
function BaseCardModel:IsPlusLengendCard()
    return tobool(self:GetCardQualitySpecial() == 4)
end

--是否显示特效
local EffectQualityCondition = 8  -- 显示特效的品质限制
function BaseCardModel:IsShowEffect()
    if self:IsLegendCard() or self:GetCardQuality() >= EffectQualityCondition then
        return true
    else
        return false
    end
end

function BaseCardModel:GetName()
    return self.staticData.name2
end

function BaseCardModel:GetProfile()
    return self.staticData.profile
end

-- 神秘人引入所需钻石
function BaseCardModel:GetMysteryPrice()
    return self.staticData.mysteryPrice
end

-- 万能碎片合成所需数量
function BaseCardModel:GetUniversalPieceNeed()
    return self.staticData.generalPiece or 0
end

-- 日文名，除了通用的卡牌之外，其他地方都应该显示日文名
function BaseCardModel:GetNameJP()
    return self.staticData.name2
end

-- 对应每个版本中名字的英文语言
function BaseCardModel:GetNameByEnglish()
    return self.staticData.name
end

function BaseCardModel:GetLevel()
    return self.cacheData.lvl or 1
end

function BaseCardModel:GetTrainingLevel()
    return self.cacheData.trainId and TrainingCard[tostring(self.cacheData.trainId)].pictureID
end

function BaseCardModel:GetTrainID()
    return self.cacheData.trainId
end

function BaseCardModel:GetPosByChina()
    local pos = self.staticData.mainPosition
    return string.split(pos, "#")
end

-- 球员额外装备加成（不算进阶过的装备）
function BaseCardModel:GetEquipPowerAttr()
    return {}
end

-- 球员进阶加成
function BaseCardModel:GetUpgradePowerAttr()
    return {}
end

-- 入手时间
function BaseCardModel:GetObtainTime()
    return self.cacheData.c_t
end

-- 头像的索引
function BaseCardModel:GetAvatar()
    return self.staticData.pictureID
end

-- 稀有度
function BaseCardModel:GetRarity()
    return self:GetCardQuality()
end

-- 国籍
function BaseCardModel:GetNation()
    return self.staticData.nationIcon
end

-- 国籍名称
function BaseCardModel:GetNationName()
    return self.staticData.nation
end

-- 球员身高
function BaseCardModel:GetHeight()
    return self.staticData.height
end

-- 球员投放
function BaseCardModel:GetValid()
    return self.staticData.valid
end

-- 3D模型索引
function BaseCardModel:GetModelID()
    return self.staticData.modelID
end

-- 生日
function BaseCardModel:GetBirthday()
    if self.staticData.birthday then
        local birth = self.staticData.birthday[1] .. "." .. self.staticData.birthday[2] .. "." .. self.staticData.birthday[3]
        return birth
    end
    return "1990.10.06"
end

local DefaultChemicalTab = 1
-- 化学反应(多版本注意chemicalTab字段为空)
function BaseCardModel:GetChemicalData(chemicalTab)
    if type(PlayerChemical) ~= "table" then
        return {}
    end
    if not chemicalTab then
        chemicalTab = self:GetChemicalTab()
    end
    local currentChemicalData = {}
    local totalChemicalData = PlayerChemical[tostring(self:GetCid())] or {}
    for i, v in ipairs(totalChemicalData) do
        local belongToChemical = v.chemicalTab or DefaultChemicalTab
        if tonumber(belongToChemical) == tonumber(chemicalTab) then
            table.insert(currentChemicalData, v)
        end
    end
    return currentChemicalData
end

-- 多化学标签(默认是第一套)
function BaseCardModel:GetChemicalTab()
    return self.cacheData.chemicalTab or DefaultChemicalTab
end

function BaseCardModel:SetChemicalTab(chemicalTab)
    self.cacheData.chemicalTab = chemicalTab
end

-- 记录当前点击时选择的多化学标签
function BaseCardModel:GetChooseChemicalTab()
    return self.chooseTab or self:GetChemicalTab()
end

function BaseCardModel:SetChooseChemicalTab(chooseTab)
    self.chooseTab = chooseTab
end

function BaseCardModel:GetChemicalTabNum()
    local totalChemicalData = PlayerChemical[tostring(self:GetCid())] or {}
    local chemicalTabNum = {}
    for i, v in ipairs(totalChemicalData) do
        local chemicalTab = v.chemicalTab
        if chemicalTab and not chemicalTabNum[tonumber(chemicalTab)] then
            chemicalTabNum[tonumber(chemicalTab)] = true
        end
    end
    local tabNum = table.nums(chemicalTabNum)

    local chooseTab = self:GetChooseChemicalTab()
    if chooseTab > tabNum then
        self:SetChooseChemicalTab(self:GetChemicalTab())
    end
    return tabNum
end

-- 转生次数
function BaseCardModel:GetAscend()
    return tonumber(self.cacheData.ascend)
end

-- 是否可以升级
function BaseCardModel:CanUpdate()
    return self.cacheData.exp >= CardLevel[tostring(self.cacheData.lvl)].cumCardExp
end

-- 是否存在进阶次数
function BaseCardModel:IsExistUpgradeNum()
    local quality = self.staticData.quality
    return self:GetUpgrade() < CardQuality[tostring(quality)].upgrade
end

-- 是否可以培养
function BaseCardModel:IsCanTrain()
    local cardQualityTable = CardQuality[tostring(self:GetCardQuality())]
    return cardQualityTable.train == 1
end

-- 是否开启培养功能
function BaseCardModel:IsTrainOpen()
    return self:IsCanTrain() and self:GetUpgrade() >= 3
end

-- 是否开启技能功能
function BaseCardModel:IsSkillOpen()
    return false
end

-- 是否达到进阶标记（进阶中有装备可穿戴）
function BaseCardModel:HasUpgradeSign()
    return false
end

function BaseCardModel:HasSign()
    return false
end

function BaseCardModel:HasSkillSign()
    return false
end

function BaseCardModel:HasOneKeyEquip()
    return false
end

function BaseCardModel:GetOpenFromPageType()
    return self.cardOpenFromType
end

function BaseCardModel:SetOpenFromPageType(cardOpenFromType)
    self.cardOpenFromType = cardOpenFromType
end

function BaseCardModel:GetAvailableEquipToSwear()
    return {}, {}
end

-- 是否有球员贴纸
function BaseCardModel:HasPaster()
    return false
end

-- 是否图鉴形式展示贴纸
function BaseCardModel:GetIsPasterPokedex()
    return false
end

function BaseCardModel:HasPasterAvailable(existPasterIds)
    local cid = self:GetCid()
    local cardPastersMapModel = CardPastersMapModel.new()
    return cardPastersMapModel:HasPasterAvailable(cid, existPasterIds, self:GetSkills())
end

function BaseCardModel:HasPasterAvailableWithoutSame()
    return false
end

function BaseCardModel:GetPasterAvailableModel()
    local cid = self:GetCid()
    local cardPastersMapModel = CardPastersMapModel.new()
    return cardPastersMapModel:GetPasterAvailableModel(cid, self:GetSkills())
end

-- 可装备贴纸
function BaseCardModel:GetPasterAvailableModelWithoutSame()
    local availableMedals = self:GetPasterAvailableModel()
    local availableMedalsWithoutSame = {}
    for i, v in pairs(availableMedals) do
        local ptcid = v:GetPasterId()
        if not self:HasSamePaster(ptcid) or v:GetPasterUsedByAll() then
            table.insert(availableMedalsWithoutSame, v)
        end
    end
    return availableMedalsWithoutSame
end

-- 可装备贴纸中是否包含周贴
function BaseCardModel:HasWeekPasterAvailable(existPasterIds)
    local pasterAvailableModel = self:GetPasterAvailableModelWithoutSame()
    for i, v in pairs(pasterAvailableModel) do
        if v:IsWeekPaster() then
            return true
        end
    end
    return false
end

-- 可装备贴纸中是否包含除周贴全员可用贴之外的贴纸
function BaseCardModel:HasOtherPasterAvailable(existPasterIds)
    local pasterAvailableModel = self:GetPasterAvailableModelWithoutSame()
    for i, v in pairs(pasterAvailableModel) do
        if not v:GetPasterUsedByAll() and not v:IsWeekPaster() then
            return true
        end
    end
    return false
end

-- 球员贴纸数据
function BaseCardModel:GetPasterData()
    return self.cacheData.paster or {}
end

-- 是否有球员勋章
function BaseCardModel:HasMedal()
    return false
end

-- 球员贴纸数据
function BaseCardModel:GetMedals()
    return self.cacheData.medals or {}
end

-- 是否存在所需装备
function BaseCardModel:HasNeedEquip(equipId)
    local isNeed = false
    local equips = self:GetEquips()
    for i, equip in ipairs(equips) do
        local equipItemModel = self:GetEquipModel(equip.slot)
        local equipID = equipItemModel:GetEquipID()
        if not equipItemModel:IsEquip() and tonumber(equipId) == tonumber(equipID) then
            isNeed = true
            break
        end
    end
    return isNeed
end

-- 免费培养次数
function BaseCardModel:GetFreeAdvance()
    return tonumber(self.cacheData.freeAdvance)
end

function BaseCardModel:SetFreeAdvance(freeAdvance)
    assert(freeAdvance)
    self.cacheData.freeAdvance = tonumber(freeAdvance)
end

function BaseCardModel:AddFreeAdvance(add)
    assert(add)
    self.cacheData.freeAdvance = self:GetFreeAdvance() + tonumber(add)
end

-- 配表里的技能
function BaseCardModel:GetStaticSkills()
    return self.staticData.skill
end

-- 未转生潜力
function BaseCardModel:GetStaticPotential()
    return self.staticData.potential
end

-- 已经消耗的潜力
function BaseCardModel:GetConsumePotent()
    return tonumber(self.cacheData.consumePotent)
end

-- 传奇之路潜力
function BaseCardModel:GetLegendPotent()
    return 0
end

-- 最大转生次数（静态数据）
function BaseCardModel:GetMaxAscendNum()
    local cardQualityTable = CardQuality[tostring(self:GetCardQuality())]
    return tonumber(cardQualityTable.ascend)
end

function BaseCardModel:GetStaticSkillsNum()
    local skills = self:GetStaticSkills() or {}
    return table.nums(skills)
end

function BaseCardModel:IsBaseSkill(slot)
    local skillsNum = self:GetStaticSkillsNum()
    return tonumber(slot) <= skillsNum
end

function BaseCardModel:IsMaxAscend()
    local maxAscend = self:GetMaxAscendNum()
    local currentAscend = self:GetAscend()
    if currentAscend >= maxAscend then
        return true
    end
    return false
end

-- 球员是否有转生功能
function BaseCardModel:CanAscend()
    return self:GetMaxAscendNum() > 0
end

-- 每次转生每个维度增加的属性(静态数据)
function BaseCardModel:GetAscendAttribute()
    local cardQualityTable = CardQuality[tostring(self:GetCardQuality())]
    return cardQualityTable.ascendAttribute
end

-- 是否可以升级
function BaseCardModel:IsCanLevelUp()
    return self:GetLevel() < self:GetLevelLimit()
end

-- 是否达到max状态（进阶次数达到最大值且等级达到最大值）
function BaseCardModel:IsLevelMaxState()
    local cardQualityTable = CardQuality[tostring(self:GetCardQuality())]
    return self:GetUpgrade() >= cardQualityTable.upgrade and self:GetLevel() >= cardQualityTable.maxLvl
end

local AscendNeedUpgradeMinLevel = 4
local AscendMinLevel = 2
-- 紫色及紫色以上品质的卡牌进阶+4后开启1转和2转，每多进阶1次，额外开启1次转生
function BaseCardModel:GetAscendTimesNeedUpgradeLevel(upgrade)
    local ascendTimes = tonumber(upgrade) - AscendNeedUpgradeMinLevel
    if ascendTimes >= 0 then
        ascendTimes = AscendMinLevel + ascendTimes
    end
    return ascendTimes
end

-- 获取转生所需要的进阶等级
function BaseCardModel:GetNeedUpgradeLevelByAscendTimes(ascend)
    local needUpgradeLevel = AscendNeedUpgradeMinLevel
    local exUpgradeLevel = tonumber(ascend) - AscendMinLevel
    if exUpgradeLevel >= 0 then
        needUpgradeLevel = needUpgradeLevel + exUpgradeLevel
    end
    return needUpgradeLevel
end

-- 是否开启转生功能(紫色及以上品质的球员卡达到max后)
function BaseCardModel:IsRebornOpen()
    return self:CanAscend() and self:GetAscendTimesNeedUpgradeLevel(self:GetUpgrade()) >= 0
end

function BaseCardModel:IsMedalOpen()
    local playerInfoModel = PlayerInfoModel.new()
    local playerLevel = playerInfoModel:GetLevel()
    local LevelLimit = require("data.LevelLimit")
    local needLvl = LevelLimit["medal"].playerLevel
    dump(playerLevel, "playerLevel")
    dump(needLvl, "needLvl")
    dump(self:GetMedalMaxPos(), "self:GetMedalMaxPos()")
    dump(self:IsLevelMaxState(), "self:IsLevelMaxState()")
    return tobool(playerLevel >= needLvl) and tobool(self:GetMedalMaxPos() >= 1) and self:IsLevelMaxState()
end

-- 根据当前进阶状态取得当前的等级上限
function BaseCardModel:GetLevelLimit()
    local levelLimit = (self:GetUpgrade() + 1) * 10
    local quality = self.staticData.quality
    local currentQualityMaxLevel = CardQuality[tostring(quality)].maxLvl
    return levelLimit >= currentQualityMaxLevel and currentQualityMaxLevel or levelLimit
end

-- 是否可以进阶(存在进阶次数并且装备都已穿上)
function BaseCardModel:IsCanUpgrade()
    local equipsData = self:GetEquips()
    for i, equip in ipairs(equipsData) do
        if equip.isEquip == false then
            return false
        end
    end
    return self:IsExistUpgradeNum()
end

-- 是否出现在转会市场
function BaseCardModel:IsTransferOpen()
    return false
end

-- 化学反应中球员额外加成
function BaseCardModel:GetChemicalPlayersAddValue(cid)
    return 0
end

-- 球员经验
function BaseCardModel:GetExp()
    return self.cacheData.exp
end

-- 累计经验达到当前等级
function BaseCardModel:GetExpLimit()
    local level = self:GetLevel()
    return CardLevel[tostring(level)].cumCardExp
end
function BaseCardModel:GetExpLimitEx(level)
    return CardLevel[tostring(level)].cumCardExp
end

-- 总共累计多少经验可以达到下一等级
function BaseCardModel:GetLevelUpExpLimit()
    if self:IsCanLevelUp() then
        return CardLevel[tostring(self.cacheData.lvl + 1)].cumCardExp or CardLevel[tostring(self.cacheData.lvl)].cumCardExp
    else
        return self:GetExpLimit()
    end
end
function BaseCardModel:GetLevelUpExpLimitEx(level)
    return CardLevel[tostring(level + 1)].cumCardExp or CardLevel[tostring(level)].cumCardExp
end

-- 当前等级到下一等级总共所需的经验
function BaseCardModel:GetLevelUpExp()
    local level = self:GetLevel()
    return CardLevel[tostring(level + 1)] and CardLevel[tostring(level + 1)].cardExp or CardLevel[tostring(level)].cardExp
end

function BaseCardModel:GetLevelUpExpEx(level)
    return CardLevel[tostring(level + 1)] and CardLevel[tostring(level + 1)].cardExp or CardLevel[tostring(level)].cardExp
end

function BaseCardModel:GetUpgrade()
    return self.cacheData.upgrade or 0
end

-- 最大进阶次数
function BaseCardModel:GetMaxUpgradeNum()
    return CardQuality[tostring(self.staticData.quality)].upgrade
end

-- 即将穿上的装备给球员增加的属性
-- 返回一个table
function BaseCardModel:GetEquipAbilityPlus(slot)
    if self.cacheData.equips then
        local calculateUpgrade = self:GetUpgrade()
        if not self:IsExistUpgradeNum() then -- 进阶满后得算上一次进阶装备加成
            calculateUpgrade = calculateUpgrade - 1
        end
        for i, equip in ipairs(self.cacheData.equips) do
            if tostring(equip.slot) == tostring(slot) then
                local gridIDArray = self.staticData.grid -- array
                local gridID = gridIDArray[equip.slot + 1]
                local gridTable = Grid[tostring(gridID)]
                return gridTable["upgrade" .. tostring(calculateUpgrade)]
            end
        end
    end

    return {}
end

-- 守门员
function BaseCardModel:IsGKPlayer()
    for i, v in pairs(self.staticData.position) do
        if tostring(v) == "GK" then
            return true
        end
    end

    return false
end

-- 属性名字
function BaseCardModel:GetAttrNameList()
    if self:IsGKPlayer() then
        return BaseCardModel.GoalKeeperAttribute
    else
        return BaseCardModel.NormalPlayerAttribute
    end
end

function BaseCardModel:InitEquipsAndSkills()
    self.equipsMap = {}
    self.skillsMap = {}

    local equips = self:GetEquips()
    for i, equip in ipairs(equips) do
        local equipItemModel = PlayerBindingEquipModel.new(equip.eid)
        equipItemModel:InitWithCache(equip)
        self.equipsMap[tostring(equip.slot)] = equipItemModel
    end

    local skills = self:GetSkills()
    for i, skill in ipairs(skills) do
        local skillItemModel = SkillItemModel.new()
        skillItemModel:InitWithCache(skill, i)
        skillItemModel:SetCoachMainModel(self:GetCoachMainModel())
        skillItemModel:SetLegendRoadLvl(self:GetLegendSkillLvl(i))
        skillItemModel:SetHomeCourtLvl(self:GetHomeCourtSkillLvl(i, skill.sid))
        skillItemModel:SetFancyLvl(self:GetFancySkillLvl(i))
        skillItemModel:SetSupportLvl(self:GetSupportSkillLvl(i))
        -- 需要根据技能的slot位置存储，因为很有可能会有两个相同的技能
        table.insert(self.skillsMap, skillItemModel)
    end
end

function BaseCardModel:GetLegendSkillLvl(slot)
    return 0
end

function BaseCardModel:GetHomeCourtSkillLvl(slot, sid)
    return 0
end

function BaseCardModel:GetFancySkillLvl(slot)
    return 0
end

function BaseCardModel:GetSupportSkillLvl(slot)
    return 0
end

-- 球员装备
function BaseCardModel:GetEquips()
    return self.staticData.equips
end

function BaseCardModel:GetEquipsMap()
    return self.equipsMap
end

function BaseCardModel:GetEquipModel(slot)
    return self.equipsMap[tostring(slot)]
end

-- 球员技能
function BaseCardModel:GetSkills()
    return self.staticData.skills
end

function BaseCardModel:GetSkillsMap()
    return self.skillsMap
end

function BaseCardModel:GetSkillModel(slot)
    return self.skillsMap[slot]
end

function BaseCardModel:HasSkillLevelUp()
    local hasSkillLevelUp = false
    if self.skillsMap then
        for i, skillItemModel in ipairs(self.skillsMap) do
            local isMaxLevel = skillItemModel:IsUpToCurrentUpgradeMaxLevel()
            if not isMaxLevel then
                hasSkillLevelUp = true
                break
            end
        end
    end
    return hasSkillLevelUp
end

function BaseCardModel:GetSkillItemModelBySlot(slot)
    local skillItemModel = SkillItemModel.new()
    local skill = self.cacheData.skills[slot]
    skillItemModel:InitWithCache(skill, slot)
    skillItemModel:SetCoachMainModel(self:GetCoachMainModel())
    skillItemModel:SetLegendRoadLvl(self:GetLegendSkillLvl(slot))
    skillItemModel:SetHomeCourtLvl(self:GetHomeCourtSkillLvl(slot, skill.sid))
    skillItemModel:SetFancyLvl(self:GetFancySkillLvl(slot))
    skillItemModel:SetSupportLvl(self:GetSupportSkillLvl(slot))
    return skillItemModel
end

-- 当前所有激活的技能等级是否达到最大
function BaseCardModel:IsSkillLevelMax()
    self:InitEquipsAndSkills()
    for i, skillItemModel in ipairs(self.skillsMap) do
        if skillItemModel:IsOpen() then
            if skillItemModel:GetLevel() < skillItemModel:GetSkillMaxLevel() then
                return false
            end
        end
    end

    return true
end

-- 可拥有最大技能点数
function BaseCardModel:GetMaxSkillPoint()
    local maxSkillPoint = 0

    local skillsData = self:GetSkills()
    local skillMaxLvl = self:GetMaxSkillLevel(self:GetAscend())
    for i, skill in ipairs(skillsData) do
        if skill.isOpen then
            maxSkillPoint = maxSkillPoint + (skillMaxLvl - skill.lvl)
        end
    end

    return maxSkillPoint
end

-- 当前技能点数是否已达到最大
function BaseCardModel:IsSkillPointMax()
    return self:GetSkillPoint() >= self:GetMaxSkillPoint()
end

-- 已经激活的技能数量
function BaseCardModel:GetActivatedSkillAmount()
    local ret = 0
    local skillsData = self:GetSkills()
    for i, skill in ipairs(skillsData) do
        if skill.isOpen then
            ret = ret + 1
        end
    end
    return ret
end

-- 可用装备包括可用装备碎片达成合成数都会点亮装备红点（装备未达到，碎片达到也算满足）
function BaseCardModel:CanWearEquip(slot)
    return false
end

-- 可用装备包括可用装备碎片达成合成数都会点亮装备红点（装备未达到，碎片达到也算满足, 不考虑等级即装备等级未达到也算满足。）
function BaseCardModel:IsReachWearEquipCondition(slot)
    return false
end

-- 是否已装备当前进阶所需的装备
function BaseCardModel:HasEquipFull()
    return false
end

-- 球员位置（表格数据）
function BaseCardModel:GetPosition()
    return self.staticData.position
end

-- 转会条件
function BaseCardModel:GetTransferCondition()
    return self.staticData.transferCondition
end

-- 球员指定位置描述（表格针对不同版本显示不一致）
function BaseCardModel:GetSinglePositionDesc(pos)
    return Letter2NumPos[pos].displayPos
end

-- 球员位置描述（表格针对不同版本显示不一致）
function BaseCardModel:GetPositionDesc()
    local posDescArray = {}
    local posArray = self.staticData.position
    for i, v in ipairs(posArray) do
        local pos = Letter2NumPos[v].displayPos
        table.insert(posDescArray, pos)
    end
    return posDescArray
end

-- 概括位置（F/M/D/GK）
function BaseCardModel:GetBriefPosition()
    local posTable = self:GetPosition()
    local ret = {}
    local tmp ={}
    for i, v in ipairs(posTable) do
        local briefPos = BaseCardModel.BriefPositionMap[v]
        tmp[briefPos] = true
    end
    for k, v in pairs(tmp) do
        table.insert(ret, k)
    end
    return ret
end

-- 由转生或者培养带来的潜力属性加成
function BaseCardModel:GetAdvancePotential(index)
    if not self.cacheData.advanceAttr then
        self.cacheData.advanceAttr = {}
    end
    return self.cacheData.advanceAttr[index] or 0
end

function BaseCardModel:GetPower()
    return 0
end

function BaseCardModel:GetValue()
    return 0
end

function BaseCardModel:GetAscendPriceUp()
    return self.cacheData.ascendPriceUp or 0
end

-- 球员技能点数
function BaseCardModel:GetSkillPoint()
    return self.cacheData.skillPoint
end

-- 技能总数
function BaseCardModel:GetSkillAmount()
    return #self.cacheData.skills
end

-- 球员是否上锁
function BaseCardModel:GetLock()
    local isLock = not self.lockHelper:IsNoLock(self.cacheData.lock)
    return isLock
end

-- 无锁状态0
function BaseCardModel:IsNoLock()
    local isNoLock = self.lockHelper:IsNoLock(self.cacheData.lock)
    return isNoLock
end
-- 玩家自锁 - 强制锁1
function BaseCardModel:IsInPlayerLock()
    return self:IsLockByType(self.cacheData.lock, LockType.PlayerLock)
end
-- 当前阵容上场锁（上场球员） - 强制锁2
function BaseCardModel:IsInPlayingLock()
    if self.teamsModel == nil then
        self.teamsModel = require("ui.models.PlayerTeamsModel").new()
    end
    local currTid =  self.teamsModel:GetNowTeamId()
    self.lockHelper:ChangeLockTypeByTeamId(currTid)
    return self:IsLockByType(self.cacheData.lock, LockType.CourtLock)
end
-- 竞技场上场锁（上场球员） - 强制锁4
function BaseCardModel:IsInCwarLock()
    return self:IsLockByType(self.cacheData.lock, LockType.ArenaLock)
end
-- 当前阵容 替补 - 提示锁8
function BaseCardModel:IsInPlayingRepLock()
    return self:IsLockByType(self.cacheData.lock, LockType.BenchLock)
end
-- 竞技场阵容 替补 - 提示锁16
function BaseCardModel:IsInCwarRepLock()
    return self:IsLockByType(self.cacheData.lock, LockType.ArenaBench_Lock)
end

-- 白银竞技场阵容上场锁（上场球员） - 强制锁
function BaseCardModel:IsInSilverLock()
    return self:IsLockByType(self.cacheData.lock, LockType.Arena_Silver_Lock)
end
-- 白银竞技场阵容上场锁 替补 - 强制锁
function BaseCardModel:IsInSilverRepLock()
    return self:IsLockByType(self.cacheData.lock, LockType.Arena_Silver_Rep_Lock)
end
-- 黄金竞技场阵容上场锁（上场球员） - 强制锁
function BaseCardModel:IsInGoldLock()
    return self:IsLockByType(self.cacheData.lock, LockType.Arena_Gold_Lock)
end
-- 黄金竞技场阵容上场锁 替补 - 强制锁
function BaseCardModel:IsInGoldRepLock()
    return self:IsLockByType(self.cacheData.lock, LockType.Arena_Gold_Rep_Lock)
end
-- 黑金竞技场阵容上场锁（上场球员） - 强制锁
function BaseCardModel:IsInBlackGoldLock()
    return self:IsLockByType(self.cacheData.lock, LockType.Arena_Black_Lock)
end
-- 黑金竞技场阵容上场锁 替补 - 强制锁
function BaseCardModel:IsInBlackGoldRepLock()
    return self:IsLockByType(self.cacheData.lock, LockType.Arena_Black_Rep_Lock)
end
-- 白金竞技场阵容上场锁（上场球员） - 强制锁
function BaseCardModel:IsInPlatinumLock()
    return self:IsLockByType(self.cacheData.lock, LockType.Arena_Platinum_Lock)
end
-- 白金竞技场阵容上场锁 替补 - 强制锁
function BaseCardModel:IsInPlatinumRepLock()
    return self:IsLockByType(self.cacheData.lock, LockType.Arena_Platinum_Rep_Lock)
end

-- 多套阵容非主阵容上场锁
function BaseCardModel:IsInBenchFormationPlayingLock()
    return self:IsLockByType(self.cacheData.lock, LockType.FirstBenchFormation_CourtLock) or self:IsLockByType(self.cacheData.lock, LockType.SecondBenchFormation_CourtLock)
end

-- 多套阵容非主阵容替补锁
function BaseCardModel:IsInBenchFormationBenchLock()
    return self:IsLockByType(self.cacheData.lock, LockType.FirstBenchFormation_BenchLock) or self:IsLockByType(self.cacheData.lock, LockType.SecondBenchFormation_BenchLock)
end

-- 争霸赛上锁
function BaseCardModel:IsInCompete()
    return self:IsLockByType(self.cacheData.lock, LockType.Compete_Lock)
end

-- 教练任务 任务中上锁
function BaseCardModel:IsInCoachMission()
    return self:IsLockByType(self.cacheData.lock, LockType.CoachMission_Lock)
end

-- 争霸赛上锁 替补 --强制锁
function BaseCardModel:IsInCompeteRep()
    return self:IsLockByType(self.cacheData.lock, LockType.Compete_Rep_Lock)
end

-- 特殊赛事上场锁
function BaseCardModel:IsInSpecialEventsLock()
    local specialEventsLock = LockType.SpecialEvents_Lock
    local specialLockList = {}
    local specialLock = false
    for lockType, specialEventId in pairs(specialEventsLock) do
        if self:IsLockByType(self.cacheData.lock, lockType) then
            specialLock = true
            specialLockList[lockType] = specialEventId
        end
    end
    return specialLock, specialLockList
end

-- 特殊赛事上场锁 替补
function BaseCardModel:IsInSpecialEventsRepLock()
    local specialEventsRepLock = LockType.SpecialEvents_RepLock
    local specialRepLockList = {}
    local specialRepLock = false
    for lockType,  specialEventId in pairs(specialEventsRepLock) do
        if self:IsLockByType(self.cacheData.lock, lockType) then
            specialRepLock = true
            specialRepLockList[lockType] = specialEventId
        end
    end
    return specialRepLock, specialRepLockList
end

-- 巅峰对决锁
function BaseCardModel:IsInPeakLock()
    local peakLock = LockType.Peak_Lock
    local peakLockList = {}
    local isPeakLock = false
    for lockType, v in pairs(peakLock) do
        if self:IsLockByType(self.cacheData.lock, lockType) then
            isPeakLock = true
            peakLockList[lockType] = lockType
        end
    end
    local peakRepLock = LockType.Peak_RepLock
    for lockType, v in pairs(peakRepLock) do
        if self:IsLockByType(self.cacheData.lock, lockType) then
            isPeakLock =  true
            peakLockList[lockType] = lockType
        end
    end
    return isPeakLock, peakLockList
end

-- 传奇记忆，被添加的球员上锁
function BaseCardModel:IsMemoryLock()
    return self:IsLockByType(self.cacheData.lock, LockType.CardMemory_Lock)
end

-- 红金竞技场上锁（上场和替补球员） - 强制锁
function BaseCardModel:IsInRedGoldLock()
    return self:IsLockByType(self.cacheData.lock, LockType.Arena_RedGold_Lock)
end

-- 周年庆竞技场上锁（上场和替补球员） - 强制锁
function BaseCardModel:IsInAnniversaryLock()
    return self:IsLockByType(self.cacheData.lock, LockType.Arena_Anniversary_Lock)
end

-- 巅峰竞技场上锁（上场和替补球员） - 强制锁
function BaseCardModel:IsInArenaPeakLock()
    return self:IsLockByType(self.cacheData.lock, LockType.Arena_Peak_Lock)
end

-- 球员助力上锁（上场和替补球员） - 强制锁
function BaseCardModel:IsInSupporterLock()
    local isSupporter = self:IsSupportOtherCard()
    local isSupported = self:IsHasSupportCard()
    return isSupporter or isSupported
    -- 球员助力锁值加上后开放
    -- return self:IsLockByType(self.cacheData.lock, LockType.Supporter_Lock) or self:IsLockByType(self.cacheData.lock, LockType.Supported_Lock)
end

--不允许出售（强制锁）
function BaseCardModel:IsNotAllowSell()
    local lockTypes = self.lockHelper:IsLockByLockTypes(self.cacheData.lock, LockTypeFilter.CanSell)
    local isInSupporterLock = self:IsInSupporterLock()
    return lockTypes or isInSupporterLock
    -- 球员助力锁值加上后开放
    -- return lockTypes
end

-- 球员是否在某些锁值中
function BaseCardModel:IsInUse(lockTypeFilterInfo)
    local isLock = self.lockHelper:IsLockByLockTypes(self.cacheData.lock, lockTypeFilterInfo)
    return isLock
end

-- 获取锁的信息
function BaseCardModel:GetLockState()
    if self.teamsModel == nil then
        self.teamsModel = require("ui.models.PlayerTeamsModel").new()
    end
    self.lockHelper:InitLockNum(self.cacheData.lock, self.teamsModel:GetNowTeamId())
    local isLock = self.lockHelper:GetLockState()
    local lockData = self.lockHelper:GetLockData()
    ------------------------------
    -- 球员助力锁值加上后删去
    if not isLock and self:IsInSupporterLock() then
        isLock = true
        if self:IsSupportOtherCard() then
            lockData = { desc = lang.trans("supporter_lock"), getKey = function() return true end  }
        elseif self:IsHasSupportCard() then
            lockData = { desc = lang.trans("supported_lock"), getKey = function() return true end  }
        end
    end
    ------------------------------
    return isLock, lockData
end

-- 不允许操作
function BaseCardModel:IsOperable()
    return false
end

-- 不允许跳转
function BaseCardModel:IsAllowChangeScene()
    return false
end

-- 当前id是否在化学反应中
function BaseCardModel:IsExistChemicalCardID(cid)
    return false
end

function BaseCardModel:GetLegendPotentImprove()
    return 0
end

-- 等级是否达到上限
function BaseCardModel:IsMaxLevel()
    local cardQualityTable = CardQuality[tostring(self:GetCardQuality())]
    return tonumber(self:GetLevel()) >= tonumber(cardQualityTable.maxLvl)
end

-- 技能默认最大进阶等级上限
function BaseCardModel:GetDefaultUpgardeSkillLevel()
    local cardQualityTable = CardQuality[tostring(self:GetCardQuality())]
    local upgradeTable = Upgrade[tostring(cardQualityTable.upgrade)]
    return upgradeTable.skillMaxLvl
end

-- 当前技能等级上限
function BaseCardModel:GetMaxSkillLevel(ascend)
    assert(ascend)
    if self:GetUpgrade() <= 0 then
        return 0
    end

    local upgradeTable = Upgrade[tostring(self:GetUpgrade())]
    local cardQualityTable = CardQuality[tostring(self:GetCardQuality())]
    return upgradeTable.skillMaxLvl + ascend * cardQualityTable.ascendSkillLvl
end

-- 技能默认最大等级上限（包括进阶及转生）
function BaseCardModel:GetDefaultMaxSkillLevel()
    local cardQualityTable = CardQuality[tostring(self:GetCardQuality())]
    local skillMaxUpgradeLvl = self:GetDefaultUpgardeSkillLevel()
    local skillMaxAscendLvl = cardQualityTable.ascend * cardQualityTable.ascendSkillLvl
    return tonumber(skillMaxUpgradeLvl) + tonumber(skillMaxAscendLvl)
end

function BaseCardModel:GetMaxSkillPoint()
    return 0
end

-- 判断自己是否在这个阵容里面(根据pcid判断)
function BaseCardModel:IsPlayerInTeam(tid)
    return false
end

-- 再判断配缘人是否存在这个阵容里面(根据cid判断)
function BaseCardModel:IsChemicalPlayerInTeam(cardID, tid)
    return false
end

-- 缘分类技能是否生效
function BaseCardModel:IsChemicalSkillValid(cardID1, cardID2, tid)
    return false
end

-- 刷新数据
function BaseCardModel:RefreshCardData(...)

end

function BaseCardModel:IsStaticCard()
    return self.ownershipType == CardOwnershipType.NONE
end

function BaseCardModel:GetCardResources()
    return self.staticData.cardResource or {}
end

-- 是否属于球员来信中的球员
function BaseCardModel:IsBelongToLetterCard()
    for k, v in pairs(Letter) do
        for k1, v1 in pairs(v.card) do
            if self.staticData.ID == string.sub(v1, 1, string.find(v1, "=") - 1) then
                return true
            end
        end
    end
    return false
end

function BaseCardModel:SortPasterList(CardAppendPasterModel)
    table.sort(CardAppendPasterModel, function(aModel, bModel)
        local aPasterSort = aModel:GetPasterSortPriority()
        local bPasterSort = bModel:GetPasterSortPriority()

        if aPasterSort == bPasterSort then
            if aModel:GetSkillValid() == bModel:GetSkillValid() then
                return aModel:GetPasterQuality() > bModel:GetPasterQuality()
            else
                return aModel:GetSkillValid() > bModel:GetSkillValid()
            end
        else
            return aPasterSort > bPasterSort
        end
    end)
end

-- 初始球员身上贴纸数据
function BaseCardModel:InitPasterModel()
    local pasterData = self:GetPasterData()
    local skills = self:GetSkills()
    self.cardPastersModelMap = {}

    for i, v in ipairs(pasterData) do
        local ptid = v.ptid
        local pasterSkillData
        for slot, skillData in ipairs(skills) do
            if skillData.ptid == ptid then
                pasterSkillData = skillData
                local model = CardAppendPasterModel.new(ptid)
                model:InitWithCache(v, pasterSkillData)
                model:SetCoachMainModel(self:GetCoachMainModel())
                model:SetLegendRoadLvl(self:GetLegendSkillLvl(slot))
                model:SetHomeCourtLvl(self:GetHomeCourtSkillLvl(slot, skillData.sid))
                model:SetFancyLvl(self:GetFancySkillLvl(slot))
                model:SetSupportLvl(self:GetSupportSkillLvl(slot))
                table.insert(self.cardPastersModelMap, model)
                break
            end
        end
    end
    self:SortPasterList(self.cardPastersModelMap)
end

-- type 1-周贴 2-月贴 3-荣耀贴纸 5-纪念贴纸, -1-无贴纸 (在有数据的情况直接取最上层model减少计算)
function BaseCardModel:GetPasterMainType()
    local pasterType = -1
    local i, pasterModel = next(self.cardPastersModelMap)
    if pasterModel then
        pasterType = pasterModel:GetPasterType()
    else
        local paster = self.cacheData.paster
        if paster and next(paster) then
            table.sort(paster, function(aData, bData)
                return tonumber(PasterSortPriority[aData.type]) > tonumber(PasterSortPriority[bData.type])
            end)
            local i, data = next(paster)
            pasterType = tonumber(data.type)
        end
    end

    return pasterType
end

function BaseCardModel:GetPasterModel()
    return self.cardPastersModelMap
end

-- 获得争霸贴纸限制数量
function BaseCardModel:GetWorldPasterLimit()
    return self.staticData.worldPaster
end

-- 获得周贴纸限制数量
function BaseCardModel:GetWeekPasterLimit()
    return CommonConstants.WeekPasterLimit
end

-- 获得当前装备的争霸贴纸数量
function BaseCardModel:GetWorldPasterNum()
    local pasterData = self:GetPasterData()
    local result = 0
    for i, v in ipairs(pasterData) do
        if v.type == PasterMainType.Compete then
            result = result + 1
        end
    end
    return result
end

-- 获得当前装备的周贴纸数量
function BaseCardModel:GetWeekPasterNum()
    local pasterData = self:GetPasterData()
    local result = 0
    for i, v in ipairs(pasterData) do
        if v.type == PasterMainType.Week then
            result = result + 1
        end
    end
    return result
end


-- 获得当前装备的荣耀贴纸数量
function BaseCardModel:GetHonorPasterNum()
    local pasterData = self:GetPasterData()
    local result = 0
    for i, v in ipairs(pasterData) do
        if v.type == PasterMainType.Honor then
            result = result + 1
        end
    end
    return result
end


-- 获得当前装备的纪念贴纸数量
function BaseCardModel:GetAnnualPasterNum()
    local pasterData = self:GetPasterData()
    local result = 0
    for i, v in ipairs(pasterData) do
        if v.type == PasterMainType.Annual then
            result = result + 1
        end
    end
    return result
end

-- 获得当前装备的月贴纸数量
function BaseCardModel:GetMonthPasterNum()
    local pasterData = self:GetPasterData()
    local result = 0
    for i, v in ipairs(pasterData) do
        if v.type == PasterMainType.Month then
            result = result + 1
        end
    end
    return result
end

-- 是否可以通过抽卡获得该卡
function BaseCardModel:IsCanByGachaGain()
    return tonumber(self.staticData.valid) == 1 and self.staticData.outOfPrintTime == nil
        and tonumber(self.staticData.qualitySpecial) == 0 and tonumber(self.staticData.packageWeight) ~= 0
end

-- 额外解锁
function BaseCardModel:IsCanByElseGain()
    local condition = self.staticData.transferCondition
    local quality = self.staticData.quality
    if condition == "none" then
        return false
    end
    if condition == "condition" then
        return true
    end
    if tonumber(condition) >=1 and tonumber(condition) <= 10 and tonumber(quality) == 4 or
        tonumber(quality) == 5 or tonumber(quality) == 6 then
        return true
    end
    return false
end

-- 通过球探设解锁
function BaseCardModel:IsCanByScoutGain()
    local condition = self.staticData.transferCondition
    local quality = self.staticData.quality
    if condition == "none" then
        return false
    end
    if tonumber(condition) >=1 and tonumber(condition) <= 10 and tonumber(quality) ~= 7 then
        return true
    end
end

-- 获得球员获得方式
function BaseCardModel:GetTheWayOfGainTheCard()
    return CardAccess[self:GetCid()] and CardAccess[self:GetCid()].cardAccess
end

-- 返回该球员参加了化学反应的球员列表
function BaseCardModel:GetJoinedChemicalList()
    local chemicalPlayers = {}
    for k, v in pairs(PlayerChemical) do
        for _, playerInfo in pairs(v) do
            for __, playerCid in pairs(playerInfo.cids) do
                local cardData = Card[k]
                if self.staticData.ID == playerCid and cardData and tonumber(cardData.valid) == 1 then
                    -- 由于该球员可能参与某个球员多个化学反应，因此需记录一下化学反应的数据
                    local contents = {}
                    contents.cid = k
                    contents.chemicalData = playerInfo
                    table.insert(chemicalPlayers, contents)
                end
            end
        end
    end

    return chemicalPlayers
end

-- 返回该球员是哪些球员的联携球员列表
function BaseCardModel:GetJoinedCorrelationList()
    local correlationPlayers = {}
    for k, v in pairs(PlayerCorrelation) do
        if self.staticData.ID == v.correlationPlayer1 or self.staticData.ID == v.correlationPlayer2 then
            local car1State = Card[v.correlationPlayer1] and tonumber(Card[v.correlationPlayer1].valid)
            local car2State = Card[v.correlationPlayer2] and tonumber(Card[v.correlationPlayer2].valid)
            local car3State = Card[self.staticData.ID] and tonumber(Card[self.staticData.ID].valid)
            local car4State = Card[k] and tonumber(Card[k].valid)
            local contents = {}
            if car1State == 1 and car2State == 1 and car3State == 1 and car4State == 1 then
                contents.cid = k
                contents.chemicalData = {}
                contents.chemicalData.cids = {}
                table.insert(contents.chemicalData.cids, v.correlationPlayer1)
                table.insert(contents.chemicalData.cids, v.correlationPlayer2)
                table.insert(correlationPlayers, contents)
            end
        end
    end
    return correlationPlayers
end

-- 返回该球员是谁的最佳拍档的球员列表
function BaseCardModel:GetJoinedBestPartnerList()
    local bestPartners = {}
    for k, v in pairs(Card) do
        for _, skill in pairs(v.skill) do
            local skillData = Skills[skill]
            if skillData and skillData.type == 3 then
                if skillData.cardID2 == self.staticData.ID and tonumber(v.valid) == 1 then
                    table.insert(bestPartners, skillData.cardID)
                end
            end
        end
    end

    return bestPartners
end

function BaseCardModel:GetJoinedLetterList()
    local letterPlayers = {}
    for k, v in pairs(Letter) do
        letterPlayers[v.ID] = {}
        if v.finishCondition.card ~= nil then
            for _, cid in pairs(v.finishCondition.card) do
                if self.staticData.ID == cid then
                    local itemData = {}
                    -- 球员来信只奖励一名球员
                    itemData.rewardPlayer = v.contents.card[1].id
                    itemData.letterPlayer = v.finishCondition.card
                    letterPlayers[v.ID] = itemData
                end
            end
        end
    end

    return letterPlayers
end


function BaseCardModel:CheckIsMatchForSpecialEvents(specialEventsMatchId, position)
    self.specialEventsMatchId = specialEventsMatchId
    local SpecificMatchBase = require("data.SpecificMatchBase")
    local specificMatchBase = SpecificMatchBase[tostring(specialEventsMatchId)]

    local nationFlag = false
    local posFlag = false
    local skillFlag = false
    -- check if suggested by nation or by skill

    if type(specificMatchBase.nation) == "table" then
        for k, nation in pairs(specificMatchBase.nation) do
            if nation == self:GetNation() then
                nationFlag = true
                break
            end
        end
    end

    if not nationFlag then
        local cardPositions
        if position then
            cardPositions = { position }
        else
            cardPositions = {}
            local cardPositionLetters = self:GetPosition()
            for i, posLetter in pairs(cardPositionLetters) do
                local posNumbers = FormationConstants.PositionToNumber[posLetter]
                for j, posNumber in pairs(posNumbers) do
                    table.insert(cardPositions, tostring(posNumber))
                    cardPositions[#cardPositions + 1] = tostring(posNumber)
                end
            end
        end

        local cardSkills = self:GetSkills()

        for i = 1, 9 do
            posFlag = false
            skillFlag = false
            local matchLocations = specificMatchBase["player" .. tostring(i) .. "Location"]
            if type(matchLocations) ~= "table" then
                matchLocations = { tostring(matchLocations) }
            end
            local matchSkills = specificMatchBase["player" .. tostring(i) .. "Skill"]
            if type(matchSkills) ~= "table" then
                matchSkills = { tostring(matchSkills) }
            end

            for j, matchLocation in ipairs(matchLocations) do
                for k, cardPosition in ipairs(cardPositions) do
                    if matchLocation == cardPosition then
                        posFlag = true
                        break
                    end
                end
                if posFlag then
                    break
                end
            end

            if posFlag then
                for j, matchSkill in ipairs(matchSkills) do
                    for k, cardSkill in ipairs(cardSkills) do
                        if matchSkill == cardSkill.sid then
                            skillFlag = true
                            break
                        end
                    end
                    if skillFlag then
                        break
                    end
                end
            end
            if skillFlag then
                break
            end
        end
    end

    self.specialEventsNationMatch = nationFlag
    self.specialEventsSkillMatch = (posFlag and skillFlag)
end

function BaseCardModel:IsSuitForSpecialEvent()
    if self.specialEventsMatchId ~= nil then
        return self.specialEventsNationMatch or self.specialEventsSkillMatch
    end

    return false
end

function BaseCardModel:IsSuitForSpecialEventsNationMatch()
    if self.specialEventsNationMatch ~= nil then
        return self.specialEventsNationMatch
    end

    return false
end

function BaseCardModel:IsSuitForSpecialEventsSkillMatch()
    if self.specialEventsSkillMatch ~= nil then
        return self.specialEventsSkillMatch
    end

    return false
end

function BaseCardModel:CheckIsMatchForCompete(competeSpecialTeamData)
    local quality = self:GetCardQuality()
    local qualitySpecial = self:GetCardQualitySpecial()
    local cardSkills = self:GetSkills()
    local nation = self:GetNation()
    local skillRequest = competeSpecialTeamData.skillRequest
    local nationRequest = competeSpecialTeamData.nationRequest
    local playerQualityRequst = competeSpecialTeamData.playerQualityRequst
    local playerQualitySpecialRequst = competeSpecialTeamData.qualitySpecial
    local qualityFlag = false
    local skillFlag = false
    local nationFlag = false

    if type(skillRequest) == "table" then
        for i,rSkill in ipairs(skillRequest) do
            for j,cSkill in ipairs(cardSkills) do
                if rSkill == cSkill.sid then
                    skillFlag = true
                    break
                end
            end
        end
    else
        skillFlag = true
    end

    if type(nationRequest) == "table" then
        for i,rNation in ipairs(nationRequest) do
            if rNation == nation then
                nationFlag = true
                break
            end
        end
    else
        nationFlag = true
    end

    if playerQualityRequst ~= 0 then
        if playerQualityRequst == quality and playerQualitySpecialRequst == qualitySpecial then
            qualityFlag = true
        end
    else
        qualityFlag = true
    end
    self.competeMatch = qualityFlag and nationFlag and skillFlag
    return self.competeMatch
end

function BaseCardModel:IsSuitForCompete()
    return self.competeMatch
end

function BaseCardModel:GetSpecialEventDiscount()
    if self.specialEventsMatchId ~= nil and not self:IsSuitForSpecialEvent() then
        local SpecificMatchBase = require("data.SpecificMatchBase")
        local specificMatchBase = SpecificMatchBase[tostring(self.specialEventsMatchId)]
        return specificMatchBase.attenuation
    else
        return 0
    end
end

function BaseCardModel:GetMedalMaxPos()
    return CardQuality[tostring(self:GetCardQuality())].availableMedal or 0
end

-- 初始球员身上勋章数据
function BaseCardModel:InitMedalModel()
    local medalsData = self:GetMedals()
    self.medalsModelMap = {}
    for k, v in pairs(medalsData) do
        local pmid = v.pmid
        local model = CardMedalModel.new(pmid)
        model:InitWithCache(v)
        self.medalsModelMap[tostring(v.position)] = model
    end
end

-- 初始球员身上勋章数据
function BaseCardModel:InitFeatureModel()
    self.featuresModelMap = {}
    if self:HasCoachFeature() then
        local featuresData = self:GetCoachFeature()
        local effectAmount = self:GetCoachGuideEffectAmount()
        for i = 1, CoachItemType.SkillFeaturesNum do
            local slot = tostring(i)
            local featureSkillData = featuresData[slot]
            local sid = featureSkillData and featureSkillData.sid
            local model = CardFeatureModel.new(sid, slot, effectAmount)
            model:InitWithCache(featureSkillData)
            self.featuresModelMap[slot] = model
        end
    end
end

-- 球员特性当前球员身上技能的数量
function BaseCardModel:GetFeaturesCount()
    local count = 0
    local featuresData = self:GetCoachFeature()
    for k,v in pairs(featuresData) do
        count = count + 1
    end
    return count
end

-- 球员特性modelMap
function BaseCardModel:GetFeatureModelsMap()
    return self.featuresModelMap or {}
end

-- 球员特性model
function BaseCardModel:GetFeatureModel(slot)
    return self.featuresModelMap and self.featuresModelMap[tostring(slot)]
end

-- 获取球员特性技能数据
function BaseCardModel:GetCoachFeature()
    return {}
end

-- 特性是否开启
function BaseCardModel:IsCoachFeatureOpen()
    return false
end

-- 球员是否在特性栏
function BaseCardModel:HasCoachFeature()
    return false
end

-- 球员在特性栏的第几个栏位对应 CoachGuidePrice
function BaseCardModel:GetCoachGuideSlotId()
    return 0
end

-- 球员在特性栏对应栏位下最多有几个技能 对应CoachGuidePrice.effectAmount
function BaseCardModel:GetCoachGuideEffectAmount()
    return 0
end

-- 球员勋章
function BaseCardModel:GetMedalModels(position)
    return self.medalsModelMap
end

function BaseCardModel:GetPosMedalModel(pos)
    local medalsModelMap = self:GetMedalModels()
    return medalsModelMap[tostring(pos)]
end

function BaseCardModel:GetSkillsModel()
    local sortSkillModels = {}
    local medalModels = self:GetMedalModels()
    local tempSkills = {}
    for k, v in pairs(medalModels) do
        local skillData = v:GetSkill()
        local sid, lvl = next(skillData)
        if sid then
            local data = {}
            data.sid = sid
            data.lvl = lvl
            data.isOpen = true
            if tempSkills[tostring(sid)] then
                data.lvl = tonumber(tempSkills[tostring(sid)].lvl) + tonumber(lvl)
            end
            tempSkills[tostring(sid)] = data
        end
    end

    for k, v in pairs(tempSkills) do
        local skillItemModel = SkillItemModel.new()
        skillItemModel:InitWithCache(v, k)
        skillItemModel:SetCoachMainModel(self:GetCoachMainModel())
        skillItemModel:SetLegendRoadLvl(self:GetLegendSkillLvl(k))
        skillItemModel:SetHomeCourtLvl(self:GetHomeCourtSkillLvl(k, v.sid))
        skillItemModel:SetFancyLvl(self:GetFancySkillLvl(k))
        skillItemModel:SetSupportLvl(self:GetSupportSkillLvl(k))
        table.insert(sortSkillModels, skillItemModel)
    end

    return sortSkillModels
end

function BaseCardModel:GetBenedictionsModel()
    local sortBenedictionModels = {}
    local medalModels = self:GetMedalModels()
    local tempBenedictions = {}
    for k, v in pairs(medalModels) do
        local skillData = v:GetBenediction()
        local sid, lvl = next(skillData)
        if sid then
            local data = {}
            data.sid = sid
            data.lvl = lvl
            data.isOpen = true
            if tempBenedictions[tostring(sid)] then
                data.lvl = tonumber(tempBenedictions[tostring(sid)].lvl) + tonumber(lvl)
            end
            tempBenedictions[tostring(sid)] = data
        end
    end

    for k, v in pairs(tempBenedictions) do
        local medalSkillModel = MedalSkillModel.new()
        medalSkillModel:InitWithCache(v, k)
        table.insert(sortBenedictionModels, medalSkillModel)
    end

    return sortBenedictionModels
end

function BaseCardModel:GetMedalAttrPlus()
    local attrPlus = {}
    local medalModels = self:GetMedalModels()
    for k, v in pairs(medalModels) do
        local attrData = v:GetBaseAttr()
        for abilityIndex, plus in pairs(attrData) do
            if attrPlus[abilityIndex] then
                attrPlus[abilityIndex] = tonumber(attrPlus[abilityIndex]) + tonumber(plus)
            else
                attrPlus[abilityIndex] = tonumber(plus)
            end
        end
    end
    return attrPlus
end

function BaseCardModel:GetMedalCombine()
    local combine = { ['baseAttribute'] = {}, ['extraAttribute'] = {}, ['skill'] = {}, ['bless'] = {}}
    local medalsData = self:GetMedals()
    for k, v in pairs(medalsData) do
        local baseAttribute = v.baseAttribute or {}
        for abilityIndex, plus in pairs(baseAttribute) do
            if combine.baseAttribute[abilityIndex] then
                combine.baseAttribute[abilityIndex] = tonumber(combine.baseAttribute[abilityIndex]) + tonumber(plus)
            else
                combine.baseAttribute[abilityIndex] = tonumber(plus)
            end
        end

        local extraAttribute  = v.extraAttribute  or {}
        for abilityIndex, plus in pairs(extraAttribute ) do
            if combine.extraAttribute [abilityIndex] then
                combine.extraAttribute [abilityIndex] = tonumber(combine.extraAttribute[abilityIndex]) + tonumber(plus)
            else
                combine.extraAttribute [abilityIndex] = tonumber(plus)
            end
        end

        local skill = v.skill or {}
        for sid, lvl in pairs(skill) do
            local data = {}
            data.sid = sid
            data.lvl = tonumber(lvl)
            if combine.skill[tostring(sid)] then
                data.lvl = combine.skill[tostring(sid)].lvl + data.lvl
            end
            combine.skill[tostring(sid)] = data
        end

        local bless = v.bless or {}
        for sid, lvl in pairs(bless) do
            local data = {}
            data.sid = sid
            data.lvl = tonumber(lvl)
            if combine.bless[tostring(sid)] then
                data.lvl = combine.bless[tostring(sid)].lvl + data.lvl
            end
            combine.bless[tostring(sid)] = data
        end
    end
    return combine
end

-- 球员是否有球员特训功能
-- B及B品质以上均可以
function BaseCardModel:CanTrainingBase()
    return self:GetCardQuality() >= CommonConstants.SilverID
end

function BaseCardModel:GetTrainingBaseData()
    return self.cacheData.trainingBase or {}
end

-- 球员特训当前完成阶段
function BaseCardModel:GetTrainingBase()
    local chapter = 0
    local stage = 0
    if self.cacheData.trainingBase ~= nil then
        chapter = tonumber(self.cacheData.trainingBase.chapter or 0)
        stage = tonumber(self.cacheData.trainingBase.stage or 0)
        if chapter < 0 then chapter = 0 end
        if stage < 0 then stage = 0 end
    end
    return chapter * 1000 + stage, chapter, stage
end

function BaseCardModel:GetCoachMainModel()
    return nil
end

-- 根据球员单个技能字段及技能配置，判断是否计算该技能的【五维属性】
-- @return [isCompeteSkill]: 是否计算技能
-- @return [skillTable]: 该技能的配置
function BaseCardModel:IsComputeSkillAttrAux(skill)
    local isComputeSkill = true
    local skillTable = nil
    if skill.isOpen and skill.lvl >= 1 then
        if skill.ptid then -- 贴纸带来的技能
            -- 月贴技能唯一生效skillValid == 1
            -- 月贴技能不与球员自身技能冲突
            isComputeSkill = (skill.skillValid == 1 and skill.skillConflict ~= 1)
        end
        if isComputeSkill then
            skillTable = Skills[skill.exSid or tostring(skill.sid)]
        end
        if isComputeSkill and skillTable ~= nil then
            if skillTable.type == SkillType.EVENT then
                -- 过滤事件技能
                isComputeSkill = false
            elseif skillTable.type == SkillType.ATTRIBUTE then
                isComputeSkill = true
            elseif skillTable.type == SkillType.CHEMICAL then
                -- 最佳拍档类技能在同一个阵型中生效
                isComputeSkill = self:IsChemicalSkillValid(skillTable.cardID, skillTable.cardID2)
            elseif skillTable.type == SkillType.TRAINING then
                if skillTable.skillType == SkillType.ATTRIBUTE then
                    -- 特训技能带来的最佳拍档技能，根据skillType，直接计算属性，无需最佳拍档在场
                    isComputeSkill = true
                elseif skillTable.skillType == SkillType.CHEMICAL then
                    -- 特训技能带来的最佳拍档技能，根据skillType，需最佳拍档在场
                    local chemicalSkillTable = Skills[tostring(skill.sid)] -- 通过sid获得最佳拍档配置
                    isComputeSkill = self:IsChemicalSkillValid(chemicalSkillTable.cardID, chemicalSkillTable.cardID2)
                else
                    isComputeSkill = false
                end
            else
                isComputeSkill = false
            end
        else
            isComputeSkill = false
        end
    else
        isComputeSkill = false
    end
    return isComputeSkill, skillTable
end

-- 根据球员单个技能字段及技能配置，判断是否计算该技能的【百分比加成】
-- @return [isCompeteSkill]: 是否计算技能
-- @return [skillTable]: 该技能的配置
function BaseCardModel:IsComputeSkillPercentAux(skill)
    local isComputeSkill = true
    local skillTable = nil
    if skill.isOpen and skill.lvl >= 1 then
        if skill.ptid then -- 贴纸带来的技能
            isComputeSkill = (skill.skillValid == 1 and skill.skillConflict ~= 1)
        end
        if isComputeSkill then
            skillTable = Skills[skill.exSid or tostring(skill.sid)]
        end
        if isComputeSkill and skillTable ~= nil then
            -- 事件技能或特训技能增加百分比
            isComputeSkill = (skillTable.type == SkillType.EVENT or skillTable.type == SkillType.TRAINING)
        else
            isComputeSkill = false
        end
    else
        isComputeSkill = false
    end
    return isComputeSkill, skillTable
end

function BaseCardModel:InitMemoryData()
    self.canMemory = nil
    self.memoryModels = {}
end

-- 当前卡牌是否有传奇记忆功能
function BaseCardModel:CanMemory()
    if self.canMemory == nil then -- 此变量通过静态配置生成，计算一次存储
        local hasMemoryData = not table.isEmpty(self:GetMemoryData())
        local hasConfig = false
        if not hasMemoryData then
            local baseId = self:GetBaseID()
            local currQualityNum = self:GetCardFixQualityNum()
            for qualitySuffix, v in pairs(CardHelper.ConfigQuality) do
                local cid = baseId .. tostring(qualitySuffix)
                local cardConfig = Card[cid]
                if cardConfig and tonumber(cardConfig.valid) == 1 then -- 有相关卡牌且投放
                    local qualityNum = CardHelper.GetCardFixQualityNum(cardConfig.quality, cardConfig.qualitySpecial)
                    local qualityFixed = CardHelper.GetQualityFixed(cardConfig.quality, cardConfig.qualitySpecial)
                    -- 品质较低且考虑华为特殊卡品质
                    if qualityNum < currQualityNum and (qualityFixed ~= CardHelper.HWSpecialFixedCardQuality or cache.getIsContainHWCard()) then
                        hasConfig = true
                        break
                    end
                end
            end
        end
        self.canMemory = hasMemoryData or hasConfig
    end
    return self.canMemory
end

-- 传奇记忆功能是否开启
function BaseCardModel:IsMemoryOpen()
    return self:CanMemory() and self:GetUpgrade() >= self:GetMaxUpgradeNum() -- 进阶满级开启传奇记忆功能且有相关低品质卡牌
end

-- 获得存储的传奇记忆相关联卡牌数据
-- memory = { qualityConfig = pcid }
function BaseCardModel:GetMemoryData()
    return self.cacheData.memory or {}
end

-- 被那个球员添加到了球员记忆里
-- memoryParent = { pcid = pcid }
function BaseCardModel:GetMemoryParent()
    return self.cacheData.memoryParent
end

-- 获得传奇记忆相关联的memoryModel
-- @param needRefresh [boolean]: force to refresh
function BaseCardModel:GetMemoryItemModels(needRefresh)
    if table.isEmpty(self.memoryModels) or (needRefresh or false) then
        self.memoryModels = {}
        local memory = self:GetMemoryData()
        local baseId = self:GetBaseID()
        local currQualityNum = self:GetCardFixQualityNum()
        for qualitySuffix, v in pairs(CardHelper.ConfigQuality) do
            local cid = baseId .. tostring(qualitySuffix)
            local cardConfig = Card[cid]
            if cardConfig and tonumber(cardConfig.valid) == 1 then -- 有相关卡牌且投放
                local qualityNum = CardHelper.GetCardFixQualityNum(cardConfig.quality, cardConfig.qualitySpecial)
                local qualityFixed = CardHelper.GetQualityFixed(cardConfig.quality, cardConfig.qualitySpecial)
                -- 品质较低且考虑华为特殊卡品质
                if qualityNum < currQualityNum and (qualityFixed ~= CardHelper.HWSpecialFixedCardQuality or cache.getIsContainHWCard()) then
                    local qualityKey = CardHelper.GetQualityConfigFixed(cardConfig.quality, cardConfig.qualitySpecial)
                    local pcid = memory[qualityKey] -- 当前槽位添加的卡牌
                    local filledCard = nil
                    if pcid then
                        filledCard = require("ui.models.cardDetail.PlayerCardModel").new(pcid)
                    end
                    local memoryItemModel = MemoryItemModel.new(self, cardConfig.quality, cardConfig.qualitySpecial, filledCard)
                    table.insert(self.memoryModels, memoryItemModel)
                end
            end
        end
        table.sort(self.memoryModels, function(a, b)
            return tonumber(a:GetQualityFixedNum()) > tonumber(b:GetQualityFixedNum())
        end)
    end
    return self.memoryModels
end

function BaseCardModel:HasPasterSKillExAvailable()
    return false
end

function BaseCardModel:GetLegendSkillImprove()
    local skillImprove = {}
    return skillImprove
end

function BaseCardModel:GetLegendCardImprove()
    local cardImprove = {}
    return cardImprove
end

-- 是否有传奇之路配置
function BaseCardModel:HasLegendRoad()
    return tobool(LegendRoadPlayer[self:GetBaseID()] ~= nil)
end

-- 是否开启球员助阵
function BaseCardModel:CanUseSupporter()
    return false
end

local LegendRoadQualityCondition = 6 -- 传奇之路要求ss以上才开启
--判断传奇之路是否开启
function BaseCardModel:IsOpenLegendRoad()
    if not self:HasLegendRoad() then
        return false
    end
    if self:GetAscend() < self:GetMaxAscendNum() then
        return false
    end
    return self:GetCardQuality() >= LegendRoadQualityCondition
end

--判断此卡的传奇之路进度是否可用于当前被助阵的卡牌
function BaseCardModel:LegendRoadIsCanSupporting()
    local cid = self:GetCid()
    local pcid = self:GetPcid()
    local cardsMap = self:GetCardsMap()
    for k, v in pairs(cardsMap) do
        --有助阵卡并且传奇之路使用了助阵卡
        if v.spcid ~= nil and v.spcid ~= 0 and v.spcid ~= pcid and v.slrType == SupporterType.SlrType.SupportCard then
            local cardData = cardsMap[tostring(v.spcid)]
            --并且助阵卡与本卡cid相同 并且使用了助阵卡的传奇之路进度
            if cardData.cid == cid then
                return false
            end
        end
    end
    return true
end

return BaseCardModel

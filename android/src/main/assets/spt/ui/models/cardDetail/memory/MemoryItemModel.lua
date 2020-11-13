local CardHelper = require("ui.scene.cardDetail.CardHelper")
local AdditionType = require("ui.models.cardDetail.memory.CardMemoryAdditionType")
local CardMemory = require("data.CardMemory")
local Model = require("ui.models.Model")
local CardMemoryImproveModel = require("ui.models.cardDetail.memory.CardMemoryImproveModel")

local MemoryItemModel = class(Model, "MemoryItemModel")

MemoryItemModel.Icon_Upgrade_Active = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Memory/CardDetail_Memory_Logo_Upgrade_1.png"
MemoryItemModel.Icon_Upgrade_inactive = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Memory/CardDetail_Memory_Logo_Upgrade_2.png"

MemoryItemModel.Icon_Ascend_Active = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Memory/CardDetail_Memory_Logo_Ascend_1.png"
MemoryItemModel.Icon_Ascend_inactive = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Memory/CardDetail_Memory_Logo_Ascend_2.png"

MemoryItemModel.Icon_TrainingBase_Active = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Memory/CardDetail_Memory_Logo_TrainingBase_1.png"
MemoryItemModel.Icon_TrainingBase_inactive = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Memory/CardDetail_Memory_Logo_TrainingBase_2.png"

function MemoryItemModel:ctor(targetCard, quality, qualitySpecial, filledCard, isOther)
    self.targetCard = targetCard -- 当前大卡的model
    self.quality = tonumber(quality)
    self.qualitySpecial = tonumber(qualitySpecial)
    self.qualityFixed = CardHelper.GetQualityFixed(self.quality, self.qualitySpecial)
    self.qualityKey = CardHelper.GetQualityConfigFixed(self.quality, self.qualitySpecial)
    self.qualityNum = CardHelper.GetCardFixQualityNum(self.quality, self.qualitySpecial)
    self.qualityStr = lang.transstr(CardHelper.QualitySign[CardHelper.ConfigQuality[self.qualityKey]])
    self.filledCard = filledCard -- 当前槽位添加的球员的cardModel
    if isOther == nil then
        self.isOther = false
    else
        self.isOther = isOther
    end

    self.isFilledCard = (self.filledCard ~= nil)
    self.tab = AdditionType.Upgrade -- 默认选择进阶tab
    self.tabData = nil
    self.iconRes = nil
    self.hasImprove = true -- 判断玩家身上所有该cid球员是否有带来属性加成的

    self.data = nil

    MemoryItemModel.super.ctor(self)
end

function MemoryItemModel:Init()
    self.data = {}
    self.tabData = {}
    self.iconRes = {}

    self:InitFilledCard()
    self:InitCurrCardData()
    self:ParseConfig()

    if not self.isFilledCard then
        local cardMemoryImproveModel = CardMemoryImproveModel.new()
        self.hasImprove = cardMemoryImproveModel:HasImprove(self:GetFillableCid())
    end
end

-- 完善filledCard
function MemoryItemModel:InitFilledCard()
    if not self.filledCard then -- 如果没有填充卡牌，则使用StaticCardModel初始化一个静态的进行显示
        self.filledCard = require("ui.models.cardDetail.StaticCardModel").new(self:GetFillableCid())
    end
end

-- 初始化当前填充卡牌的进阶、转生、特训的状态，并为self.data初始化显示的类别
function MemoryItemModel:InitCurrCardData()
    self.currCardData = {}
    -- 一定可以进阶
    self.data[AdditionType.Upgrade] = {}
    self.currCardData[AdditionType.Upgrade] = self:GetFilledCardUpgrade()
    self.tabData[AdditionType.Upgrade] = true
    self.iconRes[AdditionType.Upgrade] = {}
    self.iconRes[AdditionType.Upgrade]["active"] = res.LoadRes(self.Icon_Upgrade_Active)
    self.iconRes[AdditionType.Upgrade]["inactive"] = res.LoadRes(self.Icon_Upgrade_inactive)
    -- 是否可以转生
    if self:CanFilledCardAscend() then
        self.data[AdditionType.Ascend] = {}
        self.currCardData[AdditionType.Ascend] = self:GetFilledCardAscend()
        self.tabData[AdditionType.Ascend] = true
        self.iconRes[AdditionType.Ascend] = {}
        self.iconRes[AdditionType.Ascend]["active"] = res.LoadRes(self.Icon_Ascend_Active)
        self.iconRes[AdditionType.Ascend]["inactive"] = res.LoadRes(self.Icon_Ascend_inactive)
    else
        self.tabData[AdditionType.Ascend] = false
    end
    -- 是否可以特训
    if self:CanFilledCardTrainingBase() then
        self.data[AdditionType.TrainingBase] = {}
        self.currCardData[AdditionType.TrainingBase] = self:GetFilledCardTrainingBase()
        self.tabData[AdditionType.TrainingBase] = true
        self.iconRes[AdditionType.TrainingBase] = {}
        self.iconRes[AdditionType.TrainingBase]["active"] = res.LoadRes(self.Icon_TrainingBase_Active)
        self.iconRes[AdditionType.TrainingBase]["inactive"] = res.LoadRes(self.Icon_TrainingBase_inactive)
    else
        self.tabData[AdditionType.TrainingBase] = false
    end
end

-- 解析配置
function MemoryItemModel:ParseConfig()
    if table.isEmpty(self.data) or table.isEmpty(self.currCardData) then return end

    for additionType, v in pairs(self.data) do
        local currTypeConfigs = CardMemory[additionType][self.qualityKey] or {}
        for typeDetail, config in pairs(currTypeConfigs) do
            if config.isShow == 1 then
                local tempConfig = clone(config)
                tempConfig.isActive = self.currCardData[additionType] >= tempConfig.typeDetail
                tempConfig.cardName = self:GetCardName()
                tempConfig.qualityStr = self.qualityStr
                tempConfig.iconRes = self.iconRes[additionType] or {}
                table.insert(self.data[additionType], tempConfig)
            end
        end
        table.sort(self.data[additionType], function(a, b)
            return tonumber(a.typeDetail) < tonumber(b.typeDetail)
        end)
        for k, v in ipairs(self.data[additionType]) do
            v.idx = tonumber(k)
        end
    end
end

-- 获得filledCard进阶情况
function MemoryItemModel:GetFilledCardUpgrade()
    return self.filledCard ~= nil and self.filledCard:GetUpgrade() or 0
end

-- 获得filledCard转生情况
function MemoryItemModel:CanFilledCardAscend()
    return self.filledCard ~= nil and self.filledCard:CanAscend() or false
end

function MemoryItemModel:GetFilledCardAscend()
    return self.filledCard ~= nil and self.filledCard:GetAscend() or 0
end

-- 获得filledCard特训情况
function MemoryItemModel:CanFilledCardTrainingBase()
    return self.filledCard ~= nil and self.filledCard:CanTrainingBase() or false
end

function MemoryItemModel:GetFilledCardTrainingBase()
    local key, chapter, stage
    if self.filledCard ~= nil then
        key, chapter, stage = self.filledCard:GetTrainingBase()
    end
    return chapter or 0
end

-- 是否是otherCard模式
function MemoryItemModel:IsOther()
    return self.isOther
end

-- 获得添加的卡牌model
function MemoryItemModel:GetFilledCard()
    return self.filledCard
end

-- 是否添加卡牌
function MemoryItemModel:IsFilledCard()
    return self.isFilledCard
end

-- 获得tab显示数据
function MemoryItemModel:GetTabData()
    return self.tabData
end

-- 获得当前tab
function MemoryItemModel:GetCurrTab()
    return self.tab
end

-- 设置tab
function MemoryItemModel:SetCurrTab(tab)
    self.tab = tab
end

-- 获得当前tab下的数据
function MemoryItemModel:GetCurrTabDatas()
    return self.data[self:GetCurrTab()] or {}
end

-- 获得可添加的修正后品质
function MemoryItemModel:GetQualityFixed()
    return self.qualityFixed
end

-- 获得品质映射数值，排序
function MemoryItemModel:GetQualityFixedNum()
    return self.qualityNum
end

-- 获得可添加的品质的文本表示
function MemoryItemModel:GetQualityStr()
    return self.qualityStr
end

-- 获得可添加的卡牌的cid
function MemoryItemModel:GetFillableCid()
    return tostring(self.targetCard:GetBaseID()) .. self.qualityKey
end

-- 获得被加成的卡牌model
function MemoryItemModel:GetTargetCardModel()
    return self.targetCard
end

-- 获得被加成的卡牌名称
function MemoryItemModel:GetCardName()
    return self.targetCard:GetName()
end

-- 是否存在该cid卡牌
function MemoryItemModel:IsExistCardID()
    local cardsMapModel = self.targetCard:GetCardsMapModel()
    local cid = self:GetFillableCid()
    return cardsMapModel:IsExistCardID(cid)
end

-- 所有该品质的卡牌是否可以带来属性加成
function MemoryItemModel:HasImprove()
    return self.hasImprove
end

return MemoryItemModel

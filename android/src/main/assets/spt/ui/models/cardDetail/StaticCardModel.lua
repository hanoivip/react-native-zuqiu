local Card = require("data.Card")
local CardLevel = require("data.CardLevel")
local Grid = require("data.Grid")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local SkillItemModel = require("ui.models.common.SkillItemModel")
local CardOwnershipType = require("ui.controllers.cardDetail.CardOwnershipType")
local BaseCardModel = require("ui.models.cardDetail.BaseCardModel")
local CardAppendPasterModel = require("ui.models.cardDetail.CardAppendPasterModel")
local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local Paster = require("data.Paster")
local StaticCardModel = class(BaseCardModel, "StaticCardModel")
-- 静态数据model, 不属于玩家与阵型
function StaticCardModel:ctor(cid, playerCardsMapModel)
    StaticCardModel.super.ctor(self)
    self.cid = cid
    self:InitWithCache(cid)
    self.playerCardsMapModel = playerCardsMapModel or PlayerCardsMapModel.new()
    self:InitCardsMap(self.playerCardsMapModel)
    self.ownershipType = CardOwnershipType.NONE
end

function StaticCardModel:InitCardsMap(playerCardsMapModel)
    self.cardsMap = playerCardsMapModel.data
end

function StaticCardModel:InitWithCache(cid)
    self.staticData = Card[tostring(cid)]
end

-- 等级
function StaticCardModel:GetLevel()
    return 1
end

-- 球员特训
function StaticCardModel:GetTrainingLevel()
    return nil
end

-- 转生
function StaticCardModel:GetAscend()
    return 0
end

function StaticCardModel:IsLevelMaxState()
    return false
end

-- 是否开启培养功能
function StaticCardModel:IsTrainOpen()
    return false
end

-- 是否开启转生功能(紫色及以上品质的球员卡达到max后)
function StaticCardModel:IsRebornOpen()
    return false
end

-- 进阶
function StaticCardModel:GetUpgrade()
    return 0
end

function StaticCardModel:IsCanUpgrade()
    return false
end

function StaticCardModel:HasPasterAvailable()
    return false
end

function StaticCardModel:SetIsPasterPokedex(state)
    self.isPasterPokedex = state
end

function StaticCardModel:GetIsPasterPokedex()
    return self.isPasterPokedex
end

-- 重写初始球员身上贴纸数据
function StaticCardModel:InitPasterModel()
    if not self.cardPastersMapModel then
        self.cardPastersMapModel = CardPastersMapModel.new()
    end
    self.cardPastersModelMap = {}
    for k, v in pairs(Paster) do
        if v.cardID and #v.cardID > 0 then
            for k2,v2 in pairs(v.cardID) do
                if self:GetCid() == v2 then
                    local model = CardAppendPasterModel.new()
                    local isHave = false
                    for k3,v3 in pairs(self.cardPastersMapModel:GetPasterMap()) do
                        if v3.ptcid == k then
                            isHave = true
                            break
                        end
                    end
                    isHave = isHave or self.playerCardsMapModel:IsExistPasterID(self:GetCid(), k)
                    model:InitWithCache({ptid = nil, ["type"] = v.type, pcid = nil, ptcid = k, isHave = isHave}, {}, self:GetIsPasterPokedex())
                    table.insert(self.cardPastersModelMap, model)
                end
            end
        end
    end
    self:SortPasterList(self.cardPastersModelMap)
end

-- 使用十个维度的属性相加
function StaticCardModel:GetPower()
    if not self:IsGKPlayer() then
        return self.staticData.pass 
        + self.staticData.dribble 
        + self.staticData.shoot 
        + self.staticData.intercept 
        + self.staticData.steal 
    else
        return self.staticData.goalkeeping
        + self.staticData.anticipation
        + self.staticData.commanding
        + self.staticData.composure
        + self.staticData.launching
    end
end

function StaticCardModel:GetAbility(index)
    return self.staticData[tostring(index)], 0, 0, self.staticData[tostring(index)]
end

function StaticCardModel:GetPass()
    return self.staticData.pass, 0, 0
end

function StaticCardModel:GetDribble()
    return self.staticData.dribble, 0, 0
end

function StaticCardModel:GetShoot()
    return self.staticData.shoot, 0, 0
end

function StaticCardModel:GetIntercept()
    return self.staticData.intercept, 0, 0
end

function StaticCardModel:GetSteal()
    return self.staticData.steal, 0, 0
end

function StaticCardModel:GetSave()
    return self.staticData.save, 0, 0
end

function StaticCardModel:GetSkills()
    local skills = { }
    for i, v in ipairs(self.staticData.skill) do
        table.insert(skills, { sid = v })
    end
    return skills
end

function StaticCardModel:GetMaxSkillLevel(ascend)
    return 1
end

function StaticCardModel:GetSkillAmount()
    local skills = self:GetSkills()
    return #skills
end
-- 已经激活的技能数量
function StaticCardModel:GetActivatedSkillAmount()
    local ret = 0
    return ret
end

function StaticCardModel:GetSkillItemModelBySlot(slot)
    local skillItemModel = SkillItemModel.new()
    skillItemModel:InitByID(self.staticData.skill[slot])
    return skillItemModel
end

function StaticCardModel:GetEquips()
    return self.staticData.equipBase["1"]
end

-- 即将穿上的装备给球员增加的属性
-- 返回一个table
function StaticCardModel:GetEquipAbilityPlus(slot)
    local equips = self:GetEquips()
    if equips then 
        for i, equip in ipairs(equips) do
            if tostring(equip.slot) == tostring(slot) then
                local gridIDArray = self.staticData.grid -- array
                local gridID = gridIDArray[equip.slot + 1]
                local gridTable = Grid[tostring(gridID)]
                return gridTable["upgrade" .. tostring(self:GetUpgrade())]
            end
        end
    end

    return {}
end

-- 球员经验
function StaticCardModel:GetExp()
    return 0
end

-- 总共累计多少经验可以达到下一等级
function StaticCardModel:GetLevelUpExpLimit()
    return CardLevel[tostring(self.GetLevel() + 1)].cumCardExp
end

-- 身价
function StaticCardModel:GetValue()
    return self.staticData.price
end

-- 技能点
function StaticCardModel:GetSkillPoint()
    return 0
end

function StaticCardModel:GetAdvancePotential(index)
    return 0
end

function StaticCardModel:IsChemicalSkillActivate()
    return false
end

-- 化学反应中球员额外加成
-- 额外数值加成(取养成度最高的计算)
-- 每进阶一次，全属性额外+3
-- 每转生一次，全属性额外+6
function StaticCardModel:GetChemicalPlayersAddValue(cid)
    local sameCardList = self.playerCardsMapModel:GetSameCardList(cid)
    local maxPlus = 0
    local maxPcid = next(sameCardList)
    for pcid, v in pairs(sameCardList) do
        local tmpCardData = self.playerCardsMapModel:GetCardData(pcid)
        local thisCardPlus = tmpCardData.upgrade * 3 + tmpCardData.ascend * 6
        if thisCardPlus > maxPlus then
            maxPlus = thisCardPlus
            maxPcid = pcid
        end
    end
    return maxPlus, maxPcid
end

function StaticCardModel:RefreshCardData(cid)
    self:InitWithCache(cid)
end

return StaticCardModel

local Model = require("ui.models.Model")
local EventSystem = require("EventSystem")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local CoachItemBaseModel = require("ui.models.coach.common.CoachItemBaseModel")
local PlayerTalentSkillBookModel = require("ui.models.coach.common.CoachPlayerTalentSkillBookModel")
local PlayerTalentFuncItemModel = require("ui.models.coach.common.CoachPlayerTalentFuncItemModel")
local TacticItemModel = require("ui.models.coach.common.CoachTacticItemModel")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local CoachItem = require("data.CoachItem") -- id映射type
local PlayerTalentSkillBook = require("data.PlayerTalentSkillBook")
local PlayerTalentFunctionalityItem = require("data.PlayerTalentFunctionalityItem")
local CoachTacticsItem = require("data.CoachTacticsItem")
local AssistantCoachInformation = require("data.AssistantCoachInformation")
local AssistCoachInfoModel = require("ui.models.coach.common.AssistCoachInfoModel")

local CoachItemMapModel = class(Model, "CoachItemMapModel")

-- 登录时发送的cti，原指阵型/战术道具，现包括所有教练道具
function CoachItemMapModel:ctor(coachItem)
    self.coachItem = {} -- 所有道具
    self.playerTalentSkillBook = {} -- 特性书
    self.playerTalentFuncItem = {} -- 特性道具
    self.coachTacticItem = {} -- 阵型/战术升级道具
    self.assistCoachInfo = {} -- 助教情报

    if coachItem ~= nil then
        cache.setCoachItems(coachItem)
    end

    CoachItemMapModel.super.ctor(self)
end

function CoachItemMapModel:InitWithProtocol(coachItem)
    if coachItem ~= nil then
        cache.setCoachItems(coachItem)
    end
end

-- @param coachItem 教练所有道具
function CoachItemMapModel:Init(coachItem)
    CoachItemMapModel.super.Init(self)
    if coachItem then
        self.coachItem = coachItem
    else
        self.coachItem = cache.getCoachItems() or {}
    end

    for id, num in pairs(self.coachItem) do
        id = tostring(id)
        local coachItemType = self:GetCoachItemType(id)
        if coachItemType == CoachItemType.PlayerTalentSkillBook then -- 特性书
            self.playerTalentSkillBook[id] = num
        elseif coachItemType == CoachItemType.PlayerTalentFunctionalityItem then -- 特性道具
            self.playerTalentFuncItem[id] = num
        elseif coachItemType == CoachItemType.CoachTacticsItem then -- 阵型/战术道具
            self.coachTacticItem[id] = num
        elseif coachItemType == CoachItemType.AssistCoachInfo then -- 阵型/战术道具
            self.assistCoachInfo[id] = num
        else
            -- dump("wrong coach item config type!")
        end
    end
end

-- 更新缓存
function CoachItemMapModel:UpdateCoachItemCache()
    cache.setCoachItems(self.coachItem)
end

-- 根据id，获得教练道具的model
function CoachItemMapModel:GetCoachItemModelById(id)
    local id = tostring(id)
    local coachItemType = self:GetCoachItemType(id)
    local coachItemModel = CoachItemBaseModel.new()
    if coachItemType == CoachItemType.PlayerTalentSkillBook then -- 特性书
        coachItemModel = self:GetPlayerTalentSkillBookModel(id)
    elseif coachItemType == CoachItemType.PlayerTalentFunctionalityItem then -- 特性道具
        coachItemModel = self:GetPlayerTalentFuncItemModel(id)
    elseif coachItemType == CoachItemType.CoachTacticsItem then -- 阵型/战术道具
        coachItemModel = self:GetTacticItemModel(id)
    elseif coachItemType == CoachItemType.AssistCoachInfo then -- 助教情报
        coachItemModel = self:GetAssistCoachInfoModel(id)
    else
        -- dump("wrong coach item config type!")
    end
    return coachItemModel
end

-- 从奖励中更新物品，格式固定
-- @param[rewards]: contents或者gifts
-- id对应CoachTacticsItem表
-- num表示当前数目
-- add/reduce表示增/减
function CoachItemMapModel:UpdateCoachItemFromRewards(rewards)
    -- cti原指阵型/战术道具，现指所有道具
    for k, coachItem in ipairs(rewards.cti or {}) do
        local id = tostring(coachItem.id)
        local coachItemType = self:GetCoachItemType(id)
        if coachItemType == CoachItemType.PlayerTalentSkillBook then -- 特性书
            self:UpdatePlayerTalentSkillBookFromReward(coachItem)
        elseif coachItemType == CoachItemType.PlayerTalentFunctionalityItem then -- 特性道具
            self:UpdatePlayerTalentFuncItemFromReward(coachItem)
        elseif coachItemType == CoachItemType.CoachTacticsItem then -- 阵型/战术道具
            self:UpdateTacticItemFromReward(coachItem)
        elseif coachItemType == CoachItemType.AssistCoachInfo then -- 助教情报
            self:UpdateAssistCoachInfoFromReward(coachItem)
        else
            -- dump("wrong coach item config type!")
        end
    end
    self:UpdateCoachItemCache()
end

-- 根据id，获得教练物品类型
function CoachItemMapModel:GetCoachItemType(id)
    if CoachItem[tostring(id)] then
        return tonumber(CoachItem[tostring(id)].type)
    else
        -- dump(id .. " in CoachItem err")
    end
end

function CoachItemMapModel:GetCoachItemNum(id)
    return tonumber(self.coachItem[tostring(id)])
end

-- 获得物品显示的prefab路径
function CoachItemMapModel:GetItemBoxPrefabPath(id)
    local coachItemType = self:GetCoachItemType(id)
    return self:GetItemBoxPrefabPathByType(coachItemType)
end

function CoachItemMapModel:GetItemBoxPrefabPathByType(coachItemType)
    if coachItemType == CoachItemType.PlayerTalentSkillBook then -- 特性书
        return "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/PlayerTalentSkillBookItem/CoachSkillBookBox.prefab"
    elseif coachItemType == CoachItemType.PlayerTalentFunctionalityItem then -- 特性道具
        return "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/TacticItem/CoachItemBox.prefab"
    elseif coachItemType == CoachItemType.CoachTacticsItem then -- 阵型/战术道具
        return "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/TacticItem/CoachItemBox.prefab"
    elseif coachItemType == CoachItemType.AssistCoachInfo then -- 助教情报
        return "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/AssistCoachInfo/AssistCoachInfoBox.prefab"
    else
        -- dump("wrong coach item config type!")
        return ""
    end
end

----------------------------------
-- 特性书，PlayerTalentSkillBook --
----------------------------------

-- 获得所有特性书物品的table
-- { id = num , ... }
function CoachItemMapModel:GetAllPlayerTalentSkillBook()
    return self.playerTalentSkillBook
end

-- 获得所有特性书的model table
-- { id = {model} , ... }
function CoachItemMapModel:GetAllPlayerTalentSkillBookModels()
    local itemModelList = {}
    for id, num in pairs(self.playerTalentSkillBook or {}) do
        if num > 0 then
            local aModel = self:GetPlayerTalentSkillBookModel(id)
            itemModelList[id] = aModel
        end
    end
    return itemModelList
end

-- 获得特性书的数量
function CoachItemMapModel:GetPlayerTalentSkillBook(id)
    return tonumber(self.playerTalentSkillBook[tostring(id)]) or 0
end

-- 增加特性书的数量
function CoachItemMapModel:AddPlayerTalentSkillBook(id, num)
    num = tonumber(num)
    num = math.clamp(num, 0, num)
    self:SetPlayerTalentSkillBook(id, self:GetPlayerTalentSkillBook(id) + tonumber(num))
end

-- 减少特性书的数量
function CoachItemMapModel:ReducePlayerTalentSkillBook(id, num)
    num = tonumber(num)
    num = math.clamp(num, 0, num)
    self:SetPlayerTalentSkillBook(id, self:GetPlayerTalentSkillBook(id) - tonumber(num))
end

-- 设置特性书的数量
function CoachItemMapModel:SetPlayerTalentSkillBook(id, num, updateCache)
    num = math.clamp(num, 0, num)
    self.coachItem[tostring(id)] = num
    self.playerTalentSkillBook[tostring(id)] = num
    EventSystem.SendEvent("Coach_Player_Talent_Skill_Book_Change", id, num)
    if updateCache then
        self:UpdateCoachItemCache()
    end
end

function CoachItemMapModel:UpdatePlayerTalentSkillBookFromReward(reward)
    self:SetPlayerTalentSkillBook(reward.id, reward.num)
end

-- 获得特性书的配置
function CoachItemMapModel:GetPlayerTalentSkillBookConfig(id)
    return PlayerTalentSkillBook[tostring(id)] or {}
end

-- 获得特性书的model
function CoachItemMapModel:GetPlayerTalentSkillBookModel(id)
    local playerTalentSkillBookModel = PlayerTalentSkillBookModel.new()
    playerTalentSkillBookModel:InitWithId(id)
    playerTalentSkillBookModel:SetOwnNum(self:GetPlayerTalentSkillBook(id))
    return playerTalentSkillBookModel
end

-- 获得特性书的名字
function CoachItemMapModel:GetPlayerTalentSkillBookName(id)
    return self:GetPlayerTalentSkillBookConfig(id).name
end
----------------------------------
-- 特性书，PlayerTalentSkillBook --
----------------------------------


-------------------------------------------
-- 特性道具 PlayerTalentFunctionalityItem --
-------------------------------------------

-- 获得所有特性道具物品的table
-- { id = num , ... }
function CoachItemMapModel:GetAllPlayerTalentFuncItem()
    return self.playerTalentFuncItem
end

-- 获得所有特性道具的model table
-- { id = {model} , ... }
function CoachItemMapModel:GetAllPlayerTalentFuncItemModels()
    local itemModelList = {}
    for id, num in pairs(self.playerTalentFuncItem or {}) do
        if num > 0 then
            local aModel = self:GetPlayerTalentFuncItemModel(id)
            itemModelList[id] = aModel
        end
    end
    return itemModelList
end

-- 获得特性道具的数量
function CoachItemMapModel:GetPlayerTalentFuncItem(id)
    return tonumber(self.playerTalentFuncItem[tostring(id)]) or 0
end

-- 增加特性道具的数量
function CoachItemMapModel:AddPlayerTalentFuncItem(id, num)
    num = tonumber(num)
    num = math.clamp(num, 0, num)
    self:SetPlayerTalentFuncItem(id, self:GetPlayerTalentFuncItem(id) + tonumber(num))
end

-- 减少特性道具的数量
function CoachItemMapModel:ReducePlayerTalentFuncItem(id, num)
    num = tonumber(num)
    num = math.clamp(num, 0, num)
    self:SetPlayerTalentFuncItem(id, self:GetPlayerTalentFuncItem(id) - tonumber(num))
end

-- 设置特性道具的数量
function CoachItemMapModel:SetPlayerTalentFuncItem(id, num, updateCache)
    num = math.clamp(num, 0, num)
    self.coachItem[tostring(id)] = num
    self.playerTalentFuncItem[tostring(id)] = num
    EventSystem.SendEvent("Coach_Player_Talent_Func_Item_Change", id, num)
    if updateCache then
        self:UpdateCoachItemCache()
    end
end

function CoachItemMapModel:UpdatePlayerTalentFuncItemFromReward(reward)
    self:SetPlayerTalentFuncItem(reward.id, reward.num)
end

-- 获得特性道具的配置
function CoachItemMapModel:GetPlayerTalentFuncItemConfig(id)
    return PlayerTalentSkillBook[tostring(id)] or {}
end

-- 获得特性道具的model
function CoachItemMapModel:GetPlayerTalentFuncItemModel(id)
    local playerTalentFuncItemModel = PlayerTalentFuncItemModel.new()
    playerTalentFuncItemModel:InitWithId(id)
    playerTalentFuncItemModel:SetOwnNum(self:GetPlayerTalentFuncItem(id))
    return playerTalentFuncItemModel
end

-- 获得特性道具的名字
function CoachItemMapModel:GetPlayerTalentFuncItemName(id)
    return self:GetPlayerTalentFuncItemConfig(id).name
end
-------------------------------------------
-- 特性道具 PlayerTalentFunctionalityItem --
-------------------------------------------


----------------------------------
-- 阵型/战术物品 CoachTacticItem --
----------------------------------

-- 获得所有阵型/战术升级物品的table
-- { id = num , ... }
function CoachItemMapModel:GetAllCoachTacticItems()
    return self.coachTacticItem
end

-- 获得所有教练物品的table
function CoachItemMapModel:GetAllCoachItems()
    return cache.getCoachItems() or {}
end

-- 获得所有阵型/战术升级物品的model table
-- { id = {model} , ... }
function CoachItemMapModel:GetAllCoachTacticItemModels()
    local itemModelList = {}
    for id, num in pairs(self.coachTacticItem or {}) do
        if num > 0 then
            local aModel = self:GetTacticItemModel(id)
            itemModelList[id] = aModel
        end
    end
    return itemModelList
end

-- 获得阵型/战术物品的数量
function CoachItemMapModel:GetTacticItem(id)
    return tonumber(self.coachTacticItem[tostring(id)]) or 0
end

-- 增加阵型/战术物品的数量
function CoachItemMapModel:AddTacticItem(id, num)
    num = tonumber(num)
    num = math.clamp(num, 0, num)
    self:SetTacticItem(id, self:GetTacticItem(id) + tonumber(num))
end

-- 减少阵型/战术物品的数量
function CoachItemMapModel:ReduceTacticItem(id, num)
    num = tonumber(num)
    num = math.clamp(num, 0, num)
    self:SetTacticItem(id, self:GetTacticItem(id) - tonumber(num))
end

-- 设置阵型/战术物品的数量
function CoachItemMapModel:SetTacticItem(id, num, updateCache)
    num = math.clamp(num, 0, num)
    self.coachItem[tostring(id)] = num
    self.coachTacticItem[tostring(id)] = num
    EventSystem.SendEvent("Coach_Item_Tactic_Change", id, num)
    if updateCache then
        self:UpdateCoachItemCache()
    end
end

function CoachItemMapModel:UpdateTacticItemFromReward(reward)
    self:SetTacticItem(reward.id, reward.num)
end

-- 获得阵型/战术物品的配置
function CoachItemMapModel:GetTacticItemConfig(id)
    return CoachTacticsItem[tostring(id)] or {}
end

-- 获得阵型/战术物品的model
function CoachItemMapModel:GetTacticItemModel(id)
    local tacticItemModel = TacticItemModel.new()
    tacticItemModel:InitWithId(id)
    tacticItemModel:SetOwnNum(self:GetTacticItem(id))
    return tacticItemModel
end

-- 获得阵型/战术物品的名字
function CoachItemMapModel:GetTacticItemName(id)
    return self:GetTacticItemConfig(id).name
end

-- 根据阵型id获得升级所需物品id
function CoachItemMapModel:ParseFormationItemConfig(formationId)
    formationId = tonumber(formationId)
    local id = nil
    local config = nil
    for k, v in pairs(CoachTacticsItem) do
        -- 阵型物品 && 该阵型类别有配置 && 等于选择的阵型
        if tonumber(v.type) == CoachItemType.TacticItemType.Formation and v.formationID ~= nil and v.formationID > 0 and tonumber(v.formationID) == formationId then
            id = tostring(k)
            config = v
            break
        end
    end
    return id, config
end

-- 根据战术类型和id获得升级所需物品id
function CoachItemMapModel:ParseTacticItemConfig(tacticType, level)
    tacticType = tostring(tacticType)
    level = tonumber(level)
    local id = nil
    local config = nil
    for k, v in pairs(CoachTacticsItem) do
        -- 战术型物品 && 该战术类别有配置 && 等于战术选择的级别
        if tonumber(v.type) == CoachItemType.TacticItemType.Tactic and v[tacticType] ~= nil and v[tacticType] > 0 and tonumber(v[tacticType]) == level then
            id = tostring(k)
            config = v
            break
        end
    end
    return id, config
end
----------------------------------
-- 阵型/战术物品 CoachTacticItem --
----------------------------------

-----------------------------------
-- 助教情报 AssistCoachInfoModel --
-----------------------------------

-- 获得所有助教情报的table
-- { id = num , ... }
function CoachItemMapModel:GetAllAssistCoachInfo()
    return self.assistCoachInfo
end

-- 获得所有助教情报的model table
-- { id = {model} , ... }
function CoachItemMapModel:GetAllAssistCoachInfoModels()
    local itemModelList = {}
    for id, num in pairs(self.assistCoachInfo or {}) do
        if num > 0 then
            local aciModel = self:GetAssistCoachInfoModel(id)
            itemModelList[id] = aciModel
        end
    end
    return itemModelList
end

-- 获得展开的所有助教情报的model数组，根据数目展开
-- { {model(id=11001, fixId=1)} , {model(id=11001, fixId=2)}, {model(id=11002,fixId=3)} ... }
function CoachItemMapModel:GetExpandAssistCoachInfoModels()
    local aciModels = {}
    local fixId = 1
    for id, num in pairs(self.assistCoachInfo or {}) do
        if num > 0 then
            for i = 1, num do
                local aciModel = self:GetAssistCoachInfoModel(id)
                aciModel:SetOwnNum(1)
                aciModel.fixId = tostring(fixId)
                aciModels[aciModel.fixId] = aciModel
                fixId = fixId + 1
            end
        end
    end
    return aciModels
end

-- 获得助教情报的数量
function CoachItemMapModel:GetAssistCoachInfo(id)
    return tonumber(self.assistCoachInfo[tostring(id)]) or 0
end

-- 增加助教情报的数量
function CoachItemMapModel:AddAssistCoachInfo(id, num)
    num = tonumber(num)
    num = math.clamp(num, 0, num)
    self:SetAssistCoachInfo(id, self:GetAssistCoachInfo(id) + tonumber(num))
end

-- 减少助教情报的数量
function CoachItemMapModel:ReduceAssistCoachInfo(id, num)
    num = tonumber(num)
    num = math.clamp(num, 0, num)
    self:SetAssistCoachInfo(id, self:GetAssistCoachInfo(id) - tonumber(num))
end

-- 设置助教情报的数量
function CoachItemMapModel:SetAssistCoachInfo(id, num, updateCache)
    num = math.clamp(num, 0, num)
    self.coachItem[tostring(id)] = num
    self.assistCoachInfo[tostring(id)] = num
    EventSystem.SendEvent("Coach_Assist_Coach_Info_Change", id, num)
    if updateCache then
        self:UpdateCoachItemCache()
    end
end

-- 从奖励更新助教情报
function CoachItemMapModel:UpdateAssistCoachInfoFromReward(reward)
    self:SetAssistCoachInfo(reward.id, reward.num)
end

-- 获得助教情报的配置
function CoachItemMapModel:GetAssistCoachInfoConfig(id)
    return AssistantCoachInformation[tostring(id)] or {}
end

-- 获得助教情报的model
function CoachItemMapModel:GetAssistCoachInfoModel(id)
    local assistCoachInfoModel = AssistCoachInfoModel.new()
    assistCoachInfoModel:InitWithId(id)
    assistCoachInfoModel:SetOwnNum(self:GetAssistCoachInfo(id))
    return assistCoachInfoModel
end

-- 获得助教情报的名字
function CoachItemMapModel:GetAssistCoachInfoName(id)
    return self:GetAssistCoachInfoConfig(id).name
end
-------------------------------------------
-- 助教情报 AssistCoachInfoModel --
-------------------------------------------

return CoachItemMapModel

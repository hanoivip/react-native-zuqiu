local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Object = UnityEngine.Object

local GameObjectHelper = require("ui.common.GameObjectHelper")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local BuildingBase = require("data.BuildingBase")
local Building = require("data.Building")
local GuildWarBuff = require("data.GuildWarBuff")
local BlockDebuffSkills = require("ui.scene.match.overlay.BlockDebuffSkills")

local DisabledSkillConfig = {
    "A08",
    "A02_1",
    "D05_1",
    "E07_1",
    "D06_1",
    "A04_1",
    "D07_1",
    "E05_1",
    "A08_1",
    "B02_1",
    "D05_A_1",
    "C01_A_1",
    "D06_A_1",
    "E10_1", -- 特殊处理
    "B04",
    "B05",
    "LR_GCHIELLINI2", -- 特殊处理
    "LR_GPIQUE2",
}

local StatePanel = class(unity.base)

function StatePanel:ctor()
    self.leftPanel = self.___ex.leftPanel
    self.rightPanel = self.___ex.rightPanel
    self.mask = self.___ex.mask
    -- 天气名称
    self.weatherName = self.___ex.weatherName
    -- 天气图标
    self.weatherIcon = self.___ex.weatherIcon
    -- 天气等级
    self.weatherLevel = self.___ex.weatherLevel
    -- 因天气而被降低等级的对手的技能
    self.skillGroup = self.___ex.skillGroup
    -- 天气影响效果
    self.weatherEffectNum = self.___ex.weatherEffectNum
    -- 草地名称
    self.grassName = self.___ex.grassName
    -- 草地图标
    self.grassIcon = self.___ex.grassIcon
    -- 草地等级
    self.grassLevel = self.___ex.grassLevel
    -- 草地功能描述
    self.grassDesc = self.___ex.grassDesc
    -- 草地影响效果
    self.grassEffectNum = self.___ex.grassEffectNum
    -- 公会战进入核心玩法的buff显示
    self.atkBuffTxt = self.___ex.atkBuffTxt
    self.defBuffTxt = self.___ex.defBuffTxt
    self.toTalentBtn = self.___ex.toTalentBtn
    self.toStateBtn = self.___ex.toStateBtn   
    self.leftTeamSign = self.___ex.leftTeamSign
    self.rightTeamSign = self.___ex.rightTeamSign    
    self.stateItemScriptMap = nil
    self.talentItemScriptMap = nil
    self.matchInfoModel = nil
end

function StatePanel:init()
    self:InitPlayersPanel()
    if not self.matchInfoModel:IsDemoMatch() then
        self:BuildWeatherInfo()
        self:BuildGrassInfo()
        self:BuildTalentInfo()
        self:InitTalentPanel()
    end
    self:BindAll()
    self:SwitchToStatePanel()
end

function StatePanel:InitPlayersPanel()
    self.stateItemScriptMap = {}
    self.matchInfoModel = MatchInfoModel.GetInstance()
    local initTeamData = self.matchInfoModel:GetPlayerInitTeamData()
    for i, athleteData in ipairs(initTeamData) do
        local stateItem = res.Instantiate("Assets/CapstonesRes/Game/UI/Match/Overlay/StateItem.prefab")
        local stateItemScript = res.GetLuaScript(stateItem)
        stateItemScript:init(athleteData)
        stateItem.transform:SetParent(self.leftPanel.transform)
        stateItem.transform.localScale = Vector3(1, 1, 1)
        stateItem.transform.localPosition = Vector3(0, 0, 0)

        self.stateItemScriptMap[athleteData.onfieldId] = stateItemScript
    end
    initTeamData = self.matchInfoModel:GetOpponentInitTeamData()
    for i, athleteData in ipairs(initTeamData) do
        local stateItem = res.Instantiate("Assets/CapstonesRes/Game/UI/Match/Overlay/StateItem.prefab")
        local stateItemScript = res.GetLuaScript(stateItem)
        stateItemScript:init(athleteData)
        stateItem.transform:SetParent(self.rightPanel.transform)
        stateItem.transform.localScale = Vector3(1, 1, 1)
        stateItem.transform.localPosition = Vector3(0, 0, 0)

        self.stateItemScriptMap[athleteData.onfieldId] = stateItemScript        
    end
end

function StatePanel:UpdatePlayersPanelItem(athleteData)
    local found = false
    for onfieldId, stateItemScript in pairs(self.stateItemScriptMap) do
        if stateItemScript.athleteId == athleteData.id then
            found = true
            break
        end
    end

    if not found then
        -- 这是新换上的球员，应该初始化
        local stateItemScript = self.stateItemScriptMap[athleteData.onfieldId]
        stateItemScript:init(athleteData)
    end
end

function StatePanel:UpdatePlayerState()
    local initTeamData = self.matchInfoModel:GetPlayerInitTeamData()
    for i, athleteData in ipairs(initTeamData) do
        self:UpdatePlayersPanelItem(athleteData)
    end
    initTeamData = self.matchInfoModel:GetOpponentInitTeamData()
    for i, athleteData in ipairs(initTeamData) do
        self:UpdatePlayersPanelItem(athleteData)
    end
end

-- public struct AthleteBuff --BuffInstance
-- {
--     public int BuffId; // Buff的唯一ID
--     public float Time; // Buff出现或者消失的时间
--     public int AthleteId; // Buff作用的球员ID
--     public int OnfieldId; // Buff作用的球员OnfieldID 注意这里是从1开始编号
--     public float Value; // Buff的增益效果, Value = 1 => +100%; Value = -0.5 => -50%
--     public int State; // 0 == Buff出现, 1 == Buff消失
--     public string SkillId; // Buff对应的技能ID
-- }
function StatePanel:onAthleteBuff(buffInstance)
    if buffInstance.State == 0 then
        self:addBuff(buffInstance)
    else
        self:removeBuff(buffInstance)
    end
end

-- 禁用技能
local function IsDisabledSkill(skillId)
    for i, skillConfig in ipairs(DisabledSkillConfig) do
        if skillConfig == skillId then
            return true
        end
    end
    return false
end

-- 禁用debuff
local function IsBlockDebuffSkill(skillId)
    for i, skillConfig in ipairs(BlockDebuffSkills) do
        if skillConfig == skillId then
            return true
        end
    end
    return false
end

-- for disabled skill
function StatePanel:addBuff(buffInstance)
    if buffInstance.Value ~= 0 or (IsDisabledSkill(buffInstance.SkillId) and buffInstance.MarkedSkillId ~= "" and buffInstance.MarkedSkillId ~= nil) 
        or IsBlockDebuffSkill(buffInstance.SkillId) then
        self.stateItemScriptMap[buffInstance.OnfieldId]:addBuff(buffInstance)
    end
end

-- for disabled skill
function StatePanel:removeBuff(buffInstance)
    if buffInstance.Value ~= 0 or (IsDisabledSkill(buffInstance.SkillId) and buffInstance.MarkedSkillId ~= "" and buffInstance.MarkedSkillId ~= nil) 
        or IsBlockDebuffSkill(buffInstance.SkillId) then
        self.stateItemScriptMap[buffInstance.OnfieldId]:removeBuff(buffInstance)
    end
end

function StatePanel:BindAll()
    self.mask:regOnButtonClick(function ()
        self:SwitchToStatePanel()
        EventSystem.SendEvent("NoteMenu.ToggleStatePanel")
    end)
    self.toTalentBtn:regOnButtonClick(function()
        self:SwitchToTalentPanel()
    end)
    self.toStateBtn:regOnButtonClick(function()
        self:SwitchToStatePanel()
    end)
end

--- 构建天气信息
function StatePanel:BuildWeatherInfo()
    local baseInfoData = self.matchInfoModel:GetBaseInfo()
    local atkBuff = baseInfoData.playerBuff
    GameObjectHelper.FastSetActive(self.atkBuffTxt.transform.parent.gameObject, atkBuff)
    self.atkBuffTxt.text = lang.trans("guildwar_atkBuff", atkBuff and GuildWarBuff[atkBuff].effect)
    local weatherBaseData = BuildingBase[baseInfoData.weatherTech]
    local skillAffect = weatherBaseData.skillAffect
    self.weatherName.text = weatherBaseData.name
    self.weatherIcon.sprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Loading/Images/Icon_" .. baseInfoData.weatherTech .. ".png")
    local buildingData = Building[baseInfoData.weatherTech]
    if buildingData and baseInfoData.weatherTechLvl > 0 then
        GameObjectHelper.FastSetActive(self.weatherLevel.gameObject, true)
        self.weatherLevel.text = "Lv" .. baseInfoData.weatherTechLvl
        local weatherData = buildingData[baseInfoData.weatherTechLvl + 1]
        self.weatherEffectNum.text = lang.trans("reduce_num", weatherData.skillEffect)
    else
        GameObjectHelper.FastSetActive(self.weatherLevel.gameObject, false)
    end
    if type(skillAffect) == "table" then
        GameObjectHelper.FastSetActive(self.skillGroup.gameObject, true)
        local obj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/EffectSkill.prefab")
        for i, skillID in ipairs(skillAffect) do
            local go = Object.Instantiate(obj)
            local spt = res.GetLuaScript(go)
            go.transform:SetParent(self.skillGroup, false)
            spt:InitView(skillID)
        end
    else
        GameObjectHelper.FastSetActive(self.skillGroup.gameObject, false)
    end
end

local function getGrassDesc(grassText)
    local grassSecondHalfDesc = ""
    local grassDescList = string.split(grassText, "，") 
    if type(grassDescList) == "table" and #grassDescList < 2 then
        grassDescList = string.split(grassText, ",")
    end

    if #grassDescList >= 2 then
        grassSecondHalfDesc = grassDescList[2]
    end

    return grassSecondHalfDesc
end
--- 构建草地信息
function StatePanel:BuildGrassInfo()
    local baseInfoData = self.matchInfoModel:GetBaseInfo()
    local defBuff = baseInfoData.opponentBuff 
    GameObjectHelper.FastSetActive(self.defBuffTxt.transform.parent.gameObject, defBuff)
    self.defBuffTxt.text = lang.trans("guildwar_defBuff", defBuff and GuildWarBuff[defBuff].effect)
    local grassBaseData = BuildingBase[baseInfoData.grassTech]
    local grassSecondHalfDesc = getGrassDesc(grassBaseData.fuctionDesc)

    self.grassName.text = grassBaseData.name
    self.grassIcon.sprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/Details/" .. baseInfoData.grassTech .. "_Icon.png")
    self.grassDesc.text = grassSecondHalfDesc
	local buildData = Building[baseInfoData.grassTech]
    if buildData and baseInfoData.grassTechLvl > 0 then
        GameObjectHelper.FastSetActive(self.grassLevel.gameObject, true)
        self.grassLevel.text = "Lv" .. baseInfoData.grassTechLvl
        local grassData = buildData[baseInfoData.grassTechLvl + 1]
        self.grassEffectNum.text = lang.trans("reduce_point", grassData.attrEffect)
    else
        GameObjectHelper.FastSetActive(self.grassLevel.gameObject, false)
    end
end

function StatePanel:BuildTalentInfo()
    local isPlayerHome = self.matchInfoModel:isPlayerHome()
    self.leftTeamSign:init(isPlayerHome)
    self.leftTeamSign:SetVisible(true)
    self.rightTeamSign:init(not isPlayerHome)
    self.rightTeamSign:SetVisible(true)
end

function StatePanel:InitTalentPanel()
    self.talentItemScriptMap = {}
    self.matchInfoModel = MatchInfoModel.GetInstance()
    local initTeamData = self.matchInfoModel:GetPlayerInitTeamData()
    for i, athleteData in ipairs(initTeamData) do
        local talent = res.Instantiate("Assets/CapstonesRes/Game/UI/Match/Overlay/TalentItem.prefab")
        local talentScript = res.GetLuaScript(talent)
        talentScript:init(athleteData)
        talent.transform:SetParent(self.leftPanel.transform)
        talent.transform.localScale = Vector3(1, 1, 1)
        talent.transform.localPosition = Vector3(0, 0, 0)

        self.talentItemScriptMap[athleteData.onfieldId] = talentScript
    end
    initTeamData = self.matchInfoModel:GetOpponentInitTeamData()
    for i, athleteData in ipairs(initTeamData) do
        local talent = res.Instantiate("Assets/CapstonesRes/Game/UI/Match/Overlay/TalentItem.prefab")
        local talentScript = res.GetLuaScript(talent)
        talentScript:init(athleteData)
        talent.transform:SetParent(self.rightPanel.transform)
        talent.transform.localScale = Vector3(1, 1, 1)
        talent.transform.localPosition = Vector3(0, 0, 0)

        self.talentItemScriptMap[athleteData.onfieldId] = talentScript
    end
end

function StatePanel:SwitchToStatePanel()
    self.leftTeamSign:SetVisible(false)
    self.rightTeamSign:SetVisible(false)
    self.talentItemScriptMap = self.talentItemScriptMap or {}
    for k, v in pairs(self.talentItemScriptMap) do
        GameObjectHelper.FastSetActive(v.gameObject, false)
    end
    self.stateItemScriptMap = self.stateItemScriptMap or {}
    for k, v in pairs(self.stateItemScriptMap) do
        GameObjectHelper.FastSetActive(v.gameObject, true)
    end
    GameObjectHelper.FastSetActive(self.toStateBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.toTalentBtn.gameObject, true)
end

function StatePanel:SwitchToTalentPanel()
    self.leftTeamSign:SetVisible(true)
    self.rightTeamSign:SetVisible(true)
    for k, v in pairs(self.talentItemScriptMap) do
        GameObjectHelper.FastSetActive(v.gameObject, true)
    end
    for k, v in pairs(self.stateItemScriptMap) do
        GameObjectHelper.FastSetActive(v.gameObject, false)
    end
    GameObjectHelper.FastSetActive(self.toStateBtn.gameObject, true)
    GameObjectHelper.FastSetActive(self.toTalentBtn.gameObject, false)
end

return StatePanel

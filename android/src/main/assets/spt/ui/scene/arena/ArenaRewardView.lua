local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local ArenaIndexType = require("ui.scene.arena.ArenaIndexType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaScore = require("data.ArenaScore")
local ArenaRewardView = class(unity.base)

function ArenaRewardView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.arenaTitle = self.___ex.arenaTitle
    self.btnConfirm = self.___ex.btnConfirm
    self.barArea = self.___ex.barArea
    self.desc = self.___ex.desc
    self.arenaTitleIcon = self.___ex.arenaTitleIcon
    self.rewardDisplayArea = self.___ex.rewardDisplayArea
    self.cup = self.___ex.cup
    self.barMap = {}
end

function ArenaRewardView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
end

function ArenaRewardView:OnBtnConfirm()
    if self.clickConfirm then 
        self.clickConfirm()
    end
end

function ArenaRewardView:IsShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.rewardDisplayArea, isShow)
end

function ArenaRewardView:InitView(arenaModel, arenaType)
    self:IsShowDisplayArea(true)
    local title = arenaType .. "_arena"
    self.arenaTitle.text = lang.trans(title)
    local arenaIndex = ArenaIndexType[arenaType]
    self.arenaTitleIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Arena/Arena" .. arenaIndex .. ".png")
    self.cup.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Details/Bytes/Cup" .. arenaIndex .. ".png")
    self.cup:SetNativeSize()
    local teamsStage = arenaModel:GetMatchTeamsStage(arenaType)
    local list = teamsStage.list
    local standardStage = teamsStage.stage
    local playerCount = 0
    local allotDesc = ""
    for i, v in ipairs(list) do
        local symbol = i < #list and "," or ""
        local cnt = tonumber(v.cnt)
        playerCount = playerCount + cnt
        local name = arenaModel:GetGradeName(v.stage)
        allotDesc = allotDesc .. lang.transstr("arena_team_player", cnt, name) ..symbol
    end
    local standardName = arenaModel:GetGradeName(standardStage)
    self.desc.text = lang.trans("arena_team_info", playerCount, allotDesc, standardName)

    local rewardBarRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/RewardBar.prefab")
    for k, v in pairs(ArenaScore) do
        local index = tonumber(k)
        if not self.barMap[k] then 
            local rewardPrefab = Object.Instantiate(rewardBarRes)
            local spt = res.GetLuaScript(rewardPrefab)
            rewardPrefab.transform:SetParent(self.barArea, false)
            rewardPrefab.transform:SetSiblingIndex(index - 1)
            self.barMap[k] = spt
        end
        self.barMap[k]:InitView(arenaModel, index, standardStage, arenaType)
    end
end

function ArenaRewardView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return ArenaRewardView

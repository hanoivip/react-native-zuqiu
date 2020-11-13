local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local DialogManager = require("ui.control.manager.DialogManager")
local FormationPageView = require("ui.scene.formation.FormationPageView")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local ArenaFormationPageView = class(FormationPageView, "ArenaFormationPageView")

function ArenaFormationPageView:ctor()
    ArenaFormationPageView.super.ctor(self)
    self.txtArenaName = self.___ex.txtArenaName
    self.txtArenaCardQualityCondition = self.___ex.txtArenaCardQualityCondition
    self.arenaNameGradient = self.___ex.arenaNameGradient
    self.btnAutoClearFormation = self.___ex.btnAutoClearFormation
    self.titleArea = self.___ex.titleArea

    self.btnAutoClearFormation:regOnButtonClick(function()
        self:ClearFormation()
    end)
end

function ArenaFormationPageView:PostSaveTeamData()
    self:SaveTeamData(function()
        DialogManager.ShowToastByLang("formation_saveSuccess")
        self:FormationDataChange(false)
    end)
end

-- 暂时保留另一种清空数据但不缓存
--function ArenaFormationPageView:PostClearTeamData()
--    local resp = req.arenaClearTeam(self.playerTeamsModel:GetTeamType())
--    if api.success(resp) then
--        self.formationCacheDataModel:SetInitPlayersCacheDataWithKeyPlayers(self.initPlayersData)
--        self.formationCacheDataModel:SetKeyPlayersDefaultData()
--        self:UpdateTeamData(resp.val)
--        self:FormationDataChange(false)
--        DialogManager.ShowToastByLang("clear_formation_success")
--    end
--end

---- 在首发阵容为空的情况下需保存默认数据
--function ArenaFormationPageView:JudgeStarters()
--    local starterNum = 0
--    local totalPlayers = table.nums(self.initPlayersData)
--    for pos, pcid in pairs(self.initPlayersData) do 
--        if tonumber(pcid) ~= 0 then 
--            starterNum = starterNum + 1
--        end
--    end
--    if starterNum == 0 then 
--        self:PostClearTeamData()
--    else
--        DialogManager.ShowToastByLang("formation_validType_initPlayers_notEnough")
--    end
--end

--function ArenaFormationPageView:SaveFormation()
--    -- 如果阵容已修改
--    if self:CheckTeamChanged() then
--        -- 阵容是否合法
--        local validType = self:CheckTeamValid()
--        if validType == FormationConstants.FormationValidType.VALID then
--            self:PostSaveTeamData()
--        elseif validType == FormationConstants.FormationValidType.NOVALID_INITPLAYERS_NOTENOUGH then
--            if self.playerTeamsModel:IsMatchingArena() then
--                DialogManager.ShowToastByLang("formation_validType_initPlayers_notEnough")
--            else
--                self:JudgeStarters()
--            end
--        elseif validType == FormationConstants.FormationValidType.NOVALID_HASSAMEPLAYER then
--            DialogManager.ShowToastByLang("formation_validType_hasSamePlayer")
--        end
--    else
--        DialogManager.ShowToastByLang("formation_noNeedSave")
--    end
--end

function ArenaFormationPageView:RefreshPage(isPush)
    ArenaFormationPageView.super.RefreshPage(self, isPush)
    self:BuildTitle()
end

function ArenaFormationPageView:ClearFormation()
    local title = lang.trans("clear_formation_title")
    local content = lang.trans("clear_formation_content")
    DialogManager.ShowConfirmPop(title, content, function() self:ClearCourtPlayers() end)
end

function ArenaFormationPageView:ClearCourtPlayers()
    if self.playerTeamsModel:IsMatchingArena() then 
        DialogManager.ShowToast(lang.trans("clear_fail"))
    else
        self:coroutine(function()
            local resp = req.arenaClearTeam(self.playerTeamsModel:GetTeamType())
            if api.success(resp) then
                self.initPlayersData = self.playerTeamsModel:GetClearStartersData()
                self.replacePlayersData = self.playerTeamsModel:GetClearBenchData()
                self.formationCacheDataModel:SetInitPlayerCacheData(self.initPlayersData)
                self.formationCacheDataModel:SetReplacePlayerCacheData(self.replacePlayersData)
                self.formationCacheDataModel:SetTacticsCacheData({})
                self.waitPlayersNoRepeatList, self.waitPlayersRepeatList = self.formationCacheDataModel:GetWaitPlayerCacheData(self.nowSortType)
                self:InitCandidateScrollerView()
                self:BuildPage()
                self.candidateScrollerView:BuildPage()

                self.formationCacheDataModel:SetInitPlayersCacheDataWithKeyPlayers(self.initPlayersData)
                self.formationCacheDataModel:SetKeyPlayersDefaultData()
                self:UpdateTeamData(resp.val)
                self:FormationDataChange(false)
                DialogManager.ShowToastByLang("clear_formation_success")
            end
        end)
    end
end

-- 保存阵容数据
function ArenaFormationPageView:SaveTeamData(onComplete)
    local replacePlayersData = {}
    for pos, pcId in pairs(self.replacePlayersData) do
        if tonumber(pcId) ~= 0 then
            replacePlayersData[pos] = pcId
        end
    end

    self:coroutine(function()
        if self.formationCacheDataModel:CheckInitPlayersChangedWithKeyPlayers(self.initPlayersData) then
            self.formationCacheDataModel:SetInitPlayersCacheDataWithKeyPlayers(self.initPlayersData)
            self.formationCacheDataModel:SetKeyPlayersDefaultData()
        end
        local keyPlayersData = self.formationCacheDataModel:GetKeyPlayersCacheData()
        keyPlayersData = self.playerTeamsModel:FixKeyPlayersData(keyPlayersData, self.initPlayersData)
        local tacticsData = self.formationCacheDataModel:GetTacticsCacheData()
        local teamType = self.playerTeamsModel:GetTeamType()
        local resp = req.arenaSaveTeam(self.nowTeamId, self.nowFormationId, self.initPlayersData, replacePlayersData, teamType, keyPlayersData, tacticsData, self.selectedType)
        if api.success(resp) then
            self.playerTeamsModel:SetFormationId(self.nowTeamId, self.nowFormationId)
            self.playerTeamsModel:SetInitPlayersData(self.nowTeamId, self.initPlayersData)
            self.playerTeamsModel:SetReplacePlayersData(self.nowTeamId, self.replacePlayersData)
            self.playerTeamsModel:SetSelectedType(self.selectedType)
            self.savedSelectedType = self.selectedType
            self.playerTeamsModel:SetNowTeamKeyPlayersData(self.formationCacheDataModel:GetKeyPlayersCacheData())
            self.playerTeamsModel:SetNowTeamTacticsData(self.formationCacheDataModel:GetTacticsCacheData())
            self:ResetCardsLock(resp.val)
            if type(onComplete) == "function" then
                onComplete()
            end
        end
    end)
end

function ArenaFormationPageView:BuildTitle()
    local teamType = self.playerTeamsModel:GetTeamType()
    self.arenaNameGradient:ResetPointColors(2)
    -- 白银竞技场
    if teamType == FormationConstants.TeamType.CWAR_SILVER then
        self.txtArenaName.text = lang.trans("silver_arena")
        self.txtArenaCardQualityCondition.text = lang.trans("arena_silver_condition")
        self.arenaNameGradient:AddPointColors(0, Color(0.898, 0.898, 0.898))
        self.arenaNameGradient:AddPointColors(1, Color(0.361, 0.361, 0.361))
    -- 黄金竞技场
    elseif teamType == FormationConstants.TeamType.CWAR_GOLD then
        self.txtArenaName.text = lang.trans("gold_arena")
        self.txtArenaCardQualityCondition.text = lang.trans("arena_gold_condition")
        self.arenaNameGradient:AddPointColors(0, Color(0.969, 0.937, 0.698))
        self.arenaNameGradient:AddPointColors(1, Color(0.461, 0.365, 0.224))
    -- 黑金竞技场
    elseif teamType == FormationConstants.TeamType.CWAR_BLACKGOLD then
        self.txtArenaName.text = lang.trans("black_arena")
        self.txtArenaCardQualityCondition.text = lang.trans("arena_black_condition")
        self.arenaNameGradient:AddPointColors(0, Color(0.894, 0.878, 0.631))
        self.arenaNameGradient:AddPointColors(1, Color(0.369, 0.275, 0.082))
    -- 白金竞技场
    elseif teamType == FormationConstants.TeamType.CWAR_PLATINUM then
        self.txtArenaName.text = lang.trans("platinum_arena")
        self.txtArenaCardQualityCondition.text = lang.trans("arena_platinum_condition")
        self.arenaNameGradient:AddPointColors(0, Color(0.98, 0.965, 0.882))
        self.arenaNameGradient:AddPointColors(1, Color(0.773, 0.714, 0.549))
    elseif teamType == FormationConstants.TeamType.CWAR_RED then
        self.txtArenaName.text = lang.trans("red_arena")
        self.txtArenaCardQualityCondition.text = lang.trans("arena_red_condition")
        self.arenaNameGradient:AddPointColors(0, Color(0.98, 0.965, 0.882))
        self.arenaNameGradient:AddPointColors(1, Color(0.773, 0.714, 0.549))
    elseif teamType == FormationConstants.TeamType.CWAR_ANN then
        self.txtArenaName.text = lang.trans("yellow_arena")
        self.txtArenaCardQualityCondition.text = lang.trans("arena_yellow_condition")
        self.arenaNameGradient:AddPointColors(0, Color(0.98, 0.965, 0.882))
        self.arenaNameGradient:AddPointColors(1, Color(0.773, 0.714, 0.549))
    elseif teamType == FormationConstants.TeamType.CWAR_Blue then
        self.txtArenaName.text = lang.trans("blue_arena")
        self.txtArenaCardQualityCondition.text = lang.trans("arena_blue_condition")
        self.arenaNameGradient:AddPointColors(0, Color(0.98, 0.965, 0.882))
        self.arenaNameGradient:AddPointColors(1, Color(0.773, 0.714, 0.549))
    end
end

return ArenaFormationPageView

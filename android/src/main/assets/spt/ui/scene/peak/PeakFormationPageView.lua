local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local DialogManager = require("ui.control.manager.DialogManager")
local FormationPageView = require("ui.scene.formation.FormationPageView")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local PeakFormationPageView = class(FormationPageView, "PeakFormationPageView")

function PeakFormationPageView:ctor()
    PeakFormationPageView.super.ctor(self)
    self.txtArenaName = self.___ex.txtArenaName
    self.txtArenaCardQualityCondition = self.___ex.txtArenaCardQualityCondition
    self.arenaNameGradient = self.___ex.arenaNameGradient
    self.btnAutoClearFormation = self.___ex.btnAutoClearFormation
    self.titleArea = self.___ex.titleArea

    self.btnAutoClearFormation:regOnButtonClick(function()
        self:ClearFormation()
    end)
end

-- function PeakFormationPageView:PostSaveTeamData()
--     self:SaveTeamData(function()
--         DialogManager.ShowToastByLang("formation_saveSuccess")
--         self:FormationDataChange(false)
--     end)
-- end

function PeakFormationPageView:RefreshPage(isPush)
    PeakFormationPageView.super.RefreshPage(self, isPush)
    self:BuildTitle()
end

function PeakFormationPageView:ClearFormation()
    local title = lang.trans("clear_formation_title")
    local content = lang.trans("peak_clear_formation")
    DialogManager.ShowConfirmPop(title, content, function() self:ClearCourtPlayers() end)
end

function PeakFormationPageView:ClearCourtPlayers()
    self:coroutine(function()
        local resp = req.peakClearTeam(self.playerTeamsModel:GetPtid())
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

-- 保存阵容数据
function PeakFormationPageView:SaveTeamData(onComplete)
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
        local nowTeamId = self.playerTeamsModel:GetPtid()
        local teamType = self.playerTeamsModel:GetTeamType()
        local resp = req.peakSaveTeam(nowTeamId, self.nowFormationId, self.initPlayersData, teamType, replacePlayersData, keyPlayersData, tacticsData, self.selectedType)
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

function PeakFormationPageView:BuildTitle()
    local pcid = self.playerTeamsModel:GetPtid()
    self.txtArenaCardQualityCondition.text = lang.trans("peak_formation_id", pcid + 1)
end

return PeakFormationPageView
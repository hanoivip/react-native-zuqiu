local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local DialogManager = require("ui.control.manager.DialogManager")
local FormationPageView = require("ui.scene.formation.FormationPageView")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local SpecificMatchBase = require("data.SpecificMatchBase")
local SpecialEventsFormationView = class(FormationPageView, "SpecialEventsFormationView")

function SpecialEventsFormationView:ctor()
    SpecialEventsFormationView.super.ctor(self)
    self.btnAutoClearFormation = self.___ex.btnAutoClearFormation
    self.specialEventsTips = self.___ex.specialEventsTips

    self.btnAutoClearFormation:regOnButtonClick(
        function()
            self:ClearFormation()
        end
    )
end

function SpecialEventsFormationView:HideAutoBtnAndMoveClearBtn()
    self.btnAutoClearFormation.transform.parent.localPosition  = self.automaticBtn.transform.parent.localPosition
    self.automaticBtn.transform.parent.gameObject:SetActive(false)
end

function SpecialEventsFormationView:InitView(matchId, playerTeamsModel, formationCacheDataModel)
    SpecialEventsFormationView.super.InitView(self, playerTeamsModel, formationCacheDataModel)
    self.matchId = matchId
    self.eventId = SpecificMatchBase[matchId].id
end

function SpecialEventsFormationView:PostSaveTeamData()
    self:SaveTeamData(
        function()
            DialogManager.ShowToastByLang("formation_saveSuccess")
            self:FormationDataChange(false)
        end
    )
end

function SpecialEventsFormationView:RefreshPage(isPush)
    SpecialEventsFormationView.super.RefreshPage(self, isPush)
end

function SpecialEventsFormationView:ClearFormation()
    local title = lang.trans("clear_formation_title")
    local content = lang.trans("special_events_clear_formation_content")
    DialogManager.ShowConfirmPop(
        title,
        content,
        function()
            self:ClearCourtPlayers()
        end
    )
end

function SpecialEventsFormationView:ClearCourtPlayers()
    self:coroutine(
        function()
            local resp = req.specificClearTeam(self.eventId)
            if api.success(resp) then
                self.initPlayersData = self.playerTeamsModel:GetClearStartersData()
                self.replacePlayersData = self.playerTeamsModel:GetClearBenchData()
                self.formationCacheDataModel:SetInitPlayerCacheData(self.initPlayersData)
                self.formationCacheDataModel:SetReplacePlayerCacheData(self.replacePlayersData)
                self.formationCacheDataModel:SetTacticsCacheData({})
                self.waitPlayersNoRepeatList,
                    self.waitPlayersRepeatList = self.formationCacheDataModel:GetWaitPlayerCacheData(self.nowSortType)
                self:InitCandidateScrollerView()
                self:BuildPage()
                self.candidateScrollerView:BuildPage()

                self.formationCacheDataModel:SetInitPlayersCacheDataWithKeyPlayers(self.initPlayersData)
                self.formationCacheDataModel:SetKeyPlayersDefaultData()
                self:UpdateTeamData(resp.val)
                self:FormationDataChange(false)
                DialogManager.ShowToastByLang("clear_formation_success")
            end
        end
    )
end

-- 保存阵容数据
function SpecialEventsFormationView:SaveTeamData(onComplete)
    local replacePlayersData = {}
    for pos, pcId in pairs(self.replacePlayersData) do
        if tonumber(pcId) ~= 0 then
            replacePlayersData[pos] = pcId
        end
    end

    self:coroutine(
        function()
            if self.formationCacheDataModel:CheckInitPlayersChangedWithKeyPlayers(self.initPlayersData) then
                self.formationCacheDataModel:SetInitPlayersCacheDataWithKeyPlayers(self.initPlayersData)
                self.formationCacheDataModel:SetKeyPlayersDefaultData()
            end
            local keyPlayersData = self.formationCacheDataModel:GetKeyPlayersCacheData()
            keyPlayersData = self.playerTeamsModel:FixKeyPlayersData(keyPlayersData, self.initPlayersData)
            local tacticsData = self.formationCacheDataModel:GetTacticsCacheData()
            local teamType = FormationConstants.TeamType.SPECIFIC
            local resp =
                req.specificSaveTeam(
                self.eventId,
                self.nowFormationId,
                self.initPlayersData,
                teamType,
                replacePlayersData,
                keyPlayersData,
                tacticsData,
                self.selectedType
            )
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
        end
    )
end

return SpecialEventsFormationView

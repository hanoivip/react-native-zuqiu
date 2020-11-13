local DialogManager = require("ui.control.manager.DialogManager")
local FormationPageView = require("ui.scene.formation.FormationPageView")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteFormationPageView = class(FormationPageView, "CompeteFormationPageView")

function CompeteFormationPageView:ctor()
    CompeteFormationPageView.super.ctor(self)
    self.btnAutoClearFormation = self.___ex.btnAutoClearFormation
    self.specialEventsTips = self.___ex.specialEventsTips
    self.seasonNameTxt = self.___ex.seasonNameTxt
    self.automaticBtnArea = self.___ex.automaticBtnArea
    self.seasonTitleGo = self.___ex.seasonTitleGo
    self.helpBtn = self.___ex.helpBtn

    self.btnAutoClearFormation:regOnButtonClick(function()
        self:ClearFormation()
    end)
    self.helpBtn:regOnButtonClick(function()
        self:OnHelpClick()
    end)

    -- PlayerCardCircle资源路径
    self.playerCardCirclePath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Main/Prefab/CompetePlayerCardCircle.prefab"
end

function CompeteFormationPageView:HideAutoBtnAndMoveClearBtn()
    self.btnAutoClearFormation.transform.parent.localPosition  = self.automaticBtnArea.transform.localPosition
    GameObjectHelper.FastSetActive(self.automaticBtnArea.gameObject, false)
end

function CompeteFormationPageView:InitView(playerTeamsModel, formationCacheDataModel)
    CompeteFormationPageView.super.InitView(self, playerTeamsModel, formationCacheDataModel)
    self.competeSpecialTeamData = formationCacheDataModel.competeSpecialTeamData
    local competeSeasonName = self.competeSpecialTeamData and self.competeSpecialTeamData.name
    if competeSeasonName then
        self.seasonNameTxt.text = lang.transstr("compete_formation_title") .. ":" .. competeSeasonName
        GameObjectHelper.FastSetActive(self.seasonTitleGo, true)
    else
        GameObjectHelper.FastSetActive(self.seasonTitleGo, false)
    end
end

-- 初始化候补滚动视图
function CompeteFormationPageView:InitCandidateScrollerView()
    self.candidateScrollerView:InitView(self.waitPlayersNoRepeatList, self.waitPlayersRepeatList, self.nowCardShowType, self, self.matchId, self.formationCacheDataModel)
end

function CompeteFormationPageView:PostSaveTeamData()
    self:SaveTeamData(
        function()
            DialogManager.ShowToastByLang("formation_saveSuccess")
            self:FormationDataChange(false)
        end
    )
end

function CompeteFormationPageView:RefreshPage(isPush)
    CompeteFormationPageView.super.RefreshPage(self, isPush)
end

function CompeteFormationPageView:ClearFormation()
    local title = lang.trans("clear_formation_title")
    local content = lang.trans("clear_formation_content2")
    DialogManager.ShowConfirmPop(title, content, function() self:ClearCourtPlayers() end)
end

function CompeteFormationPageView:ClearCourtPlayers()
    self:coroutine(function()
        local resp = req.competeTeamClear(self.playerTeamsModel:GetTeamType())
        if api.success(resp) then
            self.initPlayersData = self.playerTeamsModel:GetClearStartersData()
            self.replacePlayersData = self.playerTeamsModel:GetClearBenchData()
            self.formationCacheDataModel:SetInitPlayerCacheData(self.initPlayersData)
            self.formationCacheDataModel:SetReplacePlayerCacheData(self.replacePlayersData)
            self.formationCacheDataModel:SetTacticsCacheData( { })
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
function CompeteFormationPageView:SaveTeamData(onComplete)
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
        local resp = req.worldTournamentSaveTeam(self.nowTeamId, self.nowFormationId, self.initPlayersData, replacePlayersData, teamType, keyPlayersData, tacticsData, self.selectedType)
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

function CompeteFormationPageView:OnHelpClick()
    local title = lang.trans("tips")
    local msg = self.competeSpecialTeamData.desc
    DialogManager.ShowAlertPop(title, msg)
end

return CompeteFormationPageView

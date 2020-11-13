local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local DialogManager = require("ui.control.manager.DialogManager")
local FormationPageView = require("ui.scene.formation.FormationPageView")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local ManyFormationPageView = class(FormationPageView, "ManyFormationPageView")

function ManyFormationPageView:ctor()
    ManyFormationPageView.super.ctor(self)
    -- 设置为默认阵容按钮
    self.setDefaultFormationBtn = self.___ex.setDefaultFormationBtn
    -- 一键清空按钮
    self.clearFormationBtn = self.___ex.clearFormationBtn
    self.switchFormationGroup = self.___ex.switchFormationGroup
    self.defaultFormationText = self.___ex.defaultFormationText
    self.benchFormationText = self.___ex.benchFormationText
    self.teamOne = self.___ex.teamOne
    self.teamTwo = self.___ex.teamTwo
    self.teamThree = self.___ex.teamThree
    self.iconOne = self.___ex.iconOne
    self.iconTwo = self.___ex.iconTwo
    self.iconThree = self.___ex.iconThree
    self.oneBtn = self.___ex.oneBtn
    self.twoBtn = self.___ex.twoBtn
    self.threeBtn = self.___ex.threeBtn
end

function ManyFormationPageView:InitView(playerTeamsModel, formationCacheDataModel)
    ManyFormationPageView.super.InitView(self, playerTeamsModel, formationCacheDataModel)
    self.iconSet = {self.iconOne, self.iconTwo, self.iconThree}
    self.teamSwitchBtnSet = {self.oneBtn, self.twoBtn, self.threeBtn} 
    self:BindManyFormationEvent()
    local initCurrTeamId = self.formationCacheDataModel:GetInitCurrTeamId()
    local cacheTeamId = self.formationCacheDataModel:GetCacheTeamId()
    self.nowTeamId = cacheTeamId or initCurrTeamId
    self:InitDefaultIcon(initCurrTeamId)
    self:InitButtonImage(self.nowTeamId)
    self:SetTheFormationText(self.nowTeamId)
end

function ManyFormationPageView:BindManyFormationEvent()
    -- 设置为默认阵容按钮
    self.setDefaultFormationBtn:regOnButtonClick(function()
        local validType = self:CheckTeamValid()
        if validType == FormationConstants.FormationValidType.VALID then
            self.formationCacheDataModel:SetInitCurrTeamId(self.nowTeamId)
            if self.formationCacheDataModel:CheckNowTeamIdChanged() then
                DialogManager.ShowToastByLang("formation_currFormationIsSetDefault")
            else
                DialogManager.ShowToastByLang("formation_currFormationIsDefault")
            end
            self:InitDefaultIcon(self.formationCacheDataModel:GetInitCurrTeamId())
            self:SetTheFormationText(self.formationCacheDataModel:GetInitCurrTeamId())
        else
            DialogManager.ShowToastByLang("formation_currFormationCanNotSetDefault")
        end
    end)
    -- 设置一键清空按钮
    self.clearFormationBtn:regOnButtonClick(function()
        self:ClearFormation()
    end)
    -- 设置阵容切换按钮
    self:SetSwitchGroupBindEvent()
end


function ManyFormationPageView:SetTheFormationText(teamId)
    if teamId then
        self.defaultFormationText:SetActive(true)
        self.benchFormationText:SetActive(false)
        return 
    end
    local flag = self.nowTeamId == self.formationCacheDataModel:GetInitCurrTeamId()
    if flag == true then
        self.defaultFormationText:SetActive(true)
        self.benchFormationText:SetActive(false)
    else
        self.defaultFormationText:SetActive(false)
        self.benchFormationText:SetActive(true)
    end
end

function ManyFormationPageView:InitButtonImage(index)
    for i = 1, #self.teamSwitchBtnSet do
        if i-1 == index then
            self.teamSwitchBtnSet[i].Image.overrideSprite = res.LoadRes(format("Assets/CapstonesRes/Game/UI/Scene/Formation/Images/PagClick.png"))
            self.teamSwitchBtnSet[i].Text2:SetActive(true)
            self.teamSwitchBtnSet[i].Text:SetActive(false)
        else
            self.teamSwitchBtnSet[i].Image.overrideSprite = res.LoadRes(format("Assets/CapstonesRes/Game/UI/Scene/Formation/Images/PageCommon.png")) 
            self.teamSwitchBtnSet[i].Text2:SetActive(false)
            self.teamSwitchBtnSet[i].Text:SetActive(true)
        end
    end
end

function ManyFormationPageView:InitDefaultIcon(index)
    for i = 1, #self.iconSet do
        if i-1 == index then
            self.iconSet[i]:SetActive(true)
        else
            self.iconSet[i]:SetActive(false)
        end
    end
end

-- 询问是否保存阵容
function ManyFormationPageView:AskSaveTeamOrNot(callback)
    -- 如果阵容已修改
    if self:CheckTeamChanged() then
        DialogManager.ShowConfirmPopByLang("formation_saveFormation", "formation_useTeamOrNot", function ()
            -- 阵容是否合法
            local validType = self:CheckTeamValid()
            if validType == FormationConstants.FormationValidType.VALID then
                self:SaveTeamData(function ()
                    if type(callback) == "function" then
                        callback()
                    end
                end)
            elseif validType == FormationConstants.FormationValidType.NOVALID_INITPLAYERS_NOTENOUGH then
                DialogManager.ShowToastByLang("formation_validType_initPlayers_notEnough")
                self:InitButtonImage(self.nowTeamId)
            elseif validType == FormationConstants.FormationValidType.NOVALID_HASSAMEPLAYER then
                DialogManager.ShowToastByLang("formation_validType_hasSamePlayer")
                self:InitButtonImage(self.nowTeamId)
            end
        end, function ()
            self:ResetTeamDataSelectedType()
            if type(callback) == "function" then
                callback()
            end
        end, nil, DialogManager.DialogType.GeneralBox)
    else
        self:ResetTeamDataSelectedType()
        if type(callback) == "function" then
            callback()
        end
    end
end


-- 阵容切换封装函数
function ManyFormationPageView:SwitchFormationFun(index)
    self:AskSaveTeamOrNot(function()
        self.nowTeamId = index
        self.formationCacheDataModel:SetCacheTeamId(index)
        self:SwitchTeam(self.nowTeamId)
        self:SetTheFormationText()
        self:InitDefaultIcon(self.formationCacheDataModel:GetInitCurrTeamId())
        self:InitButtonImage(self.nowTeamId)
    end)
end

-- 设置阵容切换按钮
function ManyFormationPageView:SetSwitchGroupBindEvent()
    self.teamOne:regOnButtonClick(function()
        if self.nowTeamId == 0 then
            return
        end
        self:SwitchFormationFun(0)
        self:InitDefaultIcon(self.formationCacheDataModel:GetInitCurrTeamId())
        self:InitButtonImage(self.nowTeamId)
    end)
    self.teamTwo:regOnButtonClick(function()
        if self.nowTeamId == 1 then
            return
        end
        self:SwitchFormationFun(1)
        self:InitDefaultIcon(self.formationCacheDataModel:GetInitCurrTeamId())
        self:InitButtonImage(self.nowTeamId)
    end)
    self.teamThree:regOnButtonClick(function()
        if self.nowTeamId == 2 then
            return
        end
        self:SwitchFormationFun(2)
        self:InitDefaultIcon(self.formationCacheDataModel:GetInitCurrTeamId())
        self:InitButtonImage(self.nowTeamId)
    end)
end


function ManyFormationPageView:PostSaveTeamData()
    self:SaveTeamData(
        function()
            DialogManager.ShowToastByLang("formation_saveSuccess")
            self:FormationDataChange(false)
        end
    )
end


function ManyFormationPageView:RefreshPage(isPush, playerTeamsModel, formationCacheDataModel)
    self.playerTeamsModel = playerTeamsModel and playerTeamsModel or self.playerTeamsModel
    self.formationCacheDataModel = formationCacheDataModel and formationCacheDataModel or self.formationCacheDataModel
    
    if isPush then
        self:InitDefaultIcon(self.playerTeamsModel:GetNowTeamId())
        self:InitButtonImage(self.playerTeamsModel:GetNowTeamId())
        self:SetTheFormationText(self.playerTeamsModel:GetNowTeamId())
        self:RefreshCurrentTeamData(self.playerTeamsModel:GetNowTeamId())
    end
    ManyFormationPageView.super.RefreshPage(self, isPush)
end

function ManyFormationPageView:ClearFormation()
    if self.nowTeamId == self.formationCacheDataModel:GetInitCurrTeamId() then
        DialogManager.ShowToastByLang("formation_notClearDefaultFormation")
        return
    end
    local title = lang.trans("clear_formation_title")
    local content = lang.trans("formation_clearNonDefaultFormation")
    DialogManager.ShowConfirmPop(
        title,
        content,
        function()
            self:ClearCourtPlayers()
        end
    )
end

function ManyFormationPageView:ClearCourtPlayers()
    self:coroutine(
        function()
            local teamType = self.formationCacheDataModel:GetTeamType()
            local resp = req.teamClear(self.nowTeamId, teamType)
            if api.success(resp) then
                self.initPlayersData = self.playerTeamsModel:GetClearCurrentTeamStartersData(self.nowTeamId)
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
        end
    )
end


-- 保存阵容数据
function ManyFormationPageView:SaveTeamData(onComplete)
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
        local flag = self.formationCacheDataModel.currTeamIdChanged
        local teamType = self.playerTeamsModel:GetTeamType()
        local resp = req.saveTeam(self.nowTeamId, self.nowFormationId, self.initPlayersData, replacePlayersData, teamType, keyPlayersData, tacticsData, self.selectedType, flag)
        if api.success(resp) then
            self:UpdateTeamData(resp.val)
            if type(onComplete) == "function" then
                onComplete()
            end
            -- 保存阵型
            GuideManager.Show(self)
        end
    end)
end

return ManyFormationPageView

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local SortType = require("ui.controllers.playerList.SortType")
local PosType = require("ui.controllers.playerList.PosType")
local Letter2NumPos = require("data.Letter2NumPos")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Vector2 = UnityEngine.Vector2

local PlayerSearchView = class(unity.base)

local HWCardQuality = "5_Plus"

PlayerSearchView.SkillCount = 3

function PlayerSearchView:ctor()
    self.title = self.___ex.title
    self.btnConfirm = self.___ex.btnConfirm
    self.btnReset = self.___ex.btnReset
    self.close = self.___ex.close
    self.posArea = self.___ex.posArea
    self.qualityArea = self.___ex.qualityArea
    self.skillInfo = self.___ex.skillInfo
    self.btnCloseSkill = self.___ex.btnCloseSkill
    self.selectNationView = self.___ex.selectNationView
    self.mainPage = self.___ex.mainPage
    self.skillPage = self.___ex.skillPage
    self.skillScrollView = self.___ex.skillScrollView
    self.skillScrollRect = self.___ex.skillScrollRect
    self.btnSkillConfirm = self.___ex.btnSkillConfirm
    self.btnSkillCancel = self.___ex.btnSkillCancel
    self.skillContent = self.___ex.skillContent
    self.skillLayout = self.___ex.skillLayout
    self.nameInput = self.___ex.nameInput
    self.posSearchMap = {}
    self.qualitySearchMap = {}
    self.skillSearchMap = {}
    self.qualityAreaLayout = self.___ex.qualityAreaLayout
end

function PlayerSearchView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
    self.btnReset:regOnButtonClick(function()
        self:OnBtnReset()
    end)
    self.close:regOnButtonClick(function()
        self:Close()
    end)
    self.btnSkillConfirm:regOnButtonClick(function()
        self:SkillSelectConfirm()
    end)
    self.btnSkillCancel:regOnButtonClick(function()
        self:SkillSelectCancel()
        self:SkillSelectConfirm()
    end)
    DialogAnimation.Appear(self.transform)
    EventSystem.AddEvent("PlayerSearch.OnNationClick", self, self.PlayerSearchOnNationSelect)
    EventSystem.AddEvent("PlayerSearchView.UpdateSkillSelectCount", self, self.UpdateSkillSelectCount)
end

function PlayerSearchView:Close()
    self.cardIndexViewModel:CancelSelect()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function PlayerSearchView:OnBtnConfirm()
    self.selectName = self.nameInput.text
    self.selectNationality = self.cardIndexViewModel:GetSeletNationData() and self.cardIndexViewModel:GetSeletNationData().nationality or ""
    self.cardIndexViewModel:SetSeletSkillConfirmData()
    self.cardIndexViewModel:SetSeletNationConfirmData()
    self:ClickConfirm()
    self:Close()
end

function PlayerSearchView:ClickConfirm()
    if self.clickConfirm then
        self.clickConfirm(self.selectPos, self.selectQuality, self.selectNationality, self.selectName, self.selectSkill)
    end
end

function PlayerSearchView:OnBtnReset()
    if self.clickReset then
        self.clickReset()
    end
end

function PlayerSearchView:OnReset()
    for index, v in pairs(self.selectPos) do
        local currentPos = self.posSearchMap[index]
        currentPos:ChangeState(false)
    end
    for index, v in pairs(self.selectQuality) do
        local currentQuality = self.qualitySearchMap[index]
        currentQuality:ChangeState(false)
    end
    self.selectPos = {}
    self.selectQuality = {}
    self.selectSkill = {}
    self.skillViewMap = {}
    self.selectName = ""
    self.nameInput.text = self.selectName
    self.selectNationality = ""
    self.skillCounter = 0
    self.cardIndexViewModel:SetSeletNationData(nil)
    self.cardIndexViewModel:SetSeletSkillDataMap(nil)
    self:ClickConfirm()
    self:UpdateSkillView()
    EventSystem.SendEvent("CardSelectNation.OnCancelSelect")
end

function PlayerSearchView:ClickQualitySearch(index)
    local currentItemBar = self.qualitySearchMap[index]
    if self.selectQuality[index] then 
        self.selectQuality[index] = nil
        currentItemBar:ChangeState(false)
    else
        self.selectQuality[index] = true
        currentItemBar:ChangeState(true)
    end
end

function PlayerSearchView:ClickPosSearch(index)
    local currentItemBar = self.posSearchMap[index]
    if self.selectPos[index] then 
        self.selectPos[index] = nil
        currentItemBar:ChangeState(false)
    else
        self.selectPos[index] = true
        currentItemBar:ChangeState(true)
    end
end

function PlayerSearchView:InitView(playerListModel, cardIndexViewModel)
    self.playerListModel = playerListModel
    self.cardIndexViewModel = cardIndexViewModel
    self:OpenMainPageView()
    local searchPrefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/SearchBar.prefab")
    self:InitPositionView(searchPrefab)
    self:InitQualityView(searchPrefab)
    self:InitSelectBar()
    self:InitSeletNationView()
    self:InitSkillSelectArea()
    self:InitNameInputView()
end

function PlayerSearchView:InitSeletNationView()
    self.selectNationView:InitView(self.cardIndexViewModel)
end

function PlayerSearchView:InitPositionView(searchPrefab)
    for i = 1, table.nums(PosType) do
        local searchObject = Object.Instantiate(searchPrefab)
        local spt = res.GetLuaScript(searchObject)
        searchObject.transform:SetParent(self.posArea, false)
        local desc = Letter2NumPos[PosType[i]].displayPos
        spt:InitView(desc, true)
        spt.clickSearch = function() self:ClickPosSearch(i) end
        self.posSearchMap[i] = spt
    end
end

function PlayerSearchView:InitQualityView(searchPrefab)
    local keys = table.keys(CardHelper.QualitySign)
    if table.nums(keys) > 12 then
        self.qualityAreaLayout.spacing = Vector2(0, 0)
    else
        self.qualityAreaLayout.spacing = Vector2(0, 20)
    end
    table.sort(keys, function(a, b) return a < b end)
    for i = 1, #keys do
        local searchObject = Object.Instantiate(searchPrefab)
        local spt = res.GetLuaScript(searchObject)
        searchObject.transform:SetParent(self.qualityArea, false)
        local desc = CardHelper.GetQualitySign(keys[i])
        spt:InitView(desc, true)
        spt.clickSearch = function() self:ClickQualitySearch(keys[i]) end
        self.qualitySearchMap[keys[i]] = spt
    end
    -- if not cache.getIsContainHWCard() then
    --     GameObjectHelper.FastSetActive(self.qualitySearchMap[HWCardQuality].gameObject, false)
    -- end
end

function PlayerSearchView:InitSelectBar()
    self.selectPos = self.cardIndexViewModel:GetViewPosition()
    if self.selectPos then
        for k, v in pairs(self.selectPos) do
            self.posSearchMap[k]:ChangeState(true)
        end
    end
    self.selectQuality = self.cardIndexViewModel:GetViewQuality()
    if self.selectQuality then
        for k, v in pairs(self.selectQuality) do
            self.qualitySearchMap[k]:ChangeState(true)
        end
    end
end

function PlayerSearchView:InitNameInputView()
    self.selectName = self.cardIndexViewModel:GetViewPlayerName()
    self.nameInput.text = self.selectName
end

function PlayerSearchView:PlayerSearchOnNationSelect(selectNationName, selectNationData)
    if selectNationName ~= "" then
        self.selectNationality = selectNationName
        self.selectNationData = nil
    else
        self.selectNationality = ""
        self.selectNationData = selectNationData
    end
    self.cardIndexViewModel:SetSeletNationData(selectNationData)
end

function PlayerSearchView:InitSkillSelectArea()
    local skillPrefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardIndex/SkillItemButton.prefab")
    self.selectSkill = self.cardIndexViewModel:GetViewSkill()
    self.skillTempMap = {}
    self.skillViewMap = self.cardIndexViewModel:GetSeletSkillDataMap()
    if table.nums(self.skillViewMap) == 0 then
        for i = 1, PlayerSearchView.SkillCount do
            self.skillViewMap[i] = ""
            self.skillTempMap[i] = ""
        end
    end
    -- 选择
    self.skillSptMap = {}
    for i = 1, PlayerSearchView.SkillCount do
        local skill = Object.Instantiate(skillPrefab)
        local spt = res.GetLuaScript(skill)
        skill.transform:SetParent(self.skillLayout, false)
        spt.selectBtn:regOnButtonClick(function() self:OnSkillSelectClick() end)
        spt:InitView(self, 1, "")
        self.skillSptMap[i] = spt
    end
    self:UpdateSkillView()
    self:UpdateSkillSelectCount()
end

function PlayerSearchView:UpdateSkillView()
    self.skillCounter = 0
    if self.skillSptMap then
        for i = 1, PlayerSearchView.SkillCount do
            if self.skillViewMap and self.selectSkill[i] then
                self.skillCounter = self.skillCounter + 1
                self.skillSptMap[i]:InitView(self, 3, self.cardIndexViewModel:GetSkillData(self.selectSkill[i]))
                self.skillViewMap[i] = self.selectSkill[i]
            else
                self.skillSptMap[i]:InitView(self, 1, "")
                self.skillViewMap[i] = ""
            end
        end
    end
end

function PlayerSearchView:UpdateSkillSelectCount()
    self.skillInfo.text = lang.trans("cardIndex_selectSkillCount", self.skillCounter, PlayerSearchView.SkillCount)
end

function PlayerSearchView:OnSkillSelectClick()
    self:OpenSkillPageView()
end

function PlayerSearchView:OpenSkillPageView()
    self.close:unRegOnButtonClick(function()
        self:Close()
    end)
    self.close:regOnButtonClick(function()
        self:SkillSelectCancel()
        self:OpenMainPageView()
    end)
    self:UpdateSkillSelectCount()
    GameObjectHelper.FastSetActive(self.mainPage, false)
    GameObjectHelper.FastSetActive(self.skillPage, true)
    self.title.text = lang.trans("cardIndex_selectSkill")
    EventSystem.SendEvent("SkillItemList.UpdateState")
end

function PlayerSearchView:OpenMainPageView()
    GameObjectHelper.FastSetActive(self.mainPage, true)
    GameObjectHelper.FastSetActive(self.skillPage, false)
    self.title.text = lang.trans("cardIndex_selectTitle")
    self.close:unRegOnButtonClick(function()
        self:SkillSelectCancel()
        self:OpenMainPageView()
    end)
    self.close:regOnButtonClick(function()
        self:Close()
    end)
    self:UpdateSkillView()
end

function PlayerSearchView:SkillSelectConfirm()
    self.selectSkill = {}
    for index, sid in pairs(self.skillViewMap) do
        if sid ~= "" then
            table.insert(self.selectSkill, sid)
        end
        self.skillTempMap[index] = sid
    end
    self.cardIndexViewModel:SetSeletSkillDataMap(self.skillViewMap)
    self:OpenMainPageView()
end

function PlayerSearchView:SkillSelectCancel()
    self.skillCounter = 0
    for i = 1, PlayerSearchView.SkillCount do
        self.skillViewMap[i] = ""
        self.skillTempMap[i] = ""
    end
    
    EventSystem.SendEvent("SkillItemList.CancelSelectSkill")
    self.cardIndexViewModel:SetSeletSkillDataMap(self.skillViewMap)
    self:UpdateSkillSelectCount()
end

function PlayerSearchView:onDestroy()
    EventSystem.RemoveEvent("PlayerSearch.OnNationClick", self, self.PlayerSearchOnNationSelect)
    EventSystem.RemoveEvent("PlayerSearchView.UpdateSkillSelectCount", self, self.UpdateSkillSelectCount)
end

return PlayerSearchView

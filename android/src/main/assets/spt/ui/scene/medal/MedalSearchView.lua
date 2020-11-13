local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local SortType = require("ui.controllers.playerList.SortType")
local Letter2NumPos = require("data.Letter2NumPos")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local MedalSearchView = class(unity.base, "MedalSearchView")

MedalSearchView.SkillCount = 1

local EventSkillCount = 1
local MedalSkillCount = 1

local SkillPageType = {
    Event = 1,
    Medal = 2
}

local skillPrefabPath = "Assets/CapstonesRes/Game/UI/Scene/CardIndex/SkillItemButton.prefab"

function MedalSearchView:ctor()
    self.title = self.___ex.title
    self.btnConfirm = self.___ex.btnConfirm
    self.btnReset = self.___ex.btnReset
    self.close = self.___ex.close
    self.posArea = self.___ex.posArea
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
    self.selectBodyView = self.___ex.selectBodyView
    self.selectQualityView = self.___ex.selectQualityView
    self.eventSkillGroup = self.___ex.eventSkillGroup
    self.medalSkillGroup = self.___ex.medalSkillGroup

    self.selectAttr = {}
    self.selectBody = nil -- 不使用
    self.selectQuality = nil -- 不使用
    self.selectSkill = {} -- 无用声明，skillSelectItemView中有访问
    self.skillViewMap = {} -- 无用的声明，因为SkillSelectItemView中有访问，所以必须处理
    
    self.skillCounter = 0 -- SkillSelectItemView使用此参数
    self.eventSkillCounter = 0
    self.medalSkillCounter = 0
    self.currSkillPageType = nil -- eventSkill or medalSkill
    -- 右侧两个技能icon的控制脚本
    self.skillSptMap = {}
    -- 额外属性筛选
    self.attrSearchMap = {}
end

function MedalSearchView:start()
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
    end)
    -- not use
    self.selectBodyView.selectDropdown = function(selectDropdownKey) self:SelectBodyDropdown(selectDropdownKey) end
    self.selectQualityView.selectDropdown = function(selectDropdownKey) self:SelectQualityDropdown(selectDropdownKey) end

    DialogAnimation.Appear(self.transform)
end

function MedalSearchView:InitView(medalListModel, medalListSkillSearchModel)
    self.medalListModel = medalListModel
    self.medalListSkillSearchModel = medalListSkillSearchModel
    self:OpenMainPageView()
    local searchPrefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/SearchBar.prefab")
    self:InitAttrView(searchPrefab)
    self:InitSelectBodyView()
    self:InitSelectQualityView()
    self:InitSkillSelectArea()
end

-- 不使用
function MedalSearchView:InitSelectBodyView()
    local boxRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/DropdownBox.prefab")
    self.selectBody = self.medalListModel:GetSelectBodyCache()
    local bodyDropdownMap = self.medalListModel:GetBodyDropdownMap()
    self.selectBodyView:InitView(self.medalListModel, boxRes, self.selectBody, bodyDropdownMap)
end

-- 不使用
function MedalSearchView:InitSelectQualityView()
    local boxRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/DropdownBox.prefab")
    self.selectQuality = self.medalListModel:GetSelectQualityCache()
    local qualityDropdownMap = self.medalListModel:GetQualityDropdownMap()
    self.selectQualityView:InitView(self.medalListModel, boxRes, self.selectQuality, qualityDropdownMap)
end

function MedalSearchView:InitAttrView(searchPrefab)
    local attrMap = {}
    for i, v in ipairs(CardHelper.NormalPlayerOrder) do
        table.insert(attrMap, v)
    end
    for i, v in ipairs(CardHelper.GoalKeeperOrder) do
        table.insert(attrMap, v)
    end
    self.selectAttr = self.medalListModel:GetAttrCache()
    for i, attr in ipairs(attrMap) do
        local searchObject = Object.Instantiate(searchPrefab)
        local spt = res.GetLuaScript(searchObject)
        searchObject.transform:SetParent(self.posArea, false)
        local desc = lang.trans(attr)
        spt:InitView(desc, true)
        local isSelect = self.selectAttr[attr] and true or false
        spt:ChangeState(isSelect)
        spt.clickSearch = function() self:ClickAttrSearch(i, attr) end
        self.attrSearchMap[i] = spt
    end
end

-- 初始化右侧两个点选技能面板
function MedalSearchView:InitSkillSelectArea()
    -- 获得当前情况下用户已选择的技能初始化技能列表中对号
    self.selectSkill = self.medalListSkillSearchModel:GetSelectSkill()
    self.skillViewMap = {}
    if table.nums(self.skillViewMap) == 0 then
        for i = 1, MedalSearchView.SkillCount do
            self.skillViewMap[i] = ""
        end
    end

    self.skillSptMap = {}

    -- 初始化普通技能筛选icon
    local eventSkillObj, eventSkillSpt = res.Instantiate(skillPrefabPath)
    eventSkillObj.transform:SetParent(self.eventSkillGroup.transform, false)
    eventSkillSpt.selectBtn:regOnButtonClick(function() self:OnEventSkillSearch() end)
    eventSkillSpt:InitView(self, 1, "")
    self.skillSptMap.eventSkill = eventSkillSpt
    -- 初始化荣耀技能筛选icon
    local medalSkillObj, medalSkillSpt = res.Instantiate(skillPrefabPath)
    medalSkillObj.transform:SetParent(self.medalSkillGroup.transform, false)
    medalSkillSpt.selectBtn:regOnButtonClick(function() self:OnMedalSkillSearch() end)
    medalSkillSpt:InitView(self, 1, "")
    self.skillSptMap.medalSkill = medalSkillSpt
    -- 根据用户已选择的内容更新界面显示
    self:UpdateSkillView()
end

function MedalSearchView:OpenMainPageView()
    GameObjectHelper.FastSetActive(self.mainPage, true)
    GameObjectHelper.FastSetActive(self.skillPage, false)

    self.close:unRegOnButtonClick(function()
        self:OpenMainPageView()
    end)
    self.close:regOnButtonClick(function()
        self:RecoverPreData()
        self:Close()
    end)
    self.title.text = lang.trans("medal_info_select")
end

function MedalSearchView:OpenSkillPageView()
    self.close:unRegOnButtonClick(function()
        self:Close()
    end)
    self.close:regOnButtonClick(function()
        self:OnPageSkillClose()
        self:OpenMainPageView()
    end)
    GameObjectHelper.FastSetActive(self.mainPage, false)
    GameObjectHelper.FastSetActive(self.skillPage, true)
    self.title.text = lang.trans("cardIndex_selectSkill")
    -- skillSelectItemView中
    EventSystem.SendEvent("SkillItemList.UpdateState")
end

function MedalSearchView:OnBtnConfirm()
    self:ClickConfirm()
    self:Close()
end

function MedalSearchView:ClickConfirm()
    if self.clickConfirm then
        self.clickConfirm(self.selectAttr, self.selectBody, self.selectQuality, self.medalListSkillSearchModel:GetSelectSkill())
    end
end

function MedalSearchView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function MedalSearchView:OnBtnReset()
    if self.clickReset then
        self.clickReset()
    end
end

function MedalSearchView:OnReset()
    -- 取消属性选择
    for attr, index in pairs(self.selectAttr) do
        local currentAttr = self.attrSearchMap[index]
        currentAttr:ChangeState(false)
    end
    -- 取消技能选择
    self:CancelSkillTempChoose()

    self.selectAttr = {}
    self.selectBody = nil
    self.selectQuality = nil
    self.selectSkill = {}
    self.skillViewMap = {}
    self.skillCounter = 0

    -- 更新右侧技能面板
    self:UpdateSkillView()
end

-- 不使用
function MedalSearchView:SelectBodyDropdown(selectDropdownKey)
    self.selectBody = selectDropdownKey
end

-- 不使用
function MedalSearchView:SelectQualityDropdown(selectDropdownKey)
    self.selectQuality = selectDropdownKey
end

function MedalSearchView:ClickAttrSearch(index, attr)
    local currentItemBar = self.attrSearchMap[index]
    if self.selectAttr[attr] then 
        self.selectAttr[attr] = nil
        currentItemBar:ChangeState(false)
    else
        self.selectAttr[attr] = index
        currentItemBar:ChangeState(true)
    end
end

function MedalSearchView:EnterScene()
    EventSystem.AddEvent("MedalSearchView.UpdateSelectSkill", self, self.UpdateSelectSkill)
end

function MedalSearchView:ExitScene()
    EventSystem.RemoveEvent("MedalSearchView.UpdateSelectSkill", self, self.UpdateSelectSkill)
end

-- 技能面板相关
-- 更新技能列表左下方显示文本
function MedalSearchView:UpdateEventSkillSelectCount()
    self.skillInfo.text = lang.trans("cardIndex_selectSkillCount", self.eventSkillCounter, EventSkillCount)
end

function MedalSearchView:UpdateMedalSkillSelectCount()
    self.skillInfo.text = lang.trans("cardIndex_selectSkillCount", self.medalSkillCounter, MedalSkillCount)
end

-- 更新右侧技能选择面板内容
function MedalSearchView:UpdateSkillView()
    local selectEventSkill = self.medalListSkillSearchModel:GetSelectEventSkillData()
    if not selectEventSkill then
        self.skillSptMap.eventSkill:InitView(self, 1, "")
    else
        self.skillSptMap.eventSkill:InitView(self, 3, selectEventSkill)
    end

    local selectMedalSkill = self.medalListSkillSearchModel:GetSelectMedalSkillData()
    if not selectMedalSkill then
        self.skillSptMap.medalSkill:InitView(self, 1, "")
    else
        self.skillSptMap.medalSkill:InitView(self, 3, selectMedalSkill)
    end
end

-- 点击打开Event技能筛选列表
function MedalSearchView:OnEventSkillSearch()
    self.currSkillPageType = SkillPageType.Event
    self.eventSkillCounter = self.medalListSkillSearchModel:GetEventSelectSkillNum()
    self.skillCounter = self.eventSkillCounter
    self.medalListSkillSearchModel:SetSelectEventTempSkillData(self.medalListSkillSearchModel:GetSelectEventSkillData())
    self:OpenSkillPageView()
    self:UpdateEventSkillSelectCount()
    if self.onClickEventSkillSearch then
        self.onClickEventSkillSearch()
    end
end

-- 点击打开Medal技能筛选列表
function MedalSearchView:OnMedalSkillSearch()
    self.currSkillPageType = SkillPageType.Medal
    self.medalSkillCounter = self.medalListSkillSearchModel:GetMedalSelectSkillNum()
    self.skillCounter = self.medalSkillCounter
    self.medalListSkillSearchModel:SetSelectMedalTempSkillData(self.medalListSkillSearchModel:GetSelectMedalSkillData())
    self:OpenSkillPageView()
    self:UpdateMedalSkillSelectCount()
    if self.onClickMedalSkillSearch then
        self.onClickMedalSkillSearch()
    end
end

-- 选择技能事件函数
function MedalSearchView:UpdateSelectSkill(selectSkillData)
    if self.currSkillPageType == SkillPageType.Event then
        -- 临时存储，确认时传递至MedalListSkillSearchModel
        self.medalListSkillSearchModel:SetSelectEventTempSkillData(selectSkillData)
        self.eventSkillCounter = selectSkillData.isSelect and self.eventSkillCounter + 1 or self.eventSkillCounter - 1
        self:UpdateEventSkillSelectCount()
    elseif self.currSkillPageType == SkillPageType.Medal then
        self.medalListSkillSearchModel:SetSelectMedalTempSkillData(selectSkillData)
        self.medalSkillCounter = selectSkillData.isSelect and self.medalSkillCounter + 1 or self.medalSkillCounter - 1
        self:UpdateMedalSkillSelectCount()
    end
end

-- 点击技能面板的确认
function MedalSearchView:SkillSelectConfirm()
    if self.currSkillPageType == SkillPageType.Event then
        -- 界面上临时存储的技能选择传递给最终选择
        self.medalListSkillSearchModel:SetSelectEventSkillData(self.medalListSkillSearchModel:GetSelectEventTempSkillData())
    elseif self.currSkillPageType == SkillPageType.Medal then
        self.medalListSkillSearchModel:SetSelectMedalSkillData(self.medalListSkillSearchModel:GetSelectMedalTempSkillData())
    end
    self:UpdateSkillView()
    self:OpenMainPageView()
end

-- 点击技能面板的重置
function MedalSearchView:SkillSelectCancel()
    for i = 1, MedalSearchView.SkillCount do
        self.skillViewMap[i] = ""
    end

    if self.currSkillPageType == SkillPageType.Event then
        self.medalListSkillSearchModel:ResetSelectEventTempSkillData()
        self.eventSkillCounter = 0
        self.skillCounter = self.eventSkillCounter
        self:UpdateEventSkillSelectCount()
    elseif self.currSkillPageType == SkillPageType.Medal then
        self.medalListSkillSearchModel:ResetSelectMedalTempSkillData()
        self.medalSkillCounter = 0
        self.skillCounter = self.medalSkillCounter
        self:UpdateMedalSkillSelectCount()
    end
    if self.currSkillPageType == SkillPageType.Event then
        -- 界面上临时存储的技能选择传递给最终选择
        self.medalListSkillSearchModel:SetSelectEventSkillData(self.medalListSkillSearchModel:GetSelectEventTempSkillData())
    elseif self.currSkillPageType == SkillPageType.Medal then
        self.medalListSkillSearchModel:SetSelectMedalSkillData(self.medalListSkillSearchModel:GetSelectMedalTempSkillData())
    end
    self:UpdateSkillView()

    -- skillSelectItemView中
    EventSystem.SendEvent("SkillItemList.CancelSelectSkill")
end

-- 点击技能面板的关闭
function MedalSearchView:OnPageSkillClose()
    self:CancelSkillTempChoose()
    self:UpdateSkillView()
    self:OpenMainPageView()
end

-- 取消技能列表界面临时选择
function MedalSearchView:CancelSkillTempChoose()
    self.medalListSkillSearchModel:ResetSelectEventTempSkillData()
    self.eventSkillCounter = 0

    self.medalListSkillSearchModel:ResetSelectMedalTempSkillData()
    self.medalSkillCounter = 0

    self.skillCounter = 0
end

function MedalSearchView:RecoverPreData()
    self.medalListSkillSearchModel:RecoverPreSkillSelectData()
end

return MedalSearchView
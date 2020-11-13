local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local Skills = require("data.Skills")
local PasterUpgradeSortType = require("ui.scene.pasterUpgrade.PasterUpgradeSortType")
local PasterUpgradeQualityType = require("ui.scene.pasterUpgrade.PasterUpgradeQualityType")

local PasterUpgradeFilterView = class(unity.base)

function PasterUpgradeFilterView:ctor()
    self.btnConfirm = self.___ex.btnConfirm
    self.btnReset = self.___ex.btnReset
    self.close = self.___ex.close
    self.skillScrollView = self.___ex.skillScrollView
    self.btnSkillConfirm = self.___ex.btnSkillConfirm
    self.btnSkillCancel = self.___ex.btnSkillCancel
    self.btnCloseSkill = self.___ex.btnCloseSkill
    self.qualityArea = self.___ex.qualityArea
    self.mainPage = self.___ex.mainPage
    self.skillPage = self.___ex.skillPage
    self.skillBtnConfirm = self.___ex.skillBtnConfirm
    self.skillBtnCancel = self.___ex.skillBtnCancel
    self.skillInfo = self.___ex.skillInfo
    self.titleTxt = self.___ex.titleTxt
    self.skillBtn = self.___ex.skillBtn
    self.skillParent = self.___ex.skillParent
    self.skillOpenState = false
    self.SkillCount = 1
    self.skillCounter = 0
    self.skillViewMap = {}
end

function PasterUpgradeFilterView:start()
    self.close:regOnButtonClick(function()
        self:Close()
        self.pasterUpgradeFilterModel:SetPreFilterSkill()
    end)

    self.btnConfirm:regOnButtonClick(function()
        self:OnConfirmClick()
    end)

    self.btnReset:regOnButtonClick(function()
        self:OnResetClick()
    end)

    self.skillBtn:regOnButtonClick(function()
        self:OnOpenSkillClick()
    end)

    self.btnSkillConfirm:regOnButtonClick(function()
        self:OnSkillConfirmClick()
    end)

    self.btnSkillCancel:regOnButtonClick(function()
        self:OnSkillCancelClick()
    end)

    DialogAnimation.Appear(self.transform, nil)
end

function PasterUpgradeFilterView:Close()
    if self.skillOpenState then
        self:ChangeSkillPageState(false)
    else
        if type(self.closeDialog) == "function" then
            DialogAnimation.Disappear(self.transform, nil, function()
                self.closeDialog()
            end)
        end
    end
    self.skillOpenState = false
end

function PasterUpgradeFilterView:OnConfirmClick()
    if self.clickConfirm then 
        self.clickConfirm()
    end
end

function PasterUpgradeFilterView:OnResetClick()
    if self.clickReset then 
        self.clickReset()
    end
end

function PasterUpgradeFilterView:UpdateSkillSelectCount()
    self.skillInfo.text = lang.trans("cardIndex_selectSkillCount", self.skillCounter, self.SkillCount)
end

function PasterUpgradeFilterView:InitView(pasterUpgradeFilterModel)
    self.pasterUpgradeFilterModel = pasterUpgradeFilterModel
    self:ChangeSkillPageState(false)
    local filterMap = self.pasterUpgradeFilterModel:GetFilterMap()
    local quality = filterMap and filterMap.quality
    local skill = filterMap and filterMap.skill
    self.selectSkill = {skill}
    self:RefreshQualityArea(quality)
    self:RefreshSkillArea(skill)
    self:UpdateSkillSelectCount()
end

function PasterUpgradeFilterView:RefreshQualityArea(qualitys)
    if not self.qualityBarList then
        self.qualityBarList = {}
        local searchBarRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/SearchBar.prefab")
        for i,v in ipairs(PasterUpgradeQualityType.Quality) do
            local obj = Object.Instantiate(searchBarRes)
            obj.transform:SetParent(self.qualityArea, false)
            self.qualityBarList[i] = res.GetLuaScript(obj)
        end
    end

    for i,v in ipairs(PasterUpgradeQualityType.Quality) do
        local qualityIndex = i
        local desc = lang.transstr(v)
        self.qualityBarList[i]:InitView(desc, true)
        self.qualityBarList[i].clickSearch = function()
            self:ClickQuality(qualityIndex)
        end
        if qualitys and qualitys[qualityIndex] then
            self.qualityBarList[qualityIndex]:ChangeState(true)
        end
    end
end

function PasterUpgradeFilterView:RefreshSkillArea(skill)
    if skill then
        self.skillCounter = 1
    end
    self:RefreshSelectSkill(skill)
    self:CreateSkillItemList()
end

function PasterUpgradeFilterView:RefreshSelectSkill(skill)
    if skill then
        GameObjectHelper.FastSetActive(self.skillParent.gameObject, true)
        if not self.selectSkillView then
            local obj, selectSkillView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardIndex/SkillItemListButton.prefab")
            self.selectSkillView = selectSkillView
            obj.transform:SetParent(self.skillParent, false)
        end
        local skillData = Skills[skill]
        skillData.name = skillData.skillName
        skillData.isSelect = false
        self.selectSkillView:InitView(self, 3, skillData)
    else
        GameObjectHelper.FastSetActive(self.skillParent.gameObject, false)
    end
    self.pasterUpgradeFilterModel:SetFilterSkill(skill)
    self:UpdateSkillSelectCount()
end

function PasterUpgradeFilterView:CreateSkillItemList()
    self.skillScrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardIndex/SkillItemListButton.prefab")
        return obj, spt
    end
    self.skillScrollView.onScrollResetItem = function(spt, index)
        local itemData = self.skillScrollView.itemDatas[index]
        spt:InitView(self, 2, itemData)
        self.skillScrollView:updateItemIndex(spt, index)
    end
    self:RefreshSkillList()
end

function PasterUpgradeFilterView:RefreshSkillList()
    local skills = self.pasterUpgradeFilterModel:GetSkillList()
    self.skillScrollView:clearData()
    for i = 1, #skills do
        table.insert(self.skillScrollView.itemDatas, skills[i])
    end
    self.skillScrollView:refresh()
    EventSystem.SendEvent("SkillItemList.UpdateState")
end

function PasterUpgradeFilterView:ClickQuality(qualityIndex)
    local filterMap = self.pasterUpgradeFilterModel:GetFilterMap()
    local curBtnState = filterMap and filterMap.quality and filterMap.quality[qualityIndex]
    if not filterMap then
       filterMap = {}
    end
    if not filterMap.quality then
       filterMap.quality = {}
    end
    filterMap.quality[qualityIndex] = not curBtnState
    self.pasterUpgradeFilterModel:SetFilterMap(filterMap)
    self.qualityBarList[qualityIndex]:ChangeState(not curBtnState)
end

function PasterUpgradeFilterView:OnOpenSkillClick()
    self:ChangeSkillPageState(true)
end

function PasterUpgradeFilterView:OnSkillConfirmClick()
    self:ChangeSkillPageState(false)
    local filterMap = self.pasterUpgradeFilterModel:GetFilterMap()
    self:RefreshSelectSkill(filterMap and filterMap.skill)
end

function PasterUpgradeFilterView:OnSkillCancelClick()
    self:RefreshSelectSkill()
    EventSystem.SendEvent("SkillItemList.CancelSelectSkill")
    self.skillCounter = 0
    self:UpdateSkillSelectCount()
end

function PasterUpgradeFilterView:ChangeSkillPageState(isOpen)
    GameObjectHelper.FastSetActive(self.mainPage, not isOpen)
    GameObjectHelper.FastSetActive(self.skillPage, isOpen)
    self.skillOpenState = isOpen
end

function PasterUpgradeFilterView:onDestroy()

end

return PasterUpgradeFilterView

local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Button = UI.Button
local CardIndexConstants = require("ui.scene.cardIndex.CardIndexConstants")
local QualityType = require("ui.controllers.cardIndex.QualityType")
local Letter2NumPos = require("data.Letter2NumPos")
local Skills = require("data.Skills")
local EventSystem = require("EventSystem")
local AssetFinder = require("ui.common.AssetFinder")
local SearchDlgView = class(unity.base)

function SearchDlgView:ctor()
    self.searchBtn = self.___ex.searchBtn
    self.posBtns = self.___ex.posBtns
    self.qualityBtns = self.___ex.qualityBtns
    self.closeBtn = self.___ex.closeBtn
    self.resetBtn = self.___ex.resetBtn
    self.skillBtns = self.___ex.skillBtns
    self.playerNameInput = self.___ex.playerNameInput
    self.skillImg = self.___ex.skillImg
    self.skillName = self.___ex.skillName
    self.emptyImg = self.___ex.emptyImg
    self.nationalityPopupListView = self.___ex.nationalityPopupListView
end

function SearchDlgView:start()
    self.searchBtn:regOnButtonClick(function()
        if type(self.searchFunc) == "function" then
            self.searchFunc()
        end
    end)

    self.resetBtn:regOnButtonClick(function()
        self:ResetAll()
    end)

    for i, v in ipairs(CardIndexConstants.PlayerPos) do
        self.posBtns["btn" .. i].transform:GetChild(0):GetComponent(Text).text = Letter2NumPos[v].displayPos
        self.posBtns["btn" .. i]:regOnButtonClick(function()
            self:OnClickPos("btn" .. i)
        end)
    end

    for i, v in ipairs(QualityType.QualityDescMap) do
        if self.qualityBtns["btn" .. i] then
            self.qualityBtns["btn" .. i].transform:GetChild(0):GetComponent(Text).text = lang.transstr(v.Desc)
            self.qualityBtns["btn" .. i]:regOnButtonClick(function()
                self:OnClickQuality(i)
            end)
        else
            break
        end
    end

    self.closeBtn:regOnButtonClick(function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)

    for k, v in pairs(self.skillBtns) do
        v:regOnButtonClick(function()
            if type(self.openSkillBoard) == "function" then
                self.openSkillBoard()
            end
        end)
    end 

    EventSystem.AddEvent("SearchDlg.RefreshSkillItem", self, self.RefreshSkillItem)
end

function SearchDlgView:InitView(cardIndexSearchModel)
    self.cardIndexSearchModel = cardIndexSearchModel
    self.nationalityPopupListView:InitView(self.cardIndexSearchModel, CardIndexConstants.ListType.NATIONALITY)
    self.nationalityPopupListView:BuildPage()
    self:RefreshSkillItem()

    self:RefreshView()
end

function SearchDlgView:RefreshView()
    local lastPos = self.cardIndexSearchModel:GetPos()
    local lastQuality = self.cardIndexSearchModel:GetQuality()
    local lastName = self.cardIndexSearchModel:GetName()
    if lastPos then
        for i, v in ipairs(CardIndexConstants.PlayerPos) do
            if Letter2NumPos[v].displayPos == lastPos then
                self:OnClickPos("btn" .. i)
            end
        end
    end

    if lastQuality then
        self:OnClickQuality(tonumber(lastQuality))
    end

    if lastName and lastName ~= "" then
        self.playerNameInput.text = lastName
    end
    self:SetNationalityFieldText()
end

function SearchDlgView:OnClickPos(btn)
    assert(type(btn) == "string")
    for k, v in pairs(self.posBtns) do
        if k ~= btn then
            v.gameObject:GetComponent(Button).interactable = false
        else
            if v.gameObject:GetComponent(Button).interactable then
                self.selectPos = nil
                v.gameObject:GetComponent(Button).interactable = false
            else
                self.selectPos = self.posBtns[btn].transform:GetChild(0):GetComponent(Text).text
                v.gameObject:GetComponent(Button).interactable = true
            end
        end
    end    
end

function SearchDlgView:OnClickQuality(quality)
    for k, v in pairs(self.qualityBtns) do
        if k ~= "btn" .. quality then
            v.gameObject:GetComponent(Button).interactable = false
        else
            if v.gameObject:GetComponent(Button).interactable then
                self.quality = nil
                v.gameObject:GetComponent(Button).interactable = false
            else
                self.quality = quality
                v.gameObject:GetComponent(Button).interactable = true
            end
        end
    end
end

function SearchDlgView:ResetAll()
    for k, v in pairs(self.qualityBtns) do
        v.gameObject:GetComponent(Button).interactable = false
    end

    for k, v in pairs(self.posBtns) do
        v.gameObject:GetComponent(Button).interactable = false
    end
    self.cardIndexSearchModel:SetSkills({})
    self.cardIndexSearchModel:SetNationality(nil)
    self:SetNationalityFieldText()
    self.playerNameInput.text = ""
    self.quality = nil
    self.selectPos = nil
end

function SearchDlgView:RefreshSkillItem()
    local selectSkills = self.cardIndexSearchModel:GetSkills()
    for i = 1, 3 do
        if selectSkills[i] then
            self.emptyImg["img" .. i]:SetActive(false)
            self.skillName["text" .. i].text = Skills[selectSkills[i]].skillName
            self.skillImg["img" .. i].gameObject:SetActive(true)
            self.skillImg["img" .. i].overrideSprite = AssetFinder.GetSkillIcon(Skills[selectSkills[i]].picIndex)
        else
            self.emptyImg["img" .. i]:SetActive(true)
            self.skillName["text" .. i].text = "?"
            self.skillImg["img" .. i].gameObject:SetActive(false)
        end
    end
end

function SearchDlgView:onDestroy()
    EventSystem.RemoveEvent("SearchDlg.RefreshSkillItem", self, self.RefreshSkillItem)
end

function SearchDlgView:GetNationalityFieldText()
    return self.nationalityPopupListView:GetInputFieldText()
end

function SearchDlgView:SetNationalityFieldText()
    self.nationalityPopupListView:SetInputFieldText()
end

return SearchDlgView

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local QualityType = require("ui.controllers.cardIndex.QualityType")
local QualitySearchView = class(unity.base)

function QualitySearchView:ctor()
    self.qualityArea = self.___ex.qualityArea
    self.btnConfirm = self.___ex.btnConfirm
    self.close = self.___ex.close
    self.qualitySearchMap = {}
end

function QualitySearchView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
    self.close:regOnButtonClick(function()
        DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
    end)
    DialogAnimation.Appear(self.transform)
end

function QualitySearchView:OnBtnConfirm()
    if self.clickConfirm then
        self.clickConfirm(self.selectQualityIndex)
    end
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function QualitySearchView:OnBtnReset()
    if self.clickReset then
        self.clickReset()
    end
end

function QualitySearchView:ClickQualitySearch(index)
    if self.selectQualityIndex ~= index then 
        local preSearch = self.qualitySearchMap[tostring(self.selectQualityIndex)]
        if preSearch then 
            preSearch:ChangeState(false)
        end
        local currentSearch = self.qualitySearchMap[tostring(index)]
        if currentSearch then 
            currentSearch:ChangeState(true)
        end
        self.selectQualityIndex = index
    end
end

function QualitySearchView:InitView(cardIndexViewModel)
    local searchPrefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/SearchBar.prefab")
    for i = table.nums(QualityType.QualityDescMap), 1, -1 do
        local searchObject = Object.Instantiate(searchPrefab)
        local spt = res.GetLuaScript(searchObject)
        searchObject.transform:SetParent(self.qualityArea, false)
        local qualityMap = QualityType.QualityDescMap[i]
        local desc = lang.trans(qualityMap.Desc)
        spt:InitView(desc)
        spt.clickSearch = function() self:ClickQualitySearch(qualityMap.Quality) end
        self.qualitySearchMap[tostring(qualityMap.Quality)] = spt
    end

    self:SetSelectBar(cardIndexViewModel)
end

function QualitySearchView:SetSelectBar(cardIndexViewModel)
    self.selectQualityIndex = cardIndexViewModel:GetQuality()
    if self.selectQualityIndex then 
        self.qualitySearchMap[tostring(self.selectQualityIndex)]:ChangeState(true)
    end
end

return QualitySearchView

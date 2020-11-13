local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local SortType = require("ui.controllers.playerList.SortType")
local PosType = require("ui.controllers.playerList.PosType")
local Letter2NumPos = require("data.Letter2NumPos")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PasterFilterView = class(unity.base)

function PasterFilterView:ctor()
    self.title = self.___ex.title
    self.btnConfirm = self.___ex.btnConfirm
    self.btnReset = self.___ex.btnReset
    self.close = self.___ex.close
    self.nameInput = self.___ex.nameInput
    self.selectNationView = self.___ex.selectNationView
    self.btnMonth = self.___ex.btnMonth
    self.btnWeek = self.___ex.btnWeek

    self.posSearchMap = {}
    self.qualitySearchMap = {}
    self.skillSearchMap = {}
end

function PasterFilterView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
    self.btnReset:regOnButtonClick(function()
        self:OnBtnReset()
    end)
    self.btnMonth:regOnButtonClick(function()
        self:OnBtnMonth()
    end)
    self.btnWeek:regOnButtonClick(function()
        self:OnBtnWeek()
    end)
    self.close:regOnButtonClick(function()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform)
    EventSystem.AddEvent("PlayerSearch.OnNationClick", self, self.PlayerSearchOnNationSelect)
end

function PasterFilterView:InitView(pasterSplitableModelList, cardIndexViewModel)
    self.cardIndexViewModel = cardIndexViewModel
    self:InitSeletNationView()
    self:InitNameInputView()
end

function PasterFilterView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function PasterFilterView:OnBtnConfirm()
    self.selectName = self.nameInput.text
    self.selectNationality = self.cardIndexViewModel:GetSeletNationData() and self.cardIndexViewModel:GetSeletNationData().nationality or ""
    self.cardIndexViewModel:SetSeletNationConfirmData()
    self:ClickConfirm()
    self:Close()
end

function PasterFilterView:ClickConfirm()
    if self.clickConfirm then
        self.clickConfirm(self.selectNationality, self.selectName)
    end
end

function PasterFilterView:OnBtnReset()
    if self.clickReset then
        self.clickReset()
    end
end

function PasterFilterView:OnBtnMonth()
    if self.clickMonth then
        self.clickMonth()
    end
end

function PasterFilterView:OnBtnWeek()
    if self.clickWeek then
        self.clickWeek()
    end
end

function PasterFilterView:OnReset()
    self.selectName = ""
    self.nameInput.text = self.selectName
    self.selectNationality = ""
    self.cardIndexViewModel:SetSeletNationData(nil)
    self:ClickConfirm()
    EventSystem.SendEvent("CardSelectNation.OnCancelSelect")
end

function PasterFilterView:InitSeletNationView()
    self.selectNationView:InitView(self.cardIndexViewModel)
end

function PasterFilterView:InitNameInputView()
    self.selectName = self.cardIndexViewModel:GetViewPlayerName()
    self.nameInput.text = self.selectName
end

function PasterFilterView:PlayerSearchOnNationSelect(selectNationName, selectNationData)
    if selectNationName ~= "" then
        self.selectNationality = selectNationName
        self.selectNationData = nil
    else
        self.selectNationality = ""
        self.selectNationData = selectNationData
    end
    self.cardIndexViewModel:SetSeletNationData(selectNationData)
end

function PasterFilterView:onDestroy()
    EventSystem.RemoveEvent("PlayerSearch.OnNationClick", self, self.PlayerSearchOnNationSelect)
end

return PasterFilterView
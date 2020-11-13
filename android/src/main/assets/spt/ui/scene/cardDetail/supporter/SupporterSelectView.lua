local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local SupporterSelectView = class(unity.base, "SupporterSelectView")

function SupporterSelectView:ctor()
--------Start_Auto_Generate--------
    self.sortSpt = self.___ex.sortSpt
    self.searchBtn = self.___ex.searchBtn
    self.searchTxt = self.___ex.searchTxt
    self.listPanelSpt = self.___ex.listPanelSpt
    self.confirmBtn = self.___ex.confirmBtn
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
    self.sortSpt.clickSort = function(index) self:OnSortClick(index) end
end

function SupporterSelectView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.confirmBtn:regOnButtonClick(function ()
        self:OnBtnConfirm()
    end)
    self.searchBtn:regOnButtonClick(function ()
        self:OnBtnSearch()
    end)
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function SupporterSelectView:InitView(playerListModel, supporterModel)
    self.playerListModel = playerListModel
    self.supporterModel = supporterModel
    self.oldSupporterModel = supporterModel:GetSupportCardModel()
    self:OnBuildPage()
end

function SupporterSelectView:EventSortCardList()
    self:SetSelectDetail(self.playerListModel)
    if self.sortCardListCallBack then
        self.sortCardListCallBack()
    end
end

function SupporterSelectView:OnBuildPage()
    self.listPanelSpt:ResetWithCellSpace(22, 25)
    self.listPanelSpt:ResetWithViewSize(1070, 340)
end

function SupporterSelectView:EventResetOneCard(pcid)
    if self.resetOneCardCallBack then
        self.resetOneCardCallBack(pcid)
    end
end

function SupporterSelectView:SetSelectDetail(playerListModel)
    local isSelected = false
    if playerListModel then
        local selectPos = playerListModel:GetSelectPos()
        local selectQuality = playerListModel:GetSelectQuality()
        local selectName = playerListModel:GetSeletName()
        local selectNationality = playerListModel:GetSeletNationality()
        local selectSkill = playerListModel:GetSeletSkill()

        if selectPos and next(selectPos) then
            isSelected = true
        end
        if selectQuality and next(selectQuality) then
            isSelected = true
        end
        if selectSkill and next(selectSkill) then
            isSelected = true
        end
        if selectName ~= "" or selectNationality ~= "" then
            isSelected = true
        end
        self.searchTxt.text = isSelected and lang.trans("pos_be_selected_title") or lang.trans("cardIndex_select")
    end
end

function SupporterSelectView:InitialData()
    local selectTypeIndex = self.playerListModel:GetSelectTypeIndex()
    self.sortSpt:InitialData(selectTypeIndex)
end

function SupporterSelectView:OnSelectSort(index)
    self.sortSpt:OnSelectSortItem(index)
end

function SupporterSelectView:OnSortClick(index)
    if self.clickSort then
        self.clickSort(index)
    end
end

-- 确认预览助阵球员
function SupporterSelectView:OnBtnConfirm()
    if self.clickConfirm and type(self.clickConfirm) == "function" then
        self.clickConfirm()
    end
end

-- 球员筛选
function SupporterSelectView:OnBtnSearch()
    if self.clickSearch and type(self.clickSearch) == "function" then
        self.clickSearch()
    end
end

function SupporterSelectView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if self.clickConfirm and type(self.clickConfirm) == "function" then
            self.clickConfirm(true)
        end
    end)
end

function SupporterSelectView:CloseView()
    if type(self.closeDialog) == "function" then
        EventSystem.SendEvent("Supporter_Select")
        self.closeDialog()
    end
end

function SupporterSelectView:EnterScene()
    EventSystem.AddEvent("PlayerListModel_SortCardList", self, self.EventSortCardList)
    EventSystem.AddEvent("PlayerListModel_ResetCardData", self, self.EventResetOneCard)

end

function SupporterSelectView:ExitScene()
    EventSystem.RemoveEvent("PlayerListModel_SortCardList", self, self.EventSortCardList)
    EventSystem.RemoveEvent("PlayerListModel_ResetCardData", self, self.EventResetOneCard)

end

return SupporterSelectView

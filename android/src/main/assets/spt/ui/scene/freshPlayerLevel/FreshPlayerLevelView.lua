local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local FreshPlayerLevelView = class(unity.base)

function FreshPlayerLevelView:ctor()
--------Start_Auto_Generate--------
    self.scrollSpt = self.___ex.scrollSpt
    self.previewBtn = self.___ex.previewBtn
    self.nextBtn = self.___ex.nextBtn
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
    self.canvasGroup = self.___ex.canvasGroup
end

function FreshPlayerLevelView:start()
    self:BindButtonHandler()
    self:PlayInAnimator()
    self.scrollSpt:regOnItemIndexChanged(function(index)
        self:OnItemIndexChange(index)
    end)
end

function FreshPlayerLevelView:InitView(freshPlayerLevelModel)
    self.freshPlayerLevelModel = freshPlayerLevelModel
    local allBoxData = freshPlayerLevelModel:GetAllBoxData()
    self.itemCount = #allBoxData
    if self.itemCount <= 0 then
        self:Close()
    else
        self.scrollSpt:InitView(allBoxData, freshPlayerLevelModel, self.buyBtnClick, self.onTimeOut)
        if self.itemCount <= 1 then
            GameObjectHelper.FastSetActive(self.previewBtn.gameObject, false)
            GameObjectHelper.FastSetActive(self.nextBtn.gameObject, false)
        end
    end
end

function FreshPlayerLevelView:OnItemIndexChange(index)
    local previewState, nextState = false, false
    if self.itemCount > 1 then
        previewState = index > 1
        nextState = index < self.itemCount
    end
    GameObjectHelper.FastSetActive(self.previewBtn.gameObject, previewState)
    GameObjectHelper.FastSetActive(self.nextBtn.gameObject, nextState)
end

function FreshPlayerLevelView:BindButtonHandler()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)

    self.previewBtn:regOnButtonClick(function()
        self.scrollSpt:scrollToPreviousGroup()
    end)

    self.nextBtn:regOnButtonClick(function()
        self.scrollSpt:scrollToNextGroup()
    end)
end

function FreshPlayerLevelView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FreshPlayerLevelView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function FreshPlayerLevelView:CloseView()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function FreshPlayerLevelView:Close()
    self:PlayOutAnimator()
end

function FreshPlayerLevelView:GetScrollNormalizedPosition()
    self.scrollIndex = self.freshPlayerLevelModel:GetPageIndex()
end

function FreshPlayerLevelView:SetScrollNormalizedPosition()
    self.scrollSpt:scrollToCellImmediate(self.scrollIndex)
end

return FreshPlayerLevelView

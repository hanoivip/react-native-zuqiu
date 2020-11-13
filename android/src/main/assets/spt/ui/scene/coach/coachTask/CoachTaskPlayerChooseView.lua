local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local CoachTaskPlayerChooseView = class(unity.base)

function CoachTaskPlayerChooseView:ctor()
    self.scroll = self.___ex.scroll
    self.canvasGroup = self.___ex.canvasGroup
    self.close = self.___ex.close
    self.hintText = self.___ex.hintText
    self.confirmBtn = self.___ex.confirmBtn
    self.trainPlayerFrame = self.___ex.trainPlayerFrame
    self.sortMenuView = self.___ex.sortMenuView
    self.posText = self.___ex.posText
    self.btnSearch = self.___ex.btnSearch

    self.scroll:regOnCreateItem(function(scrollSelf, index)
        if type(self.onScrollCreateItem) == "function" then
            return self.onScrollCreateItem(scrollSelf, index)
        end
    end)
    self.scroll:regOnResetItem(function(scrollSelf, spt, index)
        if type(self.onScrollResetItem) == "function" then
            return self.onScrollResetItem(scrollSelf, spt, index)
        end
    end)
end

function CoachTaskPlayerChooseView:start()
    self.close:regOnButtonClick(function()
        DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
            if type(self.closeDialog) == "function" then
                self.closeDialog()
            end
        end)
    end)

    self.confirmBtn:regOnButtonClick(function()
        if type(self.onConfirmClick) == "function" then
            self.onConfirmClick()
        end
    end)
    self.btnSearch:regOnButtonClick(function()
        if type(self.clickSearch) == "function" then
            self.clickSearch()
        end
    end)
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CoachTaskPlayerChooseView:InitView(coachTaskPlayerChooseModel)

end

function CoachTaskPlayerChooseView:SetTrainPlayer(cardModel, pcid)
    GameObjectHelper.FastSetActive(self.trainPlayerFrame.gameObject, true)
    if not self.trainPlayer then
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Coach/CoachTask/CoachTaskCardFrame.prefab")
        obj.transform:SetParent(self.trainPlayerFrame, false)
        self.trainPlayer = spt
    end
    self.trainPlayer:InitView(PlayerCardModel.new(pcid), true)
end

function CoachTaskPlayerChooseView:ClearChoosePlayer()
    GameObjectHelper.FastSetActive(self.trainPlayerFrame.gameObject, false)
end

function CoachTaskPlayerChooseView:Close()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

return CoachTaskPlayerChooseView

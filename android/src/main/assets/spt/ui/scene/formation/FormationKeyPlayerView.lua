local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local FormationKeyPlayerView = class(unity.base)

function FormationKeyPlayerView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.btnConfirm = self.___ex.btnConfirm
    self.keyPlayerBoard = self.___ex.keyPlayerBoard
    self.canvasGroup = self.___ex.canvasGroup
end

function FormationKeyPlayerView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.btnConfirm:regOnButtonClick(function ()
        self:OnConfirm()
    end)
    self:PlayInAnimator()
end

function FormationKeyPlayerView:InitView(playerTeamsModel, formationCacheDataModel, isFromPlayerTeamsCache)
    self.keyPlayerBoard:InitView(playerTeamsModel, formationCacheDataModel, isFromPlayerTeamsCache)
end

function FormationKeyPlayerView:OnConfirm()
    self.keyPlayerBoard:SetKeyPlayersCacheData()
    self:Close()
end

function FormationKeyPlayerView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FormationKeyPlayerView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function FormationKeyPlayerView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function FormationKeyPlayerView:Close()
    self:PlayOutAnimator()
end

return FormationKeyPlayerView
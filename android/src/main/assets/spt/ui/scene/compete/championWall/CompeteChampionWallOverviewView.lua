local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local CompeteChampionWallOverviewView = class(unity.base, "CompeteChampionWallOverviewView")

function CompeteChampionWallOverviewView:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    -- 确认按钮
    self.btnClose = self.___ex.btnClose
    self.content = self.___ex.content
    self.bigEarScroll = self.___ex.bigEarScroll
    self.smallEarScroll = self.___ex.smallEarScroll
end

function CompeteChampionWallOverviewView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CompeteChampionWallOverviewView:InitView(competeChampionWallOverviewModel)
    self.model = competeChampionWallOverviewModel
    self.bigEarScroll:InitView(self.model:GetBigEarData())
    self.smallEarScroll:InitView(self.model:GetSmallEarData())
end

function CompeteChampionWallOverviewView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        if self.onClickBtnClose and type(self.onClickBtnClose) == "function" then
            self.onClickBtnClose()
        end
    end)
end

function CompeteChampionWallOverviewView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

function CompeteChampionWallOverviewView:OnEnterScene()
end

function CompeteChampionWallOverviewView:OnExitScene()
end

return CompeteChampionWallOverviewView

local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local FancyWatchView = class(unity.base)

function FancyWatchView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.content = self.___ex.content
    self.nonePlayer = self.___ex.nonePlayer
end

function FancyWatchView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self:PlayInAnimator()
end

function FancyWatchView:InitView(fancyGroupModel)
    local tlist = {}
    for i = 1, 11 do
        local card = fancyGroupModel:GetCard(i)
        local name = card:GetName()
        if name then
            table.insert(tlist, name)
        end
    end
    GameObjectHelper.FastSetActive(self.nonePlayer.gameObject, #tlist == 0)
    for i = 1, 11 do
        self.content['n' .. i].text = tlist[i] and tlist[i] or ""
    end
end

function FancyWatchView:WatchCard()
    res.PushDialogImmediate("ui.controllers.myScene.MySceneCtrl")
end

function FancyWatchView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FancyWatchView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function FancyWatchView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
        GuideManager.Show(self)
    end
end

function FancyWatchView:Close()
    self:PlayOutAnimator()
end

return FancyWatchView
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local VideoReplayView = class(unity.base)

function VideoReplayView:ctor()
    -- 关闭按钮
    self.closeBtn = self.___ex.closeBtn
    -- 滚动列表
    self.scrollView = self.___ex.scrollView
    self.canvasGroup = self.___ex.canvasGroup
end

function VideoReplayView:InitView()
end

function VideoReplayView:start()
    self:BindAll()
    self:PlayInAnimator()
end

-- 为所有的按钮绑定事件
function VideoReplayView:BindAll()
    -- 关闭按钮
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function VideoReplayView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function VideoReplayView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function VideoReplayView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function VideoReplayView:Close()
    self:PlayOutAnimator()
end

return VideoReplayView
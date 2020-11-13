local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PersonScheduleView = class(unity.base)

function PersonScheduleView:ctor()
    self.scrollView = self.___ex.scrollView
    self.btnClose = self.___ex.btnClose
    self.scrollView.clickVideo = function(vid, version) self:OnClickVideo(vid, version) end
end

function PersonScheduleView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function PersonScheduleView:OnClickVideo(vid, version)
    if self.clickVideo then 
        self.clickVideo(vid, version)
    end
end

function PersonScheduleView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function PersonScheduleView:InitView(arenaPersonScheduleModel, arenaScheduleTeamModel)
    self.scrollView:InitView(arenaPersonScheduleModel, arenaScheduleTeamModel)
end

function PersonScheduleView:EnterScene()

end

function PersonScheduleView:ExitScene()

end

return PersonScheduleView

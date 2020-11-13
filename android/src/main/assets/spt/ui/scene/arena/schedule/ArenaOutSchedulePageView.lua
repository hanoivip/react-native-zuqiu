local ArenaScheduleTeamModel = require("ui.models.arena.schedule.ArenaScheduleTeamModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaOutSchedulePageView = class(unity.base)

function ArenaOutSchedulePageView:ctor()
    self.listView = self.___ex.listView
    self.listView.clickVideo = function(vid, version) self:OnClickVideo(vid, version) end
end

function ArenaOutSchedulePageView:OnClickVideo(vid, version)
    if self.clickVideo then 
        self.clickVideo(vid, version)
    end
end

function ArenaOutSchedulePageView:InitView(arenaKnockoutModel)
    self.arenaKnockoutModel = arenaKnockoutModel
    local arenaScheduleTeamModel = ArenaScheduleTeamModel.GetInstance()
    self.listView:InitView(arenaKnockoutModel, arenaScheduleTeamModel)
end

function ArenaOutSchedulePageView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

function ArenaOutSchedulePageView:EnterScene()

end

function ArenaOutSchedulePageView:ExitScene()

end

return ArenaOutSchedulePageView
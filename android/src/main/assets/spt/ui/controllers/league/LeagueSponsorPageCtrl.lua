local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local LeagueBgmPlayer = require("ui.scene.league.LeagueBgmPlayer")

local LeagueSponsorPageCtrl = class(BaseCtrl)

LeagueSponsorPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/League/LeagueSponsor.prefab"

function LeagueSponsorPageCtrl:Init(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
end

function LeagueSponsorPageCtrl:Refresh(leagueInfoModel)
    LeagueSponsorPageCtrl.super.Refresh(self)
    self.view:InitView(leagueInfoModel)

    self.view:RegOnDynamicLoad(function (child)
        local infoBarCtrl = InfoBarCtrl.new(child, self)
        infoBarCtrl:RegOnBtnBack(function ()
            LeagueBgmPlayer.StopPlayBgm()
            -- 进入新赛季 没有选择赞助商  往前返回 跳过展示界面 无需在返回上一级界面
            res.PopAppointSceneImmediate(2, "ui.controllers.home.HomeMainCtrl")
        end)
    end)
end

function LeagueSponsorPageCtrl:GetStatusData()
    return self.leagueInfoModel
end

return LeagueSponsorPageCtrl

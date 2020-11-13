local BaseCtrl = require("ui.controllers.BaseCtrl")
local VideoReplayModel = require("ui.models.videoReplay.VideoReplayModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local VideoReplayCtrl = class(BaseCtrl)
VideoReplayCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/VideoReplay/VideoReplayBoard.prefab"
VideoReplayCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function VideoReplayCtrl:Refresh()
    VideoReplayCtrl.super.Refresh(self)
    clr.coroutine(function()
        local respone = req.videoInfo()
        if api.success(respone) then
            local data = respone.val
            self.videoReplayModel = VideoReplayModel.new()
            self.videoReplayModel:InitWithProtocol(data)
            self:InitView()
        end
    end)
end

function VideoReplayCtrl:InitView()
    self:CreateItemList()
end

function VideoReplayCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/VideoReplay/VideoReplayItemBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local videoData = self.view.scrollView.itemDatas[index]
        spt.onReplay = function() self:OnReplay(videoData) end
        spt.onInitHomeTeamLogo = function(logoData) self:OnInitTeamLogo(spt:GetHomeTeamLogo(), logoData) end
        spt.onInitAwayTeamLogo = function(logoData) self:OnInitTeamLogo(spt:GetAwayTeamLogo(), logoData) end
        spt:InitView(videoData)
        self.view.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function VideoReplayCtrl:RefreshScrollView()
    local videoList = self.videoReplayModel:GetVideoList()
    self.view.scrollView:clearData()
    for i = 1, #videoList do
        table.insert(self.view.scrollView.itemDatas, videoList[i])
    end
    self.view.scrollView:refresh()
end

function VideoReplayCtrl:OnReplay(videoData)
    clr.coroutine(function()
        local respone = req.videoReplay(videoData.vid)
        if api.success(respone) then
            local ReplayCheckHelper = require("coregame.ReplayCheckHelper")
            ReplayCheckHelper.StartReplay(respone.val.video, videoData.vid)
        end
    end)
end

function VideoReplayCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

return VideoReplayCtrl

local AssetFinder = require("ui.common.AssetFinder")
local VideoReplayConstants = require("ui.models.videoReplay.VideoReplayConstants")
local Version = require("emulator.version")

local VideoReplayItemView = class(unity.base)

function VideoReplayItemView:ctor()
    -- 回放按钮
    self.btnReplay = self.___ex.btnReplay
    self.replayButton = self.___ex.replayButton
    -- 主队队名
    self.homeName = self.___ex.homeName
    -- 主队队徽
    self.homeTeamLogo = self.___ex.homeTeamLogo
    -- 客队队名
    self.awayName = self.___ex.awayName
    -- 客队队徽
    self.awayTeamLogo = self.___ex.awayTeamLogo
    -- 比分
    self.score = self.___ex.score
    -- 比赛类型图标
    self.matchIcon = self.___ex.matchIcon
    -- 比赛类型名字
    self.matchName = self.___ex.matchName
    -- 录像过期标志
    self.videoExpiredSymbol = self.___ex.videoExpiredSymbol
end

function VideoReplayItemView:start()
    self:BindButtonHandler()
end

function VideoReplayItemView:InitView(data)
    self.matchIcon.overrideSprite = AssetFinder.GetVideoReplayMatchTypeIcon(data.cate)
    self.matchName.text = lang.trans("videoReplay_" .. tostring(data.cate))
    -- 玩家主场或中立场地
    if data.home == VideoReplayConstants.HomeAwayType.HOME or data.home == VideoReplayConstants.HomeAwayType.NEUTRAL then
        self.homeName.text = data.p.name
        self.awayName.text = data.o.name
        self:InitHomeTeamLogo(data.p.logo)
        self:InitAwayTeamLogo(data.o.logo)
        self.score.text = tostring(data.p.score) .. " : " .. tostring(data.o.score)
    -- 玩家客场
    elseif data.home == VideoReplayConstants.HomeAwayType.AWAY then
        self.homeName.text = data.o.name
        self.awayName.text = data.p.name
        self:InitHomeTeamLogo(data.o.logo)
        self:InitAwayTeamLogo(data.p.logo)
        self.score.text = tostring(data.o.score) .. " : " .. tostring(data.p.score)
    end
    local isVideoExpired = tonumber(data.ver) ~= tonumber(Version.version)
    self.replayButton:SetActive(not isVideoExpired)
    self.videoExpiredSymbol:SetActive(isVideoExpired)
end

function VideoReplayItemView:BindButtonHandler()
    self.btnReplay:regOnButtonClick(function()
        if self.onReplay then
            self.onReplay()
        end
    end)
end

function VideoReplayItemView:InitHomeTeamLogo(logoData)
    if self.onInitHomeTeamLogo then
        self.onInitHomeTeamLogo(logoData)
    end
end

function VideoReplayItemView:GetHomeTeamLogo()
    return self.homeTeamLogo
end

function VideoReplayItemView:InitAwayTeamLogo(logoData)
    if self.onInitAwayTeamLogo then
        self.onInitAwayTeamLogo(logoData)
    end
end

function VideoReplayItemView:GetAwayTeamLogo()
    return self.awayTeamLogo
end

return VideoReplayItemView

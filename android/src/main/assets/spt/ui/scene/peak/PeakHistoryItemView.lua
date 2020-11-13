local GameObjectHelper = require("ui.common.GameObjectHelper")
local Version = require("emulator.version")

local PeakHistoryItemView = class(unity.base)

local MatchResult = {
    WIN = 1,
    DRAW = 0,
    LOSE = -1
}

function PeakHistoryItemView:ctor()
    -- 查看比赛详情
    self.btnView = self.___ex.btnView
    -- 对手队名
    self.nameTxt = self.___ex.name
    -- 对手等级
    self.level = self.___ex.level
    -- 对手所在区
    self.playerZone = self.___ex.playerZone
    -- 录像的时间
    self.historyTime = self.___ex.historyTime
    -- 对手队徽
    self.teamLogo = self.___ex.teamLogo
    -- 胜利的背景
    self.bgWin = self.___ex.bgWin
    -- 胜利结果标志
    self.winResultSymbol = self.___ex.winResultSymbol
    -- 失败结果标志
    self.loseResultSymbol = self.___ex.loseResultSymbol
    -- 平局结果标志
    self.drawResultSymbol = self.___ex.drawResultSymbol
    -- 胜利排名变化标志
    self.winRankSymbol = self.___ex.winRankSymbol
    -- 失败排名变化标志
    self.loseRankSymbol = self.___ex.loseRankSymbol
    -- 平局排名变化标志
    self.drawRankSymbol = self.___ex.drawRankSymbol
    -- 排名上升文本
    self.txtRankRise = self.___ex.txtRankRise
    -- 排名下降文本
    self.txtRankDrop = self.___ex.txtRankDrop
    -- 主场标志
    self.homeSymbol = self.___ex.homeSymbol
    -- 客场标志
    self.awaySymbol = self.___ex.awaySymbol
    -- 玩家被攻击且名次发生变化标志
    self.newSymbol = self.___ex.newSymbol
    -- 录像过期标志
    self.videoExpiredSymbol = self.___ex.videoExpiredSymbol
    -- 查看对手信息
    self.btnViewDetail = self.___ex.btnViewDetail
end

function PeakHistoryItemView:start()
    self:BindButtonHandler()
end

function PeakHistoryItemView:InitView(data)
    if data.opponent then
        self.nameTxt.text = data.opponent.name
        self.level.text = "Lv " .. tostring(data.opponent.lvl)
        self:InitTeamLogo()
        self.playerZone.text = data.opponent.zone
    end
    self.historyTime.text = data.historyTime
    GameObjectHelper.FastSetActive(self.homeSymbol, data.home == 1)
    GameObjectHelper.FastSetActive(self.awaySymbol, data.home == 0)
    GameObjectHelper.FastSetActive(self.winRankSymbol, data.rankChg > 0)
    GameObjectHelper.FastSetActive(self.loseRankSymbol, data.rankChg < 0)
    GameObjectHelper.FastSetActive(self.drawRankSymbol, data.rankChg == 0)
    GameObjectHelper.FastSetActive(self.newSymbol, data.new)
    if data.rankChg > 0 then
        self.txtRankRise.text = tostring(data.rankChg)
    elseif data.rankChg < 0 then
        self.txtRankDrop.text = tostring(-data.rankChg)
    end
    if data.rankChg > 0 then
        self.txtRankRise.text = tostring(data.rankChg)
    elseif data.rankChg < 0 then
        self.txtRankDrop.text = tostring(-data.rankChg)
    end
    self:InitMatchResultView(data.result)
end

function PeakHistoryItemView:BindButtonHandler()
    self.btnView:regOnButtonClick(function()
        if self.onViewFightDetail then
            self.onViewFightDetail()
        end
    end)
    self.btnViewDetail:regOnButtonClick(function()
        if self.onViewOpponentDetail then
            self.onViewOpponentDetail()
        end
    end)
end

function PeakHistoryItemView:InitTeamLogo()
    if self.onInitTeamLogo then
        self.onInitTeamLogo()
    end
end

function PeakHistoryItemView:GetTeamLogo()
    return self.teamLogo
end

function PeakHistoryItemView:InitMatchResultView(matchResult)
    GameObjectHelper.FastSetActive(self.winResultSymbol, matchResult == MatchResult.WIN)
    GameObjectHelper.FastSetActive(self.loseResultSymbol, matchResult == MatchResult.LOSE)
    GameObjectHelper.FastSetActive(self.drawResultSymbol, matchResult == MatchResult.DRAW)
    GameObjectHelper.FastSetActive(self.bgWin, matchResult == MatchResult.WIN)
end

return PeakHistoryItemView
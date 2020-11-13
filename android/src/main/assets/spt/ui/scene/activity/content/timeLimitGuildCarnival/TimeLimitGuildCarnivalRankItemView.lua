local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local TimeLimitGuildCarnivalRankItemView = class(unity.base, "TimeLimitGuildCarnivalRankItemView")

function TimeLimitGuildCarnivalRankItemView:ctor()
    -- 白色背景
    self.white = self.___ex.white
    -- 第一名
    self.first = self.___ex.first
    -- 第二名
    self.second = self.___ex.second
    -- 第三名
    self.third = self.___ex.third
    -- 普通排名
    self.normalRank = self.___ex.normalRank
    -- 玩家图标
    self.playerIcon = self.___ex.playerIcon
    -- 玩家名字
    self.playerName = self.___ex.playerName
    -- 贡献积分
    self.point = self.___ex.point
    -- 查看详情
    self.btnDetail= self.___ex.btnDetail
end

function TimeLimitGuildCarnivalRankItemView:InitView(data)
    self.data = data
    local rank = tonumber(data.rank)
    if rank == 1 then
        self:SetRankDisplay(true, false, false, false)
    elseif rank == 2 then
        self:SetRankDisplay(false, true, false, false)
    elseif rank == 3 then
        self:SetRankDisplay(false, false, true, false)
    else
        self:SetRankDisplay(false, false, false, true)
        self.normalRank.text = tostring(rank)
    end
    GameObjectHelper.FastSetActive(self.white.gameObject, rank % 2 == 0)
    self.playerName.text = tostring(data.name or "")
    self.point.text = tostring(data.score or "")
    self:InitTeamLogo()
end

function TimeLimitGuildCarnivalRankItemView:InitTeamLogo()
    TeamLogoCtrl.BuildTeamLogo(self.playerIcon, self.data.logo)
end

function TimeLimitGuildCarnivalRankItemView:SetRankDisplay(isFirst, isSecond, isThird, isOther)
    GameObjectHelper.FastSetActive(self.first.gameObject, isFirst)
    GameObjectHelper.FastSetActive(self.second.gameObject, isSecond)
    GameObjectHelper.FastSetActive(self.third.gameObject, isThird)
    GameObjectHelper.FastSetActive(self.normalRank.gameObject, isOther)
end

return TimeLimitGuildCarnivalRankItemView
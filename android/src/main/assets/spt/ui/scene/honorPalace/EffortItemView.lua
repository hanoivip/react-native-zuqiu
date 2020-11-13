local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local EffortItemView = class(unity.base)

function EffortItemView:ctor()
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.teamLogo = self.___ex.teamLogo
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.bgNormal = self.___ex.bgNormal
    self.bgHighLight = self.___ex.bgHighLight
    self.btnView = self.___ex.btnView
    self.effortTxt = self.___ex.effortTxt
    self.playerInfoModel = PlayerInfoModel.new()
end

function EffortItemView:start()
    self:BindButtonHandler()
end

function EffortItemView:InitView(data, index)
    self.nameTxt.text = data.name
    self.level.text = "Lv " .. tostring(data.lvl)
    self.effortTxt.text = tostring(data.level)
    self.normalRank.text = lang.trans("ladder_rank", tostring(data.rank))
    self:InitRankShowState(data.rank)
    self:InitBackGround(data._id, data.rank)
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, data.logo)
end

function EffortItemView:BindButtonHandler()
    self.btnView:regOnButtonClick(function()
        if self.onView then
            self.onView()
        end
    end)
end

function EffortItemView:InitRankShowState(rank)
    GameObjectHelper.FastSetActive(self.firstRank, rank == 1)
    GameObjectHelper.FastSetActive(self.secondRank, rank == 2)
    GameObjectHelper.FastSetActive(self.thirdRank, rank == 3)
    GameObjectHelper.FastSetActive(self.normalRank.gameObject, rank >= 4)
end

function EffortItemView:InitBackGround(id, rank)
    if self.playerInfoModel:GetID() == id then
         GameObjectHelper.FastSetActive(self.bgNormal, false)
         GameObjectHelper.FastSetActive(self.bgHighLight, true)
    else
         GameObjectHelper.FastSetActive(self.bgNormal, rank % 2 == 0)
         GameObjectHelper.FastSetActive(self.bgHighLight, false)
    end
end

return EffortItemView
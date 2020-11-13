local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local DreamRankItemView = class(unity.base)

function DreamRankItemView:ctor()
    self.nameTxt = self.___ex.name
    self.bgNormal = self.___ex.bgNormal
    self.bgHighLight = self.___ex.bgHighLight
    self.score = self.___ex.score
    self.server = self.___ex.server
    self.playerInfoModel = PlayerInfoModel.new()
end

function DreamRankItemView:InitView(rankData)
    self.nameTxt.text = rankData.name
    self.score.text = tostring(rankData.score)
    self.server.text = rankData.serverName
    self:InitBackGround(rankData.pid, rankData.rank)
end

function DreamRankItemView:InitBackGround(pid, rank)
    if self.playerInfoModel:GetID() == pid then
         GameObjectHelper.FastSetActive(self.bgNormal, false)
         GameObjectHelper.FastSetActive(self.bgHighLight, true)
         self.nameTxt.color = Color(1, 224/255, 0)
    else
        self.nameTxt.color = Color(1, 1, 1)
         GameObjectHelper.FastSetActive(self.bgNormal, rank % 2 == 0)
         GameObjectHelper.FastSetActive(self.bgHighLight, false)
    end
end

return DreamRankItemView
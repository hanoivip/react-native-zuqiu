local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildMistDataShowRankItemView = class(unity.base)

local path = "Assets/CapstonesRes/Game/UI/Scene/Guild/Image/GuildRanking/RankingOrder_%s.png"

function GuildMistDataShowRankItemView:ctor()
    self.rankTxt = self.___ex.rankTxt
    self.rankImg = self.___ex.rankImg
    self.attackNameTxt = self.___ex.attackNameTxt
    self.roundTxt = self.___ex.roundTxt
    self.winTimeTxt = self.___ex.winTimeTxt
    self.captureTimeTxt = self.___ex.captureTimeTxt
    self.holdTxt = self.___ex.holdTxt
    self.activistTxt = self.___ex.activistTxt
    self.bg = self.___ex.bg
end

function GuildMistDataShowRankItemView:Init(data, isMySelf)
    local atkScore = data.atkScore or 0
    local defScore = data.defScore or 0
    local totalScore = atkScore + defScore
    self.activistTxt.text = tostring(data.mistActive)
    self.winTimeTxt.text = tostring(totalScore)
    self.captureTimeTxt.text = tostring(atkScore)
    self.holdTxt.text = tostring(defScore)
    self.attackNameTxt.text = tostring(data.name)
    self.roundTxt.text = tostring(data.round)

    GameObjectHelper.FastSetActive(self.rankImg.gameObject, tonumber(data.rank) < 4)
    GameObjectHelper.FastSetActive(self.rankTxt.gameObject, tonumber(data.rank) >= 4)
    if tonumber(data.rank) < 4 then
        self.rankImg.overrideSprite = res.LoadRes(format(path, tostring(data.rank)))
    else
        self.rankTxt.text = tostring(data.rank)
    end
    GameObjectHelper.FastSetActive(self.bg, isMySelf)
end

return GuildMistDataShowRankItemView

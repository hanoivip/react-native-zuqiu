local GameObjectHelper = require("ui.common.GameObjectHelper")
local PowerRankModel = require("ui.models.activity.PowerRankModel")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local PowerRankItemView = class(unity.base)

function PowerRankItemView:ctor()
    self.bg1Go = self.___ex.bg1Go
    self.bg2Go = self.___ex.bg2Go
    self.rankNumTxt = self.___ex.rankNumTxt
    self.itemAreaTrans = self.___ex.itemAreaTrans
    self.teamLogoImg = self.___ex.teamLogoImg
    self.detailBtn = self.___ex.detailBtn
    self.lockGo = self.___ex.lockGo
    self.name1Go = self.___ex.name1Go
    self.name2Go = self.___ex.name2Go
    self.detailIcon1Go = self.___ex.detailIcon1Go
    self.detailIcon2Go = self.___ex.detailIcon2Go
    self.playerPowerTxt = {self.___ex.playerPower1Txt, self.___ex.playerPower2Txt}
    self.playerNameTxt = {self.___ex.playerName1Txt, self.___ex.playerName2Txt}
    self.placeGo = {self.___ex.num1Go, self.___ex.num2Go, self.___ex.num3Go}
end

function PowerRankItemView:start()
    self.detailBtn:regOnButtonClick(function()
        self:OnDetailClick()
    end)
end

function PowerRankItemView:InitView(rankData)
    self.rankData = rankData
    if not self.playerInfoModel then
        self.playerInfoModel = PlayerInfoModel.new()
    end
    local rank = tonumber(rankData.rank)
    local m1, m2 = math.modf(rank / 2)
    local bgState = m2 > 0
    local state = rankData.state
    local lockState = state == PowerRankModel.RankState.LOCK
    local rankState = state == PowerRankModel.RankState.RANKING
    local power = tostring(rankData.power)
    local playerName = rankData.name
    local logoData = rankData.logo
    for i,v in ipairs(self.placeGo) do
        GameObjectHelper.FastSetActive(v, false)
    end
    if rank <= 3 then
        GameObjectHelper.FastSetActive(self.placeGo[rank], true)
        GameObjectHelper.FastSetActive(self.rankNumTxt.gameObject, false)
    else
        GameObjectHelper.FastSetActive(self.rankNumTxt.gameObject, true)
        self.rankNumTxt.text = tostring(rank)
    end
    -- 自己的排名显示亮条
    local isMySelf = tobool(tostring(self.playerInfoModel:GetID()) == tostring(rankData.pid))
    GameObjectHelper.FastSetActive(self.bg1Go, isMySelf)
    GameObjectHelper.FastSetActive(self.bg2Go, not isMySelf)
    GameObjectHelper.FastSetActive(self.lockGo, lockState)
    GameObjectHelper.FastSetActive(self.name1Go, not lockState)
    GameObjectHelper.FastSetActive(self.name2Go, not lockState)
    GameObjectHelper.FastSetActive(self.detailIcon1Go, rankState)
    GameObjectHelper.FastSetActive(self.detailIcon2Go, rankState)
    GameObjectHelper.FastSetActive(self.teamLogoImg.gameObject, not lockState)
    GameObjectHelper.FastSetActive(self.detailBtn.gameObject, rankState)

    res.ClearChildren(self.itemAreaTrans)
    local rewardParams = {
        parentObj = self.itemAreaTrans,
        rewardData = rankData.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
    if lockState then
        return
    end
    for i,v in ipairs(self.playerPowerTxt) do
        v.text = power
    end
    for i,v in ipairs(self.playerNameTxt) do
        v.text = playerName
    end
    self:ShowTeamLogo(logoData)
end

function PowerRankItemView:ShowTeamLogo(logoData)
    TeamLogoCtrl.BuildTeamLogo(self.teamLogoImg, logoData)
end

function PowerRankItemView:OnDetailClick()
    local pid = self.rankData.pid
    local sid = self.rankData.sid
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

return PowerRankItemView
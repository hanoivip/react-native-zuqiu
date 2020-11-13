local GameObjectHelper = require("ui.common.GameObjectHelper")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local RankContentItemView = class(unity.base)

function RankContentItemView:ctor()
--------Start_Auto_Generate--------
    self.firstRankGo = self.___ex.firstRankGo
    self.secondRankGo = self.___ex.secondRankGo
    self.thirdRankGo = self.___ex.thirdRankGo
    self.rankTxt = self.___ex.rankTxt
    self.scoreTxt = self.___ex.scoreTxt
    self.signImg = self.___ex.signImg
    self.logoImg = self.___ex.logoImg
    self.playerNameTxt = self.___ex.playerNameTxt
    self.levelTxt = self.___ex.levelTxt
    self.serverTxt = self.___ex.serverTxt
    self.detailBtn = self.___ex.detailBtn
--------End_Auto_Generate----------
end

function RankContentItemView:start()
    self.detailBtn:regOnButtonClick(function()
        self:OnViewDetail()
    end)
end

function RankContentItemView:InitView(rankData)
    self.rankData = rankData
    local rank = rankData.rank
    GameObjectHelper.FastSetActive(self.firstRankGo, rank == 1)
    GameObjectHelper.FastSetActive(self.secondRankGo, rank == 2)
    GameObjectHelper.FastSetActive(self.thirdRankGo, rank == 3)
    self.scoreTxt.text = tostring(rankData.score)
    self.rankTxt.text = tostring(rank > 3 and rank or "")
    self.levelTxt.text = "LV." .. tostring(rankData.view.lvl)
    self.playerNameTxt.text = tostring(rankData.view.name)
    self.serverTxt.text = tostring(rankData.view.serverName)

    local competeSign = rankData.view.worldTournamentLevel
    local hasCompeteSign = false
    if competeSign then
        local signData = CompeteSignConvert[tostring(competeSign)]
        if signData then
            self.signImg.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Images/" .. signData.path .. ".png")
            hasCompeteSign = true
        end
    end
    GameObjectHelper.FastSetActive(self.signImg.gameObject, hasCompeteSign)
    self:ShowTeamLogo(rankData.view.logo)
end

function RankContentItemView:ShowTeamLogo(logo)
    TeamLogoCtrl.BuildTeamLogo(self.logoImg, logo)
end

function RankContentItemView:OnViewDetail()
    local pid = self.rankData.view.pid
    local sid = self.rankData.view.sid
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

return RankContentItemView

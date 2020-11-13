local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local AssetFinder = require("ui.common.AssetFinder")

local LadderChallengeTeamBarView = class(unity.base)

function LadderChallengeTeamBarView:ctor()
    -- 挑战按钮
    self.btnChallenge = self.___ex.btnChallenge
    -- 查看按钮
    self.btnView = self.___ex.btnView
    -- 队名
    self.txtName = self.___ex.txtName
    -- 等级
    self.txtLevel = self.___ex.txtLevel
    -- 排名
    self.txtRank = self.___ex.txtRank
    -- 队徽
    self.teamLogo = self.___ex.teamLogo
    -- 队徽名
    self.txtLogoName = self.___ex.txtLogoName
    -- 争霸赛标识
    self.competeSign = self.___ex.competeSign
    self.rctName = self.___ex.rctName
end

function LadderChallengeTeamBarView:start()
    self:BindButtonHandler()
end

function LadderChallengeTeamBarView:InitView(data)
    self.pcid = data.pid
    self.txtName.text = data.name
    self.txtLevel.text = "Lv " .. tostring(data.lvl)
    self.txtRank.text = tostring(data.rank)
    self.txtLogoName.text = data.name
    self:InitTeamLogo()
    self:InitCompeteSign(data)
end

function LadderChallengeTeamBarView:BindButtonHandler()
    self.btnChallenge:regOnButtonClick(function()
        if self.onChallenge then
            self.onChallenge(self.pcid)
        end
    end)
    self.btnView:regOnButtonClick(function()
        if self.onView then
            self.onView(self.pcid)
        end
    end)
end

function LadderChallengeTeamBarView:InitTeamLogo()
    if self.onInitTeamLogo then
        self.onInitTeamLogo()
    end
end

function LadderChallengeTeamBarView:GetTeamLogo()
    return self.teamLogo
end

function LadderChallengeTeamBarView:InitCompeteSign(data)
    local worldTournamentLevel = data.worldTournamentLevel
    local posX = 125
    if worldTournamentLevel ~= nil then
        local signData = CompeteSignConvert[tostring(worldTournamentLevel)]
        if signData then
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, true)
            self.competeSign.overrideSprite = AssetFinder.GetCompeteSign(signData.path)
            posX = 160
        else
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
        end
    else
        GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
    end
    self.rctName.anchoredPosition = Vector2(posX, self.rctName.anchoredPosition.y)
end

return LadderChallengeTeamBarView
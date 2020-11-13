local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local UI = UnityEngine.UI
local Sprite = UI.Sprite

local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local LeagueWelcomeInfoEnemyBarView = class(unity.base)

function LeagueWelcomeInfoEnemyBarView:ctor()
    -- 队伍logo
    self.teamLogo = self.___ex.teamLogo
    -- 队伍名称
    self.teamName = self.___ex.teamName
    -- 队伍等级
    self.teamLevel = self.___ex.teamLevel
    -- 队伍数据
    self.teamData = nil
end

function LeagueWelcomeInfoEnemyBarView:InitView(teamData)
    self.teamData = teamData
    
    self:BuildPage()
end

function LeagueWelcomeInfoEnemyBarView:start()
end

function LeagueWelcomeInfoEnemyBarView:BuildPage()
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, self.teamData.logo)
    self.teamName.text = self.teamData.name or ""
    self.teamLevel.text = "Lv." .. self.teamData.lvl or ""
end

return LeagueWelcomeInfoEnemyBarView
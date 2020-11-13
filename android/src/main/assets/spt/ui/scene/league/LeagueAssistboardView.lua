local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local UI = UnityEngine.UI
local Text = UI.Text

local EventSystem = require("EventSystem")
local LeagueConstants = require("ui.scene.league.LeagueConstants")

local LeagueAssistboardView = class(unity.base)

function LeagueAssistboardView:ctor()
    -- 列表区域
    self.listArea = self.___ex.listArea
    -- model
    self.leagueInfoModel = nil
    -- 助攻榜数据
    self.assistboardData = nil
end

function LeagueAssistboardView:InitView(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self.assistboardData = self.leagueInfoModel:GetAssistboard()
    self:InitListArea()
end

--- 初始化列表区域
function LeagueAssistboardView:InitListArea()
    local barObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/League/LeagueShootboardBar.prefab")
    for i = 1, LeagueConstants.TeamSum do
        local go = Object.Instantiate(barObj)
        go.transform:SetParent(self.listArea, false)
        local playerData = self.assistboardData[i]
        local goScript = go:GetComponent(clr.CapsUnityLuaBehav)
        goScript:InitView(i, playerData, self.leagueInfoModel)
    end
end

return LeagueAssistboardView

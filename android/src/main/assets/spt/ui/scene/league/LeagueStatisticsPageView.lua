local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav

local EventSystem = require("EventSystem")
local LeagueConstants = require("ui.scene.league.LeagueConstants")
local AssetFinder = require("ui.common.AssetFinder")

local LeagueStatisticsPageView = class(unity.base)

function LeagueStatisticsPageView:ctor()
    -- 分类按钮组
    self.selectBtnGroup = self.___ex.selectBtnGroup
    -- 内容框
    self.content = self.___ex.content
    -- model
    self.leagueInfoModel = nil
end

function LeagueStatisticsPageView:InitView(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    
    self:BuildPage()
end

function LeagueStatisticsPageView:start()
    self:BindAll()
end

function LeagueStatisticsPageView:BindAll()
    -- 积分榜按钮
    self.selectBtnGroup:BindMenuItem("scoreBtn", function ()
        self:BuildScoreboard()
    end)

    -- 射手榜按钮
    self.selectBtnGroup:BindMenuItem("shootBtn", function ()
        self:RequestShootboard()
    end)

    -- 助攻榜按钮
    self.selectBtnGroup:BindMenuItem("assistBtn", function ()
        self:RequestAssistboard()
    end)
end

function LeagueStatisticsPageView:BuildPage()
    self.selectBtnGroup:selectMenuItem("scoreBtn")
    self:BuildScoreboard()
end

--- 清空内容框
function LeagueStatisticsPageView:ClearContent()
    for i = 1, self.content.childCount do
        Object.Destroy(self.content:GetChild(i - 1).gameObject)
    end
end

--- 请求射手榜
function LeagueStatisticsPageView:RequestShootboard()
    clr.coroutine(function()
        local response = req.leagueBoard(LeagueConstants.BoardType.SHOOT)
        if api.success(response) then
            local data = response.val
            self.leagueInfoModel:InitWithShootboardProtocol(data.shooter)
            self:BuildShootboard()
        end
    end)
end

--- 请求助攻榜
function LeagueStatisticsPageView:RequestAssistboard()
    clr.coroutine(function()
        local response = req.leagueBoard(LeagueConstants.BoardType.ASSIST)
        if api.success(response) then
            local data = response.val
            self.leagueInfoModel:InitWithAssistboardProtocol(data.assister)
            self:BuildAssistboard()
        end
    end)
end

--- 构建积分榜
function LeagueStatisticsPageView:BuildScoreboard()
    self:ClearContent()
    local scoreboardPage = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/League/LeagueScoreboard.prefab"))
    scoreboardPage.transform:SetParent(self.content, false)
    local scoreboardScripts = scoreboardPage:GetComponent(CapsUnityLuaBehav)
    scoreboardScripts:InitView(self.leagueInfoModel)
end

--- 构建射手榜
function LeagueStatisticsPageView:BuildShootboard()
    self:ClearContent()
    local shootboardPage = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/League/LeagueShootboard.prefab"))
    shootboardPage.transform:SetParent(self.content, false)
    local shootboardScripts = shootboardPage:GetComponent(CapsUnityLuaBehav)
    shootboardScripts:InitView(self.leagueInfoModel)
end

--- 构建助攻榜
function LeagueStatisticsPageView:BuildAssistboard()
    self:ClearContent()
    local assistboardPage = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/League/LeagueAssistboard.prefab"))
    assistboardPage.transform:SetParent(self.content, false)
    local assistboardScripts = assistboardPage:GetComponent(CapsUnityLuaBehav)
    assistboardScripts:InitView(self.leagueInfoModel)
end

return LeagueStatisticsPageView

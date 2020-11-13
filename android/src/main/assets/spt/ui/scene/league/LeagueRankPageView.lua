local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Mathf = UnityEngine.Mathf

local LeagueConstants = require("ui.scene.league.LeagueConstants")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CommonConstants = require("ui.common.CommonConstants")

local LeagueRankPageView = class(unity.base)

function LeagueRankPageView:ctor()
    -- 关闭按钮
    self.closeBtn = self.___ex.closeBtn
    -- 联赛等级标题
    self.levelTitle = self.___ex.levelTitle
    -- 联赛等级标题下划线
    self.levelUnderline = self.___ex.levelUnderline
    -- 连线
    self.connectLine = self.___ex.connectLine
    -- 标识联赛等级的点
    self.point = self.___ex.point
    -- 上赛季信息区域
    self.lastSeasonInfoArea = self.___ex.lastSeasonInfoArea
    -- 名次
    self.rankNum = self.___ex.rankNum
    -- 第一名要显示的对象
    self.rankFirst = self.___ex.rankFirst
    -- 第二名要显示的对象
    self.rankSecond = self.___ex.rankSecond
    -- 第三名要显示的对象
    self.rankThird = self.___ex.rankThird
    -- 积分
    self.pointNum = self.___ex.pointNum
    -- 净胜球
    self.gdNum = self.___ex.gdNum
    -- 进球
    self.goalNum = self.___ex.goalNum
    -- 我的排行
    self.myRank = self.___ex.myRank
    -- 滚动视图
    self.rankScrollerView = self.___ex.rankScrollerView
    -- 画布组
    self.canvasGroup = self.___ex.canvasGroup
    -- 联赛金字塔闪光区域
    self.leagueRankEffect = self.___ex.leagueRankEffect
    -- 动画管理器
    self.animator = self.___ex.animator
    -- model
    self.leagueInfoModel = nil
    -- 联赛等级
    self.leagueLevel = nil
    -- 联赛基础信息
    self.baseInfo = nil
    -- 上一个赛季的数据
    self.lastSeasonData = nil
    -- 排行榜数据
    self.rankData = nil
end

function LeagueRankPageView:InitView(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self.leagueLevel = self.leagueInfoModel:GetLeagueLevel()
    self.baseInfo = self.leagueInfoModel:GetBaseInfo()
    self.lastSeasonData = self.baseInfo.preSeason
    self.rankData = self.leagueInfoModel:GetRankData()
    self.rankScrollerView:InitView(self.leagueInfoModel)
    
    self:BuildPage()
end

function LeagueRankPageView:start()
    self:BindAll()
end

function LeagueRankPageView:BindAll()
    -- 关闭按钮
    self.closeBtn:regOnButtonClick(function ()
        self:PlayMoveOutAnim()
    end)
end

function LeagueRankPageView:BuildPage()
    self:BuildPyramidLine()
    self:BuildPyramidLevelArea()
    self:BuildLastSeasonInfoArea()
    self:BuildRankArea()
end

--- 构建指示联赛等级的线
function LeagueRankPageView:BuildPyramidLine()
    local pointData = LeagueConstants.RankPyramidLineData[self.leagueLevel].POINT
    self.point.anchoredPosition = Vector2(pointData.X, pointData.Y)
    local pointPos = self.point.anchoredPosition
    local underlinePos = self.levelUnderline.anchoredPosition
    self.connectLine.anchoredPosition = Vector2.Lerp(pointPos, underlinePos, 0.5)
    self.connectLine.sizeDelta = Vector2(Vector2.Distance(pointPos, underlinePos), self.connectLine.sizeDelta.y)
    local radian = (underlinePos.y - pointPos.y) / self.connectLine.sizeDelta.x
    self.connectLine.eulerAngles = Vector3(0, 0, Mathf.Asin(radian) * Mathf.Rad2Deg)
end

--- 构建金字塔等级区域
function LeagueRankPageView:BuildPyramidLevelArea()
    self.levelTitle.text = lang.trans("league_leagueLevel", self.leagueLevel)
    local materialPath = "Assets/CapstonesRes/Game/UI/Scene/League/Material/EffectPyr" .. self.leagueLevel .. "side.mat"
    self.leagueRankEffect.material = Object.Instantiate(res.LoadRes(materialPath))
end

--- 构建上一个赛季信息区域
function LeagueRankPageView:BuildLastSeasonInfoArea()
    if self.lastSeasonData == nil or (self.lastSeasonData ~= nil and self.lastSeasonData.diff == nil) then
        self.lastSeasonInfoArea:SetActive(false)
        return
    end
    
    self.pointNum.text = tostring(self.lastSeasonData.score)
    self.gdNum.text = tostring(self.lastSeasonData.pwin)
    self.goalNum.text = tostring(self.lastSeasonData.goal)
    
    GameObjectHelper.FastSetActive(self.rankFirst, false)
    GameObjectHelper.FastSetActive(self.rankSecond, false)
    GameObjectHelper.FastSetActive(self.rankThird, false)
    GameObjectHelper.FastSetActive(self.rankNum.gameObject, false)

    local leagueRank = self.lastSeasonData.pos + 1

    if leagueRank == 1 then
        GameObjectHelper.FastSetActive(self.rankFirst, true)
    elseif leagueRank == 2 then
        GameObjectHelper.FastSetActive(self.rankSecond, true)
    elseif leagueRank == 3 then
        GameObjectHelper.FastSetActive(self.rankThird, true)
    else
        GameObjectHelper.FastSetActive(self.rankNum.gameObject, true)
        self.rankNum.text = tostring(leagueRank)
    end
end

--- 构建联赛总排行区域
function LeagueRankPageView:BuildRankArea()
    self.myRank.text = tostring(self.rankData.pos + 1)
end

function LeagueRankPageView:Close()
    self:PlayMoveOutAnim()
end

function LeagueRankPageView:PlayMoveOutAnim()
    self.animator:Play("MoveOut")
end

function LeagueRankPageView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:Destroy()
    end
end

function LeagueRankPageView:Destroy()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

return LeagueRankPageView

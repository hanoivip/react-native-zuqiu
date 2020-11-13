local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Mathf = UnityEngine.Mathf

local ArenaRankConstants = require("ui.scene.arena.rank.ArenaRankConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local ArenaRankMainView = class(unity.base)

local ConnectLineCorrectSize = 5
local ConnectLineCorrectDegree = -90
local PointCorrectDegree = -30
local LogoGroupCount = 6

function ArenaRankMainView:ctor()
    self.zoneGroup = self.___ex.zoneGroup
    self.infoBar = self.___ex.infoBar
    self.rankBoard = self.___ex.rankBoard
    -- 暂时隐藏规则按钮，后期可能再加
    -- self.btnRule = self.___ex.btnRule
    self.btnServer = self.___ex.btnServer
    self.btnWorld = self.___ex.btnWorld
    self.btnServerSelect = self.___ex.btnServerSelect
    self.btnServerNormal = self.___ex.btnServerNormal
    self.btnWorldSelect = self.___ex.btnWorldSelect
    self.btnWorldNormal = self.___ex.btnWorldNormal
    self.percentText = self.___ex.percentText
    self.seasonNum = self.___ex.seasonNum
    self.maxStageText = self.___ex.maxStageText
    self.curStageText = self.___ex.curStageText
    self.maxStageLogo = self.___ex.maxStageLogo
    self.curStageLogo = self.___ex.curStageLogo
    self.highGroup = self.___ex.highGroup
    self.curGroup = self.___ex.curGroup
    -- 分割线
    self.underline = self.___ex.underline
    -- 连接线
    self.connectLine = self.___ex.connectLine
    -- 连接点
    self.point = self.___ex.point
    -- 区域特效
    -- self.rankEffect = self.___ex.rankEffect

    self.animator = self.___ex.animator
end

function ArenaRankMainView:start()
    self:BindButtonHandler()
end

function ArenaRankMainView:InitView(arenaModel)
    self.arenaModel = arenaModel
    self:BuildPage()
end

function ArenaRankMainView:BindButtonHandler()
    -- 暂时隐藏规则按钮，后期可能再加
    -- self.btnRule:regOnButtonClick(function()
    --     if self.onRule then
    --         self.onRule()
    --     end
    -- end)

    self.btnServer:regOnButtonClick(function()
        if self.onServer then
            self:SetServerView(true)
            self.onServer()
        end
    end)

    self.btnWorld:regOnButtonClick(function()
        if self.onWorld then
            self:SetServerView(false)
            self.onWorld()
        end
    end)
end

function ArenaRankMainView:BuildPage()
    self:SetServerView(self.arenaModel.type == ArenaRankConstants.Type.Server)
    self:BuildPyramidLine()
    self:BuildPyramidLevelArea()
    self:BuildCurRankInfoArea()

    if luaevt.trig("__SGP__VERSION__") or luaevt.trig("__VN__VERSION__") or luaevt.trig("__KR__VERSION__") then
        GameObjectHelper.FastSetActive(self.zoneGroup["5"].gameObject, false)
        GameObjectHelper.FastSetActive(self.zoneGroup["6"].gameObject, false)
        GameObjectHelper.FastSetActive(self.zoneGroup["7"].gameObject, false)
    end

end

function ArenaRankMainView:SetServerView(isServer)
    GameObjectHelper.FastSetActive(self.btnServerSelect, isServer)
    GameObjectHelper.FastSetActive(self.btnServerNormal, not isServer)
    GameObjectHelper.FastSetActive(self.btnWorldSelect, not isServer)
    GameObjectHelper.FastSetActive(self.btnWorldNormal, isServer)
end

function ArenaRankMainView:BuildPyramidLine()
    local curStage = self.arenaModel:GetCurAreaState()
    local pointData = ArenaRankConstants.RankPyramidLineData[curStage].POINT
    self.point.anchoredPosition = Vector2(pointData.X, pointData.Y)
    local pointPos = self.point.anchoredPosition
    local underlinePos = self.underline.anchoredPosition
    self.connectLine.anchoredPosition = Vector2(underlinePos.x + self.underline.sizeDelta.x / 2, underlinePos.y)
    self.connectLine.sizeDelta = Vector2(Vector2.Distance(pointPos, self.connectLine.anchoredPosition), self.connectLine.sizeDelta.y)
    local radian = (pointPos.x - self.connectLine.anchoredPosition.x) / self.connectLine.sizeDelta.x
    self.connectLine.eulerAngles = Vector3(0, 0, Mathf.Asin(radian) * Mathf.Rad2Deg + ConnectLineCorrectDegree)
    self.point.eulerAngles = Vector3(0, 0, Mathf.Asin(radian) * Mathf.Rad2Deg + PointCorrectDegree)
    self.connectLine.sizeDelta = Vector2(Vector2.Distance(pointPos, self.connectLine.anchoredPosition) - ConnectLineCorrectSize, self.connectLine.sizeDelta.y)
end

function ArenaRankMainView:BuildPyramidLevelArea()
    -- local curStage = self.arenaModel:GetCurAreaState()
    -- local materialPath = "Assets/CapstonesRes/Game/UI/Scene/Arena/Material/EffectPyr" .. curStage .. "side.mat"
    -- self.rankEffect.material = Object.Instantiate(res.LoadRes(materialPath))
end

function ArenaRankMainView:BuildCurRankInfoArea()   
    local curStage, curStageName, highStage, highStageName, seasons = self.arenaModel:GetPlayerGradeInfo()
    local percent = (self.arenaModel.totalNum == 0 or self.arenaModel.selfRank == 0) and 0 or ((self.arenaModel.totalNum - self.arenaModel.selfRank) / self.arenaModel.totalNum) * 100
    self.percentText.text = lang.trans("arena_rank_percent", string.format("%.2f", percent))
    self.seasonNum.text = lang.trans("season_pass", seasons)
    self.maxStageText.text = curStageName    
    self.curStageText.text = highStageName
    for i = 1, LogoGroupCount do
        GameObjectHelper.FastSetActive(self.highGroup["Img" .. i], i == highStage)
        GameObjectHelper.FastSetActive(self.curGroup["Img" .. i], i == curStage)
    end
end

function ArenaRankMainView:RegOnDynamicLoad(func)
    self.infoBar:RegOnDynamicLoad(func)
end

function ArenaRankMainView:GetRankBoard()
    return self.rankBoard
end

function ArenaRankMainView:OnClickBackAnimation()
    self.animator:Play("ArenaRankBoardLeaveAnimation", 0, 0)
end

function ArenaRankMainView:OnAnimationLeave()
    self:OnBtnBack()
end

function ArenaRankMainView:OnBtnBack()
    if self.clickBack then 
        self.clickBack()
    end
end

return ArenaRankMainView

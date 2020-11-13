local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local ChapterScrollerView = class(LuaScrollRectExSameSize)
local STAGE_SUM_ON_PAGE = 8

function ChapterScrollerView:ctor()
    -- 滚动控件
    self.scrollRect = self.___ex.scrollRect
    -- 滚动点组
    self.scrollerPointGroup = self.___ex.scrollerPointGroup
    -- 副本视图model
    self.questPageViewModel = nil
    -- 主线副本数据模型
    self.questInfoModel = nil
    -- 当前章节索引
    self.nowChapterIndex = nil
    -- 当前章节数据
    self.nowChapterData = nil
    self.super.ctor(self)
end

function ChapterScrollerView:awake()
    self:regOnItemIndexChanged(function (index)
        self:SetPointGroup(index)
    end)
end

function ChapterScrollerView:InitView(questPageViewModel, nowChapterIndex)
    self.questPageViewModel = questPageViewModel
    self.questInfoModel = self.questPageViewModel:GetModel()
    self.nowChapterIndex = nowChapterIndex
    self.nowChapterData = self.questInfoModel:GetChapterDataByIndex(self.nowChapterIndex)
    self.itemDatas = {}
    local stageGroupNum = math.ceil(#self.nowChapterData.stageList / STAGE_SUM_ON_PAGE)

    for i = 1, stageGroupNum do
        local stageGroup = {}
        for j = (i - 1) * STAGE_SUM_ON_PAGE + 1, i * STAGE_SUM_ON_PAGE do
            local stageInfoModel = self.nowChapterData.stageList[j]
            if stageInfoModel then
                table.insert(stageGroup, stageInfoModel)
            end
        end
        table.insert(self.itemDatas, stageGroup)
    end

    self:refresh()
    self:BuildPointGroup()
    self:SetPointGroup(1)
    self:ScrollToStage()
end

function ChapterScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Quest/StageGroup.prefab"
    local obj, spt = res.Instantiate(prefab)
    spt:InitView(self.questPageViewModel, self.nowChapterIndex, self.itemDatas[index])
    return obj
end

function ChapterScrollerView:resetItem(spt, index)
    spt:InitView(self.questPageViewModel, self.nowChapterIndex, self.itemDatas[index])
end

function ChapterScrollerView:ControlScrollRect()
    if GuideManager.GuideIsOnGoing("main") then
        self.scrollRect.enabled = false
    else
        self.scrollRect.enabled = true
    end
end

function ChapterScrollerView:BuildPointGroup()
    if #self.itemDatas <= 1 then
        GameObjectHelper.FastSetActive(self.scrollerPointGroup.gameObject, false)
        return
    else
        GameObjectHelper.FastSetActive(self.scrollerPointGroup.gameObject, true)
    end
    
    local pointObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Transfort/PageScrollerPoint.prefab")
    local childLoadedCount = self.scrollerPointGroup.childCount
    if childLoadedCount < #self.itemDatas then
        for i = childLoadedCount + 1, #self.itemDatas do
            local pointGo = Object.Instantiate(pointObj)
            pointGo.transform:SetParent(self.scrollerPointGroup, false)
        end
    elseif childLoadedCount > #self.itemDatas then
        for i = #self.itemDatas + 1, childLoadedCount do
            Object.Destroy(self.scrollerPointGroup:GetChild(i - 1).gameObject)
        end
    end
end

function ChapterScrollerView:SetPointGroup(index)
    if #self.itemDatas <= 1 then
        return
    end
    for i = 1, self.scrollerPointGroup.childCount do
        local child = self.scrollerPointGroup:GetChild(i - 1)
        local point = child:GetChild(0).gameObject
        GameObjectHelper.FastSetActive(point, i == index)
    end
end

-- 滚动到特定关卡页
function ChapterScrollerView:ScrollToStage()
    local stageId = self.questPageViewModel:GetStageId()
    local stageInfoModel = self.questInfoModel:GetStageInfoModelById(stageId)
    local stageIndex = stageInfoModel:GetStageIndex()
    local pageIndex = math.ceil(stageIndex / STAGE_SUM_ON_PAGE)
    if pageIndex > 1 then
        self:scrollToCellImmediate(pageIndex)
    end
end

function ChapterScrollerView:onDestroy()
    self:unregOnItemIndexChanged()
end

return ChapterScrollerView

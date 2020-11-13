local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local RectTransform = UnityEngine.RectTransform
local Vector2 = UnityEngine.Vector2

local GameObjectHelper = require("ui.common.GameObjectHelper")

local QuestScrollerView = class(unity.base)

function QuestScrollerView:ctor()
    -- 翻页插件
    self.book = self.___ex.book
    -- 自动翻页
    self.autoflip = self.___ex.autoflip
    -- 屏幕锁
    self.screenLock = self.___ex.screenLock
    -- 主线副本数据模型
    self.questInfoModel = nil
    -- 副本视图model
    self.questPageViewModel = nil
    -- 当前章节索引
    self.nowChapterIndex = nil
    self.isStarted = false
    self.isRefreshView = false
    -- 是否播放翻页动画
    self.isPlayFlipAnim = false
    -- 页面索引
    self.pageIndex = nil
end

function QuestScrollerView:InitView(questPageViewModel, nowChapterIndex)
    self.questPageViewModel = questPageViewModel
    self.questInfoModel = self.questPageViewModel:GetModel()
    self.nowChapterIndex = nowChapterIndex
    if self.isStarted == true then
        self:RefreshView()
    end
    self:BuildView()
end

function QuestScrollerView:start()
    self.isStarted = true
end

function QuestScrollerView:BuildView()
    self.book.currentPage = self.nowChapterIndex * 2
    self.book.totalPageCount = self.questInfoModel:GetChapterSum() * 2 + 1
    GameObjectHelper.FastSetActive(self.book.gameObject, true)
end

function QuestScrollerView:RefreshView()
    self.isRefreshView = true
    self:BuildView()
    self.book:UpdateSprites()
    self.isRefreshView = false
end

function QuestScrollerView:JumpChapter(chapterIndex, isScrollToStage, isPlayFlipAnim)
    if not isScrollToStage then
        local firstStageId = self.questInfoModel:GetFirstStageIdByChapterIndex(chapterIndex)
        self.questPageViewModel:SetStageId(firstStageId)
    end
    if self.isStarted then
        self:Refresh(chapterIndex, isPlayFlipAnim)
    end
end

function QuestScrollerView:Refresh(chapterIndex, isPlayFlipAnim)
    self.isPlayFlipAnim = isPlayFlipAnim
    if self.isPlayFlipAnim then
        GameObjectHelper.FastSetActive(self.screenLock, true)
        if self.nowChapterIndex > chapterIndex then
            self.autoflip:FlipLeftPage()
        elseif self.nowChapterIndex < chapterIndex then
            self.autoflip:FlipRightPage()
        end
        self.nowChapterIndex = chapterIndex
    else
        self.nowChapterIndex = chapterIndex
        self:RefreshView()
    end
    EventSystem.SendEvent("QuestPageView.RefreshChapterPage", self.nowChapterIndex) 
end

function QuestScrollerView:onInstantiatePage(pageIndex, bookPage)
    self.pageIndex = pageIndex
    -- 是章节页
    if self.pageIndex % 2 == 1 then
        local chapterIndex = (self.pageIndex + 1) / 2
        local chapterPageObj = bookPage:GetChild()
        local chapterPageView = nil
        if chapterPageObj == nil or chapterPageObj == clr.null then
            chapterPageObj, chapterPageView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Quest/ChapterPage.prefab")
            chapterPageObj.transform:SetParent(bookPage.transform, false)
            bookPage:SetChild(chapterPageObj)
            chapterPageView:InitView(self.questPageViewModel, chapterIndex)
        else
            chapterPageView = res.GetLuaScript(chapterPageObj)
            local lastChapterIndex = chapterPageView:GetChapterIndex()
            if lastChapterIndex ~= chapterIndex or self.isRefreshView then
                chapterPageView:InitView(self.questPageViewModel, chapterIndex)
            end
        end
    -- 是关卡页
    else
        local chapterIndex = self.pageIndex / 2
        local stageId = nil
        if self.isPlayFlipAnim then
            stageId = self.questInfoModel:GetFirstStageIdByChapterIndex(chapterIndex)
        else
            stageId = self.questPageViewModel:GetStageId()
        end
        local stagePageObj = bookPage:GetChild()
        local stagePageView = nil
        if stagePageObj == nil or stagePageObj == clr.null then
            stagePageObj, stagePageView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Quest/StagePage.prefab")
            stagePageObj.transform:SetParent(bookPage.transform, false)
            bookPage:SetChild(stagePageObj)
            stagePageView:InitView(self.questInfoModel:GetStageInfoModelById(stageId))
        else
            stagePageView = res.GetLuaScript(stagePageObj)
            local lastStageId = stagePageView:GetStageId()
            if lastStageId ~= stageId then
                stagePageView:InitView(self.questInfoModel:GetStageInfoModelById(stageId))
            end
        end
    end
end

function QuestScrollerView:onFlip()
    GameObjectHelper.FastSetActive(self.screenLock, false)
    self.isPlayFlipAnim = false
end

function QuestScrollerView:onDestroy()
    self.isStarted = false
end

return QuestScrollerView

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3

local ChapterPageView = class(unity.base)

function ChapterPageView:ctor()
    -- 章节标题
    self.chapterTitle = self.___ex.chapterTitle
    -- 章节序列
    self.chapterIndex = self.___ex.chapterIndex
    -- 章节地图
    self.mapImg = self.___ex.mapImg
    -- 章节滚动视图
    self.chapterScrollerView = self.___ex.chapterScrollerView
    -- 选择章节按钮
    self.selectChapterBtn = self.___ex.selectChapterBtn
    -- 章节横幅
    self.chapterBanner = self.___ex.chapterBanner
    -- 副本视图model
    self.questPageViewModel = nil
    -- 主线副本数据模型
    self.questInfoModel = nil
    -- 当前章节索引
    self.nowChapterIndex = nil
    -- 当前章节数据
    self.nowChapterData = nil
end

function ChapterPageView:InitView(questPageViewModel, nowChapterIndex)
    self.questPageViewModel = questPageViewModel
    self.questInfoModel = self.questPageViewModel:GetModel()
    self.nowChapterIndex = nowChapterIndex
    self.nowChapterData = self.questInfoModel:GetChapterDataByIndex(self.nowChapterIndex)
    self.chapterScrollerView:InitView(self.questPageViewModel, self.nowChapterIndex)
    self:BuildView()
end

function ChapterPageView:start()
    self:BindAll()
    self:RegisterEvent()
end

function ChapterPageView:RefreshView()
    self.chapterScrollerView:InitView(self.questPageViewModel, self.nowChapterIndex)
end

--- 注册事件
function ChapterPageView:RegisterEvent()
    EventSystem.AddEvent("ChapterPageView.ControlScrollRect", self, self.ControlScrollRect)
    EventSystem.AddEvent("ChapterPage_RefreshView", self, self.RefreshView)
end

--- 移除事件
function ChapterPageView:RemoveEvent()
    EventSystem.RemoveEvent("ChapterPageView.ControlScrollRect", self, self.ControlScrollRect)
    EventSystem.RemoveEvent("ChapterPage_RefreshView", self, self.RefreshView)
end

function ChapterPageView:BindAll()
    -- 选择章节按钮
    self.selectChapterBtn:regOnButtonClick(function ()
        local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Quest/SelectChapterPage.prefab", "camera", true, true)
        dialogcomp.contentcomp:InitView(self.questInfoModel)
    end)
end

function ChapterPageView:BuildView()
    self.chapterTitle.text = self.nowChapterData.staticData.title
    self.chapterIndex.text = lang.trans("quest_chapterIndex", self.nowChapterIndex)
    self.chapterBanner.sprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Quest/Images/ChapterBanner/ChapterBanner" .. self.nowChapterData.chapterId .. ".png")
    self.mapImg.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Quest/Images/ChapterMap/Chapter" .. self.nowChapterData.staticData.nation .. ".png")
end

function ChapterPageView:GetChapterIndex()
    return self.nowChapterIndex
end

function ChapterPageView:ControlScrollRect()
    self.chapterScrollerView:ControlScrollRect()
end

function ChapterPageView:onDestroy()
    self:RemoveEvent()
end

return ChapterPageView
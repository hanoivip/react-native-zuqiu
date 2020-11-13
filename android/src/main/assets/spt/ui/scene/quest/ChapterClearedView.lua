local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds

local GameObjectHelper = require("ui.common.GameObjectHelper")
local CommonConstants = require("ui.common.CommonConstants")

local ChapterClearedView = class(unity.base)

function ChapterClearedView:ctor()
    -- 画布组
    self.canvasGroup = self.___ex.canvasGroup
    -- 新开启章节标题
    self.nextChapterTitle = self.___ex.nextChapterTitle
    -- 通关章节标题
    self.nowChapterTitle = self.___ex.nowChapterTitle
    -- 通关章节框
    self.nowChapterBox = self.___ex.nowChapterBox
    -- 屏幕锁
    self.screenLock = self.___ex.screenLock
    -- 动画管理器
    self.animator = self.___ex.animator
    -- 主线副本数据模型
    self.questInfoModel = nil
    -- 通关章节索引
    self.nowChapterIndex = nil
    -- 通关章节数据
    self.nowChapterData = nil
    -- 新开启章节索引
    self.nextChapterIndex = nil
    -- 新开启章节数据
    self.nextChapterData = nil
end

function ChapterClearedView:InitView(questInfoModel, nowChapterId)
    self.questInfoModel = questInfoModel
    self.nowChapterIndex = self.questInfoModel:GetChapterIndexById(nowChapterId)
    self.nowChapterData = self.questInfoModel:GetChapterDataByIndex(self.nowChapterIndex)
    self.nextChapterIndex = self.questInfoModel:GetLastChapterIndex()
    self.nextChapterData = self.questInfoModel:GetChapterDataByIndex(self.nextChapterIndex)
    self:BuildView()
    self:PlayMoveInAnim()
end

function ChapterClearedView:BuildView()
    self.nowChapterTitle.text = lang.transstr("quest_chapterIndex", self.nowChapterIndex) .. " " .. self.nowChapterData.staticData.title
    self.nextChapterTitle.text = lang.transstr("quest_chapterIndex", self.nextChapterIndex) .. " " .. self.nextChapterData.staticData.title
    GameObjectHelper.FastSetActive(self.nowChapterBox, self.nowChapterIndex ~= self.nextChapterIndex)
end

function ChapterClearedView:PlayMoveInAnim()
	GameObjectHelper.FastSetActive(self.screenLock, true)
    self.animator:Play("MoveIn", 0)
end

function ChapterClearedView:PlayMoveOutAnim()
    self.animator:Play("MoveOut", 0)
end

function ChapterClearedView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
        GameObjectHelper.FastSetActive(self.screenLock, false)
    elseif animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:Destroy()
    end
end

function ChapterClearedView:Close()
    self:PlayMoveOutAnim()
end

function ChapterClearedView:Destroy()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
    clr.coroutine(function ()
        coroutine.yield(WaitForSeconds(0.1))
        EventSystem.SendEvent("ChapterCleared.Destroy")
    end)
end

return ChapterClearedView

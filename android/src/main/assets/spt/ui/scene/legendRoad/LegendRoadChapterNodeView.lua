local LuaButton = require("ui.control.button.LuaButton")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local LegendRoadChapterNodeView = class(LuaButton, "LegendRoadChapterNodeView")

function LegendRoadChapterNodeView:ctor()
    LegendRoadChapterNodeView.super.ctor(self)
    -- 图标
    self.imgLocked = self.___ex.imgLocked
    self.imgUnlocked = self.___ex.imgUnlocked
    -- 关卡数字
    self.txtLocked = self.___ex.txtLocked
    self.txtUnlocked = self.___ex.txtUnlocked
    -- 箭头
    self.imgArrowLocked = self.___ex.imgArrowLocked
    self.imgArrowUnlocked = self.___ex.imgArrowUnlocked
    self.particle = self.___ex.particle
end

function LegendRoadChapterNodeView:InitView(legendRoadModel, chapter, chapterNum, unlockChapter)
    self.legendRoadModel = legendRoadModel
    self.chapter = chapter
    self:regOnButtonClick(function()
        self:OnChapterNodeClick()
    end)
    self.txtLocked.text = tostring(chapter)
    self.txtUnlocked.text = tostring(chapter)
    local isLocked = tobool(tonumber(chapter) > unlockChapter)
    local currentChapter = legendRoadModel:GetCurrChapterId()
    local isSelect = tobool(tonumber(currentChapter) == tonumber(chapter))
    GameObjectHelper.FastSetActive(self.particle.gameObject, isSelect)

    -- 图标
    GameObjectHelper.FastSetActive(self.imgLocked.gameObject, isLocked)
    GameObjectHelper.FastSetActive(self.imgUnlocked.gameObject, not isLocked)
    -- 数字
    GameObjectHelper.FastSetActive(self.txtLocked.gameObject, isLocked)
    GameObjectHelper.FastSetActive(self.txtUnlocked.gameObject, not isLocked)
    -- 箭头
    local notEnd = tobool(tonumber(chapter) < chapterNum)-- 是否是最后一章
    local isUnlockChapter = tobool(tonumber(chapter) <= unlockChapter)
    GameObjectHelper.FastSetActive(self.imgArrowLocked.gameObject, notEnd and not isUnlockChapter)
    GameObjectHelper.FastSetActive(self.imgArrowUnlocked.gameObject, notEnd and isUnlockChapter)
end

function LegendRoadChapterNodeView:OnChapterNodeClick()
    if self.onChapterNodeClick ~= nil and type(self.onChapterNodeClick) == "function" then
        self.onChapterNodeClick(self.chapter)
    end
end

return LegendRoadChapterNodeView

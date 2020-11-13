local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local SelectChapterScrollView = class(LuaScrollRectExSameSize)

function SelectChapterScrollView:ctor()
    -- 主线副本数据模型
    self.questInfoModel = nil
    -- 当前章节索引
    self.nowChapterIndex = nil
    self.super.ctor(self)
end

function SelectChapterScrollView:InitView(questInfoModel, nowChapterIndex)
    self.questInfoModel = questInfoModel
    self.nowChapterIndex = nowChapterIndex
    self.itemDatas = self.questInfoModel:GetQuestData()
    self:refresh()
    local targetIndex = self.nowChapterIndex - 2
    if targetIndex <= 0 then
        targetIndex = 1
    end
    self:scrollToCellImmediate(targetIndex)
end

function SelectChapterScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Quest/ChapterItemBox.prefab"
    local obj, spt = res.Instantiate(prefab)
    spt:InitView(self.questInfoModel, index, self.nowChapterIndex)
    return obj
end

function SelectChapterScrollView:resetItem(spt, index)
    spt:InitView(self.questInfoModel, index, self.nowChapterIndex)
end

return SelectChapterScrollView
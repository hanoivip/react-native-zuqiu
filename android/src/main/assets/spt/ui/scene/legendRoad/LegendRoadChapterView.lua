local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaButton = require("ui.control.button.LuaButton")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local LegendRoadChapterView = class(LuaButton, "LegendRoadChapterView")

local NodePath = "Assets/CapstonesRes/Game/UI/Scene/LegendRoad/Prefabs/Common/LegendRoadChapterNode.prefab"
function LegendRoadChapterView:ctor()
    self.rct = self.___ex.rct

    self.sptChapters = {}
end

function LegendRoadChapterView:InitView(legendRoadModel)
    self.legendRoadModel = legendRoadModel
    local chapterDatas = self.legendRoadModel:GetChapterDatas()
    self:SetChapterDatas(chapterDatas)
end

function LegendRoadChapterView:GetChapterNodeRes()
    if not self.nodeRes then
        self.nodeRes = res.LoadRes(NodePath)
    end
    return self.nodeRes
end

function LegendRoadChapterView:RefreshView()
    if table.isEmpty(self.chapterDatas) then
        return
    end
    local nodeRes = self:GetChapterNodeRes()
    if nodeRes ~= nil then
        local unlockChapter, unlockStage = self.legendRoadModel:GetCardLegendProgress()
        local nums = table.nums(self.chapterDatas)
        for index, chapterData in pairs(self.chapterDatas) do
            local spt = self.sptChapters[tostring(index)]
            if spt == nil then
                local obj = Object.Instantiate(nodeRes)
                GameObjectHelper.SetParent(obj, self.rct)
                obj.transform:SetSiblingIndex(tonumber(index) - 1)
                spt = res.GetLuaScript(obj)
                self.sptChapters[tostring(index)] = spt
            end
            spt.onChapterNodeClick = function(chapter)
                self:OnChapterNodeClick(chapter)
            end
            spt:InitView(self.legendRoadModel, index, nums, unlockChapter)
        end
    end
end

function LegendRoadChapterView:onDestroy()
    self.nodeRes = nil
end

function LegendRoadChapterView:SetChapterDatas(chapterDatas)
    self.chapterDatas = chapterDatas
end

function LegendRoadChapterView:OnChapterNodeClick(chapter)
    if self.onChapterNodeClick and type(self.onChapterNodeClick) == "function" then
        self.onChapterNodeClick(chapter)
    end
end

return LegendRoadChapterView

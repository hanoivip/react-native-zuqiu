local BaseCtrl = require("ui.controllers.BaseCtrl")
local LegendChapterPreviewCtrl = class(BaseCtrl, "LegendChapterPreviewCtrl")

LegendChapterPreviewCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/LegendRoad/Prefabs/Common/LegendChapterPreview.prefab"

function LegendChapterPreviewCtrl:ctor()
    LegendChapterPreviewCtrl.super.ctor(self)
end

function LegendChapterPreviewCtrl:Init()
    self.view.unlockClick = function() self:OnUnlockClick() end
end

function LegendChapterPreviewCtrl:Refresh(legendRoadModel, chapter)
    LegendChapterPreviewCtrl.super.Refresh(self)
    self.model = legendRoadModel
    self.chapter = chapter
    self.view:InitView(legendRoadModel, chapter)
end

-- 章节解锁不会影响属性
function LegendChapterPreviewCtrl:OnUnlockClick()
    local isUnlockChapter = self.model:IsUnlockChapter(self.chapter)
    if isUnlockChapter then
        self.view:coroutine(function()
            local pcid = self.model:GetCardModel():GetPcid()
            local unlockChapterData = self.model:GetUnlockChapterData(self.chapter)
            local id = unlockChapterData.id
            local response = req.cardLegendUnlockChapter(pcid, id)
            if api.success(response) then
                local data = response.val
                local legendCardData = data.data or {}
                self.model:SetCurrChapterId(self.chapter)
                self.model:UnlockLegendRoadChapter(legendCardData)
                self.view:OnCloseClick()
            end
        end)
    end
end

return LegendChapterPreviewCtrl
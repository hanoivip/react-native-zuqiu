local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local Vector2 = UnityEngine.Vector2
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease

local SweepBarCtrl = require("ui.controllers.quest.sweep.SweepBarCtrl")
local SweepBarTotalCtrl = require("ui.controllers.quest.sweep.SweepBarTotalCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ItemDetailModel = require("ui.models.itemDetail.ItemDetailModel")
local AssetFinder = require("ui.common.AssetFinder")

local SweepRepeatedlyView = class(unity.base)

function SweepRepeatedlyView:ctor()
    self.sweepContent = self.___ex.sweepContent
    self.scroll = self.___ex.scroll
    self.confirmButton = self.___ex.confirmButton
    self.layout = self.___ex.layout
    self.expNum = self.___ex.expNum
    self.expCanvasGroup = self.___ex.expCanvasGroup
    self.debrisObj = self.___ex.debrisObj
    self.nameTxt = self.___ex.nameTxt
    self.countTxt = self.___ex.countTxt
    self.debrisImg = self.___ex.debrisImg
end

local WaitTime = 0.5
local BarStartIndex = 2 -- 从第三个bar开始滑动
function SweepRepeatedlyView:InitView(sweepListModel)
    self.sweepListModel = sweepListModel
    self.barHeight = self.layout.cellSize.y + self.layout.spacing.y
    self:coroutine(function()
        self.expCanvasGroup.alpha = 0
        self.scroll.enabled = false
        local sweepBarRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Quest/SweepBar.prefab")
        local sweepListData = sweepListModel:GetListData()
        local finalIndex = 1
        for index, sweepData in ipairs(sweepListData) do
            SweepBarCtrl.new(index, sweepData, sweepBarRes, self.sweepContent, WaitTime)
            finalIndex = index
            self:UpdateContentPosition(finalIndex)
            coroutine.yield(WaitForSeconds(WaitTime))
        end
        local sweepTotalData = sweepListModel:GetTotalData()
        local sweepBarTotalRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Quest/SweepBarTotal.prefab")
        SweepBarTotalCtrl.new(sweepTotalData, sweepBarTotalRes, self.sweepContent, WaitTime)
        self:UpdateContentPosition(finalIndex + 1)
        self.expNum.text = sweepTotalData.exp and tostring(sweepTotalData.exp.addExp) or "0"
        self:PlayExpFadeInAnim()
        coroutine.yield(WaitForSeconds(WaitTime))
        self.scroll.enabled = true
        self:InitDebrisDate()
    end)
end

function SweepRepeatedlyView:UpdateContentPosition(finalIndex)
    if finalIndex > BarStartIndex then
        local rollHeight = (finalIndex - BarStartIndex) * self.barHeight
        local tweener = ShortcutExtensions.DOAnchorPos(self.sweepContent, Vector2(self.sweepContent.anchoredPosition.x, rollHeight), WaitTime)
    end
end

function SweepRepeatedlyView:start()
    self.confirmButton:regOnButtonClick(function()
        self:Close()
    end)
end

function SweepRepeatedlyView:InitDebrisDate()
    local id = cache.getRequiredEquipId()
    local itemModel = nil
    if id then
        itemModel = ItemDetailModel.new(id)
    else
        return
    end
    local isHasCurrItem = self.sweepListModel:IsHasCurrItem(id)
    if not isHasCurrItem then return end

    self.debrisObj:SetActive(true)
    local need_num = itemModel:GetCompositePieceNum()
    local name = itemModel:GetName()
    local curr_num = itemModel:GetEquipPieceNum()

    self.nameTxt.text = itemModel:GetName()
    self.debrisImg.overrideSprite = AssetFinder.GetEquipIcon(id)

    if tonumber(need_num) == 1 then
        self.countTxt.text = lang.trans("sweepEqsCanWear")
        return
    end
    if need_num <= curr_num then
        self.countTxt.text = lang.trans("sweepEqsCanWear_1")
    else
        self.countTxt.text = lang.trans("sweepDebris", tostring(curr_num), tostring(need_num))
    end
end

function SweepRepeatedlyView:PlayExpFadeInAnim()
    local tweener = ShortcutExtensions.DOFade(self.expCanvasGroup, 1, 0.3)
end

function SweepRepeatedlyView:Close()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function SweepRepeatedlyView:onDestroy()
    local playerInfoModel = PlayerInfoModel.new()
    playerInfoModel:UnlockLevelUp()
end

return SweepRepeatedlyView

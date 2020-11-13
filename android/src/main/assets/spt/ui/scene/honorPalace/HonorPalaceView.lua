local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local PathType = Tweening.PathType
local PathMode = Tweening.PathMode
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local AchieveTag = require("ui.controllers.honorPalace.AchieveTag")

local HonorPalaceView = class(unity.base)

function HonorPalaceView:ctor()
    self.btnBack = self.___ex.btnBack
    self.showTrophyListButton = self.___ex.showTrophyListButton
    self.scrollView = self.___ex.scrollView
    self.scrollView.clickReceive = function(trophyID) self:OnReceiveClick(trophyID) end
    self.trophyNum = self.___ex.trophyNum
    self.trophyCollectedPercent = self.___ex.trophyCollectedPercent
    self.tagButtonGroup = self.___ex.tagButtonGroup
    self.collectionDegree = self.___ex.collectionDegree
    self.showAllAchieve = self.___ex.showAllAchieve
    self.mask = self.___ex.mask
    self.passPoint = self.___ex.passPoint
    self.menu = self.___ex.menu
    self.receiveCupEffect = self.___ex.receiveCupEffect
    self.effortBtn = self.___ex.effortBtn
    self.rewardScrollView = self.___ex.rewardScrollView
    self.finishTxt = self.___ex.finishTxt
    self.finishBarTxt = self.___ex.finishBarTxt
    self.finishSlider = self.___ex.finishSlider
    self.effortTxt = self.___ex.effortTxt
    self.rankTxt = self.___ex.rankTxt
    self.effortSlider = self.___ex.effortSlider
    self.effortSliderTxt = self.___ex.effortSliderTxt
    self.effortLevelTxt = self.___ex.effortLevelTxt
end

function HonorPalaceView:start()
    self.btnBack:regOnButtonClick(function()
        if self.clickBack then
            self.clickBack()
        end
    end)

    self.showTrophyListButton:regOnButtonClick(function()
        if self.showTrophyRoom then
            self.showTrophyRoom()
        end
    end)

    self.effortBtn:regOnButtonClick(function ()
        res.PushDialog("ui.controllers.honorPalace.EffortBoardCtrl")
    end)

    local tagsTransform = self.tagButtonGroup.transform
    for i = 1, tagsTransform.childCount do
        local btnObject = tagsTransform:GetChild(i - 1).gameObject
        btnObject:GetComponent(clr.CapsUnityLuaBehav):regOnButtonClick(function()
            self:OnTagClick(i)
        end)
    end

    self.showAllAchieve:regOnButtonClick(function()
        self:OnTagClick(AchieveTag.SHOWALL)
    end)
    self.menu.localPosition = Vector3(self.menu.localPosition.x, -41, self.menu.localPosition.z)
end

function HonorPalaceView:InitView(honorPalaceModel)
    self.tagButtonGroup:selectMenuItem("showAll")
    self.trophyNum.gameObject:SetActive(true)
    self.collectionDegree.gameObject:SetActive(true)
    local playerTrophyNum = honorPalaceModel:GetTrophyNum()
    self.finishBarTxt.text = tostring(playerTrophyNum) .. " / " .. tostring(honorPalaceModel:GetHonorNumFromTable())
    self.finishSlider.maxValue = tonumber(honorPalaceModel:GetHonorNumFromTable())
    self.finishSlider.value = tonumber(playerTrophyNum)
    self.finishTxt.text = lang.trans("honor_palace_collectionDegree_1", tostring(honorPalaceModel:GetCollectedTrophyPercent(playerTrophyNum)))
    self.rewardScrollView:InitView(honorPalaceModel:GetRewardDataList(), self.scrollPos)
    self.effortTxt.text = honorPalaceModel:GetEffortValue()
    local rank = honorPalaceModel:GetSelfRank()
    self.rankTxt.text = tostring(rank)
    if tonumber(rank) == -1 then
        self.rankTxt.text = lang.trans("train_rankOut")
        self.rankTxt.fontSize = 24
    end

    self.effortSlider.maxValue = honorPalaceModel:GetNeedPoint()
    self.effortSlider.value = honorPalaceModel:GetHavePoint()
    self.effortSliderTxt.text = honorPalaceModel:GetHavePoint() .. "/" .. tostring(honorPalaceModel:GetNeedPoint())
end

function HonorPalaceView:OnReceiveClick(trophyID)
    if self.trophyCollect then
        self.trophyCollect(trophyID)
    end
end

function HonorPalaceView:ShowMask(state)
    self.mask.gameObject:SetActive(state)
end

function HonorPalaceView:RefreshView(data)
    self.scrollView:InitView(data)
end

function HonorPalaceView:OnTagClick(index)
    if self.clickTaskType then
        self.clickTaskType(index)
    end
end

function HonorPalaceView:EventTrophyCollect(trophyID)
    if self.trophyCollectCallBack then
        self.trophyCollectCallBack(trophyID)
    end
end

function HonorPalaceView:PlayTrophyLeaveAnim(obj)
    local aimPos = self.showTrophyListButton.transform.position
    local passPos = self.passPoint.transform.position
    local posTable = {passPos, aimPos}
    self.mySequence = DOTween.Sequence()
    local tweener = ShortcutExtensions.DOPath(obj.transform, clr.array(posTable, Vector3), 0.7, PathType.CatmullRom, PathMode.Full3D, 10, nil)
    local tweenerX = ShortcutExtensions.DOScaleX(obj.transform, 0, 0.7)
    local tweenerY = ShortcutExtensions.DOScaleY(obj.transform, 0, 0.7)
    TweenSettingsExtensions.Append(self.mySequence, tweener)
    TweenSettingsExtensions.AppendCallback(self.mySequence, function ()
        Object.Destroy(obj)
        self.mask.gameObject:SetActive(false)
        self.receiveCupEffect:SetActive(false)
        self.receiveCupEffect:SetActive(true)
    end)
end

function HonorPalaceView:RegisterEvent()
    EventSystem.AddEvent("HonorPalaceView.EventTrophyCollect", self, self.EventTrophyCollect)
    EventSystem.AddEvent("HonorPalaceView.ShowMask", self, self.ShowMask)
    EventSystem.AddEvent("HonorPalaceView.PlayTrophyLeaveAnim", self, self.PlayTrophyLeaveAnim)
end

function HonorPalaceView:RemoveEvent()
    EventSystem.RemoveEvent("HonorPalaceView.EventTrophyCollect", self, self.EventTrophyCollect)
    EventSystem.RemoveEvent("HonorPalaceView.ShowMask", self, self.ShowMask)
    EventSystem.RemoveEvent("HonorPalaceView.PlayTrophyLeaveAnim", self, self.PlayTrophyLeaveAnim)
end

return HonorPalaceView

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local AssetFinder = require("ui.common.AssetFinder")
local HonorPalaceItemModel = require("ui.models.honorPalace.HonorPalaceItemModel")

local HonorPalaceScrollBarView = class(unity.base)

function HonorPalaceScrollBarView:ctor()
    self.title = self.___ex.title
    self.desc = self.___ex.desc
    self.trophyImage = self.___ex.trophyImage
    self.btnCollect = self.___ex.btnCollect
    self.progressBar = self.___ex.progressBar
    self.progressText = self.___ex.progressText
    self.effectParent = self.___ex.effectParent
    self.collectButton = self.___ex.collectButton
    self.txtCollectEnable = self.___ex.txtCollectEnable
    self.txtCollectDisable = self.___ex.txtCollectDisable
    self.effortTxt = self.___ex.effortTxt
    self.disableTxt = self.___ex.disableTxt
end

function HonorPalaceScrollBarView:start()
    self.btnCollect:regOnButtonClick(function()
        self:PlayAnim()
        if self.clickReceive then
            self.clickReceive()
        end
    end)
    EventSystem.AddEvent("HonorPalaceScrollBarView.InitView", self, self.InitView)
end

function HonorPalaceScrollBarView:InitView(data)
    local honorPalaceItemModel = HonorPalaceItemModel.new(data)
    local trophyId = honorPalaceItemModel:GetID()
    self.trophyId = trophyId
    self.effortTxt.text = tostring(honorPalaceItemModel:GetEffortValue())
    self.title.text = honorPalaceItemModel:GetName()
    self.desc.text = honorPalaceItemModel:GetDesc()
    self.trophyImage.overrideSprite = AssetFinder.GetHonorPalaceTrophyIcon(trophyId)
    self.trophyImage:SetNativeSize()
    self.progressBar.value = tonumber(honorPalaceItemModel:GetValue()) / tonumber(honorPalaceItemModel:GetCondition())
    self.progressText.text = tostring(honorPalaceItemModel:GetValue()) .. " / " .. tostring(honorPalaceItemModel:GetCondition())
    local trophyState = honorPalaceItemModel:GetState()
    self.txtCollectEnable:SetActive(trophyState == 0)
    self.collectButton.interactable = trophyState == 0
    self.txtCollectDisable:SetActive(trophyState ~= 0)
    local isLastHonor = honorPalaceItemModel:GetIsLastHonor()
    -- 若当前荣誉已达最高级别，领取完奖励后显示已完成
    self.disableTxt.text = (isLastHonor and trophyState == 1) and lang.trans("have_received") or lang.trans("friends_receiveStrength_receive")
    self.btnCollect:onPointEventHandle(trophyState == 0)
    self.gameObject:SetActive(false)
    self.gameObject:SetActive(true)
end

function HonorPalaceScrollBarView:PlayAnim()
    EventSystem.SendEvent("HonorPalaceView.ShowMask", true)
    local honorMetaShowUpAnimation = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/HonorPalace/HonorMetaShowUpAnimation.prefab"))
    local parent = self.transform.root:FindChild("Board").transform
    honorMetaShowUpAnimation.transform:SetParent(parent, false)
    honorMetaShowUpAnimation.transform.position = self.effectParent.transform.position
    local nodeScript = honorMetaShowUpAnimation:GetComponent(clr.CapsUnityLuaBehav)
    nodeScript:InitView(self.trophyId)
    local tweener = ShortcutExtensions.DOMove(honorMetaShowUpAnimation.transform, parent.position, 1, false)
    self.mySequence = DOTween.Sequence()
    TweenSettingsExtensions.Append(self.mySequence, tweener)
    TweenSettingsExtensions.AppendCallback(self.mySequence, function ()
        nodeScript:PlayEffect()
        nodeScript:PlayAppearAnim()
    end)
end

function HonorPalaceScrollBarView:onDestroy()
    EventSystem.RemoveEvent("HonorPalaceScrollBarView.InitView", self, self.InitView)
end

return HonorPalaceScrollBarView

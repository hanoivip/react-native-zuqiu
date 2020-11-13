local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType

local SubstitutePanel = class(unity.base)

function SubstitutePanel:ctor()
    -- 名字
    self.nameTxt = self.___ex.name
    -- 向上的箭头
    self.arrowUp = self.___ex.arrowUp
    -- 向下的箭头
    self.arrowDown = self.___ex.arrowDown
    self.mRectTrans = self.___ex.mRectTrans
    -- 当前索引
    self.currentIndex = nil
end

function SubstitutePanel:Init(data)
    self.data = data
    self.currentIndex = 1
    self:NextCombination()
end

function SubstitutePanel:NextCombination()
    if self.currentIndex > table.getn(self.data) then
        self.gameObject:SetActive(false)
        return
    end
    local data = self.data[self.currentIndex]
    self.currentIndex = self.currentIndex + 1
    self:PlayAnim(data)
end

function SubstitutePanel:PlayAnim(data)
    self:SetDownPanel(data.down)
    self.mRectTrans.eulerAngles = Vector3(0, 1, 1)
    local downScaleIn = ShortcutExtensions.DOScaleX(self.mRectTrans, 1, 0.3)
    local downScaleOut = ShortcutExtensions.DOScaleX(self.mRectTrans, 0, 0.3)
    local upScaleIn = ShortcutExtensions.DOScaleX(self.mRectTrans, 1, 0.3)
    local upScaleOut = ShortcutExtensions.DOScaleX(self.mRectTrans, 0, 0.3)

    local mySequence = DOTween.Sequence()
    TweenSettingsExtensions.Append(mySequence, downScaleIn)
    TweenSettingsExtensions.AppendInterval(mySequence, 1)
    TweenSettingsExtensions.Append(mySequence, downScaleOut)
    TweenSettingsExtensions.AppendCallback(mySequence, function ()
        self:SetUpPanel(data.up)
    end)
    TweenSettingsExtensions.Append(mySequence, upScaleIn)
    TweenSettingsExtensions.AppendInterval(mySequence, 1)
    TweenSettingsExtensions.Append(mySequence, upScaleOut)
    TweenSettingsExtensions.AppendCallback(mySequence, function ()
        self:NextCombination()
    end)
end

function SubstitutePanel:SetDownPanel(data)
    self.nameTxt.text = tostring(data.number) .. "  " .. data.name
    self.arrowDown:SetActive(true)
    self.arrowUp:SetActive(false)
end

function SubstitutePanel:SetUpPanel(data)
    self.nameTxt.text = tostring(data.number) .. "  " .. data.name
    self.arrowDown:SetActive(false)
    self.arrowUp:SetActive(true)
end

return SubstitutePanel

local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType
local TweenExtensions = Tweening.TweenExtensions
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardDetailSkillItemView = class(unity.base)

local tostring = tostring
local tobool = tobool

function CardDetailSkillItemView:ctor()
    self.nameTxt = self.___ex.name
    self.button = self.___ex.button
    self.skillIcon = self.___ex.skillIcon
    self.levelUpSign = self.___ex.levelUpSign
    self.levelBk = self.___ex.levelBk
    self.level = self.___ex.level
    self.unactivated = self.___ex.unactivated
    self.unactivatedAlpha = self.___ex.unactivatedAlpha
    self.upgrade = self.___ex.upgrade
    self.upgradeTip = self.___ex.upgradeTip
end

function CardDetailSkillItemView:InitView(skillItemModel, canSkillLevelUp, unactivated)
    self.nameTxt.text = tostring(skillItemModel:GetName())
    local isOpen = tobool(skillItemModel:IsOpen())
    local showColor = Color(1, 1, 1)
    if isOpen then
        self.level.text = "Lv." .. tostring(skillItemModel:GetLevel())
        -- 缘分类技能开启但是未被激活
        if unactivated then
            local tweener = ShortcutExtensions.DOFade(self.unactivatedAlpha, 0.5, 1)
            TweenSettingsExtensions.SetLoops(tweener, -1, LoopType.Yoyo)
        end
        GameObjectHelper.FastSetActive(self.unactivated, unactivated)
    else
        showColor = Color(0, 1, 1)
        GameObjectHelper.FastSetActive(self.unactivated, false)
        local slot = skillItemModel:GetSlot()
        self.upgradeTip.text = lang.trans("need_upgrade_open", slot)
    end
    GameObjectHelper.FastSetActive(self.levelBk, isOpen)
    GameObjectHelper.FastSetActive(self.upgrade, not isOpen)
    
    self.skillIcon.color = showColor
    GameObjectHelper.FastSetActive(self.levelUpSign, canSkillLevelUp)
    self.skillIcon.overrideSprite = AssetFinder.GetSkillIcon(skillItemModel:GetIconIndex())
end

function CardDetailSkillItemView:InitViewInSearch(skillItemModel)
    self.nameTxt.text = tostring(skillItemModel:GetName())
    GameObjectHelper.FastSetActive(self.unactivated, false)
    GameObjectHelper.FastSetActive(self.levelUpSign, false)
    GameObjectHelper.FastSetActive(self.levelBk, false)
    GameObjectHelper.FastSetActive(self.upgrade, false)
    self.skillIcon.overrideSprite = AssetFinder.GetSkillIcon(skillItemModel:GetIconIndex())
end

return CardDetailSkillItemView

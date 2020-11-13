local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local Tweener = Tweening.Tweener
local AssetFinder = require("ui.common.AssetFinder")
local UpgradeItemView = class(unity.base)

function UpgradeItemView:ctor()
    self.nameTxt = self.___ex.name
    self.equipIcon = self.___ex.equipIcon
    self.board = self.___ex.board
end

function UpgradeItemView:start()
    local moveInTweener = ShortcutExtensions.DOAnchorPos(self.transform, Vector2(-800, 65), 1)
    TweenSettingsExtensions.SetEase(moveInTweener, Ease.InBack)
    TweenSettingsExtensions.OnComplete(moveInTweener, function ()  --Lua assist checked flag
        Object.Destroy(self.gameObject);
    end)
end

function UpgradeItemView:InitView(equipItemModel)
    self.nameTxt.text = tostring(equipItemModel:GetName())
    self.equipIcon.overrideSprite = AssetFinder.GetItemIcon(equipItemModel:GetIconIndex())
    self.board.overrideSprite = AssetFinder.GetItemQualityBoard(equipItemModel:GetQuality())
end

return UpgradeItemView

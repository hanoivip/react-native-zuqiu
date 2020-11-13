local GameObjectHelper = require("ui.common.GameObjectHelper")
local TabItemView = require("ui.scene.activity.content.growthPlan.TabItemView")
local GiftBagTabItemView = class(TabItemView)

function GiftBagTabItemView:ctor()
    GiftBagTabItemView.super.ctor(self)
    self.unselectedBgImg = self.___ex.unselectedBgImg
end

function GiftBagTabItemView:Init(title, tag, isSpecialTab)
    GiftBagTabItemView.super.Init(self, title, tag)
    self:InitTabView(isSpecialTab)
end

function GiftBagTabItemView:start()
    GiftBagTabItemView.super.start(self)
end

function GiftBagTabItemView:InitTabView(isSpecialTab)
    local imgPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Image/TimeLimitGiftBag/NormalUnselectedTabBg.png"
    if isSpecialTab then
        imgPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Image/TimeLimitGiftBag/UnselectedTabBg.png"
    end
    self.unselectedBgImg.overrideSprite = res.LoadRes(imgPath)
end

function GiftBagTabItemView:RefreshRedPoint(tag, isShowRedPoint)
    GiftBagTabItemView.super.RefreshRedPoint(self, tag, isShowRedPoint)
end

function GiftBagTabItemView:onDestroy()
    GiftBagTabItemView.super.onDestroy(self)
end

return GiftBagTabItemView


local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions

local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local HomeBannerScrollView = class(LuaScrollRectExSameSize)

function HomeBannerScrollView:ctor()
    self.tweenId = "BannerScroll"
    self.tweenTime = 5
    self.nowScrollIndex = nil
    self.isInited = false
    HomeBannerScrollView.super.ctor(self)
end

function HomeBannerScrollView:Clear()
    self:clearData()
end

function HomeBannerScrollView:InitView(data, selectIndex)
    self.data = data
    self.nowScrollIndex = selectIndex
    self.isInited = true
    self:refresh(self.data)
    self:scrollToCellImmediate(self.nowScrollIndex)
    self:StartAutoScroll()
end

function HomeBannerScrollView:OnItemIndexChanged(index)
    self.nowScrollIndex = index
    self:StartAutoScroll()
end

function HomeBannerScrollView:OnBtnBanner(index)
    if self.clickBanner then
        self.clickBanner(index)
    end
end

function HomeBannerScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Home/Banner/SingleBanner.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function HomeBannerScrollView:resetItem(spt, index)
    spt.clickBack = function() self:OnBtnBanner(index) end
    spt:InitView(self.data[index])
    self:updateItemIndex(spt, index)
end

function HomeBannerScrollView:onEnable()
    if self.isInited then
        self:StartAutoScroll()
    end
end

function HomeBannerScrollView:onDisable()
    self:StopAutoScroll()
end

function HomeBannerScrollView:StartAutoScroll()
    self:StopAutoScroll()
    self:AutoScroll()
end

function HomeBannerScrollView:AutoScroll()
    local mySequence = DOTween.Sequence()
    TweenSettingsExtensions.SetId(mySequence, self.tweenId)
    TweenSettingsExtensions.AppendInterval(mySequence, self.tweenTime)
    TweenSettingsExtensions.AppendCallback(mySequence, function ()
        self.nowScrollIndex = self.nowScrollIndex + 1
        if self.nowScrollIndex > #self.data then
            self.nowScrollIndex = 1
        end
        self:scrollToCellEx(self.nowScrollIndex)
        self:AutoScroll()
    end)
end

function HomeBannerScrollView:StopAutoScroll()
    DOTween.Kill(self.tweenId)
end

return HomeBannerScrollView

local BannerSignNodeView = class(unity.base)

function BannerSignNodeView:ctor()
    self.signBtn = self.___ex.signBtn
end

function BannerSignNodeView:ShowNodeState(isSelect)
    self.signBtn.interactable = isSelect
end

return BannerSignNodeView

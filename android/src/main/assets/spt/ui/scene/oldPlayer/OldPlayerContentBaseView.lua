local GameObjectHelper = require("ui.common.GameObjectHelper")
local OldPlayerContentBaseView = class(unity.base)

function OldPlayerContentBaseView:ctor()
    self.scrollView = self.___ex.scrollView
    self.title = self.___ex.title
    self:OnCreateTagList()
end

function OldPlayerContentBaseView:OnCreateTagList()
    self.scrollView:regOnCreateItem(function(scrollSelf, index)
        local obj, spt = res.Instantiate(self.ItemPath)
        scrollSelf:resetItem(spt, index)
        return obj, spt
    end)
    
    self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
        local itemData = self.scrollView.itemDatas[index]
        itemData.index = index
        spt.onRecv = function(reqCallBack) self:OnRecv(itemData, reqCallBack) end
        spt.onBuy = function(reqCallBack) self:OnBuy(itemData, reqCallBack) end
        spt:InitView(itemData)
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function OldPlayerContentBaseView:OnRecv(recvData, reqCallBack)
    if self.onRecv then 
        self.onRecv(recvData, reqCallBack)
    end
end

function OldPlayerContentBaseView:OnBuy(recvData, reqCallBack)
    if self.onBuy then 
        self.onBuy(recvData, reqCallBack)
    end
end

function OldPlayerContentBaseView:InitView(contentData)
    self.title.text = contentData.itemDatas[1].tabDesc
    self:RefrshScrollView(contentData.itemDatas)
end

function OldPlayerContentBaseView:RefrshScrollView(itemDatas)
    self.scrollView:clearData()
    self.scrollView:refresh(itemDatas)
end

function OldPlayerContentBaseView:HideView()
    GameObjectHelper.FastSetActive(self.gameObject, false)
end

function OldPlayerContentBaseView:ShowView()
    GameObjectHelper.FastSetActive(self.gameObject, true)
end

return OldPlayerContentBaseView

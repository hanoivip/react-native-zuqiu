local GameObjectHelper = require("ui.common.GameObjectHelper")

local PeakShopRefreshDialogView = class(unity.base)

function PeakShopRefreshDialogView:ctor()
    self.btnClose = self.___ex.btnClose
    -- 刷新按钮
    self.btnRefresh = self.___ex.btnRefresh
    -- 刷新次数文本
    self.txtRefreshTimes = self.___ex.txtRefreshTimes
    -- 价格
    self.priceTxt = self.___ex.priceTxt
end

function PeakShopRefreshDialogView:start()
    self:BindButtonHandler()
end

function PeakShopRefreshDialogView:InitView(peakStoreModel)
    self.priceTxt.text = "x" .. peakStoreModel:GetRefreshPrice()
    self.txtRefreshTimes.text = (peakStoreModel:GetMaxRefreshTimes() - peakStoreModel:GetRefreshTimes()) .. "/" .. peakStoreModel:GetMaxRefreshTimes()
end

function PeakShopRefreshDialogView:BindButtonHandler()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnRefresh:regOnButtonClick(function()
        if self.onRefresh then
            self.onRefresh()
        end
    end)
end

function PeakShopRefreshDialogView:Close()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

return PeakShopRefreshDialogView
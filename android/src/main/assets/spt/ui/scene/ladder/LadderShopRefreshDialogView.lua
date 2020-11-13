local GameObjectHelper = require("ui.common.GameObjectHelper")

local LadderShopRefreshDialogView = class(unity.base)

function LadderShopRefreshDialogView:ctor()
    self.btnClose = self.___ex.btnClose
    -- 刷新按钮
    self.btnRefresh = self.___ex.btnRefresh
    -- 可用的刷新按钮区域
    self.refreshButton = self.___ex.refreshButton
    -- 不可用的刷新按钮区域
    self.refreshDisableButton = self.___ex.refreshDisableButton
    -- 提示文本
    self.txtHintInfo = self.___ex.txtHintInfo
    -- 刷新次数文本
    self.txtRefreshTimes = self.___ex.txtRefreshTimes
end

function LadderShopRefreshDialogView:start()
    self:BindButtonHandler()
end

function LadderShopRefreshDialogView:InitView(ladderModel)
    local refreshRemainTimes = ladderModel:GetShopCostRefreshRemainTimes()
    if refreshRemainTimes == 0 then
        self.txtHintInfo.text = lang.trans("ladder_shop_refreshCountHint")
    else
        self.txtHintInfo.text = lang.trans("ladder_shop_refreshCostHint")
    end
    GameObjectHelper.FastSetActive(self.refreshButton, refreshRemainTimes ~= 0)
    GameObjectHelper.FastSetActive(self.refreshDisableButton, refreshRemainTimes == 0)
    self.txtRefreshTimes.text = lang.trans("ladder_shop_refreshCountValue", tostring(refreshRemainTimes))
end

function LadderShopRefreshDialogView:BindButtonHandler()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnRefresh:regOnButtonClick(function()
        if self.onRefresh then
            self.onRefresh()
        end
    end)
end

function LadderShopRefreshDialogView:Close()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

return LadderShopRefreshDialogView
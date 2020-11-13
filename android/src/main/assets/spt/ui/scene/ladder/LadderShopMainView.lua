local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local LadderShopMainView = class(unity.base)

function LadderShopMainView:ctor()
    self.btnBack = self.___ex.btnBack
    self.btnRefresh = self.___ex.btnRefresh
    self.txtAutoRefreshTime = self.___ex.txtAutoRefreshTime
    self.txtMyHonor = self.___ex.txtMyHonor
    self.shopArea = self.___ex.shopArea
end

function LadderShopMainView:start()
    self:BindButtonHandler()
end

function LadderShopMainView:InitView(ladderModel)
    self.ladderModel = ladderModel
    local autoRefreshTime = ladderModel:GetShopAutoRefreshTime()
    if autoRefreshTime == 0 then
        autoRefreshTime = 24
    end
    self.txtAutoRefreshTime.text = lang.trans("ladder_shop_AutoRefreshTimeValue", tostring(autoRefreshTime))
    self:RefreshMyCurHonorPoint()
    self:RefreshShopItems()
end

function LadderShopMainView:BindButtonHandler()
    self.btnBack:regOnButtonClick(function()
        if self.onBack then
            self.onBack()
        end
    end)
    self.btnRefresh:regOnButtonClick(function()
        if self.onRefresh then
            self.onRefresh()
        end
    end)
end

function LadderShopMainView:RefreshShopItems()
    if self.refreshShopItems then
        self.refreshShopItems()
    end
end

function LadderShopMainView:ClearShopItems()
    local count = self.shopArea.childCount
    for i = 0, count - 1 do
        Object.Destroy(self.shopArea:GetChild(i).gameObject)
    end
end

function LadderShopMainView:AddShopItem(shopTeam)
    shopTeam.transform:SetParent(self.shopArea, false)
end

function LadderShopMainView:RefreshMyCurHonorPoint()
    self.txtMyHonor.text = tostring(self.ladderModel:GetMyCurrentHonorPoint())
end

return LadderShopMainView

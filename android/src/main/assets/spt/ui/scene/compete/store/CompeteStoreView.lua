local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local CompeteStoreView = class(unity.base, "CompeteStoreView")

function CompeteStoreView:ctor()
    self.btnBack = self.___ex.btnBack
    self.scrollView = self.___ex.scrollView
    self.infoBarDynParent = self.___ex.infoBarDynParent
end

function CompeteStoreView:start()
end

function CompeteStoreView:InitView(competeStoreModel)
    self.model = competeStoreModel

    self.btnBack:regOnButtonClick(function()
        if self.onClickBack then
            self.onClickBack()
        end
    end)

    local scrollData = self.model:GetScrollViewData()
    self.scrollView:InitView(scrollData)
end

function CompeteStoreView:ClearScrollData()
    self.scrollView:clearData()
end

function CompeteStoreView:OnEnterScene()
    EventSystem.AddEvent("refresh_after_bought", self, self.refreshAfterBought)
end

function CompeteStoreView:OnExitScene()
    EventSystem.RemoveEvent("refresh_after_bought", self, self.refreshAfterBought)
end

function CompeteStoreView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return CompeteStoreView
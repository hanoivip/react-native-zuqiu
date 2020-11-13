local EventSystem = require("EventSystem")

local DiscountStoreView = class(unity.base)

function DiscountStoreView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.contentParent = self.___ex.contentParent
    self.refreshButton = self.___ex.refreshButton
    self.btnRefresh = self.___ex.btnRefresh
    self.txtRestTimes = self.___ex.txtRestTimes

    self.frameSptList = {}
end

function DiscountStoreView:start()
    self.btnRefresh:regOnButtonClick(function()
        if type(self.onBtnRefresh) == "function" then
            self.onBtnRefresh()
        end
    end)
end

function DiscountStoreView:OnEnterScene()
    EventSystem.AddEvent("LuckyWheelModel_SetTreasure", self, self.EventUpdateCouponInfo)
    EventSystem.AddEvent("LuckyWheelModel_SetDiscountStore", self, self.EventUpdateStoreList)
    EventSystem.AddEvent("LuckyWheelModel_SetRestRefreshTimes", self, self.EventUpdateRefreshTimes)
end

function DiscountStoreView:OnExitScene()
    EventSystem.RemoveEvent("LuckyWheelModel_SetTreasure", self, self.EventUpdateCouponInfo)
    EventSystem.RemoveEvent("LuckyWheelModel_SetDiscountStore", self, self.EventUpdateStoreList)
    EventSystem.RemoveEvent("LuckyWheelModel_SetRestRefreshTimes", self, self.EventUpdateRefreshTimes)
end

function DiscountStoreView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function DiscountStoreView:InitView(luckyWheelModel)
    self:UpdateStoreList(luckyWheelModel)
    self:UpdateRefreshTimes(luckyWheelModel:GetRestRefreshTimes())
end

function DiscountStoreView:UpdateStoreList(luckyWheelModel)
    self.frameSptMap = {}
    local storeList = luckyWheelModel:GetDiscountStoreList()
    for i, v in ipairs(storeList) do
        if not self.frameSptList[i] then
            local frameObj, frameSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Activties/LuckyWheel/DiscountCardFrame.prefab")
            frameObj.transform:SetParent(self.contentParent.transform, false)
            self.frameSptList[i] = frameSpt
        end
        self.frameSptList[i]:InitView(luckyWheelModel, v)
        self.frameSptList[i].onBtnBuy = function(couponID)
            if type(self.onBtnBuy) == "function" then
                self.onBtnBuy(v.cid, v.price, couponID)
            end
        end
        self.frameSptList[i].onCardClick = function()
            if type(self.onCardClick) == "function" then
                self.onCardClick(v.cid)
            end
        end
        self.frameSptMap[tostring(v.cid)] = self.frameSptList[i]
    end
end

function DiscountStoreView:UpdateRefreshTimes(restRefreshTimes)
    self.refreshButton.interactable = restRefreshTimes > 0
    self.txtRestTimes.text = tostring(restRefreshTimes) .. "/10"
end

function DiscountStoreView:Refresh(luckyWheelModel)
    self:EventUpdateCouponInfo(luckyWheelModel)
end

function DiscountStoreView:EventUpdateCouponInfo(luckyWheelModel)
    for cid, frameSpt in pairs(self.frameSptMap) do
        frameSpt:UpdateCouponInfo(luckyWheelModel)
    end
end

function DiscountStoreView:EventUpdateStoreList(luckyWheelModel)
    self:UpdateStoreList(luckyWheelModel)
end

function DiscountStoreView:EventUpdateRefreshTimes(luckyWheelModel)
    self:UpdateRefreshTimes(luckyWheelModel)
end

return DiscountStoreView

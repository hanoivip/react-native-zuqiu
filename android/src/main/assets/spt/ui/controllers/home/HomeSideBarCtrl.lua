local MailListCtrl = require("ui.controllers.mail.MailListCtrl")
local MenuCtrl = require("ui.controllers.home.MenuCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

local HomeSideBarCtrl = class()

function HomeSideBarCtrl:ctor(view, viewParent, parentCtrl)
    self.parentCtrl = parentCtrl
    if view then 
        self.HomeSideBarView = view
    else
        local viewObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Home/SideBar/SideBar.prefab")
        viewObject.transform:SetParent(viewParent.transform, false)
        self.HomeSideBarView = viewObject:GetComponent(clr.CapsUnityLuaBehav)
    end

    self.HomeSideBarView.clickStore = function() self:OnBtnStore() end
    self.HomeSideBarView.clickEmail = function() self:OnBtnEmail() end
    self.HomeSideBarView.clickActivity = function() self:OnBtnActivity() end
    self.HomeSideBarView.clickMore = function() self:OnBtnMore() end
end

function HomeSideBarCtrl:OnBtnStore()
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        local storeCtrl = res.PushSceneImmediate("ui.controllers.store.StoreCtrl")
        GuideManager.Show(storeCtrl)
    end)
end

function HomeSideBarCtrl:OnBtnEmail()
    local mailListCtrl = MailListCtrl.new()
end

function HomeSideBarCtrl:OnBtnActivity()
    if GuideManager.GuideIsOnGoing('GrowthPlan') then
        res.PushScene("ui.controllers.activity.ActivityCtrl", 'GrowthPlanLevel')
        GuideManager.Show()
    else
        res.PushScene("ui.controllers.activity.ActivityCtrl")
    end
end

function HomeSideBarCtrl:OnBtnMore()
    MenuCtrl.new()
end

function HomeSideBarCtrl:IsShowGachaPage()
    clr.coroutine(function ()
        local response = req.storeDay()
        if api.success(response) then
            local today = response.val.createDays
        end
    end)
end

return HomeSideBarCtrl

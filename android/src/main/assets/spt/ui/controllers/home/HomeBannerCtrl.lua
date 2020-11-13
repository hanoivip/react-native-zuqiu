local PlayerHomeEventModel = require("ui.models.PlayerHomeEventModel")
local BannerModel = require("ui.models.banner.BannerModel")
local HomeBannerSignCtrl = require("ui.controllers.home.HomeBannerSignCtrl")
local BannerJumpType = require("ui.controllers.home.BannerJumpType")
local HomeBannerCtrl = class()

function HomeBannerCtrl:ctor(view, viewParent, parentScript)
    self.bannerView = view
    self.parentScript = parentScript
    self.homeBannerSignCtrl = HomeBannerSignCtrl.new(self.bannerView.bannerSignContent)
    self.bannerModel = BannerModel.new()
    self.bannerIndex = nil
end

function HomeBannerCtrl:InitView(bannerData, bannerIndex)
    local isShowBanner = false
    if bannerData and next(bannerData) then
        isShowBanner = true
        self.homeBannerSignCtrl:InitView(#bannerData)
        self.bannerView.scroll:regOnItemIndexChanged(function(bannerIndex)
            self:ChangeSign(bannerIndex)
            self.bannerView.scroll:OnItemIndexChanged(bannerIndex)
        end)
        self.bannerView.scroll:InitView(bannerData, bannerIndex)
        self.bannerView.scroll.clickBanner = function(bannerIndex) self:OnBtnBanner(bannerIndex) end
    end
    self.bannerView:InitView(isShowBanner)
end

function HomeBannerCtrl:ChangeSign(bannerIndex)
    if self.bannerIndex == bannerIndex then return end
    self.homeBannerSignCtrl:ChangeSign(bannerIndex)
    self.bannerModel:SetSelectBanner(bannerIndex)
    self.bannerIndex = bannerIndex
end

function HomeBannerCtrl:Refresh()
    local playerHomeEventModel = PlayerHomeEventModel.new()
    self.bannerModel:InitWithProtocol(playerHomeEventModel:GetBannerData())
    self:InitView(self.bannerModel:GetBannerData(), self.bannerModel:GetSelectBanner())
end

function HomeBannerCtrl:OnBtnBanner(bannerIndex)
    local bannerData = self.bannerModel:GetBannerData()
    assert(bannerData)
    local activityData = bannerData[bannerIndex]
    assert(activityData)
    if activityData["bannerJump"] == BannerJumpType.Activity then
        res.PushScene("ui.controllers.activity.ActivityCtrl", activityData.type)
    elseif activityData["bannerJump"] == BannerJumpType.Gacha then
        if not activityData["jumpPosition"] then
            activityData["jumpPosition"] = "A1"
        end
        res.PushScene("ui.controllers.gacha.GachaMainCtrl", nil, nil, activityData["jumpPosition"])
    end
end

return HomeBannerCtrl

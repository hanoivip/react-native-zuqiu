local Model = require("ui.models.Model")
local BannerModel = class(Model, "BannerModel")

function BannerModel:ctor()
    BannerModel.super.ctor(self)
    self.bannerIndex = 1
    self.selectBannerData = nil
    self.data = {}
end

function BannerModel:InitWithProtocol(data)
    self.data = data
end

function BannerModel:GetBannerData()
    return self.data 
end

function BannerModel:GetSelectBanner()
    if self.selectBannerData then 
        local selectType = self.selectBannerData["type"]
        local selectId = self.selectBannerData["id"]
        for i, v in ipairs(self.data) do
            local bannerType = v["type"]
            local bannerdId = v["id"] 
            if selectType == bannerType and selectId == bannerdId then
                self.bannerIndex = i
                break
            end
        end
    end
    return self.bannerIndex 
end

function BannerModel:GetSelectBannerData()
    return self.selectBannerData 
end

function BannerModel:SetSelectBanner(bannerIndex)
    self.bannerIndex = bannerIndex
    self.selectBannerData = self.data[bannerIndex]
end

return BannerModel

local AssetFinder = require("ui.common.AssetFinder")
local UnityEngine = clr.UnityEngine
local TransfortSponsorItemView = class(unity.base)

function TransfortSponsorItemView:ctor()
    self.logoImg = self.___ex.logoImg
    self.nameTxt = self.___ex.nameTxt
    self.focus = self.___ex.focus
    self.upgrade = self.___ex.upgrade
    self.upgradeFinish = self.___ex.upgradeFinish
end

function TransfortSponsorItemView:start()
end

function TransfortSponsorItemView:InitView(data, i, sponsorLvl, oldLvl)
    self.nameTxt.text = data.sponsorName
    self.logoImg.overrideSprite = AssetFinder.GetSponsorIcon(data.picIndex)
    if oldLvl and oldLvl < 0 then
        sponsorLvl = 1
    end
    self.upgrade:SetActive(i == oldLvl)
    self.focus:SetActive(i == sponsorLvl)
    clr.coroutine(function ()
        coroutine.yield(UnityEngine.WaitForSeconds(0.5))
        if oldLvl and i == sponsorLvl then
            self.upgradeFinish:SetActive(true)
        end
    end)
end

return TransfortSponsorItemView

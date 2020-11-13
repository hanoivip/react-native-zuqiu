local GameObjectHelper = require("ui.common.GameObjectHelper")
local SponsorUpgrade = require("data.SponsorUpgrade")

local TransportRuleView = class(unity.base)

function TransportRuleView:ctor()
    self.scrollView = self.___ex.scrollView
    self.menuGroup = self.___ex.menuGroup
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.contentTitle = self.___ex.contentTitle
    self.descContent = self.___ex.descContent
    self.ruleContent = self.___ex.ruleContent
    self.sponsorContent = self.___ex.sponsorContent
    self.sponsorDescRect = self.___ex.sponsorDescRect
end

function TransportRuleView:start()
    self.ruleItemPath = "Assets/CapstonesRes/Game/UI/Scene/Transfort/TransportRuleSponsorItem.prefab"
end

function TransportRuleView:InitView()

end

function TransportRuleView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function TransportRuleView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function TransportRuleView:InitBasicDescView()
    self.menuGroup:selectMenuItem("basic")
    GameObjectHelper.FastSetActive(self.descContent, true)
    GameObjectHelper.FastSetActive(self.ruleContent, false)
    GameObjectHelper.FastSetActive(self.sponsorContent, false)
end

function TransportRuleView:InitSponsorDescView()
    self.menuGroup:selectMenuItem("sponsor")
    GameObjectHelper.FastSetActive(self.descContent, false)
    GameObjectHelper.FastSetActive(self.ruleContent, false)
    GameObjectHelper.FastSetActive(self.sponsorContent, true)
    local upgrade = {}
    for k, v in pairs(SponsorUpgrade) do
        table.insert(upgrade, v)
    end
    table.sort(upgrade, function (a, b)
        return tonumber(a.quality) > tonumber(b.quality)
    end)
    res.ClearChildren(self.sponsorDescRect)
    for k, v in pairs(upgrade) do
        local obj, spt = res.Instantiate(self.ruleItemPath)
        obj.transform:SetParent(self.sponsorDescRect, false)
        spt:InitView(v)
    end
end

function TransportRuleView:InitRuleDescView()
    self.menuGroup:selectMenuItem("rule")
    GameObjectHelper.FastSetActive(self.descContent, false)
    GameObjectHelper.FastSetActive(self.ruleContent, true)
    GameObjectHelper.FastSetActive(self.sponsorContent, false)
end

return TransportRuleView

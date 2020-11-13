local GameObjectHelper = require("ui.common.GameObjectHelper")

local MedalRuleView = class(unity.base)

function MedalRuleView:ctor()
    self.scrollView = self.___ex.scrollView
    self.menuGroup = self.___ex.menuGroup
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.contentTitle = self.___ex.contentTitle
    self.descContent = self.___ex.descContent
    self.descQContent = self.___ex.descQContent
    self.descText = self.___ex.descText
    self.descTitleText = self.___ex.descTitleText
    self.descQText = self.___ex.descQText
    self.allItem = self.___ex.allItem
end

function MedalRuleView:start()
    self:InitLocalTable()
end

--策划写死
function MedalRuleView:InitLocalTable()
    local namePre = lang.transstr("medal_quality_name_pre")
    local allNames = { "C", "B", "A", "S", "SS", "SSS", "SSS", "SSS", "SSS"}
    local allNamePres = {namePre, namePre, namePre, namePre, namePre, namePre, "", "", ""}
    local allPreNames = {"", "", "", "", "", "", lang.transstr("medal_RY"), lang.transstr("medal_XY"), lang.transstr("medal_ZZ")}
    local alldes1 = { "+10", "+20", "+30", "+40", "+50", "+70", "+70", "+70", "+70"}
    local alldes2 = { "nil", "0.1% - 1%", "1% - 2%", "2% - 4%", "4% - 8%", "10% - 13%", "11%-14%", "12%-15%", "12%-16%"}
    for k,v in pairs(self.allItem) do
        k = tonumber(k)
        local itemData = {
            mName = allPreNames[k] .. allNames[k] .. allNamePres[k] .. lang.transstr("medal_quality_name"),
            des1 = lang.transstr("medal_quality_add_property") .. alldes1[k],
            des2 = (k > 1 ) and alldes2[k] or lang.trans("none"),
            des3 = (k > 2 ) and lang.trans("medal_quality_add_level",(k > 6 and 6 or k) - 2) or lang.trans("none")
        }
        v:InitView(itemData)
    end
end

function MedalRuleView:InitView()
end

function MedalRuleView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function MedalRuleView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function MedalRuleView:SetShowText(mType)
    self.descText.text = lang.trans("medal_" .. mType .. "_content")
    self.contentTitle.text = lang.trans("medal_" .. mType .. "_title")
end

function MedalRuleView:InitBaseDescView()
    self.menuGroup:selectMenuItem("baseDesc")
    self:SetAreaShow(true, false)
    self:SetShowText("baseDesc")
end

function MedalRuleView:InitQualityDescView()
    self.menuGroup:selectMenuItem("qualityDesc")
    self:SetAreaShow(false, true)
    self:SetShowText("qualityDesc")
    
end

function MedalRuleView:InitBreakDescView()
    self.menuGroup:selectMenuItem("breakDesc")
    self:SetAreaShow(true, false)
    self:SetShowText("breakDesc")
end

function MedalRuleView:SetAreaShow(flag1, flag2)
    GameObjectHelper.FastSetActive(self.descContent, flag1)
    if not self.comeIn then
        clr.coroutine(function()
            unity.waitForNextEndOfFrame()
            GameObjectHelper.FastSetActive(self.descQContent, flag2)
        end)
        self.comeIn = true
    else
        GameObjectHelper.FastSetActive(self.descQContent, flag2)
    end
end

return MedalRuleView
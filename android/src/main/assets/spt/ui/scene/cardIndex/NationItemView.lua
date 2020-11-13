local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local NationItemView = class(unity.base)

function NationItemView:ctor()
    self.icon = self.___ex.icon
    self.nameTxt = self.___ex.name
    self.selectSign = self.___ex.selectSign
    self.btnSelect = self.___ex.btnSelect
end

function NationItemView:start()
    EventSystem.AddEvent("PlayerSearch.OnNationClick", self, self.UpdateState)
end

function NationItemView:InitView(nationName, nationData, onNationSelect)
    self.nationName = nationName
    self.onSelect = onNationSelect
    self.nameTxt.text = nationData.name
    if nationData.isShow == 0 then
        GameObjectHelper.FastSetActive(self.gameObject, false)
        return
    end
    local nationRes = AssetFinder.GetNationIcon(nationName)
    self.icon.overrideSprite = nationRes
    self.btnSelect:regOnButtonClick(function()
        if self.onSelect then
            self.onSelect(nationName, nationData)
        end
    end)
end

function NationItemView:UpdateState(selectNationName, selectNationData)
    if self.nationName == selectNationName then
        GameObjectHelper.FastSetActive(self.selectSign, true)
        self.nameTxt.color = Color(0.98, 0.92, 0.275, 1)
    else
        GameObjectHelper.FastSetActive(self.selectSign, false)
        self.nameTxt.color = Color.white
    end
end

function NationItemView:onDestroy()
    EventSystem.RemoveEvent("PlayerSearch.OnNationClick", self, self.UpdateState)
end

return NationItemView
local UnityEngine = clr.UnityEngine
local AssetFinder = require("ui.common.AssetFinder")
local Text=UnityEngine.UI.Text

local DreamBagGroupItemView = class(unity.base)


function DreamBagGroupItemView:ctor()
    self.titleText = self.___ex.titleText
    self.itemParent = self.___ex.itemParent
end

function DreamBagGroupItemView:InitView(data, clickNationCallBack)
    self.titleText.text = lang.trans("first_letter_team", data.firstLetter)
    res.ClearChildren(self.itemParent)
    for nationName, nationInfo in pairs(data.nations) do
        for teamName, teamInfo in pairs(nationInfo) do
            if type(teamInfo) == "table" then
                local nationObj, nationSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamBag/NationItem.prefab")
                teamInfo.firstLetter = data.firstLetter
                teamInfo.nationName = nationName
                nationSpt.transform:SetParent(self.itemParent, false)
                nationSpt:InitView(teamInfo, clickNationCallBack, data.needFilterPosIndex)
            end
        end
    end
end

return DreamBagGroupItemView

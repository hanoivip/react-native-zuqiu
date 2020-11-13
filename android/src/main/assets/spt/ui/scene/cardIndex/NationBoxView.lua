local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local NationBoxView = class(unity.base)
local DefaultNation = ""

function NationBoxView:ctor()
    self.letter = self.___ex.letter
    self.gridGroup = self.___ex.gridGroup
    self.selfRectTransform = self.___ex.selfRectTransform
    self.btnLetter = self.___ex.btnLetter
end

function NationBoxView:InitView(data, letter, objRes)
    self.letter.text = tostring(letter)
    if letter == "0" then
        self.letter.text = lang.trans("none")
        GameObjectHelper.FastSetActive(self.gridGroup.gameObject, false)
        GameObjectHelper.FastSetActive(self.btnLetter.gameObject, true)
        self.btnLetter:regOnButtonClick(function()
            self.onNationSelect(DefaultNation, nil)
        end)
    else
        GameObjectHelper.FastSetActive(self.btnLetter.gameObject, false)
        local counter = 0
        for nation, nationData in pairs(data) do
            local obj = Object.Instantiate(objRes)
            local spt = res.GetLuaScript(obj)
            obj.transform:SetParent(self.gridGroup)
            obj.transform.localScale = Vector3.one
            spt:InitView(nation, nationData, self.onNationSelect)
            if nationData.isShow == 1 then
                counter = counter + 1
            end
        end
        self.selfRectTransform.sizeDelta = Vector2(self.selfRectTransform.sizeDelta.x, 40 + counter * 60)
    end
end

return NationBoxView

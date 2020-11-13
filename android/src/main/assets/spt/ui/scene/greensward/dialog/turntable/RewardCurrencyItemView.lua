local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")

local RewardCurrencyItemView = class(unity.base)

local moralePos = Vector3(0, 7, 0)
local fightPos = Vector3(9, 7, 0)

function RewardCurrencyItemView:ctor()
--------Start_Auto_Generate--------
    self.currencyImg = self.___ex.currencyImg
    self.numPlusTxt = self.___ex.numPlusTxt
    self.numMinusTxt = self.___ex.numMinusTxt
--------End_Auto_Generate----------
end
function RewardCurrencyItemView:InitView(contents, isPlus)
    local num = contents.morale or contents.fight
    local sign = "-"
    local currencyPath
    if isPlus then
        self.numPlusTxt.text = "+" .. num
    else
        self.numMinusTxt.text = "-" .. num
    end
    if contents.morale then
        currencyPath = CurrencyImagePath.morale
        self.currencyImg.transform.localPosition = moralePos
    elseif contents.fight then
        currencyPath = CurrencyImagePath.fight
        self.currencyImg.transform.localPosition = fightPos
    end
    self.currencyImg.overrideSprite = res.LoadRes(currencyPath)
    GameObjectHelper.FastSetActive(self.numPlusTxt.gameObject, isPlus)
    GameObjectHelper.FastSetActive(self.numMinusTxt.gameObject, not isPlus)
end

return RewardCurrencyItemView

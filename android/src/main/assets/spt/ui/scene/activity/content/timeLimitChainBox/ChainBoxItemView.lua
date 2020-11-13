local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ChainBoxState = require("ui.scene.activity.content.timeLimitChainBox.ChainBoxState")
local ChainBoxItemView = class(unity.base)

function ChainBoxItemView:ctor()
--------Start_Auto_Generate--------
    self.chooseGo = self.___ex.chooseGo
    self.boxTrans = self.___ex.boxTrans
    self.boxNormalGo = self.___ex.boxNormalGo
    self.numberNormalTxt = self.___ex.numberNormalTxt
    self.boxSpecialGo = self.___ex.boxSpecialGo
    self.numberSpecialTxt = self.___ex.numberSpecialTxt
    self.maskGo = self.___ex.maskGo
    self.sellGo = self.___ex.sellGo
    self.nextGo = self.___ex.nextGo
    self.lockGo = self.___ex.lockGo
    self.boxBtn = self.___ex.boxBtn
--------End_Auto_Generate----------
end

function ChainBoxItemView:InitView(boxData)
    local state = boxData.clientBoxState
    local isLast = boxData.isLast or false
    GameObjectHelper.FastSetActive(self.maskGo, state ~= ChainBoxState.Buy)
    GameObjectHelper.FastSetActive(self.chooseGo, state == ChainBoxState.Buy)
    GameObjectHelper.FastSetActive(self.sellGo, state == ChainBoxState.Sell)
    GameObjectHelper.FastSetActive(self.lockGo, state == ChainBoxState.Disable)
    GameObjectHelper.FastSetActive(self.nextGo, not isLast)
    GameObjectHelper.FastSetActive(self.boxNormalGo, not isLast)
    GameObjectHelper.FastSetActive(self.boxSpecialGo, isLast)
    if state == ChainBoxState.Buy then
        self.boxTrans.localScale = Vector3(1.3, 1.3, 1.3)
    else
        self.boxTrans.localScale = Vector3.one
    end
    local indexStr = tostring(boxData.index)
    self.numberNormalTxt.text = indexStr
    self.numberSpecialTxt.text = indexStr
end

return ChainBoxItemView

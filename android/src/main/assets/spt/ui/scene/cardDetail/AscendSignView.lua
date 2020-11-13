local GameObjectHelper = require("ui.common.GameObjectHelper")
local AscendSignView = class(unity.base)

function AscendSignView:ctor()
    self.iconShadow = self.___ex.iconShadow
    self.ascendText = self.___ex.ascendText
    self.ascendNeedCondition = self.___ex.ascendNeedCondition
    self.completeSign = self.___ex.completeSign
    self.desc = self.___ex.desc
    self.animator = self.___ex.animator
end

function AscendSignView:InitView(index, cardModel)
    local ascend = cardModel:GetAscend()
    local upgrade = cardModel:GetUpgrade()
    local needUpgrade = cardModel:GetNeedUpgradeLevelByAscendTimes(index)
    local isOpen = tobool(upgrade >= needUpgrade)
    local isComplete = tobool(ascend >= index)
    self.ascendText.text = lang.trans("ascend_need_upgrade", needUpgrade)
    GameObjectHelper.FastSetActive(self.iconShadow.gameObject, not isOpen)
    GameObjectHelper.FastSetActive(self.ascendNeedCondition.gameObject, not isOpen)
    GameObjectHelper.FastSetActive(self.completeSign.gameObject, isComplete)

    self.desc.text = lang.trans("ascend_num", index)
    local maxAscendNum = cardModel:GetMaxAscendNum()
    GameObjectHelper.FastSetActive(self.gameObject, not tobool(index > maxAscendNum))
end

function AscendSignView:ShowAscendEffect(newCardModel)
    self.animator:Play("AscendSignOn", 0, 0)
end

return AscendSignView

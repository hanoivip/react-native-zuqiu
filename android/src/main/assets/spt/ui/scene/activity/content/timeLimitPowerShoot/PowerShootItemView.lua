local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local PowerShootItemView = class(unity.base)

function PowerShootItemView:ctor()
--------Start_Auto_Generate--------
    self.closeGo = self.___ex.closeGo
    self.openGo = self.___ex.openGo
    self.shootBtn = self.___ex.shootBtn
    self.rewardTrans = self.___ex.rewardTrans
    self.uIEffectGo = self.___ex.uIEffectGo
--------End_Auto_Generate----------
    self.animator = self.___ex.animator
end

function PowerShootItemView:start()
    self.shootBtn:regOnButtonClick(function()
        self:OnShootBtnClick()
    end)
end

function PowerShootItemView:InitView(boxData)
    self.state = tobool(boxData.content)
    self.pos = boxData.pos
    local content = boxData.content and boxData.content.contents
    self:ChangeButtonSate(self.state)
    if self.state then
        self:RefreshItemContent(content)
        self.animator:Play("PowerShootItemOpenEnd", 0, 0)
    else
        self.animator:Play("PowerShootItemCloseEnd", 0, 0)
    end
end

function PowerShootItemView:RefreshItemContent(content)
    res.ClearChildren(self.rewardTrans)
    local rewardParams = {
        parentObj = self.rewardTrans,
        rewardData = content,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        itemParams = {
            nameColor = Color.white,
            nameShadowColor = Color.black,
        },
    }
    RewardDataCtrl.new(rewardParams)
end

function PowerShootItemView:OnShootBtnClick()
    if self.onShoot then
        self.onShoot()
    end
    if not self.state then
        self:ChangeSate(true, false)
    end
end

function PowerShootItemView:ChangeSate(state, isRotate)
    self.state = state
    if isRotate then
        self:ChangeButtonSate()
        self:PlayAnimByState()
    end
end

function PowerShootItemView:ShowEffect()
    GameObjectHelper.FastSetActive(self.uIEffectGo, true)
end

function PowerShootItemView:PlayAnimByState()
    if self.state then
        self.animator:Play("PowerShootItemOpen", 0, 0)
    else
        self.animator:Play("PowerShootItemClose", 0, 0)
    end
end

function PowerShootItemView:onEndAnim()
    self:ChangeButtonSate()
    self:PlayAnimByState()
end

function PowerShootItemView:ChangeButtonSate(state)
    if state then
        self.state = state
    end
    GameObjectHelper.FastSetActive(self.uIEffectGo, false)
    GameObjectHelper.FastSetActive(self.closeGo, not self.state)
    GameObjectHelper.FastSetActive(self.openGo, self.state)
    GameObjectHelper.FastSetActive(self.rewardTrans.gameObject, self.state)
end

return PowerShootItemView

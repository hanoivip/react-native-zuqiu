local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local ItemFilterView = class(unity.base)

function ItemFilterView:ctor()
    self.btnClose = self.___ex.btnClose
    self.btnConfirm = self.___ex.btnConfirm
    self.btnReset = self.___ex.btnReset
    self.kindButtonArea = self.___ex.kindButtonArea
end

function ItemFilterView:start()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirmClick()
    end)
    self.btnReset:regOnButtonClick(function()
        self:OnBtnResetClick()
    end)
    self:PlayInAnimator()
end

function ItemFilterView:InitView(kindMap)
    local kindButtonPrefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/ItemList/ItemKindButton.prefab")
    for index, kindData in ipairs(kindMap) do
        local kindButton = Object.Instantiate(kindButtonPrefab)
        kindButton.transform:SetParent(self.kindButtonArea, false)
        local spt = res.GetLuaScript(kindButton)
        kindData.script = spt
        spt:InitView(kindData.id, kindData.name, kindData.state)
    end
end

function ItemFilterView:OnBtnConfirmClick()
    if self.clickConfirm then
        self.clickConfirm()
        self:Close()
    end
end

function ItemFilterView:OnBtnResetClick()
    if self.clickReset then
        self.clickReset()
    end
end

function ItemFilterView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function ItemFilterView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function ItemFilterView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function ItemFilterView:Close()
    self:PlayOutAnimator()
end

return ItemFilterView

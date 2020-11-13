local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")

local CoachTalentUpdateView = class(unity.base, "CoachTalentUpdateView")

function CoachTalentUpdateView:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    self.txtTitleRef = self.___ex.txtTitleRef
    -- 货币
    self.objCurrency = self.___ex.objCurrency
    self.imgCurrency = self.___ex.imgCurrency
    self.txtCurrency = self.___ex.txtCurrency
    -- 面板
    self.boardView = self.___ex.boardView
end

function CoachTalentUpdateView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CoachTalentUpdateView:InitView(coachTalentUpdateModel)
    self.model = coachTalentUpdateModel
    self:InitCurrencyItem()
    self.boardView:InitView(self.model:GetData())
end

function CoachTalentUpdateView:RegBtnEvent()
end

function CoachTalentUpdateView:OnEnterScene()
    EventSystem.AddEvent("CoachTalentUpdateSkill", self, self.OnBtnUpdateClick)
end

function CoachTalentUpdateView:OnExitScene()
    EventSystem.RemoveEvent("CoachTalentUpdateSkill", self, self.OnBtnUpdateClick)
end

function CoachTalentUpdateView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

-- 更新消耗物品显示
function CoachTalentUpdateView:InitCurrencyItem()
    self.imgCurrency.overrideSprite = res.LoadRes(CurrencyImagePath.ctp)
    self.txtCurrency.text = string.formatNumWithUnit(self.model:GetCtp())
end

-- 升级
function CoachTalentUpdateView:OnBtnUpdateClick(itemData)
    if self.onBtnUpdateClick then
        self.onBtnUpdateClick(itemData)
    end
end

-- 解锁后更新面板
function CoachTalentUpdateView:UpdateAfterUnlock()
    self:UpdateAfterUpgrade()
end

-- 升级后更新面板
function CoachTalentUpdateView:UpdateAfterUpgrade()
    self:InitCurrencyItem()
    self.boardView:InitView(self.model:GetData())
    EventSystem.SendEvent("UpdateAfterUpgrade")
end

return CoachTalentUpdateView

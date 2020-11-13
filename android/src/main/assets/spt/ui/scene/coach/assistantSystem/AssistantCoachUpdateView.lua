local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")

local AssistantCoachUpdateView = class(unity.base, "AssistantCoachUpdateView")

function AssistantCoachUpdateView:ctor()
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
    self.rct = self.___ex.rct
end

function AssistantCoachUpdateView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function AssistantCoachUpdateView:InitView(assistantCoachUpdateModel)
    self.model = assistantCoachUpdateModel
    self.boardView.onBtnUpdateClick = function() self:OnBtnUpdateClick() end
    self.boardView:InitView(self.model:GetAssistantCoachModel(), self)
    self:InitCurrencyItem()
end

function AssistantCoachUpdateView:OnEnterScene()
end

function AssistantCoachUpdateView:OnExitScene()
end

function AssistantCoachUpdateView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

-- 更新消耗物品显示
function AssistantCoachUpdateView:InitCurrencyItem()
    self.imgCurrency.overrideSprite = res.LoadRes(CurrencyImagePath.ace)
    self.txtCurrency.text = string.formatNumWithUnit(self.model:GetCurrAce())
end

-- 升级
function AssistantCoachUpdateView:OnBtnUpdateClick(assistantCoachModel)
    if self.onBtnUpdateClick then
        self.onBtnUpdateClick(assistantCoachModel)
    end
end

-- 升级后更新面板
function AssistantCoachUpdateView:UpdateAfterUpgrade(data)
    self.boardView:InitView(self.model:GetAssistantCoachModel(), self)
    self.txtCurrency.text = string.formatNumWithUnit(self.model:GetCurrAce())
    EventSystem.SendEvent("AssistantCoach_UpdateAfterUpgrade", data)
end

-- 设置面板大小
function AssistantCoachUpdateView:SetBoardSize(y)
    self.rct.sizeDelta = Vector2(self.rct.sizeDelta.x, y)
end

return AssistantCoachUpdateView

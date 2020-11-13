local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GreenswardMoraleSupplyView = class(unity.base, "GreenswardMoraleSupplyView")

local skill_item_path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/CycleDetail/GreenswardCycleDetailSkillItem.prefab"

function GreenswardMoraleSupplyView:ctor()
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 关闭按钮
    self.btnClose = self.___ex.btnClose
    -- canvasGroup
    self.canvasGroup = self.___ex.canvasGroup
    -- 面板的Rect Transform
    self.rctBoard = self.___ex.rctBoard
    self.scroll = self.___ex.scroll
    -- 剩余次数
    self.txtLeft = self.___ex.txtLeft
    self.contentArea = self.___ex.contentArea
    -- 一键领取
    self.btnGetBatch = self.___ex.btnGetBatch
    -- 一键赠送
    self.btnSendBatch = self.___ex.btnSendBatch
end

function GreenswardMoraleSupplyView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function GreenswardMoraleSupplyView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.contentArea.gameObject, isShow)
end

function GreenswardMoraleSupplyView:InitView(greenswardMoraleSupplyModel)
    self.model = greenswardMoraleSupplyModel
    self.scroll:RegOnItemButtonClick("btnGet", function(itemData)
        self:OnBtnGet(itemData)
    end)
    self.scroll:RegOnItemButtonClick("btnSend", function(itemData)
        self:OnBtnSend(itemData)
    end)
end

function GreenswardMoraleSupplyView:RefreshView()
    if not self.model then return end

    self.scroll:InitView(self.model:GetFriendList(), self.model)
    self.txtLeft.text = lang.trans("greensward_morale_supply_left", self.model:GetLeftTimes(), self.model:GetLimitTimes())
end

function GreenswardMoraleSupplyView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    -- 一键领取
    self.btnGetBatch:regOnButtonClick(function()
        self:OnBtnGetBatch()
    end)
    -- 一键赠送
    self.btnSendBatch:regOnButtonClick(function()
        self:OnBtnSendBatch()
    end)
end

function GreenswardMoraleSupplyView:Close()
    local callback = function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

-- 领取单个好友士气
function GreenswardMoraleSupplyView:OnBtnGet(itemData)
    if self.onBtnGet ~= nil and type(self.onBtnGet) == "function" then
        self.onBtnGet(itemData)
    end
end

-- 赠送单个好友士气
function GreenswardMoraleSupplyView:OnBtnSend(itemData)
    if self.onBtnSend ~= nil and type(self.onBtnSend) == "function" then
        self.onBtnSend(itemData)
    end
end

-- 一键领取
function GreenswardMoraleSupplyView:OnBtnGetBatch()
    if self.onBtnGetBatch ~= nil and type(self.onBtnGetBatch) == "function" then
        self.onBtnGetBatch()
    end
end

-- 一键赠送
function GreenswardMoraleSupplyView:OnBtnSendBatch()
    if self.onBtnSendBatch ~= nil and type(self.onBtnSendBatch) == "function" then
        self.onBtnSendBatch()
    end
end

-- 一键领取后更新
function GreenswardMoraleSupplyView:UpdateAfterGetBatch()
    local pos = self.scroll:GetScrollNormalizedPosition()
    self:RefreshView()
    self.scroll:SetScrollNormalizedPosition(pos)
end

-- 一键赠送后更新
function GreenswardMoraleSupplyView:UpdateAfterSendBatch()
    local pos = self.scroll:GetScrollNormalizedPosition()
    self:RefreshView()
    self.scroll:SetScrollNormalizedPosition(pos)
end

return GreenswardMoraleSupplyView

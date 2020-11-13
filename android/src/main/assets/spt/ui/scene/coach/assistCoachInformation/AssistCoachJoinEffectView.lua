local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local LuaButton = require("ui.control.button.LuaButton")

local AssistCoachJoinEffectView = class(unity.base, "AssistCoachJoinEffectView")

local ANIM_STEP = {
    TOP = 1,
    BOTTOM = 2,
    OVER = 3
}

function AssistCoachJoinEffectView:ctor()
    AssistCoachJoinEffectView.super.ctor(self)
    self.canvasGroup = self.___ex.canvasGroup
    self.clickMask = self.___ex.clickMask
    -- 预期星级
    self.txtPreStar = self.___ex.txtPreStar
    -- 情报详情
    self.txtPreAttri = self.___ex.txtPreAttri
    self.objContent = self.___ex.objContent
    self.objTop = self.___ex.objTop
    self.objMiddle = self.___ex.objMiddle
    self.objBottom = self.___ex.objBottom
    -- 生效物品
    self.sptItems = self.___ex.sptItems
    -- 星级
    self.sptStars = self.___ex.sptStars
    -- 下方名字
    self.sptAttrs = self.___ex.sptAttrs

    -- top&middle&close动画控制
    self.animatorTop = self.___ex.animatorTop
    self.animatorBottom = self.___ex.animatorBottom
    self.animTop = self.___ex.animTop
    self.animBottom = self.___ex.animBottom

    -- 当前动画播放的进度
    self.animStep = nil
end

function AssistCoachJoinEffectView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self:RegBtnEvent()
end

function AssistCoachJoinEffectView:InitView(assistCoachJoinEffectModel)
    self.model = assistCoachJoinEffectModel
    GameObjectHelper.FastSetActive(self.objContent.gameObject, false)
    -- 设置动画事件
    self.animTop.onEndTopAnim = function() self:OnEndTopAnim() end
    self.animTop.onStartBottomAnim = function() self:OnStartBottomAnim() end
    self.animTop.onCloseDialog = function() self:Close() end
    self.animBottom.onEndBottomAnim = function() self:OnEndBottomAnim() end
end

function AssistCoachJoinEffectView:RefreshView()
    GameObjectHelper.FastSetActive(self.objContent.gameObject, true)
    GameObjectHelper.FastSetActive(self.objTop.gameObject, true)
    GameObjectHelper.FastSetActive(self.objMiddle.gameObject, true)
    GameObjectHelper.FastSetActive(self.objBottom.gameObject, false)

    local itemNum = self.model:GetCostItemNum()
    -- 设置物品显示成功或失败
    for i = 1, table.nums(self.sptItems) do
        if i > itemNum then break end
        self.sptItems[tostring(i)]:InitView(self.model:GetSuccessItemModel(i))
    end
    -- 预期星级
    self.txtPreStar.text = lang.transstr("assistant_coach_info_used_2") .. "："
    -- 情报详情
    self.txtPreAttri.text = lang.transstr("assistant_coach_info_used_4") .. "："
    self.sptStars:InitView(self.model:GetPreStar())
    -- 名称显示
    self.sptAttrs:InitView(self.model:GetSuccessItemModels())

    self.animStep = ANIM_STEP.TOP
    self.animatorTop:Play("Top")
    self.animatorTop:Update(0)
end

function AssistCoachJoinEffectView:OnEnterScene()
end

function AssistCoachJoinEffectView:OnExitScene()
end

function AssistCoachJoinEffectView:Close()
    if self.onCloseDialog ~= nil and type(self.onCloseDialog) == "function" then
        self.onCloseDialog()
    end
    if self.closeDialog ~= nil and type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function AssistCoachJoinEffectView:RegBtnEvent()
    self.clickMask:regOnButtonClick(function()
        self:OnClickScreen()
    end)
end

function AssistCoachJoinEffectView:OnClickScreen()
    if self.animStep == ANIM_STEP.TOP then
        self:OnEndTopAnim()
    elseif self.animStep == ANIM_STEP.BOTTOM then
        self:OnEndBottomAnim()
    elseif self.animStep == ANIM_STEP.OVER then
        self:OnPlayCloseAnim()
    end
end

-- 动画事件调用
function AssistCoachJoinEffectView:OnEndTopAnim()
    if self.animStep == ANIM_STEP.TOP then
        self.animStep = ANIM_STEP.BOTTOM
        self.animatorTop:SetBool("isStatic", true)
    end
end

-- 动画事件调用
function AssistCoachJoinEffectView:OnStartBottomAnim()
    if self.animStep == ANIM_STEP.BOTTOM then
        GameObjectHelper.FastSetActive(self.objBottom.gameObject, true)
        self.animatorBottom:Play("Bottom")
        self.animatorBottom:Update(0)
    end
end

-- 动画事件调用
function AssistCoachJoinEffectView:OnEndBottomAnim()
    if self.animStep == ANIM_STEP.BOTTOM then
        GameObjectHelper.FastSetActive(self.objBottom.gameObject, true)
        self.animStep = ANIM_STEP.OVER
        self.animatorBottom:SetBool("isStatic", true)
    end
end

-- 用户点击屏幕触发
function AssistCoachJoinEffectView:OnPlayCloseAnim()
    if self.animStep == ANIM_STEP.OVER then
        self.animatorTop:SetBool("isClose", true)
    end
end

return AssistCoachJoinEffectView

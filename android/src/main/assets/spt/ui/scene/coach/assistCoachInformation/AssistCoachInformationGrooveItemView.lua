local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistCoachInformationGrooveItemView = class(unity.base, "AssistCoachInformationGrooveItemView")

local COLOR_FULL = Color(72/255, 186/255, 23/255)

local COLOR_NOT_FULL = Color(45/255, 178/255, 1)

function AssistCoachInformationGrooveItemView:ctor()
    self.objHasInfo = self.___ex.objHasInfo
    self.objNotHasInfo = self.___ex.objNotHasInfo
    -- 生效概率
    self.txtProgressTitle = self.___ex.txtProgressTitle
    self.txtProgress = self.___ex.txtProgress
    self.txtPercent = self.___ex.txtPercent
    -- 星级
    self.sptStars = self.___ex.sptStars
    -- 情报名称
    self.txtName = self.___ex.txtName
    -- 特殊情报标识
    self.imgSpecial = self.___ex.imgSpecial
    -- 点击概率取消
    self.btnCancel = self.___ex.btnCancel
    -- 点击名字查看详细
    self.btnView = self.___ex.btnView

    -- 助理教练头像脚本
    self.portraitSpt = nil
end

function AssistCoachInformationGrooveItemView:start()
    self.btnCancel:regOnButtonClick(function()
        self:OnGrooveItemCancel()
    end)
    self.btnView:regOnButtonClick(function()
        self:OnGrooveItemView()
    end)
end

function AssistCoachInformationGrooveItemView:InitView(assistCoachInfoModel)
    self.aciModel = assistCoachInfoModel
    self:DisplayView(self.aciModel ~= nil)

    if self.aciModel ~= nil then
        self.sptStars:InitView(self.aciModel:GetAssistantInfoQuailty())
        self.txtName.text = tostring(self.aciModel:GetName())
        -- 生效概率
        local prob = tonumber(self.aciModel:GetComposeEfxProbability())
        -- 未满100%是蓝色
        if prob < 100 then
            self.txtProgressTitle.color = COLOR_NOT_FULL
            self.txtProgress.color = COLOR_NOT_FULL
            self.txtPercent.color = COLOR_NOT_FULL
        else
            self.txtProgressTitle.color = COLOR_FULL
            self.txtProgress.color = COLOR_FULL
            self.txtPercent.color = COLOR_FULL
        end
        self.txtProgress.text = tostring(prob)
        -- 是否是特殊情报表情
        GameObjectHelper.FastSetActive(self.imgSpecial.gameObject, self.aciModel:IsSuperInformation())
    end
end

function AssistCoachInformationGrooveItemView:DisplayView(hasInfo)
    GameObjectHelper.FastSetActive(self.objHasInfo.gameObject, hasInfo)
    GameObjectHelper.FastSetActive(self.objNotHasInfo.gameObject, not hasInfo)
end

function AssistCoachInformationGrooveItemView:IsAvailable()
    return tobool(self.aciModel == nil)
end

function AssistCoachInformationGrooveItemView:GetUsedAciId()
    if not self:IsAvailable() then
        return self.aciModel:GetId()
    else
        return nil
    end
end

function AssistCoachInformationGrooveItemView:OnGrooveItemCancel()
    if self.aciModel ~= nil and self.onGrooveItemCancel and type(self.onGrooveItemCancel) == "function" then
        self.onGrooveItemCancel(self.aciModel)
    end
end

function AssistCoachInformationGrooveItemView:OnGrooveItemView()
    if self.aciModel ~= nil then
        res.PushDialog("ui.controllers.coach.assistCoachInformation.AssistCoachInformationItemDetailCtrl", self.aciModel)
    end
end

return AssistCoachInformationGrooveItemView

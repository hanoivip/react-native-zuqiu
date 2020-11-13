local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")

local AssistantCoachUpdateCtrl = class(BaseCtrl, "AssistantCoachUpdateCtrl")

AssistantCoachUpdateCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantSystem/Prefabs/AssistantCoachUpdate.prefab"

AssistantCoachUpdateCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function AssistantCoachUpdateCtrl:ctor()
    AssistantCoachUpdateCtrl.super.ctor(self)
end

function AssistantCoachUpdateCtrl:Init()
    AssistantCoachUpdateCtrl.super.Init(self)
    self.view.onBtnUpdateClick = function() self:OnBtnUpdateClick() end
end

function AssistantCoachUpdateCtrl:Refresh(assistantCoachUpdateModel)
    AssistantCoachUpdateCtrl.super.Refresh(self)
    if not assistantCoachUpdateModel then
        local CoachTalentUpdateModel = require("ui.models.coach.assistantSystem.AssistantCoachUpdateModel")
        self.model = CoachTalentUpdateModel.new()
    else
        self.model = assistantCoachUpdateModel
    end
    self.view:InitView(self.model)
end

function AssistantCoachUpdateCtrl:GetStatusData()
    return self.model:GetStatusData()
end

function AssistantCoachUpdateCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function AssistantCoachUpdateCtrl:OnExitScene()
    self.view:OnExitScene()
end

-- 点击升级按钮
function AssistantCoachUpdateCtrl:OnBtnUpdateClick()
    local hadAceNum = self.model:GetCurrAce()
    local needAceNum = self.model:GetNeedAceNum()
    if hadAceNum < needAceNum then
        DialogManager.ShowToast(lang.transstr("lack_item_tips", lang.transstr(CurrencyNameMap.ace))) -- 助理教练经验书不足
        return
    end

    local acModel = self.model:GetAssistantCoachModel()
    local isMax = acModel:IsMax()
    local isCoachMax = acModel:IsCoachMax()
    if isCoachMax and isMax then
        DialogManager.ShowToastByLang("hero_hall_upgrade_max_level") -- 已满级
        return
    elseif isCoachMax and not isMax then
        DialogManager.ShowToastByLang("coach_baseInfo_coach_max_hint") -- 请升级教练解锁更高等级
        return
    elseif not isCoachMax and isMax then
        DialogManager.ShowToastByLang("hero_hall_upgrade_max_level")
        return
    end

    -- 点击确定回调
    local confirmCallback = function()
        self.view:coroutine(function()
            local acid = self.model:GetAcid()
            local respone = req.assistantCoachUpdate(acid)
            if api.success(respone) then
                local data = respone.val
                if type(data) == "table" and next(data) then
                    self.model:UpdateAfterUpgrade(data)
                    -- 更新界面
                    self.view:UpdateAfterUpgrade(data)
                    -- 恭喜升级成功
                    res.PushDialog("ui.controllers.coach.assistantSystem.AssistantCoachUpdateSuccessCtrl", self.model:GetAssistantCoachModel())
                end
            end
        end)
    end

    local title = lang.transstr("coach_team") .. lang.transstr("levelUp") -- 助理教练升级
    -- 是否使用助理教练经验书XX升级[name]
    local msg = lang.transstr("coach_baseInfo_update_tip", lang.transstr(CurrencyNameMap.ace) .. "X" .. needAceNum, self.model:GetName())
    DialogManager.ShowConfirmPop(title, msg, confirmCallback)
end

return AssistantCoachUpdateCtrl

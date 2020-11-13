local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local CoachBaseInfoDetailView = class(unity.base, "CoachBaseInfoDetailView")

-- 教练头像prefab
local CoachPortraitPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/CoachPortrait.prefab"

function CoachBaseInfoDetailView:ctor()
    self.rctPortrait = self.___ex.rctPortrait
    self.btnConfirm = self.___ex.btnConfirm
    self.txtDesc = self.___ex.txtDesc
end

function CoachBaseInfoDetailView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CoachBaseInfoDetailView:InitView(coachBaseInfoModel)
    self.model = coachBaseInfoModel
    -- 教练头像
    local portraitObj, portraitSpt = res.Instantiate(CoachPortraitPath)
    if portraitObj ~= nil and portraitSpt ~= nil then
        portraitObj.transform:SetParent(self.rctPortrait.transform, false)
        portraitObj.transform.localScale = Vector3.one
        portraitObj.transform.localPosition = Vector3.zero
        portraitSpt:InitView(self.model:GetCredentialLevel(), self.model:GetStarLevel(), true)
    end
    local descs = self.model:GetCoachDesc()
    local desc = ""
    for k, v in pairs(descs) do
        desc = desc .. v .. "\n"
    end
    self.txtDesc.text = desc
end

function CoachBaseInfoDetailView:RegBtnEvent()
    self.btnConfirm:regOnButtonClick(function()
        self:Close()
    end)
end

function CoachBaseInfoDetailView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

return CoachBaseInfoDetailView

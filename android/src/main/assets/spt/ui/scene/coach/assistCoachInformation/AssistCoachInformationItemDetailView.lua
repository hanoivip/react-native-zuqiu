local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")

local AssistCoachInformationItemDetailView = class(unity.base, "AssistCoachInformationItemDetailView")

function AssistCoachInformationItemDetailView:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    self.txtTitleRef = self.___ex.txtTitleRef
    self.rctContainer = self.___ex.rctContainer
    self.txtName = self.___ex.txtName
    self.txtDesc = self.___ex.txtDesc
end

function AssistCoachInformationItemDetailView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function AssistCoachInformationItemDetailView:InitView(aciModel)
    self.aciModel = aciModel
    local title = lang.transstr("information") .. lang.transstr("detail")
    self.txtTitle.text = title
    self.txtTitleRef.text = title

    local contents = {
        cti = {
            {
                id = tostring(self.aciModel:GetId()),
                num = 1,
            }
        }
    }

    local rewardParams = {
        parentObj = self.rctContainer,
        rewardData = contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = false,
        isShowCardReward = false,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
    self.txtName.text = self.aciModel:GetName()
    self.txtDesc.text = self.aciModel:GetDesc()
end

function AssistCoachInformationItemDetailView:OnEnterScene()
end

function AssistCoachInformationItemDetailView:OnExitScene()
end

function AssistCoachInformationItemDetailView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

return AssistCoachInformationItemDetailView

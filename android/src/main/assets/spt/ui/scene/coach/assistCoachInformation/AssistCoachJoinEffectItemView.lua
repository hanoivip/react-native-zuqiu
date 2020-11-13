local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistCoachJoinEffectItemView = class(unity.base, "AssistCoachJoinEffectItemView")


function AssistCoachJoinEffectItemView:ctor()
    self.imgSuccess = self.___ex.imgSuccess
    self.imgFail = self.___ex.imgFail
end

function AssistCoachJoinEffectItemView:InitView(assistCoachInfoModel)
    self.aciModel = assistCoachInfoModel
    if self.aciModel then
        local quality = self.aciModel:GetAssistantInfoQuailty()
        local superInfomation = self.aciModel:GetSuperInformation()
        self.imgSuccess.overrideSprite = AssetFinder.GetAssistantCoachInformationIcon(superInfomation, quality)
        GameObjectHelper.FastSetActive(self.imgSuccess.gameObject, self.aciModel.isSuccess)
        GameObjectHelper.FastSetActive(self.imgFail.gameObject, not self.aciModel.isSuccess)
    else
        GameObjectHelper.FastSetActive(self.imgSuccess.gameObject, false)
        GameObjectHelper.FastSetActive(self.imgFail.gameObject, true)
    end
end

return AssistCoachJoinEffectItemView

local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CardTrainingBaseRuleView = class(unity.base)

function CardTrainingBaseRuleView:ctor()
    self.menuButtonGroup = self.___ex.menuButtonGroup
    self.contentAear = self.___ex.contentAear
    self.closeBtn = self.___ex.closeBtn
    self.trainContent = self.___ex.trainContent
    self.trainVertical = self.___ex.trainVertical

    DialogAnimation.Appear(self.transform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function CardTrainingBaseRuleView:InitView(eventId, model)
    self.eventId = eventId
    self.model = model
end

function CardTrainingBaseRuleView:InitMenuItem(spt, value, index)
    spt.___ex.upText.text = lang.transstr(value.text)
    spt.___ex.downText.text = spt.___ex.upText.text
end

function CardTrainingBaseRuleView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end


function CardTrainingBaseRuleView:OnInitList(key, itemDatas)
    if key == "train" then 
        self:OnInitTrain(key, itemDatas)
    end 
end

local ItemPath = {
    ["train"] = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/CardTrainingBaseItemRuleBoard.prefab"
}
function CardTrainingBaseRuleView:OnInitTrain(key, itemDatas)
    for k, v in pairs(itemDatas) do
        local obj, spt = res.Instantiate(ItemPath[key])
        obj.transform:SetParent(self.trainContent.transform, false)
        spt:InitView(v)
    end

    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        self.trainVertical.enabled = false
        unity.waitForNextEndOfFrame()
        self.trainVertical.enabled = true
    end)
end

return CardTrainingBaseRuleView

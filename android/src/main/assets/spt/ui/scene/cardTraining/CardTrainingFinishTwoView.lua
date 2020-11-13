local CardTrainingConstant = require("ui.scene.cardTraining.CardTrainingConstant")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")

local CardTrainingFinishTwoView = class(unity.base)

function CardTrainingFinishTwoView:ctor()
    self.skillAreaRect = self.___ex.skillAreaRect
    self.tipTxt = self.___ex.tipTxt
    self.toggleGroup = self.___ex.toggleGroup
    self.skillPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/Finish2Item.prefab"
end

function CardTrainingFinishTwoView:start()
end

function CardTrainingFinishTwoView:InitView(cardTrainingMainModel)
    self.cardTrainingMainModel = cardTrainingMainModel or self.cardTrainingMainModel
    self.tipTxt.text = lang.trans("card_training_finish", self.cardTrainingMainModel:GetName())
    local skillAttributes = self.cardTrainingMainModel:GetSkillAttributeArray()
    local skillOption = self.cardTrainingMainModel:GetLvlImproveOfSkillSelectedOption()
    self:InitSkillItem(skillAttributes, skillOption)
end

function CardTrainingFinishTwoView:InitSkillItem(skillList, skillOption)
    res.ClearChildren(self.skillAreaRect)
    for k, v in pairs(skillList) do
        local obj, spt = res.Instantiate(self.skillPath)
        obj.transform:SetParent(self.skillAreaRect, false)
        spt:InitView(v, self.toggleGroup, skillOption)
        spt.onSkillChanged = function ()
            self:OnSkillChanged(v.option)
        end
    end
end

function CardTrainingFinishTwoView:OnSkillChanged(option)
    local pcid = self.cardTrainingMainModel:GetPcid()
    local lvl = self.cardTrainingMainModel:GetCurrLevelSelected()
    self:coroutine(function ()
        local response = req.changeEffect(pcid, lvl, CardTrainingConstant.MaxSubId, option)
        if api.success(response) then
            local data = response.val
            assert(data.card, "server need return card info")
            PlayerCardsMapModel.new():ResetCardData(pcid, data.card)
            EventSystem.SendEvent("CardTraining_RefreshMainView")
        end
    end)
end

return CardTrainingFinishTwoView

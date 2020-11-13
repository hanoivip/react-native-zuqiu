local AssetFinder = require("ui.common.AssetFinder")
local CardTrainingConstant = require("ui.scene.cardTraining.CardTrainingConstant")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")

local CardTrainingFinishOneView = class(unity.base)

function CardTrainingFinishOneView:ctor()
    self.skillAreaRect = self.___ex.skillAreaRect
    self.tipTxt = self.___ex.tipTxt
    self.toggleGroup = self.___ex.toggleGroup

    self.skillPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/SkillItem.prefab"
end

function CardTrainingFinishOneView:start()
end

function CardTrainingFinishOneView:InitView(cardTrainingMainModel)
    self.cardTrainingMainModel = cardTrainingMainModel or self.cardTrainingMainModel
    self.tipTxt.text = lang.trans("card_training_finish", self.cardTrainingMainModel:GetName())
    local skillList = self.cardTrainingMainModel:GetSkillArray()
    local maxLvlRewardSkill = self.cardTrainingMainModel:GetMaxSubLevelRewardExSkills()

    self:InitSkillItem(skillList, maxLvlRewardSkill)
end

function CardTrainingFinishOneView:InitSkillItem(skillList, skill)
    res.ClearChildren(self.skillAreaRect)
    for k, v in pairs(skillList) do
        local obj, spt = res.Instantiate(self.skillPath)
        obj.transform:SetParent(self.skillAreaRect, false)
        spt:InitSkillView(v, self.toggleGroup, skill)
        spt.onSkillChanged = function ()
            self:OnSkillChanged(tonumber(k) - 1)
        end
    end
end

function CardTrainingFinishOneView:OnSkillChanged(option)
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

return CardTrainingFinishOneView

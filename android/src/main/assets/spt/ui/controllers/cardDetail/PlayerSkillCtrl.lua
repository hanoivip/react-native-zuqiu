local PlayerSkillCtrl = class()

local SkillDetailCtrl = require("ui.controllers.skill.SkillDetailCtrl")

function PlayerSkillCtrl:ctor(cardDetailModel, mountPoint)
    assert(cardDetailModel and mountPoint)
    self.cardDetailModel = cardDetailModel

    local viewObject, viewSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/SkillGroupJp.prefab")
    viewObject.transform:SetParent(mountPoint.transform, false)
    self.skillView = viewSpt

    self:InitView()

    self.skillView.clickSkill = function(slot, sid)
        local skillItemModel = self.cardDetailModel:GetSkillModel(slot)
        self.skillDetailCtrl = SkillDetailCtrl.new(slot, sid, self.cardDetailModel:IsOperable())
        self.skillDetailCtrl:InitView(self.cardDetailModel:GetCardModel())
    end
end

function PlayerSkillCtrl:InitView(cardDetailModel)
    if cardDetailModel then
        self.cardDetailModel = cardDetailModel
    end

    local skillsList = self.cardDetailModel:GetSkillsList()
    local skillsMap = self.cardDetailModel:GetSkillsMap()
    self.skillView.gameObject:SetActive(true)
    self.skillView:InitView(skillsList, skillsMap, self.cardDetailModel)

    return true
end

function PlayerSkillCtrl:HideView()
    self.skillView.gameObject:SetActive(false)
end

return PlayerSkillCtrl

local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local CardSkillView = class(LuaButton)

function CardSkillView:ctor()
    CardSkillView.super.ctor(self)
    self.skillArea = self.___ex.skillArea
    self.skillAdvance = self.___ex.skillAdvance
    self.animator = self.___ex.animator
    self.skillItemView = nil
end

function CardSkillView:start()
    self:regOnButtonClick(function()
        self:OnBtnSkill(self.slot)
    end)
end

function CardSkillView:OnBtnSkill(slot)
    if self.clickSkill then 
        self.clickSkill(slot)
    end
end

function CardSkillView:SetDefaultSkill(isDefault)
    GameObjectHelper.FastSetActive(self.skillArea.gameObject, not isDefault)
end

function CardSkillView:InitView(skillItemModel, cardDetailModel)
    if skillItemModel then 
        self.slot = skillItemModel:GetSlot()
        if not self.skillItemView then
            local viewObj, viewSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/SkillItem.prefab")
            viewObj.transform:SetParent(self.skillArea, false)
            self.skillItemView = viewSpt
        end
        self.skillItemView:InitView(skillItemModel, cardDetailModel)
        self:SetDefaultSkill(false)
    else
        self:SetDefaultSkill(true)
    end
end

function CardSkillView:ShowAdvanceEffect()
    self.animator.enabled = true
    GameObjectHelper.FastSetActive(self.skillAdvance, true)
    GameObjectHelper.FastSetActive(self.gameObject, false)
    GameObjectHelper.FastSetActive(self.gameObject, true)
end

function CardSkillView:DisableAdvanceEffect()
    self.animator.enabled = false
    GameObjectHelper.FastSetActive(self.skillAdvance, false)
end

return CardSkillView

local AssetFinder = require("ui.common.AssetFinder")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local ExSkillDetailView = class(unity.base)

function ExSkillDetailView:ctor()
    self.skillIcon = self.___ex.skillIcon
    self.normalName = self.___ex.normalName
    self.skillDesc = self.___ex.skillDesc
    self.currentSkillInfo = self.___ex.currentSkillInfo
    self.currentSkillLevel = self.___ex.currentSkillLevel
    self.nextSkillInfo = self.___ex.nextSkillInfo
    self.nextSkillLevel = self.___ex.nextSkillLevel

    self.close = self.___ex.close
end

function ExSkillDetailView:start()
    self.close:regOnButtonClick(function()
        self:Close()
    end)
	DialogAnimation.Appear(self.transform)
end

function ExSkillDetailView:Close()
	DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function ExSkillDetailView:InitView(exSkillDetailModel)
    self.exSkillDetailModel = exSkillDetailModel
    self.skillIcon.overrideSprite = AssetFinder.GetSkillIcon(exSkillDetailModel:GetIconIndex())
    self.skillDesc.text = exSkillDetailModel:GetDesc()
    local name = exSkillDetailModel:GetName()
    local skillLevel = exSkillDetailModel:GetLevel()
    local lvl = " Lv." .. tostring(skillLevel)
    self.normalName.text = name .. lvl
    self.currentSkillLevel.text = exSkillDetailModel:GetLevelTitle()
    self.currentSkillInfo.text = exSkillDetailModel:GetDescByLevel()
    self.nextSkillLevel.text = exSkillDetailModel:GetNextLevelTitle()
    self.nextSkillInfo.text = exSkillDetailModel:GetDescByNextLevel()

end

return ExSkillDetailView
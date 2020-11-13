local TechnologySettingConfig = require("ui.scene.court.technologyHall.TechnologySettingConfig")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TechnologyDisplayView = class(unity.base)

function TechnologyDisplayView:ctor()
    self.title = self.___ex.title
	self.content = self.___ex.content
    self.btnClose = self.___ex.btnClose
end

function TechnologyDisplayView:InitView(courtBuildModel, courtTechnologyDetailModel, types)
    local titleStr = courtTechnologyDetailModel:GetTechnologyTitle()
    self.title.text = lang.trans(titleStr)

    self.courtBuildModel = courtBuildModel
	self.courtTechnologyDetailModel = courtTechnologyDetailModel

	local path = courtTechnologyDetailModel:GetBarResPath()
	for i, v in ipairs(types) do
		local obj, spt = res.Instantiate(path)
		obj.transform:SetParent(self.content, false)
		spt:InitView(v.TypeName, courtBuildModel)
	end
end

function TechnologyDisplayView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function TechnologyDisplayView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        self:ClickEvent()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function TechnologyDisplayView:ClickEvent()
    if self.clickEvent then 
        self.clickEvent()
    end
end

return TechnologyDisplayView
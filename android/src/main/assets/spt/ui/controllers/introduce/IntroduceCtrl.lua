local NoticeLabelCtrl = require("ui.controllers.login.NoticeLabelCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local IntroduceCtrl = class(BaseCtrl, "IntroduceCtrl")

IntroduceCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Introduce/Introduce.prefab"

function IntroduceCtrl:Init()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PopScene()
        end)
    end)
end

function IntroduceCtrl:Refresh(data, selectLabelIndex)
	selectLabelIndex = selectLabelIndex or 1
    self.view:InitView(data)
	self.noticeLabelCtrl = NoticeLabelCtrl.new(self.view.labelScroll, self, data)
	self.noticeLabelCtrl:InitView(selectLabelIndex)
end

function IntroduceCtrl:RefreshContent(selectIndex)
    self.view:SwitchPanel(selectIndex)
end

return IntroduceCtrl

local QuestPlotManager = require("ui.controllers.quest.questPlot.QuestPlotManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local QuestPlotView = class(unity.base)

function QuestPlotView:ctor()
    self.btnContinue = self.___ex.btnContinue
    self.txtDialog = self.___ex.txtDialog
end

function QuestPlotView:start()
    if self.btnContinue then
        self.btnContinue:regOnButtonClick(function()
            self:OnContinue()
        end)
    end
end

function QuestPlotView:InitView(questPlotModule, completedCallBack)
    self.questPlotModule = questPlotModule
    self.completedCallBack = completedCallBack
    local playerInfoModel = PlayerInfoModel.new()
    self.txtDialog.text = lang.trans(self.questPlotModule:GetText(), playerInfoModel:GetName())
end

function QuestPlotView:OnContinue()
    QuestPlotManager.Show(self.questPlotModule, self.completedCallBack)
end

return QuestPlotView
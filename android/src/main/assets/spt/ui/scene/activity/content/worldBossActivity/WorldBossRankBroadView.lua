local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local WorldBossRankBroadView = class(unity.base)

function WorldBossRankBroadView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.rankTitleName = self.___ex.rankTitleName
    self.rankHeadName = self.___ex.rankHeadName
    self.rankHeadVlaue = self.___ex.rankHeadVlaue
    self.helpBtn = self.___ex.helpBtn
    self.scrollView = self.___ex.scrollView
end

function WorldBossRankBroadView:start()
    self.helpBtn:regOnButtonClick(function()
        self:OnHelpBtnClick()
    end)
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform, nil)
end

function WorldBossRankBroadView:OnHelpBtnClick()
    if self.onHelpClick then
        self:onHelpClick()
    end
end

function WorldBossRankBroadView:InitView(rankModel)
    self.rankTitleName.text = rankModel:GetIsSelf() and lang.trans("worldBossActivity_single_rank_title") or lang.trans("worldBossActivity_world_rank_title")
    self.rankHeadName.text = (rankModel:GetIsSelf() and lang.transstr("worldBossActivity_single_rank") or lang.transstr("worldBossActivity_world_rank")) .. "：" 
    self.rankHeadVlaue.text = rankModel:GetRankNum() == 0 and lang.trans("train_rankOut") or tostring(rankModel:GetRankNum())
end

function WorldBossRankBroadView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return WorldBossRankBroadView
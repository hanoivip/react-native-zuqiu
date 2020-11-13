local AssetFinder = require("ui.common.AssetFinder")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local Timer = require("ui.common.Timer")

local TransportJournalMatchRecordItemView = class(unity.base)

function TransportJournalMatchRecordItemView:ctor()
    self.deleteBtn = self.___ex.deleteBtn
    self.detailBtn = self.___ex.detailBtn
    self.logoImg = self.___ex.logoImg
    self.nameTxt = self.___ex.nameTxt
    self.serverTxt = self.___ex.serverTxt
    self.powerTxt = self.___ex.powerTxt
end

function TransportJournalMatchRecordItemView:start()
    self.detailBtn:regOnButtonClick(function ()
        if self.onDetailBtnClick then
            self.onDetailBtnClick()
        end
    end)
    self.deleteBtn:regOnButtonClick(function ()
        if self.onDeleteBtnClick then
            self.onDeleteBtnClick()
        end
    end)
end

function TransportJournalMatchRecordItemView:InitView(data)
    TeamLogoCtrl.BuildTeamLogo(self.logoImg, data.logo)
    self.nameTxt.text = data.name
    self.powerTxt.text = tostring(data.power)
    self.serverTxt.text = data.serverName
end

function TransportJournalMatchRecordItemView:onDestroy()

end

return TransportJournalMatchRecordItemView
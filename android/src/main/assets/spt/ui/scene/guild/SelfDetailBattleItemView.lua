local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local MEMBERTYPE = require("ui.controllers.guild.MEMBERTYPE")
local SelfDetailBattleItemView = class(unity.base)

function SelfDetailBattleItemView:ctor()
    self.nameTxt = self.___ex.nameTxt
    self.lvlTxt = self.___ex.lvlTxt
    self.powerTxt = self.___ex.powerTxt
    self.stateTxt = self.___ex.stateTxt
    self.iconImg = self.___ex.iconImg
    self.detailBtn = self.___ex.detailBtn
end

function SelfDetailBattleItemView:Init(data)
    self.nameTxt.text = data.name
    -- authority
    self.lvlTxt.text = "Lv" .. tostring(data.lvl) .. "(" .. MEMBERTYPE[data.authority] .. ")"
    self.powerTxt.text = tostring(data.power)
    if data.isSeized then
        self.stateTxt.text = lang.trans("guildwar_occupy")
    else
        self.stateTxt.text = lang.trans("guildwar_warCnt", tostring(data.remainCount))
    end
    TeamLogoCtrl.BuildTeamLogo(self.iconImg, data.logo)

    self.detailBtn:regOnButtonClick(function ()
        if type(self.onDetailBtnClick) == "function" then
            self.onDetailBtnClick()
        end
    end)
end

return SelfDetailBattleItemView
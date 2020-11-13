local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local MEMBERTYPE = require("ui.controllers.guild.MEMBERTYPE")
local MistSelfDetailBattleItemView = class(unity.base)

function MistSelfDetailBattleItemView:ctor()
    self.nameTxt = self.___ex.nameTxt
    self.lvlTxt = self.___ex.lvlTxt
    self.powerTxt = self.___ex.powerTxt
    self.stateTxt = self.___ex.stateTxt
    self.iconImg = self.___ex.iconImg
    self.detailBtn = self.___ex.detailBtn
    self.damageTxt = self.___ex.damageTxt
end

function MistSelfDetailBattleItemView:Init(data)
    self.nameTxt.text = data.name
    -- authority
    self.lvlTxt.text = "Lv" .. tostring(data.lvl) .. "(" .. MEMBERTYPE[data.authority] .. ")"
    self.powerTxt.text = tostring(data.power)
    self.stateTxt.text = lang.trans("guildwar_warCnt", data.remainCount)
    self.damageTxt.text = lang.trans("guild_mist_damage", data.atkDamage or 0)
    TeamLogoCtrl.BuildTeamLogo(self.iconImg, data.logo)

    self.detailBtn:regOnButtonClick(function ()
        if type(self.onDetailBtnClick) == "function" then
            self.onDetailBtnClick()
        end
    end)
end

return MistSelfDetailBattleItemView
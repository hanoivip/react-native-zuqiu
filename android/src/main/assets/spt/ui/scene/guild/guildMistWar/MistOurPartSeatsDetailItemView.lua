local GameObjectHelper = require("ui.common.GameObjectHelper")
local MistOurPartSeatsDetailItemView = class(unity.base)

function MistOurPartSeatsDetailItemView:ctor()
    self.contentTxt = self.___ex.contentTxt
    self.videoBtn = self.___ex.videoBtn
end

function MistOurPartSeatsDetailItemView:Init(data, isAttackPage)
    local time = string.convertSecondToHourAndMinute(data.c_t)
    local timeString = tostring(time.hour) .. ":" .. tostring(time.minute)
    GameObjectHelper.FastSetActive(self.videoBtn.gameObject, tonumber(data.genre) == 1)
    if isAttackPage then
        if tonumber(data.genre) == 1 then
            if data.atkScore > data.defScore then
                self.contentTxt.text = lang.trans("mist_detail_win_1", timeString, data.atkName, data.defName, data.atkScore, data.defScore, data.atkDamage)
            else
                self.contentTxt.text = lang.trans("mist_detail_failure_1", timeString, data.atkName, data.defName, data.atkScore, data.defScore, data.atkDamage)
            end
        elseif tonumber(data.genre) ==  2 then
            self.contentTxt.text = lang.trans("guild_detail_change", timeString, data.defName)
        elseif tonumber(data.genre) == 3 then
            self.contentTxt.text = lang.trans("guild_detail_change_1", timeString, data.defName)
        elseif tonumber(data.genre) == 4 then
            self.contentTxt.text = lang.trans("guild_mist_resize", timeString, data.atkName, data.atkDamage)
        end
    else
        if tonumber(data.genre) == 2 then
            self.contentTxt.text = lang.trans("guild_detail_change_2", timeString, data.defName)
        elseif tonumber(data.genre) == 3 then
            self.contentTxt.text = lang.trans("guild_detail_change_3", timeString, data.defName)
        elseif tonumber(data.genre) == 1 then
            if data.atkScore > data.defScore then
                self.contentTxt.text = lang.trans("guild_detail_win", timeString, data.atkName, data.defName, data.atkScore, data.defScore)
            else
                self.contentTxt.text = lang.trans("guild_detail_failure", timeString, data.atkName, data.defName, data.atkScore, data.defScore)
            end
        elseif tonumber(data.genre) == 4 then
            self.contentTxt.text = lang.trans("guild_resize_1", timeString, data.atkName)
        end
    end

    self.videoBtn:regOnButtonClick(function ()
        if type(self.onView) == "function" then
            self.onView()
        end
    end)
end

return MistOurPartSeatsDetailItemView
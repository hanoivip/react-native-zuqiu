local GuildDataShowScheduleItemView = class(unity.base)

function GuildDataShowScheduleItemView:ctor()
    self.nameTxt = self.___ex.name
    self.buff = self.___ex.buff
    self.roundTxt = self.___ex.roundTxt
    self.capture1Txt = self.___ex.capture1Txt
    self.capture2Txt = self.___ex.capture2Txt
    self.seize1Txt = self.___ex.seize1Txt
    self.seize2Txt = self.___ex.seize2Txt
    self.attackWin = self.___ex.attackWin
    self.defenseWin = self.___ex.defenseWin
    self.attackLose = self.___ex.attackLose
    self.defenseLose = self.___ex.defenseLose
end

function GuildDataShowScheduleItemView:Init(data)

end

return GuildDataShowScheduleItemView
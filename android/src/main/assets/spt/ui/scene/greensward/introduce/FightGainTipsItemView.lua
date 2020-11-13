local FightGainTipsItem = class(unity.base, "FightGainTipsItem")

function FightGainTipsItem:ctor()
--------Start_Auto_Generate--------
    self.monsterTxt = self.___ex.monsterTxt
    self.baseTxt = self.___ex.baseTxt
    self.goalTxt = self.___ex.goalTxt
--------End_Auto_Generate----------
end

function FightGainTipsItem:InitView(fightRewardData)
    self.monsterTxt.text = tostring(fightRewardData.eventName)
    self.baseTxt.text = tostring(fightRewardData.baseFight)
    self.goalTxt.text = tostring(fightRewardData.goalFight)
end

return FightGainTipsItem

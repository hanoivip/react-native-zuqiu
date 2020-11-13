local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildDataShowMyWarItemView = class(unity.base)

function GuildDataShowMyWarItemView:ctor()
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

function GuildDataShowMyWarItemView:Init(data)
    -- 名字
    self.nameTxt.attack1.text = data.atk.attackName
    self.nameTxt.defense1.text = data.atk.defenseName
    self.nameTxt.attack2.text = data.def.attackName
    self.nameTxt.defense2.text = data.def.defenseName
    self.roundTxt.text = data.round

    GameObjectHelper.FastSetActive(self.buff.attack1.transform.parent.gameObject, data.atk.buff.atkBuff ~= nil)
    if data.atk.buff.atkBuff ~= nil then
        self.buff.attack1.text = data.buff.atk.atkBuff
    end
    GameObjectHelper.FastSetActive(self.buff.defense1.transform.parent.gameObject, data.atk.buff.defBuff ~= nil)
    if data.atk.buff.defBuff ~= nil then
        self.buff.defense1.text = data.buff.atk.defBuff
    end
    GameObjectHelper.FastSetActive(self.buff.attack2.transform.parent.gameObject, data.def.buff.atkBuff ~= nil)
    if data.def.buff.atkBuff ~= nil then
        self.buff.attack2.text = data.buff.def.atkBuff
    end
    GameObjectHelper.FastSetActive(self.buff.defense2.transform.parent.gameObject, data.def.buff.defBuff ~= nil)
    if data.def.buff.defBuff ~= nil then
        self.buff.defense2.text = data.buff.def.defBuff
    end

    self.capture1Txt.text = "总占领：" .. tostring(data.atk.captureCnt)
    self.capture2Txt.text = "总占领：" .. tostring(data.def.captureCnt)
    self.seize1Txt.text = "总攻陷：" .. tostring(data.atk.seizeCnt)
    self.seize2Txt.text = "总攻陷：" .. tostring(data.def.seizeCnt)

    GameObjectHelper.FastSetActive(self.attackWin, tonumber(data.atk.ret) == 1)
    GameObjectHelper.FastSetActive(self.attackLose, tonumber(data.atk.ret) ~= 1)
    GameObjectHelper.FastSetActive(self.defenseWin, tonumber(data.def.ret) == 1)
    GameObjectHelper.FastSetActive(self.defenseLose, tonumber(data.def.ret) ~= 1)
end



return GuildDataShowMyWarItemView
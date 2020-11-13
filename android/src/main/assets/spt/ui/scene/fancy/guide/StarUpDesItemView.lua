local StarUpDesItemView = class(unity.base)

function StarUpDesItemView:ctor()
--------Start_Auto_Generate--------
    self.starLvTxt = self.___ex.starLvTxt
    self.valueTxt = self.___ex.valueTxt
    self.skillTxt = self.___ex.skillTxt
--------End_Auto_Generate----------
end

function StarUpDesItemView:InitView(msg)
    self.starLvTxt.text = lang.transstr("star_num", msg.star)
    self.valueTxt.text = tostring(msg.allAttributeNum)
    self.skillTxt.text = tostring(msg.allSkills)
end

return StarUpDesItemView

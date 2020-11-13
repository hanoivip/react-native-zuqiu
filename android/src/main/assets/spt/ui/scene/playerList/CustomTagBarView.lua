local CustomTagBarView = class(unity.base)

function CustomTagBarView:ctor()
    CustomTagBarView.super.ctor(self)
--------Start_Auto_Generate--------
    self.msgTxt = self.___ex.msgTxt
--------End_Auto_Generate----------
end

function CustomTagBarView:InitView(msg)
    self.msgTxt.text = msg
end

return CustomTagBarView

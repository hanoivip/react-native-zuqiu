local SelectSkillsDlgView = class(unity.base)

function SelectSkillsDlgView:ctor()
    self.scroll = self.___ex.scroll
    self.count = self.___ex.count
    self.closeBtn = self.___ex.closeBtn
end

function SelectSkillsDlgView:start()
    self:SetCountText("0 / 3")
    self.closeBtn:regOnButtonClick(function()
        if type(self.OnClose) == "function" then
            self.OnClose()
        end
    end)
end

function SelectSkillsDlgView:SetCountText(text)
    self.count.text = text
end

return SelectSkillsDlgView
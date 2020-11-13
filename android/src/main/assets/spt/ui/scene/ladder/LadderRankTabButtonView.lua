local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")

local LadderRankTabButtonView = class(LuaButton)

function LadderRankTabButtonView:ctor()
    LadderRankTabButtonView.super.ctor(self)
    self.selectImage = self.___ex.selectImage
    self.unSelectImage = self.___ex.unSelectImage
    self.text = self.___ex.text
    self.text1 = self.___ex.text1
end

function LadderRankTabButtonView:start()
    self:regOnButtonClick(function()
        self:OnBtnClick()
    end)
end

function LadderRankTabButtonView:InitView(name)
    self.text.text = name
    self.text1.text = name
end

function LadderRankTabButtonView:ChangeState(isSelect)
    self:onPointEventHandle(not isSelect)
    GameObjectHelper.FastSetActive(self.selectImage, isSelect)
    GameObjectHelper.FastSetActive(self.unSelectImage, not isSelect)
end

function LadderRankTabButtonView:OnBtnClick()
    if self.clickRankTab then 
        self.clickRankTab()
    end
end

return LadderRankTabButtonView
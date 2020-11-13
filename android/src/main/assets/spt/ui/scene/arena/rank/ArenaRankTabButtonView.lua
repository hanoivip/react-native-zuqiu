local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")

local ArenaRankTabButtonView = class(LuaButton)

function ArenaRankTabButtonView:ctor()
    ArenaRankTabButtonView.super.ctor(self)
    self.selectImage = self.___ex.selectImage
    self.unSelectImage = self.___ex.unSelectImage
    self.text = self.___ex.text
    self.text1 = self.___ex.text1
end

function ArenaRankTabButtonView:start()
    self:regOnButtonClick(function()
        selectImage:OnBtnClick()
    end)
end

function ArenaRankTabButtonView:InitView(name)
    self.text.text = name
    self.text1.text = name
end

function ArenaRankTabButtonView:ChangeState(isSelect)
    self:onPointEventHandle(not isSelect)
    GameObjectHelper.FastSetActive(self.selectImage, isSelect)
    GameObjectHelper.FastSetActive(self.unSelectImage, not isSelect)
end

function ArenaRankTabButtonView:OnBtnClick()
    if self.clickRankTab then 
        self.clickRankTab()
    end
end

return ArenaRankTabButtonView
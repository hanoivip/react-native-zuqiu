local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local RankTabView = class(unity.base)

function RankTabView:ctor()
    self.selectImage = self.___ex.selectImage
    self.unSelectImage = self.___ex.unSelectImage
    self.text = self.___ex.text
    self.text1 = self.___ex.text1
    self.btnClick = self.___ex.btnClick
    self.isSelect = false
end

function RankTabView:start()
    self.btnClick:regOnButtonClick(function()
        self:OnBtnClick()
    end)
end

function RankTabView:InitView(tagData, index, selectTabIndex)
    local name = tagData.text
    self.text.text = lang.trans(name)
    self.text1.text = lang.trans(name)
    local isSelect = tobool(index == selectTabIndex)
    self:ChangeState(isSelect)
end

function RankTabView:ChangeState(isSelect)
    GameObjectHelper.FastSetActive(self.selectImage, isSelect)
    GameObjectHelper.FastSetActive(self.unSelectImage, not isSelect)
end

function RankTabView:OnBtnClick()
    if self.clickRankTab then 
        self.clickRankTab()
    end
end

return RankTabView
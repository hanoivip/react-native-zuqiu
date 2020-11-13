local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local MailListScrollView = class(LuaScrollRectExSameSize)

function MailListScrollView:ctor()
    MailListScrollView.super.ctor(self)
end

function MailListScrollView:start()
end

function MailListScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Mail/MailBar.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function MailListScrollView:resetItem(spt, index)
    local mailDetailModel = self.data[index]
    spt:InitView(mailDetailModel)
    spt.clickMail = function() self:OnClickMail(mailDetailModel:GetMailID()) end
    spt.clickCollect = function() self:OnClickCollectAtBar(mailDetailModel) end
    self:updateItemIndex(spt, index)
end

function MailListScrollView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

function MailListScrollView:OnClickMail(mailID)
    if self.clickMail then
        self.clickMail(mailID)
    end
end

function MailListScrollView:OnClickCollectAtBar(mailDetailModel)
    if self.clickCollect then
        self.clickCollect(mailDetailModel)
    end
end

return MailListScrollView

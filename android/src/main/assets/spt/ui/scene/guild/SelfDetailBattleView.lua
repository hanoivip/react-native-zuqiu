local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local SelfDetailBattleView = class(unity.base)

function SelfDetailBattleView:ctor()
    self.scrollRect = self.___ex.scrollRect
    self.closeBtn = self.___ex.closeBtn

    DialogAnimation.Appear(self.transform, nil)
end

function SelfDetailBattleView:InitView(model)
    self:InitScrollView(model)
    self:RegOnBtn()
end

function SelfDetailBattleView:InitScrollView(model)
    self.scrollRect:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/SelfDetailBattleItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.scrollRect:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        spt:Init(data)
        spt.onDetailBtnClick = function ()
            PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(data._id, data.sid) end, data._id, data.sid)
        end
        scrollSelf:updateItemIndex(spt, index)
    end)

    self.scrollRect:refresh(model:GetDatas())
end

function SelfDetailBattleView:RegOnBtn()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function SelfDetailBattleView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return SelfDetailBattleView
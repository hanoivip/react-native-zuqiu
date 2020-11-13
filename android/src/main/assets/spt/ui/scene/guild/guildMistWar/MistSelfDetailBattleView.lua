local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local MistSelfDetailBattleView = class(unity.base)

function MistSelfDetailBattleView:ctor()
    self.scrollRect = self.___ex.scrollRect
    self.closeBtn = self.___ex.closeBtn
    self.totalRemainTxt = self.___ex.totalRemainTxt
    DialogAnimation.Appear(self.transform, nil)
end

function MistSelfDetailBattleView:InitView(model)
    self:RegOnBtn()
    self:InitScrollView(model)

    local totalRemainCount = model:GetTotalRemainCount()
    self.totalRemainTxt.text = lang.trans("guild_mist_total_count", totalRemainCount)
end

function MistSelfDetailBattleView:InitScrollView(model)
    self.scrollRect:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/MistSelfDetailBattleItem.prefab"
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

function MistSelfDetailBattleView:RegOnBtn()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function MistSelfDetailBattleView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return MistSelfDetailBattleView
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local EffortBoardView = class(unity.base)

function EffortBoardView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.scrollView = self.___ex.scrollView
    self.rankTxt = self.___ex.rankTxt
    self.nameTxt = self.___ex.nameTxt
    self.lvlTxt = self.___ex.lvlTxt
    self.effortLvlTxt = self.___ex.effortLvlTxt
    self.playInfoModel = PlayerInfoModel.new()
    DialogAnimation.Appear(self.transform, nil)
end

function EffortBoardView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)

    self:InitScrollView()
end

function EffortBoardView:InitView(effortModel)
    self.rankTxt.text = tostring(effortModel:GetSelfRank())
    self.nameTxt.text = self.playInfoModel:GetName()
    self.lvlTxt.text = "Lv" .. self.playInfoModel:GetLevel()
    self.effortLvlTxt.text = tostring(effortModel:GetSelfEffortLevel())
    self.scrollView:refresh(effortModel:GetEffortData())
end

function EffortBoardView:InitScrollView()
    self.scrollView:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/HonorPalace/EffortItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.scrollView:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        spt:InitView(data)
        spt.onView = function ()
            data.sid = data.sid or self.playInfoModel:GetSID()
            PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(data._id, data.sid) end, data._id, data.sid)
        end
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function EffortBoardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return EffortBoardView
local UnityEngine = clr.UnityEngine
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GreenswardMoraleSupplyItemView = class(unity.base, "GreenswardMoraleSupplyItemView")

function GreenswardMoraleSupplyItemView:ctor()
    -- 头像
    self.imgLogo = self.___ex.imgLogo
    -- 名字
    self.txtName = self.___ex.txtName
    -- 等级
    self.txtLvl = self.___ex.txtLvl
    -- 战力
    self.txtPower = self.___ex.txtPower
    -- 获取按钮
    self.btnGet = self.___ex.btnGet
    self.buttonGet = self.___ex.buttonGet
    self.txtGot = self.___ex.txtGot
    self.iconCanGet = self.___ex.iconCanGet
    self.iconCannotGet = self.___ex.iconCannotGet
    self.txtGetNum = self.___ex.txtGetNum
    -- 赠送按钮
    self.btnSend = self.___ex.btnSend
    self.buttonSend = self.___ex.buttonSend
    self.txtSent = self.___ex.txtSent
    self.iconSend = self.___ex.iconSend
    self.txtSendNum = self.___ex.txtSendNum
end

function GreenswardMoraleSupplyItemView:start()
end

function GreenswardMoraleSupplyItemView:InitView(data, greenswardMoraleSupplyModel)
    self.data = data
    self.parentModel = greenswardMoraleSupplyModel
    local singleMorale = self.parentModel:GetSingleMorale()

    self:DisplayTeamLogo(self.data.logo)
    self.txtName.text = tostring(self.data.name)
    self.txtLvl.text = lang.trans("friends_manager_item_level", self.data.lvl)
    self.txtPower.text = lang.trans("greensward_morale_supply_power", self.data.power)

    local canRcv = (self.data.advRcv > 0) -- 可领取可点击
    self.buttonGet.interactable = canRcv
    GameObjectHelper.FastSetActive(self.iconCannotGet.gameObject, self.data.advRcv == self.parentModel.RcvStu.NotRcv) -- 未赠送
    GameObjectHelper.FastSetActive(self.iconCanGet.gameObject, canRcv) -- 已赠送未领取
    GameObjectHelper.FastSetActive(self.btnGet.gameObject, self.data.advRcv ~= self.parentModel.RcvStu.Rcved) -- 已领取
    GameObjectHelper.FastSetActive(self.txtGot.gameObject, self.data.advRcv == self.parentModel.RcvStu.Rcved)
    for k, text in pairs(self.txtGetNum) do
        text.text = "x" .. tostring(singleMorale)
    end

    local canSend = (self.data.advSend == self.parentModel.SendStu.NotSent) -- 未赠送可点击
    self.buttonSend.interactable = canSend
    GameObjectHelper.FastSetActive(self.iconSend.gameObject, canSend) -- 未赠送
    GameObjectHelper.FastSetActive(self.btnSend.gameObject, self.data.advSend ~= self.parentModel.SendStu.Sent) -- 已赠送
    GameObjectHelper.FastSetActive(self.txtSent.gameObject, self.data.advSend == self.parentModel.SendStu.Sent)
    self.txtSendNum.text = "x" .. tostring(singleMorale)
end

function GreenswardMoraleSupplyItemView:DisplayTeamLogo(logo)
    TeamLogoCtrl.BuildTeamLogo(self.imgLogo, logo)
end

return GreenswardMoraleSupplyItemView

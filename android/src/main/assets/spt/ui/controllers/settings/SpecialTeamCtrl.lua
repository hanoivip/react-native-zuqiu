local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local SpecialTeamCtrl = class(BaseCtrl)

SpecialTeamCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Settings/SpecialTeam.prefab"

function SpecialTeamCtrl:Refresh(data, specSuitId)
    self.data = data
    self.specSuitId = specSuitId
    self.playerInfoModel = PlayerInfoModel.new()
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
    end)

    self:InitView()
end

function SpecialTeamCtrl:InitView()
    self.view.setSpcialTeam = function()
        self:OnSetSpcialTeam()
    end
    self.view.cancelSpcialteam = function()
        self:onCancelSpcialteam()
    end
    self.view:InitView(self.data, self.specSuitId)
end

function SpecialTeamCtrl:OnSetSpcialTeam()
    clr.coroutine(function()
        local response = req.useSpecificTeam(self.specSuitId, true)
        if api.success(response) then
            -- 通知SettingsCtrl，修改套装数据
            -- 在开启UI缓存的情况下，data数据是没有更新的，这里就要主动更新
            local value = {
                specificTeam = self.data.logoShirt.specificTeam,
                useSpecific = self.specSuitId
            }
            value.specificTeam[self.specSuitId] = 1
            EventSystem.SendEvent("OnSetSpcialTeam", value)
            self.playerInfoModel:SetSpecificTeam(self.specSuitId)
            res.PopScene()
        end
    end)
end

function SpecialTeamCtrl:onCancelSpcialteam()
    clr.coroutine(function()
        local response = req.useSpecificTeam(self.specSuitId, false)
        if api.success(response) then
            local data = response.val
            local value = {
                useSpecific = data.useSpecific,
                specificTeam = data.specificTeam
            }
            EventSystem.SendEvent("OnSetSpcialTeam", value)
            -- 也要修改logo数据
            self.playerInfoModel:SetTeamLogo(data.logo)
            self.playerInfoModel:SetSpecificTeam(nil)
            res.PopScene()
        end
    end)
end

return SpecialTeamCtrl
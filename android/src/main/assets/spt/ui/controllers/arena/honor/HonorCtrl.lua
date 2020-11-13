local ArenaModel = require("ui.models.arena.ArenaModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ArenaHonorModel = require("ui.models.arena.honor.ArenaHonorModel")
local HonorPageType = require("ui.scene.arena.honor.HonorPageType")
local ArenaInfoBarCtrl = require("ui.controllers.common.ArenaInfoBarCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local HonorCtrl = class(BaseCtrl, "CourtMainCtrl")

HonorCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/ArenaHonor.prefab"

function HonorCtrl:Init()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = ArenaInfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self:OnClickBack()
        end)
    end)
    self.view.clickReward = function(id) self:OnClickReward(id) end
    self.view.clickRule = function() self:OnClickRule() end
    self.view.clickBack = function() self:OnClickBack() end
    self.view.clickPage = function(key) self:OnClickPage(key) end
end

function HonorCtrl:OnBtnTip()
    DialogManager.ShowAlertAlignmentPop(lang.trans("instruction"), lang.trans("aid_content"), 3)
end

function HonorCtrl:OnClickBack()
    res.PopScene()
end

function HonorCtrl:OnClickPage(key)
    
end

function HonorCtrl:OnClickRule()
    res.PushScene("ui.controllers.arena.ArenaRuleCtrl")
end

function HonorCtrl:Refresh()
    HonorCtrl.super.Refresh(self)
    clr.coroutine(function()
        local response = req.arenaHonorInfo()
        if api.success(response) then
            local data = response.val
            local arenaModel = ArenaModel.new()
            self.arenaHonorModel = ArenaHonorModel.new()
            self.arenaHonorModel:InitWithProtocol(data)
            self.view:InitView(arenaModel, self.arenaHonorModel, HonorPageType.Total)
        end
    end)
end

function HonorCtrl:OnClickReward(id)
    if self.arenaHonorModel:IsCanRecieve(id) then
        clr.coroutine(function()
            local response = req.arenaReceiveHonor(id)
            if api.success(response) then
                local data = response.val
                if data.contents then 
                    CongratulationsPageCtrl.new(data.contents)
                end
                local list = data.list
                self.arenaHonorModel:SetRewardState(id, list[tostring(id)].state)
            end
        end)
    end
end

function HonorCtrl:OnEnterScene()
    self.view:EnterScene()
end

function HonorCtrl:OnExitScene()
    self.view:ExitScene()
end

return HonorCtrl

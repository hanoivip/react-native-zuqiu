local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildChallengeModel = require("ui.models.guild.GuildChallengeModel")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local GuildChallengeEnterModel = require("ui.models.guild.GuildChallengeEnterModel")
local UnityEngine = clr.UnityEngine

local GuildChallengeCtrl = class(BaseCtrl)

GuildChallengeCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildChallenge.prefab"

function GuildChallengeCtrl:Init()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            EventSystem.SendEvent("GuildChallengeItemClick", nil)
            res.PopScene()
        end)
    end)

    self.guildChallengeModel = GuildChallengeModel.new()

    self.view.instanceItemClick = function(index)
        EventSystem.SendEvent("GuildChallengeItemClick", index)
    end

    self.view.onItemBtnEntryClick = function(levelInfo)
        local model = GuildChallengeEnterModel.new()
        model:InitWithProtocol(levelInfo)
        res.PushScene("ui.controllers.guild.GuildChallengeEnterCtrl", model)
    end

    self.view.OnBtnHelpClick = function()
        self:OnRuleHelp()
    end
end

function GuildChallengeCtrl:Refresh()
    GuildChallengeCtrl.super.Refresh(self)
    self.view:HideContentArea()        
    
    clr.coroutine(function()
        local respone = req.challengeInfo()
        if api.success(respone) then
            local data = respone.val
            self.guildChallengeModel:InitWithProtocol(data)
            self:InitView()
        end
    end)
end

function GuildChallengeCtrl:GetStatusData()
end

function GuildChallengeCtrl:InitView()
    self.view:InitView(self.guildChallengeModel)
end

function GuildChallengeCtrl:OnRuleHelp()
    res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/ChallengeRuleBoard.prefab", "camera", true, true)
end

function GuildChallengeCtrl:OnEnterScene()
end

function GuildChallengeCtrl:OnExitScene()
end

return GuildChallengeCtrl
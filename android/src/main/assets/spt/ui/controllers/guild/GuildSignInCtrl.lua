local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildSignInModel = require("ui.models.guild.GuildSignInModel")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local DialogManager = require("ui.control.manager.DialogManager")
local DialogMultipleConfirmation = require("ui.control.manager.DialogMultipleConfirmation")
local GUILD_LOGTYPE = require("ui.controllers.guild.GUILD_LOGTYPE")
local UnityEngine = clr.UnityEngine

local GuildSignInCtrl = class(BaseCtrl)

GuildSignInCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildSignIn.prefab"

function GuildSignInCtrl:Init()
    self.guildSignInModel = GuildSignInModel.new()

    self.view.onBtnLogClick = function()
        res.PushScene("ui.controllers.guild.GuildLogCtrl", GUILD_LOGTYPE.SIGN)
    end

    self.view.onBtnCoinSignClick = function()
        clr.coroutine(function()
            local respone = req.GuildSign(1)
            if api.success(respone) then
                local data = respone.val
                if type(data.cost) == "table" then
                    if data.cost["type"] == "m" then
                        local playerInfoModel = PlayerInfoModel.new()
                        playerInfoModel:AddMoney(-1 * data.cost.num)
                    end
                end
                CongratulationsPageCtrl.new(data.contents)
                self.guildSignInModel:SetSignNum(data.sign)
                self.guildSignInModel:SetProgress(data.progress)
                self.guildSignInModel:SetSelfSignState(1)
                self.view:HideButtons()
                self:InitView()
            end
        end)
    end

    self.view.onBtnDiamonSignClick = function()
        local costDiamond = self.guildSignInModel:GetDiamondPrice()
        CostDiamondHelper.CostDiamond(costDiamond, self.view, function()
			local confirmCallback = function()
				clr.coroutine(function()
					local respone = req.GuildSign(2)
					if api.success(respone) then
						local data = respone.val
						if type(data.cost) == "table" then
							if data.cost["type"] == "d" then
								local playerInfoModel = PlayerInfoModel.new()
								playerInfoModel:AddDiamond(-1 * data.cost.num)
								local consumeType = 3
								CustomEvent.ConsumeDiamond(consumeType, tonumber(data.cost.num))
							end
						end
						CongratulationsPageCtrl.new(data.contents)
						self.guildSignInModel:SetSignNum(data.sign)
						self.guildSignInModel:SetProgress(data.progress)
						self.guildSignInModel:SetSelfSignState(2)
						self.view:HideButtons()
						self:InitView()
					end
				end)
			end
			DialogMultipleConfirmation.MultipleConfirmation(lang.trans("strength"), lang.trans("buy_sp"), confirmCallback)
        end)
    end

    self.view.packetItemContentClick = function(index)
        clr.coroutine(function()
            local respone = req.sendRedEnvelope(index)
            if api.success(respone) then
                local data = respone.val
                if data.ok == true then
                    DialogManager.ShowToastByLang("guild_sendPacket")
                    self.guildSignInModel:SetPacketSendState(index, true)
                    self:InitView()
                end
            end
        end)
    end

end

function GuildSignInCtrl:Refresh(memberNum)
    GuildSignInCtrl.super.Refresh(self)
    self.memberNum = memberNum
    self.guildSignInModel:SetMemberNum(memberNum)
    
    clr.coroutine(function()
        local respone = req.GuildSignInfo()
        if api.success(respone) then
            local data = respone.val
            self.guildSignInModel:InitWithProtocol(data)
            self:InitView()
        end
    end)
end

function GuildSignInCtrl:GetStatusData()
    return self.memberNum
end

function GuildSignInCtrl:InitView()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PopScene()
        end)
    end)
    self.view:InitView(self.guildSignInModel)
end

function GuildSignInCtrl:OnEnterScene()
end

function GuildSignInCtrl:OnExitScene()
end

return GuildSignInCtrl
local BaseCtrl = require("ui.controllers.BaseCtrl")
local ChatRedPacketModel = require("ui.models.chat.ChatRedPacketModel")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CustomEvent = require("ui.common.CustomEvent")

local UnityEngine = clr.UnityEngine

local ChatRedPacketCtrl = class(BaseCtrl)

ChatRedPacketCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Chat/Prefab/ChatRedPacket.prefab"

function ChatRedPacketCtrl:Init(data, redPacketType)
    self.chatRedPacketModel = ChatRedPacketModel.new()

    self.view.onBtnOpenPacketClick = function()
        local isopen =  self.chatRedPacketModel:GetOpenState()
        if isopen then return end
        self.chatRedPacketModel:SetOpenState(true)
        clr.coroutine(function()
            local respone = req.openRedEnvelope(self.chatRedPacketModel:GetPacketId(), redPacketType)
            if api.success(respone) then
                local data = respone.val
                self.view:PlayOpenAnimation()
                self.view.onCalAnimationShow = function()
                    CongratulationsPageCtrl.new(data.contents)
                end
                self.view.onAnimationLeaveShow = function()
                    self.view.packetArea1:SetActive(false)
                    self.view.packetArea2:SetActive(true)
                end
                clr.coroutine(function()
                    local respone2 = req.viewRedEnvelope(self.chatRedPacketModel:GetPacketId(), redPacketType)
                     if api.success(respone2) then
                        local data2 = respone2.val
                        self.chatRedPacketModel:InitWithProtrol(data2)
                        self:InitView(false)
                    end
                end)
            end
        end)
    end

    self.view.onBtnViewPacketClick = function()
        self.chatRedPacketModel:SetCanViewState(false)
        self.view:PlayViewAnimation()
        self.view.onAnimationLeaveShow = function()
            self.view.packetArea1:SetActive(false)
            self.view.packetArea2:SetActive(true)
        end
        self:InitView(false)
    end
end

function ChatRedPacketCtrl:Refresh(data)
    self.chatRedPacketModel:InitWithProtrol(data)
    self:InitView(true)
end

function ChatRedPacketCtrl:InitView(notAnim)
    self.view:InitView(self.chatRedPacketModel, notAnim)
end

return ChatRedPacketCtrl

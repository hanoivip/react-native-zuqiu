local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local DialogManager = require("ui.control.manager.DialogManager")

local GuildRedPacketView = class(unity.base)

function GuildRedPacketView:ctor()
    self.diamonNum = self.___ex.diamonNum
    self.content = self.___ex.content
    self.getImg = self.___ex.getImg
    self.signNum = self.___ex.signNum
    self.getPacket = self.___ex.getPacket
    self.contentClick = self.___ex.contentClick
    self.sendPacket = self.___ex.sendPacket
end


function GuildRedPacketView:start()
   
end

function GuildRedPacketView:InitView(index, diamonNum, getMemberNum, signMemberNum, progress, issend)
    self.diamonNum.text = tostring(diamonNum)
    self.content.text = lang.transstr("guild_redPacket", getMemberNum)
    self.signNum.text = tostring(signMemberNum)
    local canGet = progress >= signMemberNum
    self.getImg:SetActive(canGet)
    self.getPacket:SetActive(canGet and (not issend))
    self.sendPacket:SetActive(issend)
    if canGet then
        self.contentClick:regOnButtonClick(function()
            if type(self.packetContentClick) == "function" then
                self.packetContentClick()
            end
        end)
    end
end

function GuildRedPacketView:RegOnDynamicLoad(func)
end

return GuildRedPacketView

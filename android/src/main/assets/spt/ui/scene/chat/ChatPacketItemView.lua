local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local TextAnchor = UnityEngine.TextAnchor

local ChatPacketItemView = class(unity.base)

function ChatPacketItemView:ctor()
    self.teamLogo = self.___ex.teamLogo
    self.nameText = self.___ex.name
    self.date = self.___ex.date
    self.diamond = self.___ex.diamond
end

function ChatPacketItemView:start()
end

local function formateNum(num)
    if string.len(num) < 2 then
        return '0' .. num
    else
        return tostring(num)
    end
end

function ChatPacketItemView:InitView(itemModel)
    self.nameText.text = itemModel:GetName()
    local timeTable = os.date("*t", itemModel:GetDate())
    self.date.text = formateNum(timeTable.month) .. "/" .. formateNum(timeTable.day)  .. "  " .. formateNum(timeTable.hour) .. ":" .. formateNum(timeTable.min)
    self.diamond.text = tostring(itemModel:GetDiamond())
    local logoTable = itemModel:GetTeamLogoInfo()
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, logoTable)
end

function ChatPacketItemView:onDestroy()
end

return ChatPacketItemView
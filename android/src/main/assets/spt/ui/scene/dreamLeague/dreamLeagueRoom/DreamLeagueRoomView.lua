local DreamLeagueRoomView  = class(unity.base)
local DreamLeagueRoomData = require("data.DreamLeagueRoom")

local DialogAnimation = require("ui.control.dialog.DialogAnimation")

function DreamLeagueRoomView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.headLine = self.___ex.headLine
    self.roomName = {}
    self.roomInfo = {}
    self.roomName.list1 = self.___ex.roomName1
    self.roomName.list2 = self.___ex.roomName2
    self.roomName.list3 = self.___ex.roomName3
    self.roomName.list4 = self.___ex.roomName4
    self.roomInfo.list1 = self.___ex.roomInfo1
    self.roomInfo.list2 = self.___ex.roomInfo2
    self.roomInfo.list3 = self.___ex.roomInfo3
    self.roomInfo.list4 = self.___ex.roomInfo4
    self.title = self.___ex.headLine

    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    
    DialogAnimation.Appear(self.transform, nil)
end

function DreamLeagueRoomView:Init( ... )
    local maxPeople = nil
    local feePerOne = nil
    local taxFee = nil
    self.title.text = lang.transstr("room_introduce")
    for i=1,4 do
        self.roomName["list"..i].text = DreamLeagueRoomData[tostring(i)].name
        maxPeople = DreamLeagueRoomData[tostring(i)].maxPeople
        feePerOne = DreamLeagueRoomData[tostring(i)].fee[1]
        taxFee = DreamLeagueRoomData[tostring(i)].taxFee
        self.roomInfo["list"..i].text = lang.transstr("room_information", maxPeople, feePerOne, taxFee)
    end

end

function DreamLeagueRoomView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
                if type(self.closeCallback) == "function" then
                    self.closeCallback()
                end
                self.closeDialog()
            end)
    end
end

function DreamLeagueRoomView:OnExitScene()
end

return DreamLeagueRoomView
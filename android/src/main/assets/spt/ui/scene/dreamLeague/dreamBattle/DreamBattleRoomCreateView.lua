local UnityEngine = clr.UnityEngine
local Text = UnityEngine.UI.Text

local AssetFinder = require("ui.common.AssetFinder")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DreamLeagueRoom = require("data.DreamLeagueRoom")

local DreamBattleRoomCreateView = class(unity.base)

function DreamBattleRoomCreateView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.createBtn = self.___ex.createBtn
    self.gameDropdown = self.___ex.gameDropdown
    self.roomTypeDropdown = self.___ex.roomTypeDropdown
    self.tipBtn = self.___ex.tipBtn
end

function DreamBattleRoomCreateView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)

    self.createBtn:regOnButtonClick(function ()
        if self.onCreateBtnClick then
            self.onCreateBtnClick()
        end
    end)

    self.tipBtn:regOnButtonClick(function ()
        if self.onTipBtnClick then
            self.onTipBtnClick()
        end
    end)

    DialogAnimation.Appear(self.transform, nil)
end

function DreamBattleRoomCreateView:InitView(dreamBattleRoomCreateModel)
    self.dreamBattleRoomCreateModel = dreamBattleRoomCreateModel
    self:InitDropdownPart()
end

function DreamBattleRoomCreateView:InitDropdownPart()
    local matchList = self.dreamBattleRoomCreateModel:GetTodayMatchTxtList()
    local txtlist = clr.System.Collections.Generic.List(clr.System.String)()  --Lua assist checked flag
    for k,v in pairs(matchList) do
        txtlist.Add(k)  --Lua assist checked flag
    end
    self.gameDropdown.AddOptions(txtlist)  --Lua assist checked flag

    local roomInfoList = self.dreamBattleRoomCreateModel:GetRoomList()
    local roomList = clr.System.Collections.Generic.List(clr.System.String)()  --Lua assist checked flag
    for k,v in pairs(roomInfoList) do
        roomList.Add(k)  --Lua assist checked flag
    end
    self.roomTypeDropdown.AddOptions(roomList)  --Lua assist checked flag
end

function DreamBattleRoomCreateView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return DreamBattleRoomCreateView

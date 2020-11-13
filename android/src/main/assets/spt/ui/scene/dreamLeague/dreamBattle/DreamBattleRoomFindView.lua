local UnityEngine = clr.UnityEngine
local Text = UnityEngine.UI.Text

local AssetFinder = require("ui.common.AssetFinder")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DreamLeagueRoom = require("data.DreamLeagueRoom")

local DreamBattleRoomFindView = class(unity.base)

function DreamBattleRoomFindView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.roomNum = self.___ex.roomNum
    self.toggleParent = self.___ex.toggleParent
    self.confirmBtn = self.___ex.confirmBtn
    self.toggleGroup = self.___ex.toggleGroup
end

function DreamBattleRoomFindView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)

    self.confirmBtn:regOnButtonClick(function ()
        if self.onConfirmBtnClick then
            self.onConfirmBtnClick()
        end
    end)

    DialogAnimation.Appear(self.transform, nil)
end

function DreamBattleRoomFindView:InitView()
    self:InitToggleInfo()
end

function DreamBattleRoomFindView:InitToggleInfo()
    self.toogleList = {}
    self.toogleTxtList = {}

    local childCount = self.toggleParent.childCount
    for i=0,childCount-1 do
        local son = self.toggleParent:GetChild(i)
        local toggle = son:GetComponent(Toggle)
        local txt = son:GetComponentInChildren(Text)  --Lua assist checked flag

        table.insert(self.toogleList, toggle)
        table.insert(self.toogleTxtList, txt)

        toggle.group = self.toggleGroup
        txt.text = DreamLeagueRoom[tostring(i+1)].name
    end

    for k, v in pairs(self.toogleList) do
        v.onValueChanged:AddListener(function (isOn)
            self.findRoomId = {}
            self.findRoomId[k] = isOn
        end)
    end
end

function DreamBattleRoomFindView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return DreamBattleRoomFindView

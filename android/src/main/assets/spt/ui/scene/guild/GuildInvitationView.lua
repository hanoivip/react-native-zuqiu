local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GuildInvitationView = class(unity.base)

function GuildInvitationView:ctor()
    self.groupObj = self.___ex.groupObj
    self.closeBtn = self.___ex.closeBtn
    self.invatiationItem = {}
    DialogAnimation.Appear(self.transform, nil)

    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function GuildInvitationView:InitView(data)
    if data and next(data) then
        for k,v in pairs(data) do
            local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildInvatationItem.prefab")
            table.insert(self.invatiationItem, spt)
            local currTr = obj.transform
            currTr:SetParent(self.groupObj.transform, true)
            currTr.localEulerAngles = Vector3.zero
            currTr.localScale = Vector3.one
            currTr.localPosition = Vector3.zero
            self.invatiationItem[k]:InitView(v)
            self.invatiationItem[k].clickReceive = self.clickReceive
        end
    end
end

function GuildInvitationView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return GuildInvitationView

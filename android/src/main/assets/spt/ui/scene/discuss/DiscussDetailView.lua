local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local DiscussDetailView = class(unity.base)

function DiscussDetailView:ctor()
    self.close = self.___ex.close
    self.mainContent = self.___ex.mainContent
    self.playerName = self.___ex.playerName
    self.playerServer = self.___ex.playerServer
    self.sendTime = self.___ex.sendTime
    self.playerIcon = self.___ex.playerIcon
    self.upBtn = self.___ex.upBtn
    self.downBtn = self.___ex.downBtn
    self.contentParent = self.___ex.contentParent
    self.replyObj = self.___ex.replyObj
    self.replyBtn = self.___ex.replyBtn
    self.inputText = self.___ex.inputText
    self.sendBtn = self.___ex.sendBtn
    self.sendObj = self.___ex.sendObj
    self.closeSendBtn = self.___ex.closeSendBtn
    self.upCount = self.___ex.upCount
    self.downCount = self.___ex.downCount

    self.close:regOnButtonClick(
        function()
            self:Close()
        end
    )
    self.sendBtn:regOnButtonClick(
        function()
            local message = tostring(self.inputText.text)
            if (not message) or message == "" then
                DialogManager.ShowToastByLang("empty_reply_discuss")
                return
            end
            self.inputText.text = ""
            self:HideSendFiled()
            self:SendMessage(message)
        end
    )
    for k,v in pairs(self.closeSendBtn) do
        v:regOnButtonClick(
            function()
                self:HideSendFiled()
            end
        )
    end
    self.replyBtn:regOnButtonClick(
        function()
            self:ShowSendFiled()
        end
    )

    self.upBtn:regOnButtonClick(
        function()
            if self.onUpClick then
                self.onUpClick()
            end
        end
    )
    self.downBtn:regOnButtonClick(
        function()
            if self.onDownClick then
                self.onDownClick()
            end
        end
    )
    DialogAnimation.Appear(self.transform, nil)
end

function DiscussDetailView:InitView(discussDetailModel)
    self.discussDetailModel = discussDetailModel
    local detailList = discussDetailModel:GetDiscussList()
    local mainDiscuss = discussDetailModel:GetMainDiscuss()
    TeamLogoCtrl.BuildTeamLogo(self.playerIcon, mainDiscuss.player.logo)
    self.mainContent.text = mainDiscuss.content
    self.playerName.text = mainDiscuss.player.name
    self.playerServer.text = mainDiscuss.player.serverName
    self.upCount.text = tostring(mainDiscuss.agreeCount)
    self.downCount.text = tostring(mainDiscuss.disagreeCount)
    self.sendTime.text = mainDiscuss.sendTime
    self:HideSendFiled()
    self:RefreshDetailList(detailList)
end

function DiscussDetailView:RefreshDetailList(detailList)
    self:ClearChildren(self.contentParent.transform)
    for i,v in ipairs(detailList) do
        local discussObj, discussSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Disscuss/ReplyItem.prefab")
        discussObj.transform:SetParent(self.contentParent, false)
        discussSpt:Init(v)
    end
end


function DiscussDetailView:SendMessage(message)
    if type(self.sendMessage) == "function" then
        self.sendMessage(message)
    end
end

function DiscussDetailView:HideSendFiled()
    GameObjectHelper.FastSetActive(self.sendObj, false)
    GameObjectHelper.FastSetActive(self.replyObj, true)
end

function DiscussDetailView:ShowSendFiled()
    GameObjectHelper.FastSetActive(self.sendObj, true)
    GameObjectHelper.FastSetActive(self.replyObj, false)
end

function DiscussDetailView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(
            self.transform,
            nil,
            function()
                if type(self.closeCallback) == "function" then
                    self.closeCallback()
                end
                self.closeDialog()
            end
        )
    end
end

function DiscussDetailView:ClearChildren(parentTrans)
    if parentTrans and parentTrans.childCount > 1 then
        for i = 2, parentTrans.childCount do
            Object.Destroy(parentTrans:GetChild(i - 1).gameObject)
        end
    end
end

return DiscussDetailView

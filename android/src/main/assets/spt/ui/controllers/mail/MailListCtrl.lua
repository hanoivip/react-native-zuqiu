local MailListCtrl = class()

local MailDetailCtrl = require("ui.controllers.mail.MailDetailCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local MailListModel = require("ui.models.mail.MailListModel")
local MailDetailModel = require("ui.models.mail.MailDetailModel")
local DialogManager = require("ui.control.manager.DialogManager")

function MailListCtrl:ctor()
    local mailDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Mail/Mail.prefab", "camera", true, true)
    self.mailListView = dialogcomp.contentcomp
    self.mailListView.RecieveAllMails = function() self:RecieveAllMails() end
    self.mailListView.checkAllRecieveButtonState = function(mailDetailModel) self:CheckAllRecieveButtonState(mailDetailModel) end

    self.mailListView.scrollView.clickMail = function(mailID) self:OnClickMail(mailID) end
    self.mailListView.scrollView.clickCollect = function(mailDetailModel) self:OnClickMail(mailDetailModel:GetMailID()) end
    self:GetMailInfo()
end

function MailListCtrl:GetMailInfo()
    clr.coroutine(function()
        local respone = req.mail(nil, nil, true)
        if api.success(respone) then
            local data = respone.val
            self.mailListModel = MailListModel.new()
            self.mailListModel:InitWithProtocol(data)

            self:InitView()
        end
    end)
end

function MailListCtrl:CheckAllRecieveButtonState(mailDetailModel)
    local mailID = mailDetailModel:GetMailID()
    local haveRead = 1
    mailDetailModel:SetRead(haveRead)
    self.mailDetailModelMap[tostring(mailID)] = mailDetailModel
    self.mailListView:SetRecieveButtonState(self.mailDetailModelMap)
    self:GetMailInfo()
end

function MailListCtrl:InitView()
    self.mailDetailModelMap = { }
    local mailsModel = {}
    local mailList = self.mailListModel:GetMailList()
    for i, mailData in ipairs(mailList) do
        local mailDetailModel = MailDetailModel.new(mailData)
        local mailID = mailDetailModel:GetMailID()
        self.mailDetailModelMap[tostring(mailID)] = mailDetailModel
        table.insert(mailsModel, mailDetailModel)
    end
    self.mailListView.scrollView:InitView(mailsModel)
    self.mailListView:ShowEmptyText(not next(mailList))
    self.mailListView:ShowRecieveButton(true)
    self.mailListView:SetRecieveButtonState(self.mailDetailModelMap)
end

function MailListCtrl:OnClickMail(mailID)
    local mailDetailModel = self.mailDetailModelMap[tostring(mailID)]
    local mailDetailCtrl = MailDetailCtrl.new()
    mailDetailCtrl:InitView(mailDetailModel)
--    if not mailDetailModel:IsRead() and mailDetailModel:IsTextMail() then 
--        self:OnClickCollectAtBar(mailDetailModel)
--    end
end

function MailListCtrl:OnClickCollectAtBar(mailDetailModel)
    clr.coroutine(function()
        local respone = req.mailCollect(mailDetailModel:GetType(), mailDetailModel:GetMailID())
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) then
                mailDetailModel:SetMailCollect(data)
                self:CheckAllRecieveButtonState(mailDetailModel)
                local isTextMail = mailDetailModel:IsTextMail()
                if not isTextMail then 
                    CongratulationsPageCtrl.new(data.contents)
                end
            end
        end
    end)
end

------------
-- 服务器是按每封邮件（带contents）发送，用类型直接叠加合并成一个contents
------------
function MailListCtrl:BuildReward(rewards)
    local finalContents = { }
    for i, eachReward in ipairs(rewards) do
        local contents = eachReward.contents
        if contents then
            for key, v in pairs(contents) do
                if type(v) == "table" then
                    if not finalContents[tostring(key)] then
                        finalContents[tostring(key)] = { }
                    end
                    for index, eachData in pairs(v) do
                        table.insert(finalContents[tostring(key)], eachData)
                    end
                else
                    if not finalContents[tostring(key)] then
                        finalContents[tostring(key)] = 0
                    end
                    finalContents[tostring(key)] = finalContents[tostring(key)] + tonumber(v)
                end
            end
        end
    end
    CongratulationsPageCtrl.new(finalContents, true)
end

function MailListCtrl:RecieveAllMails()
    if not self.mailListView.hasMail or self.mailListView.manualReceive then
        DialogManager.ShowToast(lang.trans("mail_tip_manual_receive_1"))
        return
    end
    clr.coroutine(function()
        local respone = req.mailCollectAll()
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) then
                for index, v in pairs(data) do
                    local mailDetailModel = self.mailDetailModelMap[tostring(v.mid)]
                    if mailDetailModel then
                        mailDetailModel:SetMailCollect(v)
                    end
                end
                self:BuildReward(data)
                self.mailListView:SetRecieveButtonState(self.mailDetailModelMap)
                self:GetMailInfo()
            end
        end
    end)
end
return MailListCtrl

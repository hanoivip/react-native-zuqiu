local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local MenuType = require("ui.models.friends.MenuType")
local FriendsMessagesCtrl = require("ui.controllers.friends.FriendsMessagesCtrl")
local FriendsManagerCtrl = require("ui.controllers.friends.FriendsManagerCtrl")
local FriendsAddCtrl = require("ui.controllers.friends.FriendsAddCtrl")
local FriendsInviteCtrl = require("ui.controllers.friends.friendsInvite.FriendsInviteCtrl")
local FriendsMainModel = require("ui.models.friends.FriendsMainModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local FriendsMainCtrl = class(BaseCtrl)

FriendsMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Friends/FriendsCanvas.prefab"

function FriendsMainCtrl:Init(currentMenu, friendsMainModel)
    self.friendsMainModel = friendsMainModel or FriendsMainModel.new()
    self.friendsManagerCtrl = FriendsManagerCtrl.new(res.GetLuaScript(self.view:GetFriendsBoard(MenuType.MANAGER)))
    self.friendsMessagesCtrl = FriendsMessagesCtrl.new(res.GetLuaScript(self.view:GetFriendsBoard(MenuType.MESSAGES)))
    self.friendsAddCtrl = FriendsAddCtrl.new(res.GetLuaScript(self.view:GetFriendsBoard(MenuType.ADD)))
    self.friendsPageMap = {}
end

function FriendsMainCtrl:Refresh(currentMenu)
    FriendsMainCtrl.super.Refresh(self)
    self.friendsMainModel:SetCurrentMenu(currentMenu)
    self:InitView()
end

function FriendsMainCtrl:GetStatusData()
    return self.friendsMainModel:GetCurrentMenu(), self.friendsMainModel
end

function FriendsMainCtrl:OnEnterScene()
    self.view:EnterScene()
    self.friendsManagerCtrl:OnEnterScene()
    self.friendsMessagesCtrl:OnEnterScene()
    self.friendsAddCtrl:OnEnterScene()
    for k, v in pairs(self.friendsPageMap) do
        v:OnEnterScene()
    end
end

function FriendsMainCtrl:OnExitScene()
    self.view:ExitScene()
    self.friendsManagerCtrl:OnExitScene()
    self.friendsMessagesCtrl:OnExitScene()
    self.friendsAddCtrl:OnExitScene()
    for k, v in pairs(self.friendsPageMap) do
        v:OnExitScene()
    end
end

function FriendsMainCtrl:InitView()
    self.view.clickMenu = function(index) self:OnMenuClick(index) end
    self.view.clickGacha = function() self:OnClickGacha() end

    self.view:RegOnDynamicLoad(function(child)
        InfoBarCtrl.new(child, self)
    end)

    self.view:InitView(self.friendsMainModel)
end

function FriendsMainCtrl:OnMenuClick(index)
    self.friendsMainModel:SetCurrentMenu(index)
    if index == MenuType.MESSAGES then
        self:OnFriendsMessages()
    elseif index == MenuType.MANAGER then
        self:OnFriendsManager()
    elseif index == MenuType.ADD then
        self:OnFriendsAdd()
    elseif index == MenuType.INVITE then
        self:OnFriendsInvite()
    end
    self.view:SwitchFriendsTab(self.friendsMainModel)
end

function FriendsMainCtrl:OnClickGacha()
    res.PushSceneImmediate("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.GACHA, nil, nil, nil, nil, "C1")
end

function FriendsMainCtrl:OnFriendsManager()
    clr.coroutine(function()
        local respone = req.friendsListFriends()
        if api.success(respone) then
            local friendsManagerModel = self.friendsMainModel:GetFriendsManagerModel()
            friendsManagerModel:InitWithProtocol(respone.val)
            self.friendsManagerCtrl:InitView(self.friendsMainModel, friendsManagerModel)
        end
    end)
end

function FriendsMainCtrl:OnFriendsMessages()
    local friendsMessagesModel = self.friendsMainModel:GetFriendsMessagesModel()
    self.friendsMessagesCtrl:InitView(self.friendsMainModel, friendsMessagesModel)
end

function FriendsMainCtrl:OnFriendsAdd()
    clr.coroutine(function()
        local respone = req.friendsFind("", PlayerInfoModel.new():GetSID())
        if api.success(respone) then
            local friendsAddModel = self.friendsMainModel:GetFriendsAddModel()
            friendsAddModel:InitWithProtocol(respone.val)
            self.friendsAddCtrl:InitView(self.friendsMainModel, friendsAddModel)
        end
    end)
end

function FriendsMainCtrl:OnFriendsInvite()
    self.view:coroutine(function()
        local respone = req.fiTaskInfo(nil, nil, false)
        if api.success(respone) then
            local friendsInviteModel = self.friendsMainModel:GetFriendsInviteModel()
            local data = respone.val
            if type(data) == "table" and next(data) then
                friendsInviteModel:InitWithProtocol(data)
                local friendsInviteCtrl = self.friendsPageMap[MenuType.INVITE]
                if not friendsInviteCtrl then 
                    friendsInviteCtrl = FriendsInviteCtrl.new(self.view:GetFriendsBoard(MenuType.INVITE))
                    friendsInviteCtrl:OnEnterScene()
                    self.friendsPageMap[MenuType.INVITE] = friendsInviteCtrl
                end
                friendsInviteCtrl:InitView(self.friendsMainModel, friendsInviteModel)
            end
        end
    end)
end

return FriendsMainCtrl
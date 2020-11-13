local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ItemListMenuType = require("ui.controllers.itemList.MenuType")
local ItemListConstants = require("ui.models.itemList.ItemListConstants")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerNewFunctionModel = require("ui.models.PlayerNewFunctionModel")
local FormationType = require("ui.common.enum.FormationType")
local HomeMenuBarCtrl = class()

function HomeMenuBarCtrl:ctor(viewParent, parentCtrl)
    assert(viewParent and parentCtrl)
    self.parentCtrl = parentCtrl
    self.playerInfoModel = PlayerInfoModel.new()
    local viewObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/MenuBar/HomeMenuBar/MenuBar.prefab")
    viewObject.transform:SetParent(viewParent.transform, false)
    self.menuBarView = viewObject:GetComponent(clr.CapsUnityLuaBehav)
    self:InitView()
    self:InitButtonEvent()

    local parentOnEnterScene = parentCtrl.OnEnterScene
    parentCtrl.OnEnterScene = function(parentCtrl)
        if parentOnEnterScene then 
            parentOnEnterScene(parentCtrl)
        end
        self:OnEnterScene()
    end

    local parentOnExitScene = parentCtrl.OnExitScene
    parentCtrl.OnExitScene = function(parentCtrl)
        if parentOnExitScene then 
            parentOnExitScene(parentCtrl)
        end
        self:OnExitScene()
    end
end

function HomeMenuBarCtrl:OnEnterScene()
    self.menuBarView:EnterScene()
end

function HomeMenuBarCtrl:OnExitScene()
    self.menuBarView:ExitScene()
end

function HomeMenuBarCtrl:InitButtonEvent()
    self.menuBarView.btnPlayers:regOnButtonClick(function()
        res.PushScene("ui.controllers.playerList.PlayerListMainCtrl", nil, nil, nil, nil, true)
    end)
    self.menuBarView.btnFormation:regOnButtonClick(function()
        local playerTeamsModel = require("ui.models.PlayerTeamsModel").new()
        playerTeamsModel:SetFormationType(FormationType.HOME)
        res.PushScene("ui.controllers.formation.FormationPageCtrl", playerTeamsModel)
    end)
    self.menuBarView.btnReward:regOnButtonClick(function()
        res.PushDialog("ui.controllers.rewards.RewardListCtrl")
    end)
    self.menuBarView.btnItem:regOnButtonClick(function()
        self:OpenNewFunction("transfer")
        res.PushScene("ui.controllers.transferMarket.TransferMarketCtrl", {})
    end)
end

function HomeMenuBarCtrl:OpenNewFunction(functionName)
    local playerNewFunctionList = PlayerNewFunctionModel.new()
    if playerNewFunctionList:IsOpend() then
        if  playerNewFunctionList:CheckFirstEnterScene(functionName) then 
            clr.coroutine(function()
                local response = req.setEnterSenceList(functionName, 2)
                if api.success(response) then
                    playerNewFunctionList:SetWithProtocol(response.val, functionName)
                end
            end)
        end
    end
end

function HomeMenuBarCtrl:InitView(playerInfoModel)
    if playerInfoModel then
        self.playerInfoModel = playerInfoModel
    end
    self.menuBarView:InitView(self.playerInfoModel)
end

return HomeMenuBarCtrl

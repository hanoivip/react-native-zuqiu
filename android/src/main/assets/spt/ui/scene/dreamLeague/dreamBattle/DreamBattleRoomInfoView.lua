local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DreamLeagueRoom = require("data.DreamLeagueRoom")

local DreamBattleRoomInfoView = class(unity.base)

function DreamBattleRoomInfoView:ctor()
    self.allTxt = self.___ex.allTxt
    self.closeBtn = self.___ex.closeBtn
    self.contentRect = self.___ex.contentRect
    self.enterBtn = self.___ex.enterBtn
    self.settingBtn = self.___ex.settingBtn
    self.minBetTxt = self.___ex.minBetTxt
    self.enterBtnGradient = self.___ex.enterBtnGradient
    self.settingBtnGradient = self.___ex.settingBtnGradient
    self.enterButton = self.___ex.enterButton
    self.settingButton = self.___ex.settingButton

    self.itemPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamBattle/DreamBattleRoomInfoItem.prefab"
end

function DreamBattleRoomInfoView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.enterBtn:regOnButtonClick(function ()
        if self.onEnterBtnClick then
            self.onEnterBtnClick()
        end
    end)
    self.settingBtn:regOnButtonClick(function ()
        if self.onSettingBtnClick then
            self.onSettingBtnClick()
        end
    end)

    DialogAnimation.Appear(self.transform, nil)
end

function DreamBattleRoomInfoView:InitSubSpt(playerInfo, roomMaxCount, id)
    self.sptList = {}
    local childCount = self.contentRect.childCount
    for i=0,childCount-1 do
        table.insert(self.sptList, self.contentRect:GetChild(i):GetComponent(CapsUnityLuaBehav))
    end

    for k, v in pairs(self.sptList) do
        if playerInfo and playerInfo[k] then
            v:InitView(playerInfo and playerInfo[k], id)
        end
    end

    if #self.sptList > roomMaxCount then
        for i=roomMaxCount+1, #self.sptList do
            GameObjectHelper.FastSetActive(self.sptList[i].gameObject, false)
        end
    end
end

function DreamBattleRoomInfoView:InitView(dreamBattleRoomInfoModel, isHistory)
    local totalFee = dreamBattleRoomInfoModel:GetTotalFee()
    local roomId = dreamBattleRoomInfoModel:GetRoomId()
    local playerList = dreamBattleRoomInfoModel:GetHasEnterdPlayerList()
    local id = dreamBattleRoomInfoModel:GetServerSetUpId()
    local selfInRoom = dreamBattleRoomInfoModel:GetIsSelfInRoom()
    local roomMaxCount = DreamLeagueRoom[tostring(roomId)].maxPeople

    self.allTxt.text = lang.trans("dream_all_bet", totalFee or 0)
    self.minBetTxt.text = lang.trans("dream_min_bet_1", DreamLeagueRoom[tostring(roomId)].fee[1])
    self:InitSubSpt(playerList, roomMaxCount, id)
    GameObjectHelper.FastSetActive(self.enterBtn.gameObject, not isHistory)
    GameObjectHelper.FastSetActive(self.settingBtn.gameObject, not isHistory)
    self.enterBtnGradient.enabled = not selfInRoom
    self.settingBtnGradient.enabled = not selfInRoom
    self.enterButton.interactable = not selfInRoom
    self.settingButton.interactable = not selfInRoom
end

function DreamBattleRoomInfoView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            cache.setTheTableOfDcidsWhenCreateDreamRoom()
            self.closeDialog()
        end)
    end
end

return DreamBattleRoomInfoView

local AssetFinder = require("ui.common.AssetFinder")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DreamLeagueRoom = require("data.DreamLeagueRoom")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local DreamBattleRoomJoinView = class(unity.base)

function DreamBattleRoomJoinView:ctor()
    self.allTxt = self.___ex.allTxt
    self.closeBtn = self.___ex.closeBtn
    self.contentRect = self.___ex.contentRect
    self.createBtn = self.___ex.createBtn
    self.settingBtn = self.___ex.settingBtn
    self.minBetTxt = self.___ex.minBetTxt
end

function DreamBattleRoomJoinView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.createBtn:regOnButtonClick(function ()
        if self.onCreateBtnClick then
            self.onCreateBtnClick()
        end
    end)
    self.settingBtn:regOnButtonClick(function ()
        if self.onSettingBtnClick then
            self.onSettingBtnClick()
        end
    end)

    DialogAnimation.Appear(self.transform, nil)
end

function DreamBattleRoomJoinView:InitView(roomId)
    self.minBetTxt.text = lang.trans("dream_min_bet_1", DreamLeagueRoom[tostring(roomId)].fee[1])
    local roomMaxCount = DreamLeagueRoom[tostring(roomId)].maxPeople
    self:InitSubContent(roomMaxCount)
end

function DreamBattleRoomJoinView:InitSubContent(maxCount)
    local childCount = self.contentRect.childCount
    for i=maxCount, childCount-1 do
        GameObjectHelper.FastSetActive(self.contentRect:GetChild(i).gameObject, false)
    end
end

function DreamBattleRoomJoinView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            cache.setTheTableOfDcidsWhenCreateDreamRoom()
            self.closeDialog()
        end)
    end
end

return DreamBattleRoomJoinView

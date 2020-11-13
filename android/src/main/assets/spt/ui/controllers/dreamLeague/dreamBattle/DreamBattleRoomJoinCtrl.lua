local DreamBattleMainModel = require("ui.models.dreamLeague.dreamBattle.DreamBattleMainModel")
local DreamPlayerChooseModel = require("ui.models.dreamLeague.dreamHall.DreamPlayerChooseModel")
local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local PlayerDreamCardsMapModel = require("ui.models.dreamLeague.PlayerDreamCardsMapModel")
local DialogManager = require("ui.control.manager.DialogManager")
local DreamLeagueRoom = require("data.DreamLeagueRoom")
local DreamConstants = require("ui.scene.dreamLeague.dreamMain.DreamConstants")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local BaseCtrl = require("ui.controllers.BaseCtrl")

local DreamBattleRoomJoinCtrl = class(BaseCtrl)

DreamBattleRoomJoinCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

DreamBattleRoomJoinCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamBattle/DreamBattleJoin.prefab"

function DreamBattleRoomJoinCtrl:Init(nationList, matchId, roomId, usedDcids)
    self.nationList = nationList
    self.matchId = matchId
    self.roomId = roomId
    self.usedDcids = usedDcids
    self.playerDreamCardsMapModel = PlayerDreamCardsMapModel.new()
end

function DreamBattleRoomJoinCtrl:Refresh()
    DreamBattleRoomJoinCtrl.super.Refresh(self)
    self:InitView()
end

function DreamBattleRoomJoinCtrl:InitView()
    self.view.onCreateBtnClick = function () self:OnCreateBtnClick() end
    self.view.onSettingBtnClick = function () self:OnSettingBtnClick() end
    self.view:InitView(self.roomId)
end

function DreamBattleRoomJoinCtrl:OnCreateBtnClick()
    local function confirmCreate()
        clr.coroutine(function ()
            local dcids = cache.getTheTableOfDcidsWhenCreateDreamRoom()
            local response = req.dreamLeagueRoomCreate(self.matchId, self.roomId, dcids)
            if api.success(response) then
                local data = response.val
                if data.cost.type == "dc" then
                    PlayerInfoModel.new():SetDreamCoin(data.cost.curr_num)
                end
                -- 需要给进房间的人上锁
                for k, v in pairs(dcids) do
                    self.playerDreamCardsMapModel:ResetCardLock(v, DreamConstants.DreamCardLockState.SYSTEM_LOCK)
                end
                EventSystem.SendEvent("Dream_Battle_Refresh")
                self.view:Close()
            end
        end)
    end

    DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("dream_create_room_pay", DreamLeagueRoom[tostring(self.roomId)].fee[1]), function ()
        confirmCreate()
    end)
end

function DreamBattleRoomJoinCtrl:OnSettingBtnClick()
    local allDcids = self.playerDreamCardsMapModel:GetCardList()
    local usedDcids = self.usedDcids

    local function isUsedDcids(dcid)
        for k, v in pairs(usedDcids or {}) do
            if tonumber(dcid) == tonumber(v) then return true end
        end
    end

    local partNationDcids = {}
    
    for i,v in ipairs(allDcids) do
        local dreamLeagueCardModel = DreamLeagueCardModel.new(v)
        local nation = dreamLeagueCardModel:GetNation()
        if self.nationList[nation] and not isUsedDcids(v) then
            table.insert(partNationDcids, v)
        end
    end

    local function popToThisScene()
        --因为深入了3层，所以往上捣3层即可回到本界面
        res.PopAppointSceneImmediate(3)
    end

    local dreamPlayerChooseModel = DreamPlayerChooseModel.new(nil, partNationDcids, self.nationList)
    local teamData = cache.getTheTableOfDcidsWhenCreateDreamRoom()
    if teamData then
        self:SetTeamData(dreamPlayerChooseModel, teamData)
    end
    res.PushDialog("ui.controllers.dreamLeague.dreamHall.DreamPlayerChooseCtrl", dreamPlayerChooseModel, function (selectDcid)
        if not selectDcid then
            DialogManager.ShowToastByLang("dream_no_select_dream_card")
            return
        end
        local dcidsList = cache.getTheTableOfDcidsWhenCreateDreamRoom()
        if not dcidsList then
            dcidsList = {}
            table.insert(dcidsList, selectDcid)
            cache.setTheTableOfDcidsWhenCreateDreamRoom(dcidsList)
            self:SetTeamData(dreamPlayerChooseModel, dcidsList)
            popToThisScene()
            return
        end

        if #dcidsList >= 3 then
            popToThisScene()
            DialogManager.ShowToast(lang.trans("dream_the_player_max_count"))
        else
            local isSelected = false
            local selectCardName = DreamLeagueCardModel.new(selectDcid):GetCardName()
            for k, v in ipairs(dcidsList) do
                if DreamLeagueCardModel.new(v):GetCardName() == selectCardName then
                    isSelected = true
                end
            end

            if not isSelected then
                table.insert(dcidsList, selectDcid)
                cache.setTheTableOfDcidsWhenCreateDreamRoom(dcidsList)
                self:SetTeamData(dreamPlayerChooseModel, dcidsList)
                popToThisScene()
            else
                popToThisScene()
                DialogManager.ShowToast(lang.trans("dream_the_player_has_enter"))
            end
        end
    end)
end

-- 设置已经选择了的球员，格式如下(为了使用DreamPlayerChooseModel)
-- team = {dcid = {dcid = xxx, dreamCardId = xxx, position = xxx}}
function DreamBattleRoomJoinCtrl:SetTeamData(dreamPlayerChooseModel, dcids)
    local teamData = {}
    for k, v in pairs(dcids) do
        local teamDataSub = {}
        teamDataSub.dcid = v
        teamDataSub.dreamCardId = self.playerDreamCardsMapModel:GetCardData(v).dreamCardId
        teamDataSub.position = DreamLeagueCardModel.new(v):GetPostionType()
        table.insert(teamData, teamDataSub)
    end
    dreamPlayerChooseModel:SetPlayerData(teamData)
end

function DreamBattleRoomJoinCtrl:GetStatusData()
    return self.nationList, self.matchId, self.roomId
end

return DreamBattleRoomJoinCtrl
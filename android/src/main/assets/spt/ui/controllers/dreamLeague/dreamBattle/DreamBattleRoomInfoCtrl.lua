local DreamPlayerChooseModel = require("ui.models.dreamLeague.dreamHall.DreamPlayerChooseModel")
local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local PlayerDreamCardsMapModel = require("ui.models.dreamLeague.PlayerDreamCardsMapModel")
local DialogManager = require("ui.control.manager.DialogManager")
local DreamLeagueRoom = require("data.DreamLeagueRoom")
local DreamConstants = require("ui.scene.dreamLeague.dreamMain.DreamConstants")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DreamBattleRoomInfoModel = require("ui.models.dreamLeague.dreamBattle.DreamBattleRoomInfoModel")

local BaseCtrl = require("ui.controllers.BaseCtrl")

local DreamBattleRoomInfoCtrl = class(BaseCtrl)

DreamBattleRoomInfoCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

DreamBattleRoomInfoCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamBattle/DreamBattleRoomInfo.prefab"

-- 历史记录界面不显示布阵和进入按钮
function DreamBattleRoomInfoCtrl:AheadRequest(roomData, isHistory)
    self.roomData = roomData
    self.isHistory = isHistory

    local response = req.dreamLeagueRoomInfo(roomData.id)
    if api.success(response) then
        local data = response.val
        self.data = data
        self.dreamBattleRoomInfoModel = DreamBattleRoomInfoModel.new()
        self.dreamBattleRoomInfoModel:InitWithProtocol(data, roomData)
    end
end

function DreamBattleRoomInfoCtrl:Init()
    self.playerDreamCardsMapModel = PlayerDreamCardsMapModel.new()
end

function DreamBattleRoomInfoCtrl:Refresh(roomData, isHistory, dreamBattleRoomInfoModel)
    DreamBattleRoomInfoCtrl.super.Refresh(self)

    self.view.onEnterBtnClick = function () self:OnEnterBtnClick() end
    self.view.onSettingBtnClick = function () self:OnSettingBtnClick() end
    self.view:InitView(dreamBattleRoomInfoModel or self.dreamBattleRoomInfoModel, self.isHistory)
end

function DreamBattleRoomInfoCtrl:OnSettingBtnClick()
    if self.dreamBattleRoomInfoModel:GetIsSelfInRoom() then
        return
    end
    local allDcids = self.playerDreamCardsMapModel:GetCardList()
    local nationList = self.dreamBattleRoomInfoModel:GetNationList()
    local usedDcids = self.dreamBattleRoomInfoModel:GetUsedDcids()

    local function isUsedDcids(dcid)
        for k, v in pairs(usedDcids) do
            if tonumber(dcid) == tonumber(v) then return true end
        end
    end

    local partNationDcids = {}
    for i,v in ipairs(allDcids) do
        local dreamLeagueCardModel = DreamLeagueCardModel.new(v)
        local nation = dreamLeagueCardModel:GetNation()
        if nationList[nation] and not isUsedDcids(v) then
            table.insert(partNationDcids, v)
        end
    end

    local function popToThisScene()
        --因为深入了3层，所以往上捣3层即可回到本界面
        res.PopAppointSceneImmediate(3)
    end

    local dreamPlayerChooseModel = DreamPlayerChooseModel.new(nil, partNationDcids, nationList)
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

function DreamBattleRoomInfoCtrl:GetStatusData()
    return self.roomData, self.isHistory, self.dreamBattleRoomInfoModel
end

-- 设置已经选择了的球员，格式如下(为了使用DreamPlayerChooseModel)
-- team = {dcid = {dcid = xxx, dreamCardId = xxx, position = xxx}}
function DreamBattleRoomInfoCtrl:SetTeamData(dreamPlayerChooseModel, dcids)
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

function DreamBattleRoomInfoCtrl:OnEnterBtnClick()
    if self.dreamBattleRoomInfoModel:GetIsSelfInRoom() then
        return
    end


    local id = self.dreamBattleRoomInfoModel:GetServerSetUpId()
    local function confirmEnterRoom()
        clr.coroutine(function ()
            local dcids = cache.getTheTableOfDcidsWhenCreateDreamRoom()
            local response = req.dreamLeagueRoomJoin(id, dcids)
            if api.success(response) then
                local data = response.val
                if data.cost.type == "dc" then
                    PlayerInfoModel.new():SetDreamCoin(data.cost.curr_num)
                end
                -- 需要给进房间的人上锁
                for k, v in pairs(dcids) do
                    self.playerDreamCardsMapModel:ResetCardLock(v, DreamConstants.DreamCardLockState.SYSTEM_LOCK)
                end
                cache.setTheTableOfDcidsWhenCreateDreamRoom()
                EventSystem.SendEvent("Dream_Battle_Refresh")
                response = req.dreamLeagueRoomInfo(id)
                if api.success(response) then
                    self.data = response.val
                    EventSystem.SendEvent("Dream_Battle_Refresh")
                    self.dreamBattleRoomInfoModel:InitWithProtocol(self.data, self.roomData)
                    self.view:InitView(self.dreamBattleRoomInfoModel, self.isHistory)
                end
            end
        end)
    end

    local haveEnterCount = self.dreamBattleRoomInfoModel:GetHasEnterCount()
    local roomId = self.dreamBattleRoomInfoModel:GetRoomId()
    local feeList = DreamLeagueRoom[tostring(roomId)].fee
    local enterPrice = feeList[haveEnterCount + 1]

    -- 房间人数已满
    if not enterPrice then
        DialogManager.ShowToast(lang.trans("dream_room_full_count"))
        return
    end

    DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("dream_join_room_pay", enterPrice), function ()
        confirmEnterRoom()
    end)
end

return DreamBattleRoomInfoCtrl
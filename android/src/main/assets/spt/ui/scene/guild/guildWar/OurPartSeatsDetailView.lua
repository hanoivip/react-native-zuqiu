local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local OurPartSeatsDetailView = class(unity.base)

function OurPartSeatsDetailView:ctor()
    self.scrollRect = self.___ex.scrollRect
    self.closeBtn = self.___ex.closeBtn
    self.challengeBtn = self.___ex.challengeBtn
    self.changeBtn = self.___ex.changeBtn
    self.disableBtn = self.___ex.disableBtn
    self.detailBtn = self.___ex.detailBtn
    self.disableTxt = self.___ex.disableTxt
    self.challengeTxt = self.___ex.challengeTxt
    self.iconImg = self.___ex.iconImg
    self.nameTxt = self.___ex.nameTxt
    self.stateTxt = self.___ex.stateTxt
    self.finish = self.___ex.finish
    self.lvlTxt = self.___ex.lvlTxt
    self.timeTxt = self.___ex.timeTxt
    self.titleTxt = self.___ex.titleTxt
    self.empty = self.___ex.empty
    self.noEmpty = self.___ex.noEmpty
    self.tip = self.___ex.tip
end

function OurPartSeatsDetailView:InitView(data, guildData, isAttackPage)
    self.index = guildData.index
    if isAttackPage then
        self:InitAttackView(data, guildData)
    else
        self:InitDefenseView(data, guildData)
    end
    self.transform.gameObject:SetActive(true)
    DialogAnimation.Appear(self.transform, nil)
    self:InitScrollView(data.record, isAttackPage)
    self:RegOnBtn()
end

function OurPartSeatsDetailView:InitAttackView(data, guildData)
    self.stateTxt.text = lang.trans("guild_seats_1", data.detail.seizeCnt)
    self.timeTxt.text = lang.trans("guild_seats_2", guildData.countLimit - guildData.warCnt, guildData.countLimit)
    if not guildData.isSeized and guildData.warCnt < guildData.countLimit then
        GameObjectHelper.FastSetActive(self.challengeBtn.gameObject, true)
    elseif guildData.isSeized or guildData.warCnt >= guildData.countLimit then
        GameObjectHelper.FastSetActive(self.disableBtn.gameObject, true)
        self.disableTxt.text = lang.trans("guild_challenge")
        if guildData.isSeized then
            self.timeTxt.text = lang.trans("guild_seats_2", 0, guildData.countLimit)
        end
    end

    GameObjectHelper.FastSetActive(self.iconImg.gameObject, true)
    GameObjectHelper.FastSetActive(self.finish, guildData.seizeCnt >= 2)
    GameObjectHelper.FastSetActive(self.detailBtn.gameObject, self:IsHasAttackTwoTime(data.record))
    GameObjectHelper.FastSetActive(self.tip, not self:IsHasAttackTwoTime(data.record))

    -- 席位为空
    if not guildData.name then
        GameObjectHelper.FastSetActive(self.empty, true)
        GameObjectHelper.FastSetActive(self.noEmpty, false)
        return
    end

    -- 席位不为空才需设置的数据
    self.nameTxt.text = guildData.name
    self.lvlTxt.text = "LV" .. tostring(guildData.level)
    TeamLogoCtrl.BuildTeamLogo(self.iconImg, guildData.logo)
end

function OurPartSeatsDetailView:InitDefenseView(data, guildData)
    if guildData.hasAuthority then
        if tonumber(data.deployCnt) >= tonumber(data.deployLimit) then
            GameObjectHelper.FastSetActive(self.disableBtn.gameObject, true)
            self.disableTxt.text = lang.trans("guild_change")
        else
            GameObjectHelper.FastSetActive(self.changeBtn.gameObject, true)
        end
    else
        GameObjectHelper.FastSetActive(self.timeTxt.gameObject, false)
    end

    GameObjectHelper.FastSetActive(self.finish, tonumber(guildData.seizeCnt) >= 2)
    self.titleTxt.text = lang.trans("guild_tile")
    self.stateTxt.text = lang.trans("guild_seats_1", guildData.seizeCnt)
    self.timeTxt.text = lang.trans("guild_seats_2", data.deployLimit - data.deployCnt, data.deployLimit)

    -- 席位为空
    if not guildData.name then
        GameObjectHelper.FastSetActive(self.empty, true)
        GameObjectHelper.FastSetActive(self.noEmpty, false)
        return
    end

    TeamLogoCtrl.BuildTeamLogo(self.iconImg, guildData.logo)
    self.nameTxt.text = guildData.name
    self.lvlTxt.text = "LV" .. tostring(guildData.level)
end

function OurPartSeatsDetailView:InitScrollView(record, isAttackPage)

    local function resetRecordData(record)
        local recordSorted = {}
        for k, v in pairs(record) do
            table.insert(recordSorted, v)
        end

        return recordSorted
    end

    record = resetRecordData(record)

    self.scrollRect:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/OurPartSeatsDetailItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.scrollRect:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        spt:Init(data, isAttackPage)
        spt.onView = function ()
            clr.coroutine(function()
                local respone = req.viewGuildWarVideo(data.v_id)
                if api.success(respone) then
                    local ReplayCheckHelper = require("coregame.ReplayCheckHelper")
                    ReplayCheckHelper.StartReplay(respone.val, data.v_id)
                end
            end)
        end
        scrollSelf:updateItemIndex(spt, index)
    end)

    self.scrollRect:refresh(record)
end

function OurPartSeatsDetailView:RegOnBtn()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)

    self.challengeBtn:regOnButtonClick(function ()
        if type(self.onClickChallengeBtn) == "function" then
            self.onClickChallengeBtn(self.index)
        end
    end)

    self.changeBtn:regOnButtonClick(function ()
        if type(self.onClickChangeBtn) == "function" then
            self.onClickChangeBtn()
        end
    end)

    self.detailBtn:regOnButtonClick(function()
        if type(self.onClickDetailBtn) == "function" then
            self.onClickDetailBtn()
        end
    end)
end

function OurPartSeatsDetailView:IsHasAttackTwoTime(record)
    local record = clone(record)
    local time = 0
    for k, v in pairs(record) do
        if v.genre == 4 or v.genre == 1 then
            time = time + 1
        end
    end

    return time >= 2
end

function OurPartSeatsDetailView:OnEnterScene()
end

function OurPartSeatsDetailView:OnExitScene()
end

function OurPartSeatsDetailView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return OurPartSeatsDetailView

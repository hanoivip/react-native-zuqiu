local GuildDataShowModel = require("ui.models.guild.guildWar.GuildDataShowModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GuildMistDataShowView = class(unity.base)

function GuildMistDataShowView:ctor()
    self.menuGroup = self.___ex.menuGroup
    self.bar = self.___ex.bar
    self.rankScroll = self.___ex.rankScroll
    self.myWarScroll = self.___ex.myWarScroll
    self.scheduleScroll = self.___ex.scheduleScroll
    self.myWarContent = self.___ex.myWarContent
    self.rankContent = self.___ex.rankContent
    self.scheduleContent = self.___ex.scheduleContent
    self.titleTxt = self.___ex.titleTxt
    self.closeBtn = self.___ex.closeBtn

    DialogAnimation.Appear(self.transform, nil)
end

function GuildMistDataShowView:InitView(guildDataShowModel, guildMistWarMainModel)
    self.model = guildDataShowModel
    self.titleTxt.text = lang.transstr("mist_index_data", self.model:GetPeriod())
    self:InitScrollView(self.model, guildMistWarMainModel)
    self:RegOnBtn()
end

function GuildMistDataShowView:RegOnBtn()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function GuildMistDataShowView:InitScrollView(model, guildMistWarMainModel)
    local round = model:GetRound()
    local rankData = model:GetRankData()
    local gid = guildMistWarMainModel:GetGid()
    local scheduleDataConsolidated = model:GetScheduleDataConsolidated()
    local warScheduleData = model:GetMyWarScheduleDataByGid(gid)
    self:InitRankScrollView(rankData, guildMistWarMainModel)
    self:InitMyWarScrollView(warScheduleData, round, guildMistWarMainModel)
    self:InitScheduleScrollView(scheduleDataConsolidated, gid)
end

function GuildMistDataShowView:InitRankScrollView(data, guildMistWarMainModel)
    self.rankScroll:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistDataShowRankItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.rankScroll:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        data.rank = index
        data.name = self.model:GetGuildNameById(data.gid)
        data.round = self.model:GetRound()
        -- init
        local gid = guildMistWarMainModel:GetGid()
        spt:Init(data, gid == data.gid)
        scrollSelf:updateItemIndex(spt, index)
    end)

    self.rankScroll:refresh(data)
end

function GuildMistDataShowView:InitMyWarScrollView(data, maxFinishedRound, guildMistWarMainModel)
    self.myWarScroll:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistMyWarItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    local state = tonumber(guildMistWarMainModel:GetWarState())
    self.myWarScroll:regOnResetItem(function (scrollSelf, spt, index)
        local dataItem = scrollSelf.itemDatas[index]
        --local storeBtnState = state == 30
        local storePath = "ui.controllers.guild.guildMistWar.GuildMistWarBuffStoreCtrl"
        spt:Init(dataItem, maxFinishedRound)
        --spt:IsShowBuffStore(storeBtnState)
        spt.onBuyAtkBuffBtnClick = function()
            res.PushDialog(storePath, guildMistWarMainModel, dataItem.round)
        end
        spt.onBuyDefBuffBtnClick = function()
            res.PushDialog(storePath, guildMistWarMainModel, dataItem.round)
        end
        spt.onChangeMapBtnClick = function()
            self.changeMapClick(dataItem)
        end
        scrollSelf:updateItemIndex(spt, index)
    end)

    self.myWarScroll:refresh(data)
end

function GuildMistDataShowView:InitScheduleScrollView(data, myGid)
    self.scheduleScroll:InitView(data, myGid)
end

function GuildMistDataShowView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function GuildMistDataShowView:InitMyWarView()
    self.menuGroup:selectMenuItem(GuildDataShowModel.MenuTags.MYWAR)
    GameObjectHelper.FastSetActive(self.rankContent, false)
    GameObjectHelper.FastSetActive(self.scheduleContent, false)
    GameObjectHelper.FastSetActive(self.myWarContent, true)
    GameObjectHelper.FastSetActive(self.bar, false)
end

function GuildMistDataShowView:InitRankView()
    self.menuGroup:selectMenuItem(GuildDataShowModel.MenuTags.GUILDWARRANK)
    GameObjectHelper.FastSetActive(self.bar, true)
    GameObjectHelper.FastSetActive(self.rankContent, true)
    GameObjectHelper.FastSetActive(self.myWarContent, false)
    GameObjectHelper.FastSetActive(self.scheduleContent, false)

end

function GuildMistDataShowView:InitGuildWarView()
    self.menuGroup:selectMenuItem(GuildDataShowModel.MenuTags.GUILDWAR)
    GameObjectHelper.FastSetActive(self.bar, false)
    GameObjectHelper.FastSetActive(self.rankContent, false)
    GameObjectHelper.FastSetActive(self.myWarContent, false)
    GameObjectHelper.FastSetActive(self.scheduleContent, true)
end

function GuildMistDataShowView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return GuildMistDataShowView

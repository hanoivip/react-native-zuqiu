local GuildDataShowModel = require("ui.models.guild.guildWar.GuildDataShowModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GuildDataShowView = class(unity.base)

function GuildDataShowView:ctor()
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

function GuildDataShowView:InitView(model, attackOrDefenseModel)
    self.model = model
    self.titleTxt.text = lang.transstr("guild_index_data", model:GetPeriod())
    self:InitScrollView(model, attackOrDefenseModel)
    self:RegOnBtn()
end

function GuildDataShowView:RegOnBtn()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function GuildDataShowView:InitScrollView(model, attackOrDefenseModel)
    self:InitRankScrollView(model:GetRankData(), attackOrDefenseModel)
    self:InitMyWarScrollView(model:GetMyWarScheduleDataByGid(attackOrDefenseModel:GetGid()), model:GetRound(), attackOrDefenseModel)
    self:InitScheduleScrollView(model:GetScheduleDataConsolidated(), attackOrDefenseModel:GetGid())
end

function GuildDataShowView:InitRankScrollView(data, attackOrDefenseModel)
    self.rankScroll:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildDataShowRankItem.prefab"
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
        spt:Init(data, attackOrDefenseModel:GetGid() == data.gid)
        scrollSelf:updateItemIndex(spt, index)
    end)

    self.rankScroll:refresh(data)
end

function GuildDataShowView:InitMyWarScrollView(data, maxFinishedRound, attackOrDefenseModel)
    self.myWarScroll:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/MyWarItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.myWarScroll:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        spt:Init(data, maxFinishedRound)
        spt:IsShowBuffStore(tonumber(attackOrDefenseModel:GetState()) == 30 or tonumber(attackOrDefenseModel:GetState()) == 40)
        spt.onBuyAtkBuffBtnClick = function ()
            res.PushDialog("ui.controllers.guild.guildWar.GuildBuffStoreCtrl", attackOrDefenseModel, true, data.round)
        end
        spt.onBuyDefBuffBtnClick = function ()
            res.PushDialog("ui.controllers.guild.guildWar.GuildBuffStoreCtrl", attackOrDefenseModel, false, data.round)
        end
        scrollSelf:updateItemIndex(spt, index)
    end)

    self.myWarScroll:refresh(data)
end

function GuildDataShowView:InitScheduleScrollView(data, myGid)
    self.scheduleScroll:InitView(data, myGid)
end

function GuildDataShowView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function GuildDataShowView:InitMyWarView()
    self.menuGroup:selectMenuItem(GuildDataShowModel.MenuTags.MYWAR)
    GameObjectHelper.FastSetActive(self.rankContent, false)
    GameObjectHelper.FastSetActive(self.scheduleContent, false)
    GameObjectHelper.FastSetActive(self.myWarContent, true)
    GameObjectHelper.FastSetActive(self.bar, false)
end

function GuildDataShowView:InitRankView()
    self.menuGroup:selectMenuItem(GuildDataShowModel.MenuTags.GUILDWARRANK)
    GameObjectHelper.FastSetActive(self.bar, true)
    GameObjectHelper.FastSetActive(self.rankContent, true)
    GameObjectHelper.FastSetActive(self.myWarContent, false)
    GameObjectHelper.FastSetActive(self.scheduleContent, false)

end

function GuildDataShowView:InitGuildWarView()
    self.menuGroup:selectMenuItem(GuildDataShowModel.MenuTags.GUILDWAR)
    GameObjectHelper.FastSetActive(self.bar, false)
    GameObjectHelper.FastSetActive(self.rankContent, false)
    GameObjectHelper.FastSetActive(self.myWarContent, false)
    GameObjectHelper.FastSetActive(self.scheduleContent, true)
end

function GuildDataShowView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return GuildDataShowView
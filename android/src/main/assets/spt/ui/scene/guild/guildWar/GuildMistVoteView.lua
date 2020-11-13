local Object = clr.UnityEngine.Object
local GuildWar = require("data.GuildWar")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local GuildWarType = require("ui.models.guild.guildMistWar.GuildWarType")

local GuildMistVoteView = class(unity.base)

function GuildMistVoteView:ctor()
--------Start_Auto_Generate--------
    self.infoBarSpt = self.___ex.infoBarSpt
    self.voteListTrans = self.___ex.voteListTrans
    self.tipTxt = self.___ex.tipTxt
    self.donateNumTxt = self.___ex.donateNumTxt
    self.detailBtn = self.___ex.detailBtn
--------End_Auto_Generate----------
end

function GuildMistVoteView:RegOnDynamicLoad(func)
    self.infoBarSpt:RegOnDynamicLoad(func)
end

function GuildMistVoteView:start()
    self.infoBarSpt:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PopScene()
        end)
    end)
    self.detailBtn:regOnButtonClick(function()
        self:OnDetailBtnClick()
    end)
end

function GuildMistVoteView:InitView(guildMistVoteModel)
    self.model = guildMistVoteModel
    local totalCount = self.model:GetTotalCount()
    local remainCount = self.model:GetRemainCount()
    local cumulativeDay = self.model:GetCumulativeDay()
    self.tipTxt.text = lang.trans("mist_vote_tip", totalCount, remainCount)
    self.donateNumTxt.text = "x" .. cumulativeDay
    self:RefreshScroll()
end

function GuildMistVoteView:RefreshScroll()
    local voteList = self.model:GetVotList()
    res.ClearChildren(self.voteListTrans)
    local voteItemRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistVoteItem.prefab")
    for i, v in ipairs(voteList) do
        local obj = Object.Instantiate(voteItemRes)
        obj.transform:SetParent(self.voteListTrans, false)
        local objScript = obj:GetComponent("CapsUnityLuaBehav")
        objScript:InitView(v, self.applyVote)
    end
end

function GuildMistVoteView:OnDetailBtnClick()
    local content = lang.transstr("mist_rule5")
    local mistData = {}
    for i, v in pairs(GuildWar) do
        if v.type == GuildWarType.Mist then
            table.insert(mistData, clone(v))
        end
    end
    table.sort(mistData, function(a, b) return a.minLevel < b.minLevel end)
    for i, v in ipairs(mistData) do
        local minLevel = v.minLevel
        local guildScoreMax = v.guildScoreMax
        content = content .. lang.transstr("mist_rule6", minLevel, guildScoreMax)
    end
    local title = lang.trans("tips")
    local prefabPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarDescBoard.prefab"
    local resDlg, dialogcomp = res.ShowDialog(prefabPath, "camera", true, true)
    dialogcomp.contentcomp:InitView(title, content)
end

return GuildMistVoteView

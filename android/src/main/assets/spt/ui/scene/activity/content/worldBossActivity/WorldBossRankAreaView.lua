local GameObjectHelper = require("ui.common.GameObjectHelper")

local WorldBossRankAreaView = class(unity.base)

function WorldBossRankAreaView:ctor()
    self.mRankBar = self.___ex.mRankBar
    self.worldView = self.___ex.worldView
    self.singleView = self.___ex.singleView
    self.singleNames = self.___ex.singleNames
    self.singleScores = self.___ex.singleScores
    self.worldNames = self.___ex.worldNames
    self.worldScores = self.___ex.worldScores
end

function WorldBossRankAreaView:start()
    self.worldView:regOnButtonClick(function()
        self:OnWorldViewBtnClick()
    end)
    self.singleView:regOnButtonClick(function()
        self:OnSingleViewBtnClick()
    end)
end

function WorldBossRankAreaView:OnWorldViewBtnClick()
    res.PushDialog("ui.controllers.activity.content.worldBossActivity.WorldBossRankCtrl", false)
end

function WorldBossRankAreaView:OnSingleViewBtnClick()
    res.PushDialog("ui.controllers.activity.content.worldBossActivity.WorldBossRankCtrl", true)
end

function WorldBossRankAreaView:InitView(itemData)
    self.itemData = itemData
    itemData.playerRank = (not itemData.playerRank or itemData.playerRank == 0) and lang.transstr("train_rankOut") or itemData.playerRank
    itemData.serverRank = (not itemData.playerRank or itemData.serverRank == 0) and lang.transstr("train_rankOut") or itemData.serverRank
    local strs = {}
    strs[1] = "<color=#4a2b2c>"
    strs[2] = lang.transstr("worldBossActivity_single_rank")
    strs[3] = "：</color><color=#8e0000>"
    strs[4] = itemData.playerRank
    strs[5] = "</color>   <color=#4a2b2c>"
    strs[6] = lang.transstr("worldBossActivity_world_rank")
    strs[7] = "：</color><color=#8e0000>"
    strs[8] = itemData.serverRank
    strs[9] = "</color>"
    strs = table.concat(strs)
    self.mRankBar.text = strs
    for k,v in pairs(self.singleNames) do
        v.text = itemData.playerSort[tonumber(k)] and itemData.playerSort[tonumber(k)].name or "——"
        self.singleScores[k].text = itemData.playerSort[tonumber(k)] and tostring(itemData.playerSort[tonumber(k)].score) or "——"
    end
    for k,v in pairs(self.worldNames) do
        v.text = itemData.serverSort[tonumber(k)] and itemData.serverSort[tonumber(k)].serverName or "——"
        self.worldScores[k].text = itemData.serverSort[tonumber(k)] and tostring(itemData.serverSort[tonumber(k)].score) or "——"
    end
end

return WorldBossRankAreaView
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local DreamTeamHistoryView = class(unity.base)

function DreamTeamHistoryView:ctor()
    self.position = self.___ex.position
    self.btnGroupTrans = self.___ex.btnGroupTrans
    self.btnGroup = self.___ex.btnGroup
    self.score = self.___ex.score
    self.totalScore = self.___ex.totalScore
    self.closeBtn = self.___ex.closeBtn

    DialogAnimation.Appear(self.transform, nil)
end

function DreamTeamHistoryView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function DreamTeamHistoryView:InitView(dreamTeamHistoryModel)
    self.timeData = dreamTeamHistoryModel:GetTabData()
    local initTabFunc = function(spt, value, index)
        spt:InitView(value)
    end
    local callbackTabFunc = function(value, index)
        self:OnTabClick(value, index)
    end
    self.btnGroup:CreateMenuItems(self.timeData, initTabFunc, callbackTabFunc)
    if #self.timeData > 0 then
        self.btnGroup:selectMenuItem(1)
        self:OnTabClick(self.timeData[1], 1)
    end
end

function DreamTeamHistoryView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function DreamTeamHistoryView:OnTabClick(value, index)
    local matchTag = value.matchTag
    local allScore = {0, 0, 0, 0}
    for k,v in pairs(self.position) do
        res.ClearChildren(v)
    end
    local cardPrefabPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamTeamHistory/HistoryPlayerItem.prefab"
    for k,v in pairs(self.position) do
        GameObjectHelper.FastSetActive(v.parent.gameObject, false)
    end
    for k,v in pairs(value.team) do
        local position = v.position
        GameObjectHelper.FastSetActive(self.position[tostring(position)].parent.gameObject, true)
        v.score = v.score or 0
        local score = v.score
        allScore[position] = allScore[position] + score
        local obj, spt = res.Instantiate(cardPrefabPath)
        spt:InitView(v, matchTag, self.clickDetailCallBack)
        obj.transform:SetParent(self.position[tostring(position)], false)
    end
    totalScore = 0
    for k,v in ipairs(allScore) do
        self.score[tostring(k)].text = tostring(v)
        totalScore = totalScore + v
    end
    self.totalScore.text = tostring(totalScore)
end

return DreamTeamHistoryView

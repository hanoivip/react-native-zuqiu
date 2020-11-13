local UnityEngine = clr.UnityEngine
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local DreamHallHistoryView = class(unity.base, "DreamHallHistoryView")

function DreamHallHistoryView:ctor()
    self.score = self.___ex.score
    self.closeBtn = self.___ex.closeBtn
    self.menuGroup = self.___ex.menuGroup
    self.homeTxt = self.___ex.homeTxt
    self.homeTxt1 = self.___ex.homeTxt1
    self.awayTxt = self.___ex.awayTxt
    self.awayTxt1 = self.___ex.awayTxt1
    self.homeGrid = self.___ex.homeGrid
    self.awayGrid = self.___ex.awayGrid
    self.homeFixTitle = self.___ex.homeFixTitle
    self.awayFixTitle = self.___ex.awayFixTitle
end

function DreamHallHistoryView:start()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)

    self:RegMenuClick()
end

function DreamHallHistoryView:InitView(dreamHallHistoryModel)
    local homeName = dreamHallHistoryModel:GetHomeName()
    local awayName = dreamHallHistoryModel:GetAwayName()
    local score = dreamHallHistoryModel:GetScoreText()
    local homeData = dreamHallHistoryModel:GetHomeTeamData()
    local awayData = dreamHallHistoryModel:GetAwayTeamData()
    self.score.text = score
    self.homeTxt.text = homeName
    self.homeTxt1.text = homeName
    self.awayTxt.text = awayName
    self.awayTxt1.text = awayName
    self.homeGrid:InitView(homeData)
    self.awayGrid:InitView(awayData)

    self.menuGroup:selectMenuItem("homeNation")
end

function DreamHallHistoryView:RegMenuClick()
    self.menuGroup:BindMenuItem("homeNation", function ()
        GameObjectHelper.FastSetActive(self.homeGrid.gameObject, true)
        GameObjectHelper.FastSetActive(self.homeFixTitle.gameObject, true)
        GameObjectHelper.FastSetActive(self.awayGrid.gameObject, false)
        GameObjectHelper.FastSetActive(self.awayFixTitle.gameObject, false)
    end)
    self.menuGroup:BindMenuItem("awayNation", function ()
        GameObjectHelper.FastSetActive(self.homeGrid.gameObject, false)
        GameObjectHelper.FastSetActive(self.homeFixTitle.gameObject, false)
        GameObjectHelper.FastSetActive(self.awayGrid.gameObject, true)
        GameObjectHelper.FastSetActive(self.awayFixTitle.gameObject, true)
    end)
end

function DreamHallHistoryView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end


return DreamHallHistoryView
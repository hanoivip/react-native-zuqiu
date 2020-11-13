local GameObjectHelper = require("ui.common.GameObjectHelper")
local TeamLogoModifyView = class(unity.base)

function TeamLogoModifyView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.teamLogoArea = self.___ex.teamLogoArea
    self.saveBtn = self.___ex.saveBtn
    self.buttonGroup = self.___ex.buttonGroup
    self.logoBorderBtn = self.___ex.logoBorderBtn
    self.logoColorBtn = self.___ex.logoColorBtn
    self.logoIconBtn = self.___ex.logoIconBtn
    self.logoRibbonBtn = self.___ex.logoRibbonBtn
    self.borderScroll = self.___ex.borderScroll
    self.colorScroll = self.___ex.colorScroll
    self.iconScroll = self.___ex.iconScroll
    self.ribbonScroll = self.___ex.ribbonScroll
    self.colorScrollBar = self.___ex.colorScrollBar
end

function TeamLogoModifyView:GetScroll()
    return self.borderScroll, self.colorScroll, self.iconScroll, self.ribbonScroll
end

function TeamLogoModifyView:JudgeScrollBarVisibility(tag)
    GameObjectHelper.FastSetActive(self.colorScrollBar.gameObject, tag ~= "border")
end

function TeamLogoModifyView:ShowScrollArea(tag, data)
    GameObjectHelper.FastSetActive(self.borderScroll.gameObject, tag == "border")
    GameObjectHelper.FastSetActive(self.colorScroll.gameObject, tag == "color")
    GameObjectHelper.FastSetActive(self.iconScroll.gameObject, tag == "icon")
    GameObjectHelper.FastSetActive(self.ribbonScroll.gameObject, tag == "ribbon")
    if data then
        if tag == "border" then
            self.borderScroll:refresh(data)
        elseif tag == "color" then
            self.colorScroll:refresh(data)
        elseif tag == "icon" then
            self.iconScroll:refresh(data)
        elseif tag == "ribbon" then
            self.ribbonScroll:refresh(data)
        end
    end
end

function TeamLogoModifyView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function TeamLogoModifyView:SetTeamLogo(teamLogo)
    res.ClearChildren(self.teamLogoArea)
    teamLogo.transform:SetParent(self.teamLogoArea, false)
end

function TeamLogoModifyView:RegOnSave(func)
    self.saveBtn:regOnButtonClick(func)
end

function TeamLogoModifyView:RegOnMenuBorder(func)
    self.logoBorderBtn:regOnButtonClick(func)
end

function TeamLogoModifyView:RegOnMenuColor(func)
    self.logoColorBtn:regOnButtonClick(func)
end

function TeamLogoModifyView:RegOnMenuIcon(func)
    self.logoIconBtn:regOnButtonClick(func)
end

function TeamLogoModifyView:RegOnMenuRibbon(func)
    self.logoRibbonBtn:regOnButtonClick(func)
end

return TeamLogoModifyView

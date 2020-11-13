local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local GuildMistWarGuardDetailItemView = class(unity.base)

function GuildMistWarGuardDetailItemView:ctor()
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.teamLogo = self.___ex.teamLogo
    self.btnDetail = self.___ex.btnDetail
    self.btnChange = self.___ex.btnChange
    self.btnChangeText = self.___ex.btnChangeText
    self.power = self.___ex.power
    self.btnPlace = self.___ex.btnPlace
    self.btnPlaceText = self.___ex.btnPlaceText
    self.labelNoPlace = self.___ex.labelNoPlace
    self.labelPlace = self.___ex.labelPlace
    self.animator = self.___ex.animator
end

function GuildMistWarGuardDetailItemView:start()
    self.btnDetail:regOnButtonClick(function() 
        if type(self.onViewDetail) == "function" then
            self.onViewDetail()
        end
    end)
    self.btnPlace:regOnButtonClick(function()
        if type(self.onBtnPlaceClick) == "function" then
            self.onBtnPlaceClick()
        end
    end)
    self.btnChange:regOnButtonClick(function()
        if type(self.onBtnChangeClick) == "function" then
            self.onBtnChangeClick()
        end
    end)
end

function GuildMistWarGuardDetailItemView:InitView(itemModel, currMember)
    self.itemModel = itemModel
    self.nameTxt.text = itemModel:GetName()
    self.level.text = "Lv" .. tostring(itemModel:GetLevel())
    self.power.text = tostring(itemModel:GetPower())
    local logoTable = itemModel:GetTeamLogo()
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, logoTable)
    local pos = itemModel:GetPos()
    if pos then
        self.labelNoPlace:SetActive(false)
        self.labelPlace:SetActive(true)
        self.btnChange.gameObject:SetActive(true)
        self.btnPlace.gameObject:SetActive(false)
        if currMember then
            self.btnChangeText.text = lang.transstr("guildwar_change1")
        else
            self.btnChangeText.text = lang.transstr("guildwar_change1")
        end
    else
        self.labelNoPlace:SetActive(true)
        self.labelPlace:SetActive(false)
        self.btnChange.gameObject:SetActive(false)
        self.btnPlace.gameObject:SetActive(true)
        if currMember then
            self.btnPlaceText.text = lang.transstr("guildwar_change2")
        else
            self.btnPlaceText.text = lang.transstr("guildwar_place")
        end
    end
    if self.animator then
        self.animator:Play("GuildWarGuardDetailSwitchAnimation")
    end
end

function GuildMistWarGuardDetailItemView:onDestroy()
end

return GuildMistWarGuardDetailItemView
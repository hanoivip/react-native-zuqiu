local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GUILD_MEMBERTYPE = require("ui.controllers.guild.GUILD_MEMBERTYPE")

local GuildMemberItemView = class(unity.base)

function GuildMemberItemView:ctor()
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.teamLogo = self.___ex.teamLogo
    self.btnDetail = self.___ex.btnDetail
    self.time = self.___ex.time
    self.threeContribute = self.___ex.threeContribute
    self.allContribute = self.___ex.allContribute
    self.buttonsArea = self.___ex.buttonsArea
    self.btnUp = self.___ex.btnUp
    self.btnDown = self.___ex.btnDown
    self.btnOut = self.___ex.btnOut

    EventSystem.AddEvent("GuildMember_ManagerEvent", self, self.EventManagerMember)
end

function GuildMemberItemView:start()
    self.btnDetail:regOnButtonClick(function() 
        if type(self.onViewDetail) == "function" then
            self.onViewDetail()
        end
    end)
    self.btnUp:regOnButtonClick(function() 
        if type(self.onBtnUpClick) == "function" then
            self.onBtnUpClick()
        end
    end)
    self.btnDown:regOnButtonClick(function() 
        if type(self.onBtnDownClick) == "function" then
            self.onBtnDownClick()
        end
    end)
    self.btnOut:regOnButtonClick(function() 
        if type(self.onBtnOutClick) == "function" then
            self.onBtnOutClick()
        end
    end)
end

function GuildMemberItemView:InitView(itemModel, myType)
    self.itemModel = itemModel
    self.nameTxt.text = itemModel:GetName()
    self.level.text = "Lv" .. tostring(itemModel:GetLevel()) .. " (" .. itemModel:GetMemberTypeStr() .. ")"
    self.time.text = itemModel:GetLastTime()
    self.allContribute.text = tostring(itemModel:GetTotalContribute())
    self.threeContribute.text = tostring(itemModel:GetThreeContribute())
    local logoTable = itemModel:GetTeamLogo()
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, logoTable)
    self:HandleMemberType(myType)    
end

function GuildMemberItemView:EventManagerMember(ismanager)
    if ismanager then
        self.buttonsArea:SetActive(true)
        self.btnDetail.gameObject:SetActive(false)
    else
        self.buttonsArea:SetActive(false)
        self.btnDetail.gameObject:SetActive(true)
    end
end

function GuildMemberItemView:HandleMemberType(myType)
    local upstate = false
    local downstate = false
    local outstate = false
    local thisType = self.itemModel:GetAuthority()

    if myType  == GUILD_MEMBERTYPE.ADMIN then
        if thisType ~= GUILD_MEMBERTYPE.ADMIN then
            upstate = true
            if thisType == GUILD_MEMBERTYPE.MEMBER then
                outstate = true
            else    
                downstate = true
            end
        end
    elseif myType == GUILD_MEMBERTYPE.VP or myType == GUILD_MEMBERTYPE.ELDER then
        if thisType == GUILD_MEMBERTYPE.MEMBER then
            outstate = true
        end
    end

    self.btnUp.transform.parent.gameObject:SetActive(upstate)
    self.btnDown.transform.parent.gameObject:SetActive(downstate)
    self.btnOut.transform.parent.gameObject:SetActive(outstate)
    self.level.text = "Lv" .. tostring(self.itemModel:GetLevel()) .. " (" .. self.itemModel:GetMemberTypeStr() .. ")"
end

function GuildMemberItemView:onDestroy()
    EventSystem.RemoveEvent("GuildMember_ManagerEvent", self, self.EventManagerMember)
end

return GuildMemberItemView

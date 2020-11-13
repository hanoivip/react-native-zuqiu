local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2

local GuildJoinView = class(unity.base)

function GuildJoinView:ctor()
   self.scrollerView = self.___ex.scrollerView
   self.btnSearch = self.___ex.btnSearch
   self.btnRefresh = self.___ex.btnRefresh
   self.searchInput = self.___ex.searchInput
   self.noticeText = self.___ex.noticeText
   self.btnJoin = self.___ex.btnJoin
   self.btnJoinText = self.___ex.btnJoinText
   self.btnCreate = self.___ex.btnCreate
   self.infoBarDynParent = self.___ex.infoBar
end

function GuildJoinView:start()
    self.btnSearch:regOnButtonClick(function()
        self:OnBtnSearch()
    end)
    self.btnRefresh:regOnButtonClick(function()
        self:OnBtnRefresh()
    end)
    self.btnCreate:regOnButtonClick(function()
        self:OnBtnCreateGuild()
    end)
    self.btnJoin:regOnButtonClick(function()
        self:OnBtnJoinGuild()
    end)
end

function GuildJoinView:GetInputText()
    return self.searchInput.text
end

function GuildJoinView:OnBtnRefresh()
    if type(self.onBtnRefreshClick) == "function" then
        self.onBtnRefreshClick()
    end
end

function GuildJoinView:OnBtnSearch()
    if type(self.onBtnSearchClick) == "function" then
        self.onBtnSearchClick()
    end
end

function GuildJoinView:OnBtnCreateGuild()
    if type(self.onBtnCreateGuild) == "function" then
        self.onBtnCreateGuild()
    end
end

function GuildJoinView:OnBtnJoinGuild()
    if type(self.onBtnJoinGuild) == "function" then
        self.onBtnJoinGuild()
    end
end

function GuildJoinView:InitView(data)
    self.scrollerView:InitView(data)
    EventSystem.SendEvent("GuildJoinScrollerView_ItemClick", nil)    
end

function GuildJoinView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function GuildJoinView:InitNoticeView(text, numFull, levelReach, isAuto, hasReq)
    if not text then
        self.noticeText.text = ""
        self.btnJoin.gameObject:SetActive(false)
    end
    self.btnJoin.gameObject:SetActive(true) 
    self.noticeText.text = text

    local str = ""
    local isEnable = true

    if not numFull then
        if levelReach then
            if isAuto then
                str = lang.transstr("guild_joinBtnText1")
            else
                if hasReq then
                    str = lang.transstr("guild_joinBtnText2")
                    isEnable = false
                else
                    str = lang.transstr("guild_joinBtnText3")
                end
            end
        else
            str = lang.transstr("guild_joinBtnText4")
            isEnable = false
        end
    else
        str = lang.transstr("guild_joinBtnText4")
        isEnable = false
    end
    self:SetJoinButton(isEnable, str)
end

function GuildJoinView:SetJoinButton(isEnable, text)
    self.btnJoinText.text = text
    if isEnable then
        self.btnJoin:regOnButtonClick(function()
            self:OnBtnJoinGuild()
        end)
    else
        self.btnJoin:regOnButtonClick(function()
        end)
    end 
end

function GuildJoinView:HideNoticeView()
    self.btnJoin.gameObject:SetActive(false) 
    self.noticeText.text = ""
end

return GuildJoinView

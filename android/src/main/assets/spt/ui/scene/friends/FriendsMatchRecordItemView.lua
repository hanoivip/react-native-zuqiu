local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local Version = require("emulator.version")

local FriendsMatchRecordItemView = class(unity.base)

function FriendsMatchRecordItemView:ctor()
    self.btnDeleteRecord = self.___ex.btnDeleteRecord
    self.homePlayerName = self.___ex.homePlayerName
    self.homePlayerLevel = self.___ex.homePlayerLevel
    self.homePlayerTeamLogo = self.___ex.homePlayerTeamLogo
    self.awayPlayerName = self.___ex.awayPlayerName
    self.awayPlayerLevel = self.___ex.awayPlayerLevel
    self.awayPlayerTeamLogo = self.___ex.awayPlayerTeamLogo
    self.score = self.___ex.score
    self.winSymbol = self.___ex.winSymbol
    self.drawSymbol = self.___ex.drawSymbol
    self.loseSymbol = self.___ex.loseSymbol
    self.matchTime = self.___ex.matchTime
    self.btnView = self.___ex.btnView
    self.viewBtnObj = self.___ex.viewBtnObj
    self.videoExpiredSymbol = self.___ex.videoExpiredSymbol
    self.btnViewDetailLeft = self.___ex.btnViewDetailLeft
    self.btnViewDetailRight = self.___ex.btnViewDetailRight
end

function FriendsMatchRecordItemView:start()
    self.btnDeleteRecord:regOnButtonClick(function()
        if self.onDeleteRecord then
            self.onDeleteRecord()
        end
    end)
    self.btnView:regOnButtonClick(function()
        if self.onView then
            self.onView()
        end
    end)
    self.btnViewDetailLeft:regOnButtonClick(function()
        if self.onViewDetailLeft then
            self.onViewDetailLeft()
        end
    end)
    self.btnViewDetailRight:regOnButtonClick(function()
        if self.onViewDetailRight then
            self.onViewDetailRight()
        end
    end)
end

function FriendsMatchRecordItemView:InitView(data)
    local playerInfoModel = PlayerInfoModel.new()
    -- 玩家是主场
    if data.home == 1 then
        self.homePlayerName.text = playerInfoModel:GetName()
        self.homePlayerLevel.text = lang.trans("friends_manager_item_level", playerInfoModel:GetLevel())
        self.awayPlayerName.text = data.opponent.name
        self.awayPlayerLevel.text = lang.trans("friends_manager_item_level", data.opponent.lvl)
        if data.homeScore > data.awayScore then
            self:SwitchResultSymbol(true, false, false)
        elseif data.homeScore < data.awayScore then
            self:SwitchResultSymbol(false, false, true)
        else
            self:SwitchResultSymbol(false, true, false)
        end
    -- 玩家是客场
    else
        self.awayPlayerName.text = playerInfoModel:GetName()
        self.awayPlayerLevel.text = lang.trans("friends_manager_item_level", playerInfoModel:GetLevel())
        self.homePlayerName.text = data.opponent.name
        self.homePlayerLevel.text = lang.trans("friends_manager_item_level", data.opponent.lvl)
        if data.awayScore > data.homeScore then
            self:SwitchResultSymbol(true, false, false)
        elseif data.awayScore < data.homeScore then
            self:SwitchResultSymbol(false, false, true)
        else
            self:SwitchResultSymbol(false, true, false)
        end
    end
    self.score.text = lang.trans("friends_matchRecord_item_score", data.homeScore, data.awayScore)
    self.matchTime.text = os.date("%Y-%m-%d", data.c_t)
    self:InitHomePlayerTeamLogo()
    self:InitAwayPlayerTeamLogo()
    local isVideoExpired = tonumber(data.version) ~= tonumber(Version.version)
    self.viewBtnObj:SetActive(not isVideoExpired)
    self.videoExpiredSymbol:SetActive(isVideoExpired)
end

function FriendsMatchRecordItemView:InitHomePlayerTeamLogo()
    if self.onInitHomePlayerTeamLogo then
        self.onInitHomePlayerTeamLogo()
    end
end

function FriendsMatchRecordItemView:GetHomePlayerTeamLogoGameObject()
    return self.homePlayerTeamLogo
end

function FriendsMatchRecordItemView:InitAwayPlayerTeamLogo()
    if self.onInitAwayPlayerTeamLogo then
        self.onInitAwayPlayerTeamLogo()
    end
end

function FriendsMatchRecordItemView:GetAwayPlayerTeamLogoGameObject()
    return self.awayPlayerTeamLogo
end

function FriendsMatchRecordItemView:SwitchResultSymbol(isShowWin, isShowDraw, isShowLose)
    self.winSymbol:SetActive(isShowWin)
    self.drawSymbol:SetActive(isShowDraw)
    self.loseSymbol:SetActive(isShowLose)
end

return FriendsMatchRecordItemView

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local BaseCtrl = require("ui.controllers.BaseCtrl")
local LoginModel = require("ui.models.login.LoginModel")
local AccountCtrl = require("ui.controllers.login.AccountCtrl")
local CreateRoleCtrl = require("ui.controllers.login.CreateRoleCtrl")
local UserLevelUpCtrl = require("ui.controllers.common.UserLevelUpCtrl")
local LoginConstants = require("ui.controllers.login.LoginConstants")
local MusicManager = require("ui.control.manager.MusicManager")
local UIBgmManager = require("ui.control.manager.UIBgmManager")
local Item = require("data.Item")
local ItemContent = require("data.ItemContent")
local Paster = require("data.Paster")
local RedPacket = require("data.RedPacket")
local ExchangeItem = require("data.ExchangeItem")
local WorldBossItem = require("data.WorldBossItem")
local MarblesExchangeItem = require("data.MarblesExchangeItem")
local Medal = require("data.Medal")
local DialogManager = require("ui.control.manager.DialogManager")
local EventSystems = UnityEngine.EventSystems
local CommentResManager = require("ui.control.manager.CommentResManager")
local SettingsLanguageModel = require("ui.models.settings.SettingsLanguageModel")

local LoginCtrl = class(BaseCtrl)

LoginCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Login/Login.prefab"

LoginCtrl.instance = nil

function LoginCtrl.OnLoginSuccess(channel)
    local settingsLanguageModel = SettingsLanguageModel.new()
    if settingsLanguageModel:IsFirstLogin() then
        res.PushDialog("ui.controllers.login.LoginSwitchLanguageCtrl")
    end

    if not luaevt.trig("___EVENT__SHARE_FORBIDDEN") then
        res.PushDialog("ui.controllers.login.NoticeCtrl", channel, function()
            cache.setIsShowNoticeBoard(true)
            LoginCtrl.instance.view:PlayLogoAnim()
            LoginCtrl.instance.view:ChangeLogoutButton(true)
            LoginCtrl.instance:SetLoginFlag(true)
        end)
    end
end

local function JudgeEnterScene(needChangeToTeamLogoCreate)
    clr.coroutine(function()
        local response = req.player()
        if api.success(response) then
            -- 设置TapjoyUserId
            local cvtable = _G["___resver"];

            local data = response.val
            --设置客户端与服务器时间的差值
            if data then
                local osTime = os.time()
                local serverTime = tonumber(data.serverTime or osTime)
                local deltaTime = serverTime - tonumber(osTime)
                cache.setServerDeltaTimeValue(deltaTime)
            end

            require("ui.common.CustomEvent").SetUserId(data.info._id)
            if type(data) == 'table' and type(data.info) == 'table' and api.bool(data.info.token) then
                api.setToken(data.info.token)
            end

            local PlayerInfoModel = require("ui.models.PlayerInfoModel")
            local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
            local EquipsMapModel = require("ui.models.EquipsMapModel")
            local ItemsMapModel = require("ui.models.ItemsMapModel")
            local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
            local EquipPieceMapModel = require("ui.models.EquipPieceMapModel")
            local LoginPlateModel = require("ui.models.loginPlate.LoginPlateModel")
            local PlayerGenericModel = require("ui.models.playerGeneric.PlayerGenericModel")
            local MenuBarModel = require("ui.models.menuBar.MenuBarModel")
            local PlayerLetterInsidePlayerModel = require("ui.models.playerLetter.PlayerLetterInsidePlayerModel")
            local PlayerPiecesMapModel = require("ui.models.PlayerPiecesMapModel")
            local PasterPiecesMapModel = require("ui.models.PasterPiecesMapModel")
            local CardPastersMapModel = require("ui.models.CardPastersMapModel")
            local RedPacketMapModel = require("ui.models.RedPacketMapModel")
            local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
            local PlayerDreamCardsMapModel = require("ui.models.dreamLeague.PlayerDreamCardsMapModel")
            local HeroHallMapModel = require("ui.models.heroHall.main.HeroHallMapModel")
            local CoachMainModel = require("ui.models.coach.CoachMainModel")
            local CoachItemMapModel = require("ui.models.coach.common.CoachItemMapModel")
            local FreshPlayerLevelModel = require("ui.models.freshPlayerLevel.FreshPlayerLevelModel")
            local LegendCardsMapModel = require("ui.models.legendRoad.LegendCardsMapModel")
            local MySceneModel = require("ui.models.myscene.MySceneModel")
            local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
            local CustomTagModel = require("ui.models.cardDetail.CustomTagModel")
            -- 基本信息
            local playerInfoModel = PlayerInfoModel.new()
            -- 所有卡牌信息
            local playerCardsMapModel = PlayerCardsMapModel.new()
            -- 装备信息
            local equipsMapModel = EquipsMapModel.new()
            -- 道具信息
            local itemsMapModel = ItemsMapModel.new()
            -- 阵容信息
            local playerTeamsModel = PlayerTeamsModel.new()
            -- 装备碎片
            local equipPieceMapModel = EquipPieceMapModel.new()
            -- 登录弹板信息
            local loginPlateModel = LoginPlateModel.new()
            -- 通用信息
            local playerGenericModel = PlayerGenericModel.new()
            -- 边栏菜单信息
            local menuBarModel = MenuBarModel.new()
            -- 和信件有关且已完成的卡牌（全部有关在LetterCards中）
            local playerLetterInsidePlayerModel = PlayerLetterInsidePlayerModel.new()
            -- 球员碎片信息
            local playerPiecesMapModel = PlayerPiecesMapModel.new()
            -- 贴纸信息
            local cardPastersMapModel = CardPastersMapModel.new()
            -- 球员贴纸碎片信息
            local PasterPiecesMapModel = PasterPiecesMapModel.new()
            -- 供公会聊天发放的红包信息
            local redPacketMapModel = RedPacketMapModel.new()
            -- 球员勋章信息
            local playerMedalsMapModel = PlayerMedalsMapModel.new()
            -- 梦幻联赛卡牌信息
            local playerDreamCardsMapModel = PlayerDreamCardsMapModel.new()
            -- 英雄殿堂信息
            local heroHallMapModel = HeroHallMapModel.new()
            -- 教练信息
            local coachMainModel = CoachMainModel.new()
            -- 教练阵型/战术升级物品cti
            local coachItemMapModel = CoachItemMapModel.new()
            -- 等级限时礼盒
            local freshPlayerLevelModel = FreshPlayerLevelModel.new()
            -- 传奇之路
            local legendCardsMapModel = LegendCardsMapModel.new()
            -- 我的场景
            local mySceneModel = MySceneModel.new()
            -- 梦幻卡
            local fancyCardsMapModel = FancyCardsMapModel.new()
            -- 玩家自定义标记信息
            local customTagModel = CustomTagModel.new()

            playerInfoModel:InitWithProtocol(data.info)
            playerInfoModel:SetGuild(data.guild)
            playerCardsMapModel:InitWithProtocol(data.cards)
            equipsMapModel:InitWithProtocol(data.equips)
            itemsMapModel:InitWithProtocol(data.item)
            playerTeamsModel:InitWithProtocol(data.teams)
            equipPieceMapModel:InitWithProtocol(data.equipPieces)
            loginPlateModel:InitWithProtocol(data.loginNote)
            playerGenericModel:InitWithProtocol(data.cardBagExtend, data.leagueDiff)
            menuBarModel:InitWithProtocol()
            playerLetterInsidePlayerModel:InitWithProtocol(data.letter.list)
            playerPiecesMapModel:InitWithProtocol(data.cardPiece)
            PasterPiecesMapModel:InitWithProtocol(data.pasterPiece)
            cardPastersMapModel:InitWithProtocol(data.paster)
            redPacketMapModel:InitWithProtocol(data.redPacket)
            playerMedalsMapModel:InitWithProtocol(data.medal)
            playerDreamCardsMapModel:InitWithProtocol(data.dreamCard)
            heroHallMapModel:InitWithProtocol(data.footballHall)
            coachMainModel:InitWithProtocol(data.coach, true)
            coachItemMapModel:InitWithProtocol(data.cti)
            freshPlayerLevelModel:InitWithProtocol(data.levelBox)
            legendCardsMapModel:InitWithProtocol(data.legendRoad)
            mySceneModel:InitWithProtocol(data.scenario)
            fancyCardsMapModel:InitWithProtocol(data.fancyCard)
            customTagModel:InitWithProtocol(data.albumTag)

            EventSystem.AddPersistentEvent("UserLevelUp", nil, function(levelData)
                UserLevelUpCtrl.new(levelData)
                clr.coroutine(function()
                    local response = req.levelBoxInfo()
                    local playerLevelModel = FreshPlayerLevelModel.new()
                    playerLevelModel:InitWithProtocol(response.val)
                end)
            end)

            local response1 = req.getEnterSenceList()
            if api.success(response1) then
                local data1 = response1.val
                local playerNewFunctionModel = require("ui.models.PlayerNewFunctionModel").new()
                playerNewFunctionModel:InitWithProtocol(data1)
            end

            -- 热云sdk的登录统计
            require("ui.common.ReyunCustomEvent").Login()
            if not needChangeToTeamLogoCreate then
                local server = cache.getCurrentServer()
                local playerName = data.info.name == "" and "none" or data.info.name
                local diamond = playerInfoModel:GetDiamond()
                luaevt.trig("Enter_Server")
                luaevt.trig("Enter_Game")
                luaevt.trig("HoolaiBISendCounter", "dau")
            end

            local server = cache.getCurrentServer()
            local playerName = data.info.name == "" and "none" or data.info.name
            local diamond = playerInfoModel:GetDiamond()
            local vipLvl = playerInfoModel:GetVipLevel()
            luaevt.trig("SDK_Report", "home_enter", data.info._id, playerName, data.info.lvl, server.id, server.name, diamond, vipLvl)

            if LoginConstants.isOpenSampleMatch == false or playerInfoModel:IsSampleMatchEnd() then
                if playerInfoModel:GetTeamLogo() then
                    if playerInfoModel:GetTeamUniform(require("ui.models.common.TeamUniformModel").UniformType.Home) then
                        local name = playerInfoModel:GetName()
                        if name and name ~= "" then
                            LoginCtrl.currentEventSystem = EventSystems.EventSystem.current
                            LoginCtrl.currentEventSystem.enabled = false
                            clr.coroutine(function()
                                unity.waitForEndOfFrame()
                                res.ChangeSceneImmediate("ui.controllers.home.HomeMainCtrl")
                                luaevt.trig("CheckConsumableItems")
                                LoginCtrl.currentEventSystem.enabled = true
                                -- 设置已下载的语音包
                                local resVer = _G["___resver"]
                                local commentVer = {}
                                for k,v in pairs(resVer) do
                                    if type(k) == "string" then
                                        local sIndex = string.sub(k, 0, 10)
                                        local commentIndex = string.sub(k, 4, string.len(k))
                                        if sIndex == "rescomment" then
                                            table.insert(commentVer, commentIndex)
                                        end
                                    end
                                end
                                CommentResManager.SetCommentResList(commentVer)
                            end)
                        else
                            res.PushScene("ui.controllers.teamCreate.TeamNameCtrl")
                        end
                    else
                        res.PushScene("ui.controllers.teamCreate.TeamUniformCtrl")
                    end
                else
                    if needChangeToTeamLogoCreate then
                        res.DestroyAll()
                        -- res.Instantiate("Assets/CapstonesRes/Game/UI/Common/EffectClick/TouchEffect.prefab")
                        MusicManager.play()
                        res.ChangeScene("ui.controllers.teamCreate.TeamLogoCreateCtrl")
                    else
                        res.PushScene("ui.controllers.teamCreate.TeamLogoCreateCtrl")
                    end
                end
            else
                require("coregame.MatchLoader").startDemoMatchCN()
            end
        end
    end)   
end

function LoginCtrl.OnDemoMatchEnd()
    clr.coroutine(function()
        local resp = req.sampleMatchEnd()
        if api.success(resp) then
            JudgeEnterScene(true)
            MusicManager.play()
        end
    end)
end

function LoginCtrl:Init()
    LoginCtrl.instance = self
    -- 点击特效
    -- local touchEffect = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/EffectClick/TouchEffect.prefab")
    
    res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Template/Functional/CheatPanel.prefab")

    self.view:RegOnNoticeButtonClick(function()
        res.PushDialog("ui.controllers.login.NoticeCtrl")
    end)
    
    self.view:RegOnLogoutButtonClick(function()
        if clr.plat == "IPhonePlayer" then
            DialogManager.ShowToast(lang.trans("logout_success"))
            self.view:ChangeLogoutButton(false)
        end
        luaevt.trig("SDK_Logout")
    end)

    self.view:RegOnClearDataButtonClick(function()
        cache.setIsClearData(true)
        if clr.plat == "IPhonePlayer" then
            luaevt.trig("Dist_Logout")
        else
            luaevt.trig("SDK_Logout")
        end
    end)

    self.view:RegOnStartButtonClick(function()
        if type(LoginModel.GetAccount()) == "table" and self.loginFlag then
            self:RecommandNewAccount(cache.getCurrentServer(), LoginModel.GetAccount().isFirstLogin)
        else
            luaevt.trig("SDK_Login")
            luaevt.trig("SendBIReport", "start_login", "11")
        end
    end)

    self.view:RegOnSelectServerClick(function()
        if type(LoginModel.GetAccount()) == "table" and self.loginFlag then
            res.PushDialog("ui.controllers.login.ServerListCtrl")
        else
            luaevt.trig("SDK_Login")
            luaevt.trig("SendBIReport", "start_login", "11")
        end
    end)
    
    self.view:RegOnSwitchLanguageButtonClick(function()
        res.PushDialog("ui.controllers.login.LoginSwitchLanguageCtrl")
    end)

    luaevt.trig("SDK_Report", "launch_game")

    if clr.plat == "WindowsEditor" then
        self.loginFlag = true
    end
end

function LoginCtrl:SetLoginFlag(flag)
    self.loginFlag = flag
end

function LoginCtrl:Refresh()
    luaevt.trig("SetOnBackType", "exit")

    LoginCtrl.super.Refresh(self)
    local heroMatchFightMenu = require("coregame.MatchLoader").fightMenu
    if heroMatchFightMenu and heroMatchFightMenu ~= clr.null then
        Object.Destroy(heroMatchFightMenu)
    end

    self:CloseRoleDialog()
    self:CloseAccountDialog()

    self.view:coroutine(function()
        local itemMaxId = self:GetStaticTableMaxId(Item)
        local itemContentMaxId = self:GetStaticTableMaxId(ItemContent)
        local pasterMaxId = self:GetStaticTableMaxId(Paster)
        local redPacketMaxId = self:GetStaticTableMaxId(RedPacket)
        local medalMaxId = self:GetStaticTableMaxId(Medal)
        local exchangeItemId = self:GetStaticTableMaxId(ExchangeItem)
        local worldBossItemId = self:GetStaticTableMaxId(WorldBossItem)
        local marblesExchangeItem = self:GetStaticTableMaxId(MarblesExchangeItem or {})

        local response = req.device(itemMaxId, itemContentMaxId, pasterMaxId, redPacketMaxId, medalMaxId, exchangeItemId, worldBossItemId, marblesExchangeItem)
        if api.success(response) then
            if luaevt.trig("SDK_HasAccountSystemAutoLogin") or luaevt.trig("SDK_HasAccountSystem") then
                luaevt.trig("SDK_Login")
                luaevt.trig("SDK_Report", "sdk_login_begin", clr.plat)
            else
                local token = LoginModel.GetRoleToken()
                if not token then
                    self:DefaultLogin()
                end
            end
            LoginCtrl.___deviceOver = true
            self:CheckStaticTable(response.val.jsonUpdate)
        end
    end)
end

function LoginCtrl:GetStaticTableMaxId(staticTable)
    assert(type(staticTable) == "table")
    local maxKey = 0
    for k, v in pairs(staticTable) do
        local id = tonumber(k)
        if id > maxKey then 
            maxKey = id
        end
    end
    return maxKey
end

function LoginCtrl:CheckStaticTable(jsonUpdate)
    if type(jsonUpdate) == "table" then 
        local newItem = jsonUpdate.Item
        local newItemContent = jsonUpdate.ItemContent
        local newPaster = jsonUpdate.Paster
        local newRedPacket = jsonUpdate.RedPacket
        local newMedal = jsonUpdate.Medal
        local newExchangeItem = jsonUpdate.ExchangeItem
        local newWorldBossItem = jsonUpdate.WorldBossItem
        local newMarblesExchangeItem = jsonUpdate.MarblesExchangeItem

        self:UpdateStaticTable("Item", newItem)
        self:UpdateStaticTable("ItemContent", newItemContent)
        self:UpdateStaticTable("Paster", newPaster)
        self:UpdateStaticTable("RedPacket", newRedPacket)
        self:UpdateStaticTable("Medal", newMedal)
        self:UpdateStaticTable("ExchangeItem", newExchangeItem)
        self:UpdateStaticTable("WorldBossItem", newWorldBossItem)
        self:UpdateStaticTable("MarblesExchangeItem", newMarblesExchangeItem)
    end
end

function LoginCtrl:UpdateStaticTable(key, updateTable)
    local oldStaticTable
    if key == "Item" then 
        oldStaticTable = Item
    elseif key == "ItemContent" then 
        oldStaticTable = ItemContent
    elseif key == "Paster" then 
        oldStaticTable = Paster
    elseif key == "RedPacket" then
        oldStaticTable = RedPacket
    elseif key == "Medal" then
        oldStaticTable = Medal
    elseif key == "ExchangeItem" then
        oldStaticTable = ExchangeItem
    elseif key == "WorldBossItem" then
        oldStaticTable = WorldBossItem
    elseif key == "MarblesExchangeItem" then
        oldStaticTable = MarblesExchangeItem
    end
    assert(type(oldStaticTable) == "table")
    if updateTable then 
        for id, v in pairs(updateTable) do
            oldStaticTable[id] = v
        end
    end
end

function LoginCtrl:GetStatusData()
    return nil
end

function LoginCtrl:OnEnterScene()
    EventSystem.AddEvent("SetCurrentServer", self, self.SetCurrentServer)
end

function LoginCtrl:OnExitScene()
    EventSystem.RemoveEvent("SetCurrentServer", self, self.SetCurrentServer)
end

function LoginCtrl:SetCurrentServer(server)
    self.view:SetCurrentServer(server)
end

function LoginCtrl:CloseAccountDialog()
    if self.accountCtrl then
        self.accountCtrl:Close()
        self.accountCtrl = nil
    end
end

function LoginCtrl:CloseRoleDialog()
    if self.createRoleCtrl then
        self.createRoleCtrl:Close()
        self.createRoleCtrl = nil
    end
end

function LoginCtrl:DefaultLogin()
    self:CloseRoleDialog()
    self.accountCtrl = AccountCtrl.new()
    self.accountCtrl:RegAfterLoginClick(function()
        self.accountCtrl = nil
    end)
end

function LoginCtrl:CreateRole()
    self:CloseAccountDialog()
    self.createRoleCtrl = CreateRoleCtrl.new()
end

function LoginCtrl:EnterGame()
    luaevt.trig("SendBIReport", "click_login", "13")
    UIBgmManager.play("Login/enterGame")
    local token = LoginModel.GetRoleToken()
    if token then
        api.setToken(token)
        JudgeEnterScene()
    else
        clr.coroutine(function()
            local account = LoginModel.GetAccount()
            local aid = account.aid
            local name = ""
            local tid = "c101"
            local response = req.create(aid, name, tid)
            if api.success(response) then
                local playerInfo = response.val

                luaevt.trig("BICheckPoint", "create_player_success", "13.1")

                -- 热云sdk的注册统计
                require("ui.common.ReyunCustomEvent").Register(playerInfo.id)  
                            
                api.setToken(playerInfo["token"])
                local server = cache.getCurrentServer()
                luaevt.trig("Enter_Server", playerInfo.id)
                luaevt.trig("Enter_Game", playerInfo.id)
                if LoginConstants.isOpenSampleMatch == true then
                    require("coregame.MatchLoader").startDemoMatchCN()
                else
                    LoginCtrl.OnDemoMatchEnd()
                end
            else
                luaevt.trig("BICheckPoint", "create_player_error", "13.2", {["error"] = clr.unwrap(response.msg)})
            end
        end)
    end
end

function LoginCtrl:RecommandNewAccount(server, isFirstLogin)
    local servers = LoginModel.GetServers()
    if isFirstLogin then 
        if servers[1] == server then 
            self:EnterGame()
        else
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("recommand_newAccount"), 
            function() 
                self:EnterGame() 
            end, 
            function() 
                LoginModel.SetCurrentServer(servers[1])
            end)
        end
    else
        self:EnterGame()
    end
end


return LoginCtrl


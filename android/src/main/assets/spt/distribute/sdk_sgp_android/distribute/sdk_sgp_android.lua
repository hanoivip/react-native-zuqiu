local sdk_sgp_ios = {}

local UnityEngine = clr.UnityEngine
local GameObject = UnityEngine.GameObject
local MonoBehaviour = clr.DummyBehav
local Time = UnityEngine.Time
local ResManager = clr.Capstones.UnityFramework.ResManager
local DialogManager = require("ui.control.manager.DialogManager")
local AdjustPointContast = require("ui.common.AdjustPointContast")
local CustomEvent = require("ui.common.CustomEvent")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local SettingsLanguageModel = require("ui.models.settings.SettingsLanguageModel")

local canShowSDKExit = true
local exitConfirmDlg = nil

local go = GameObject("hoolai_sdk")
ResManager.DontDestroyOnLoad(go)

clr.bcoroutine(go:AddComponent(MonoBehaviour), function()
    local lvl
    while true do
        luaevt.delayed()
        -- get player lvl and check lvlup
        if cache then
            local playerInfo = cache.getPlayerInfo()
            if type(playerInfo) == 'table' and playerInfo.lvl then
                local newlvl = tonumber(playerInfo.lvl)
                if lvl then
                    if newlvl > lvl then
                        local server = cache.getCurrentServer()
                        -- luaevt.trig('SDK_PushUserOp_LUA','Lvlup', playerInfo._id, playerInfo.name, newlvl ,server.id ,server.name ,server.id, server.name, playerInfo.vip and playerInfo.vip.lvl or 0, playerInfo.d or 0)
                        luaevt.trig('Level_Up_Report', lvl, newlvl)
                    end
                end
                lvl = newlvl
            end
        end

        if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.Escape) then
            if exitConfirmDlg and exitConfirmDlg ~= clr.null then
                exitConfirmDlg.closeDialog()
                exitConfirmDlg = nil
            else
                if canShowSDKExit then
                    canShowSDKExit = false
                    luaevt.trig('SDK_Exit')
                end
            end
        end 
        coroutine.yield()
    end
end)

luaevt.reg("SDK_HaveExit", function() return true end)

local blockdlg = nil

local function closeBlockDlg()
    if blockdlg then
        local closeDialog = blockdlg.closeDialog
        if type(closeDialog) == "function" then
            closeDialog()
        end
        blockdlg = nil
    end
end

local function showBlockDlg()
    if not blockdlg then
        local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Common/Template/Loading/WaitForPost.prefab", "overlay", false)
        blockdlg = dialogcomp
        dialogcomp.contentcomp:SetTxts({lang.trans("wait_for_diamond_arrival")})
    end
end

local function isFirstPay(playerInfoModel)
    if not playerInfoModel:GetVipCost() or tonumber(playerInfoModel:GetVipCost()) == 0 then
        luaevt.trig("AdjustReport", AdjustPointContast.ADJUST_FIRST_PAY_Android, nil, nil)
    end
end

luaevt.reg("Do_Pay", function(cate, productId, model, chargeItemView)
    -- 点击支付报送
    luaevt.trig("AdjustReport", AdjustPointContast.FB_Added_Payment_Info_A, nil, nil)
    showBlockDlg()
    clr.coroutine(function()
        local playerInfoModel = require("ui.models.PlayerInfoModel").new()
        local price = model:GetItemPrice()
        local itemName = tostring(model:GetItemName())
        local roleId = playerInfoModel:GetID()
        local roleLevel = playerInfoModel:GetLevel()
        local productName = model:GetItemName()
        local productDesc = model:GetItemDesc()
        
        local initResp = req.payInit(productId, 0)
        if api.success(initResp) then
            local orderId = initResp.val.order_id
            luaevt.unreg('Dist_PaySuccess')
            luaevt.unreg('Dist_PayFail')
            luaevt.trig("SDK_Report", "pay_begin", roleId, roleLevel, productId)
            dump(productId, "SDK_Report_goudan_productId:")
            local handle_s, handle_f
            -- reg 充值成功的回调
            handle_s = luaevt.reg('Dist_PaySuccess', function()
                luaevt.unreg('Dist_PaySuccess', handle_s)
                luaevt.unreg('Dist_PayFail', handle_f)
                closeBlockDlg()
                clr.coroutine(function()
                    local function doArrivalCheck()
                        showBlockDlg()
                        for i = 1, 30 do
                            coroutine.yield()
                        end
                        local resp = req.payCheckArrived(orderId, nil, nil, true)
                        if api.success(resp) and type(resp.val) == 'table' and resp.val.ok == 0 then
                            closeBlockDlg()
                            local title = lang.trans("charge_success_title")
                            local msg = lang.trans("charge_success")
                            local confirmFunc = function()
                            end
                            require("ui.control.manager.DialogManager").ShowAlertPop(title, msg, confirmFunc)
                            luaevt.trig('AdjustReport', AdjustPointContast.ADJUST_PAY_COMPLETED_Android, nil, nil)
                            luaevt.trig('AdjustReport', AdjustPointContast.FB_Purchase_A, nil, nil)
                            luaevt.trig("HoolaiBISendCounter", "payment", model:GetBIPrice(), model:GetPriceLocal())
                            --刷新充值面板
                            isFirstPay(playerInfoModel)
                            local mInfo = {}
                            mInfo.phylum = "pay"
                            mInfo.genus = productId
                            CustomEvent.GetDiamond("1", resp.val.d and (tonumber(resp.val.d) - (playerInfoModel:GetDiamond() or 0)) or 0, mInfo)
                            CustomEvent.GetBlackDiamond("1", resp.val.bkd and (tonumber(resp.val.bkd) - (playerInfoModel:GetBlackDiamond() or 0)) or 0, mInfo)
                            playerInfoModel:SetDiamond(resp.val.d)
                            playerInfoModel:SetBlackDiamond(resp.val.bkd)
                            EventSystem.SendEvent("Charge_Success")
                            chargeItemView:SetNotFirst()
                            -- 充值成功统计
                            luaevt.trig("SDK_Report", "pay_done", roleId, roleLevel, price, productName, productDesc, productId)
                            return true
                        else
                            return false
                        end
                    end
                    local function smartDoArrivalCheck()
                        local cur_time = Time.unscaledTime
                        local time_to_bubble = function()
                            return Time.unscaledTime - cur_time > 10
                        end
                        while not doArrivalCheck() do
                            if time_to_bubble() then
                                closeBlockDlg()
                                local title = lang.trans("charge_failed_title")
                                local msg = lang.trans("charge_failed_msg")
                                local confirmFunc = function()
                                    clr.coroutine(function()
                                        smartDoArrivalCheck()
                                    end)
                                end
                                local cancelFunc = function()
                                end
                                DialogManager.ShowConfirmPop(title, msg, confirmFunc, cancelFunc)
                                break
                            end
                        end
                    end
                    smartDoArrivalCheck()
                end)
            end)
            -- reg 充值失败的回调
            handle_f = luaevt.reg('Dist_PayFail', function()
                luaevt.unreg("Dist_PaySuccess", handle_s)
                luaevt.unreg("Dist_PayFail", handle_f)
                closeBlockDlg()
                local confirmFunc = function()
                end
                require("ui.control.manager.DialogManager").ShowAlertPopByLang("training_dribbleKickFail", "charge_failed", confirmFunc)
            end)
            luaevt.trig('SDK_Pay', itemName, productId, price, orderId)
        else
            closeBlockDlg()
        end
    end)
end)

luaevt.reg("Do_Pay_Special", function(cate, model, giftBoxItemPopCtrl)
    showBlockDlg()
    clr.coroutine(function()
        local productId = model:GetID()
        local price = model:GetPrice()
        local productName = model:GetTitle()
        local productDesc = model:GetDesc()
        local playerInfoModel = PlayerInfoModel.new()
        local roleId = playerInfoModel:GetID()
        local roleLevel = playerInfoModel:GetLevel()
        local initResp = req.buyGiftBox(productId)
        if api.success(initResp) then
            local orderId = initResp.val.order_id

            luaevt.unreg('Dist_PaySuccess')
            luaevt.unreg('Dist_PayFail')
            local handle_s, handle_f
            -- reg 充值成功的回调
            handle_s = luaevt.reg('Dist_PaySuccess', function()
                luaevt.unreg('Dist_PaySuccess', handle_s)
                luaevt.unreg('Dist_PayFail', handle_f)
                closeBlockDlg()
                clr.coroutine(function()
                    local function doArrivalCheck()
                        showBlockDlg()
                        for i = 1, 30 do
                            coroutine.yield()
                        end
                        local resp = req.payCheckArrived(orderId, nil, nil, true)
                        if api.success(resp) and type(resp.val) == 'table' and resp.val.ok == 0 then
                            closeBlockDlg()
                            local title = lang.trans("charge_success_title")
                            local msg = lang.trans("charge_success")
                            local confirmFunc = function()
                            end
                            require("ui.control.manager.DialogManager").ShowAlertPop(title, msg, confirmFunc)
                            luaevt.trig('AdjustReport', AdjustPointContast.ADJUST_PAY_COMPLETED_Android, nil, nil)
                            luaevt.trig('AdjustReport', AdjustPointContast.FB_Purchase, nil, nil)
                            luaevt.trig("HoolaiBISendCounter", "payment", model:GetBIPrice(), model:GetPriceLocal())
                            giftBoxItemPopCtrl:BuyGiftBoxSuccess(resp.val.contents)
                            luaevt.trig("SDK_Report", "pay_done", roleId, roleLevel, price, productName, productDesc, productId)
                            return true
                        else
                            return false
                        end
                    end
                    local function smartDoArrivalCheck()
                        local cur_time = Time.unscaledTime
                        local time_to_bubble = function()
                            return Time.unscaledTime - cur_time > 10
                        end

                        while not doArrivalCheck() do
                            if time_to_bubble() then
                                closeBlockDlg()
                                local title = lang.trans("charge_failed_title")
                                local msg = lang.trans("charge_failed_msg")
                                local confirmFunc = function()
                                    clr.coroutine(function()
                                        smartDoArrivalCheck()
                                    end)
                                end
                                local cancelFunc = function()
                                end
                                require("ui.control.manager.DialogManager").ShowConfirmPop(title, msg, confirmFunc, cancelFunc)
                                break
                            end
                        end
                    end
                    smartDoArrivalCheck()
                end)
            end)
            -- reg 充值失败的回调
            handle_f = luaevt.reg('Dist_PayFail', function()
                luaevt.unreg('Dist_PaySuccess', handle_s)
                luaevt.unreg('Dist_PayFail', handle_f)
                luaevt.trig("SDK_Report", "pay_error", roleId, roleLevel)
                dump(roleLevel, "SDK_Report_goudan_productId: pay_error")
                closeBlockDlg()
                local confirmFunc = function()
                end
                require("ui.control.manager.DialogManager").ShowAlertPopByLang("training_dribbleKickFail", "charge_failed", confirmFunc)
            end)
            local itemName = tostring(model:GetItemName())
            luaevt.trig('SDK_Pay', itemName, productId, price, orderId)
        else
            closeBlockDlg()
        end
    end)
end)

luaevt.reg('HasPurchaseSystem', function()
    return true
end)

luaevt.reg('Dist_CanShowSDKExit', function()
    canShowSDKExit = true
end)

luaevt.reg('Dist_ShowExitConfirm',function ()
    if not exitConfirmDlg then
        local content = {}
        content.title = lang.trans("exit_confirm")
        content.content = lang.trans("exit_confirm_msg")
        content.button1Text = lang.trans("cancel")
        content.onButton1Clicked = function()
            exitConfirmDlg = nil
        end
        content.button2Text = lang.trans("confirm")
        content.onButton2Clicked = function()
            UnityEngine.Application.Quit()
        end
        content.hideCloseIcon = true
        local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/MessageBox.prefab', 'overlay', false, true, nil, nil, 10000)
        exitConfirmDlg = dialogcomp.contentcomp
        dialogcomp.contentcomp:initData(content)
    end
end)

luaevt.reg("Dist_Logout",function()
    local LoginCtrl = require("ui.controllers.login.LoginCtrl")
    if LoginCtrl.instance then
        LoginCtrl.instance:SetLoginFlag(false)
    end
    local isClearData = cache.getIsClearData()
    if isClearData then
        clr.Capstones.UnityFramework.ResManager.ResetCacheVersion()
        cache.setIsClearData(false)
    end
    unity.restart()
end)

luaevt.reg('Dist_SGPSDK_Close',function()
    cache.setAccount(nil)
end)

local serverIdMask = {["0"] = true,["1"] = true,["2"] = true,["3"] = true,["4"] = true,}
luaevt.reg('SDK_PushUserOp_LUA', function(cate, eventName, pid, pname, plvl, serverid, servername, zoneId, zoneName, vip, diamomd)
    ndump("SDK_PushUserOp_LUA",eventName, pid, pname, plvl, serverid, servername, zoneId, zoneName, vip or 0, diamomd or 0)
    if serverIdMask[tostring(serverid)] then
        return
    end
    if pname and pname ~= "" and  pname ~= "nil" and pname ~= "none" then
        luaevt.trig('SDK_PushUserOp', eventName, pid, pname, plvl, serverid, servername, zoneId, zoneName, vip or 0, diamomd or 0)
    end
end)

luaevt.reg('AdjustReport', function(cate, eventName, key, value)
    --luaevt.trig('SDK_HoolaiADReport', eventName, key, value)
    local playerInfo = cache.getPlayerInfo()
    local server = cache.getCurrentServer()
    if not playerInfo and not server then
        --luaevt.trig('SDK_HoolaiADReport',eventName)
    else
        luaevt.trig('SDK_PushUserOp_LUA',eventName, playerInfo and playerInfo._id, playerInfo and playerInfo.name, tostring(playerInfo and playerInfo.lvl),
        server and server.id, server and server.name ,server and server.id, server and server.name , playerInfo and playerInfo.vip and playerInfo.vip.lvl or 0, playerInfo and playerInfo.d or 0)
    end
end)
-- 完成新手引导
luaevt.reg('Complete_Tutorial', function()
    luaevt.trig('AdjustReport', AdjustPointContast.ADJUST_COMPLETE_BEGINNER_GUIDE_Android,nil, nil)
    luaevt.trig('AdjustReport', AdjustPointContast.FB_Tutorials_Completed_A,nil, nil)
end)
-- 完成进入商城
luaevt.reg('Enter_Into_Store', function()
    luaevt.trig('AdjustReport', AdjustPointContast.ADJUST_ENTER_SHOP_Android, nil, nil)
end)
-- 等级提升
luaevt.reg('Level_Up_Report', function(cate, lvl, newlvl)
    for templvl = tonumber(lvl)+1, tonumber(newlvl) do
        if AdjustPointContast.LevelUp_Android[tostring(templvl)] then
            luaevt.trig("AdjustReport", AdjustPointContast.LevelUp_Android[tostring(templvl)], nil, nil)
        end
        if AdjustPointContast.FBLevelUp_A[tostring(templvl)] then
            luaevt.trig("AdjustReport", AdjustPointContast.FBLevelUp_A[tostring(templvl)], nil, nil)
        end
    end
end)
-- 角色创建
luaevt.reg('Create_Role', function()
    luaevt.trig("AdjustReport", AdjustPointContast.ADJUST_CREATE_ROLE_Android, nil, nil)
    luaevt.trig("AdjustReport", AdjustPointContast.FB_Complete_Registration_A, nil, nil)
end)
-- 进入服务器
luaevt.reg('Enter_Server', function(cate, pid)
    if pid then
        local server = cache.getCurrentServer()
        luaevt.trig('SDK_PushUserOp_LUA', AdjustPointContast.ADJUST_ENTER_SERVER_Android, pid, pid, 1, server.id, server.name, server.id, server.name, 0, 200)
        return
    end
    luaevt.trig("AdjustReport", AdjustPointContast.ADJUST_ENTER_SERVER_Android, nil, nil)
end)
-- 进入游戏
luaevt.reg('Enter_Game', function(cate, pid)
    if pid then
        local server = cache.getCurrentServer()
        luaevt.trig('SDK_PushUserOp_LUA', AdjustPointContast.ADJUST_ENTER_GAME_Android, pid, pid, 1, server.id, server.name, server.id, server.name, 0, 200)
        return
    end
    luaevt.trig("AdjustReport", AdjustPointContast.ADJUST_ENTER_GAME_Android, nil, nil)
end)
-- 首冲上边呢
-- 充值上边呢
-- 安装完成app
luaevt.reg('Install_Game_Completed', function()
    luaevt.trig("AdjustReport", AdjustPointContast.ADJUST_INSTALL_Android, nil, nil)
end)
-- 游戏更新检查
luaevt.reg('Update_Game_Check', function()
    luaevt.trig("AdjustReport", AdjustPointContast.ADJUST_UPDATE_CHECK_Android, nil, nil)
end)
-- 游戏更新完成
luaevt.reg('Update_Game_Completed', function()
    luaevt.trig("AdjustReport", AdjustPointContast.ADJUST_UPDATE_COMPLETED_Android, nil, nil)
end)

luaevt.reg('Force_Cold_Update', function()
    local bichannel = luaevt.trig("SDK_GetChannel")
    if not bichannel then
        bichannel = ""
    end
    if type(bichannel) ~= "string" then
        bichannel = tostring(bichannel)
    end
    UnityEngine.Application.OpenURL(___CONFIG__ACCOUNT_URL .. "device/forcecoldupdate?did=" .. bichannel)
end)

luaevt.reg('___EVENT__ACCOUNT_SERVER_CONFIG', function()
    local url = luaevt.trig("SDK_GetMetaData", "ACCOUNT_URL")
    if ___CONFIG__CHANGESERVER_URL then 
        ___CONFIG__ACCOUNT_URL = ___CONFIG__CHANGESERVER_URL
    elseif type(url) == "string" and url ~= "" then
        ___CONFIG__ACCOUNT_URL = url
    end
end)

-- platform in { "Facebook" }
luaevt.reg("Dist_FBShareImage_OnComplete", function(cate, data)
    clr.coroutine(function()
        local respone = req.rewardFinish("3001")
        -- "3001" 奖励任务ID
        if api.success(respone) then
            local data = respone.val
            if data["3001"] ~= nil then
                cache.setIsShareTaskComplete(data["3001"].state ~= -1)
            end
        end
        luaevt.trig("ShareSDK_OnComplete", action)
        require("ui.control.manager.DialogManager").ShowToast(lang.trans("share_success_title"))
    end)
    cache.setSharePlatform("")
    luaevt.trig("ShareSDK_CloseDialog")
end)

luaevt.reg("Dist_FBShareImage_OnFail", function(cate, data)
    require("ui.control.manager.DialogManager").ShowToast(lang.trans("not_install_facebook"))
end)

luaevt.reg("Dist_FBShareImage_OnCancel", function(cate, data)
    luaevt.trig("ShareSDK_OnCancel")
end)

local productsMap = nil
luaevt.reg("SDK_OfferProducts", function(cate, productsJson)
    if productsJson then
        productsTab = json.decode(productsJson)
        productsMap = {}
        for k,v in pairs(productsTab) do
            productsMap[v.itemId] = v
        end
    end
end)

luaevt.reg("GetProducts", function()
    return productsMap
end)

-- ---------------------------------- login
luaevt.reg("Dist_LoginSuccess_SGP", function(cate, pid, token, uid, channel, cuid, bindPhone, bindEmail, isQQ, ysdk_openkey)
    clr.coroutine(function ()
        luaevt.trig("BICheckPoint", "sdk_login_success", "11.1")
        luaevt.trig("SDK_Report", "sdk_login_done", channel, uid, clr.plat)
        ndump(cate, pid, token, uid, channel, cuid, bindPhone, bindEmail, isQQ, ysdk_openkey)
        local uinfo = {
            uid = uid,
            accessToken = token,
            productId = pid
        }
        local biChannel = luaevt.trig('SDK_GetChannel')
        if not biChannel or biChannel == '' then
            biChannel = channel
        end

        local LoginCtrl = require("ui.controllers.login.LoginCtrl")
        LoginCtrl.instance:SetLoginFlag(true)
        luaevt.trig("SDK_GetProducts")
        while not LoginCtrl.___deviceOver do
            coroutine.yield()
        end
        if not cuid or cuid == "" then
            cuid = uid
        end
        cache.setUid(uid)
        cache.setCuid(cuid)
        cache.setChannel(channel)
        local pf = "hoolai_sgp_android"
        local resp = req.unitedlogin(pf, cuid, channel, biChannel, uinfo)
        if api.success(resp) then
            -- test
            LoginCtrl.___isQQ = tobool(isQQ)
            LoginCtrl.___ysdk_openkey = tostring(ysdk_openkey)
            LoginCtrl.___ysdk_openid = tostring(cuid)
            luaevt.trig("SendBIReport", "login_success", "12")
            local data = resp.val
            if type(LoginCtrl.OnLoginSuccess) == "function" then
                LoginCtrl.OnLoginSuccess(channel)
            end
        end
    end)
end)

luaevt.reg("Dist_LoginFailed", function()
    local LoginCtrl = require("ui.controllers.login.LoginCtrl")
    if LoginCtrl.instance then
        LoginCtrl.instance:SetLoginFlag(false)
    end
    luaevt.trig("BICheckPoint", "sdk_login_failed", "11.2")
end)

local serverZone = 28800

local function GetCurrentTime()
    local function get_timezone()
        local now = os.time()
        return os.difftime(now, os.time(os.date("!*t", now)))
    end
    local localTimeZone = get_timezone()
    return os.date("%H:%M:%S", os.time() - (localTimeZone - serverZone))
end

local function GetCurrentData()
    local function get_timezone()
        local now = os.time()
        return os.difftime(now, os.time(os.date("!*t", now)))
    end
    local localTimeZone = get_timezone()
    return os.date("%Y-%m-%d", os.time() - (localTimeZone - serverZone))
end

-- BI report ----------
luaevt.reg("HasSgpSDK", function()
    return true
end)

local function SendBIReport(metric, data)
    local jsonData = json.encode(data)
    luaevt.trig("SDK_HoolaiBIReport", metric, jsonData)
end

-- earning/expenditure/flow 获得/消耗/流动
luaevt.reg("HoolaiBISendEconomy", function(cate, currency, amount, value, kingdom, phylum, classfield, genus)
    local playerInfoModel = PlayerInfoModel.new()
    local metric = "Economy"
    local data = {
        currency = currency,
        amount = amount,
        value = value,
        kingdom = kingdom,
        phylum = phylum,
        classfield = classfield,
        family = "",
        genus = genus,
        economyDate = GetCurrentData(),
        economyTime = GetCurrentTime(),
        extra = "download_from:" .. tostring(luaevt.trig("SDK_GetChannel") or "") .. "," .. "user_level:" .. tostring(playerInfoModel:GetLevel()),
        udid = luaevt.trig("GetUDID") or clr.capid(),
        roleid = clr.capid(),
    }
    SendBIReport(metric, data)
end)

local function SendLanguageBI(metric, data)
    clr.coroutine(function ()
        local jsonData = json.encode(data)
        -- 这些参数都是死的
        local urlStr = "http://119.28.108.214/tracking/?snid=666&gameid=107&metric=" .. metric .. "&clientid=123&ip=192.168.31.241&ds=" .. GetCurrentData() .. "&jsonString=" .. jsonData
        req.post(urlStr, nil, nil, nil, true)
    end)
end

-- 金币报送
luaevt.reg("HoolaiBISendCounter", function(cate, counter, value, phylum)
    local playerInfoModel = PlayerInfoModel.new()
    local metric = "Counter"
    local data = {
        userId = cache.getUid() or "123456",
        userLevel = tostring(playerInfoModel:GetLevel()),
        counter = counter,
        value = value,
        kingdom = luaevt.trig("GetLanguageFlag"),
        phylum = phylum,
        classfield = "",
        family = "",
        genus = "",
        counterDate = GetCurrentData(),
        counterTime = GetCurrentTime(),
        extra = "download_from:" .. tostring(luaevt.trig("SDK_GetChannel") or "") .. "," .. "user_level:" .. tostring(playerInfoModel:GetLevel()) .. "," .. "rolename:" .. playerInfoModel:GetName(),
        udId = luaevt.trig("GetUDID") or clr.capid(),
        roleId = clr.capid(),
    }
    SendLanguageBI(metric, data)
end)

luaevt.reg("GetLanguageFlag", function()
    local settingsLanguageModel = SettingsLanguageModel.new()
    local langId = settingsLanguageModel:GetDeviceLanguage() or "sgp"
    return settingsLanguageModel:GetLang2Server(langId) or "sgp"
end)

return sdk_sgp_ios

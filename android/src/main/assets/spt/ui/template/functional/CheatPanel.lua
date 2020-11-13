local CheatPanel = class(unity.base)

function CheatPanel:ctor()
    self.notallowed = true
    local cheatCode = ""
    self.___ex.btn.bO:regOnButtonClick(function()
        local inputCode = self.___ex.input.text
        self.___ex.input.text = ""
        self.___ex.node.input:SetActive(false)
        self.___ex.node.info:SetActive(false)

        if inputCode and inputCode ~= "" then
            self:DoCheatCode(inputCode)
        else
            local status = not self.___ex.node.btn.activeSelf
            self.___ex.node.btn:SetActive(status)
            if status then
                require("ui.control.manager.UISoundManager").play("104")
            end
        end
        cheatCode = ""
    end)

    self.___ex.btn.bA:regOnButtonClick(function()
        cheatCode = cheatCode.."A"
        self:DoCheatCode(cheatCode)
    end)
    self.___ex.btn.bB:regOnButtonClick(function()
        cheatCode = cheatCode.."B"
        self:DoCheatCode(cheatCode)
    end)
    self.___ex.btn.bC:regOnButtonClick(function()
        cheatCode = cheatCode.."C"
        self:DoCheatCode(cheatCode)
    end)
    self.___ex.btn.bD:regOnButtonClick(function()
        cheatCode = cheatCode.."D"
        self:DoCheatCode(cheatCode)
    end)
end

function CheatPanel:DoCheatCode(str)
    if str == "AAAB" then
        self.notallowed = true
        self:coroutine(function()
            local done = false
            local resp = req.checkCheat()
            while not done do
                if api.success(resp) or resp.failed ~= 'network' then
                    done = true
                else
                    resp = resp:repost()
                end
            end
            if api.success(resp) then
                if type(resp.val) == 'table' and api.bool(resp.val.allow) then
                    self.notallowed = nil
                end
            else
                self.notallowed = nil
            end
            if not self.notallowed then
                require("ui.control.manager.UISoundManager").play("125")
            end
        end)
    elseif str == "AAABBABBC" then
        if not self.notallowed then
            require("ui.control.manager.UISoundManager").play("shoot_train_win")
            self.___ex.node.input:SetActive(true)
        end
    elseif str == "AAABBABBDA" then
        local ratiow, ratioh = luaevt.trig('GetRatio')
        local data = {
            osv = luaevt.trig('GetSysVersionNum'),
            model = luaevt.trig('GetPhoneType'),
            oper = luaevt.trig('GetNetOperName'),
            net = luaevt.trig('GetNetType'),
            width = ratiow,
            height = ratioh,

            capid = clr.capid(),
            plat = clr.plat,
            ver = _G["___resver"],
            flags = clr.table(clr.Capstones.UnityFramework.ResManager.GetDistributeFlags()),
            udid = luaevt.trig('GetUDID'),
            mac = luaevt.trig('GetMacAddr'),
            imei = luaevt.trig('GetImei'),
            bichannel = luaevt.trig('SDK_GetChannel'),

            app = luaevt.trig('SDK_GetAppId'),
            appname = luaevt.trig('SDK_GetAppName'),
            appver = luaevt.trig('SDK_GetAppVerCode'),
            appvername = luaevt.trig('SDK_GetAppVerName'),
        }
        self.___ex.node.info:SetActive(false)
        self.___ex.node.info:SetActive(true)
        self.___ex.info.text = dump(data)

        clr.bcoroutine(self.___ex.node.info, function()
            coroutine.yield(clr.UnityEngine.WaitForSeconds(15))
            self.___ex.node.info:SetActive(false)
        end)
    elseif string.sub(str, 1, 13) == "switchserver:" then
        if not self.notallowed then
            local url = string.sub(str, 14)
            unity.changeServerTo(url)
        end
    elseif str == "luaconsole:" then
        if not self.notallowed then
            res.Instantiate('Assets/CapstonesRes/Game/UI/Common/Template/Functional/SimpleLuaConsole.prefab')
        end
    elseif str == "clear:update" then
        clr.Capstones.UnityFramework.ResManager.ResetCacheVersion()
        unity.restart()
    elseif str == "run" then
        clr.coroutine(function()
            function sendMessage(ret)
                clr.coroutine(function()
                    req.remoteDebug_setResult(ret)
                end)
            end
            local resp = req.remoteDebug_getString()
            if api.success(resp) and resp.val.code then
                local data = resp.val
                local func, emsg = loadstring(data.code)
                xpcall(func, function(err) return dump(err) end)
            end
        end)
    end
end

return CheatPanel

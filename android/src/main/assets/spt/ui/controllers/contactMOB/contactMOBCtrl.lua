local BaseCtrl = require("ui.controllers.BaseCtrl")
local FormationSelectTeamPageCtrl = class(BaseCtrl)
local UnityEngine = clr.UnityEngine
local Application = UnityEngine.Application
local contactMOBCtrl = class(BaseCtrl)

function contactMOBCtrl:Init()
    local path = "Assets/CapstonesRes/Game/UI/Scene/Login/MailBoard.prefab"
    local dlg, comp = res.ShowDialog(path, "overlay", false)
    comp.contentcomp.sendFunc = function() self:Send() end
end

function contactMOBCtrl:Send()
    local paramTab = {}
    table.insert(paramTab, {"subject", "【CMM】に関する問い合わせ"})
    table.insert(paramTab, {"body", "お問い合わせ内容：" .. self:getSuffix()})

    Application.OpenURL(self:encode("mailto:cmm@support.mobcast.jp", paramTab))
end

function contactMOBCtrl:getSuffix()
    local suffixVal = {}
    suffixVal.oper = luaevt.trig("GetNetOperName")
    suffixVal.osv = luaevt.trig('GetSysVersionNum')
    suffixVal.appVerName = luaevt.trig('SDK_GetAppVerName')
    if type(cache.getAccountId) == "function" then
        suffixVal.accountId = cache.getAccountId()
    end
    
    local suffix = "\n\n\n\n--------\nお客様情報（削除しないで下さい）\n"
    
    for k, v in pairs(suffixVal) do
        suffix = suffix .. lang.transstr("mail_suffix_" .. k) .. ": " .. v .. "\n"
    end

    return suffix
end

function contactMOBCtrl:encode(str, tab)
    local function urlencode(str)
        return string.gsub(str, "([^%w%.%-])", string.urlencodeChar) -- plus sign("+") does not work in mailto protocol(*-_-*|)
    end

    for i, v in ipairs(tab) do
        if i == 1 then
            str = str .. "?"
        end

        str = str .. urlencode(v[1]) .. "=" .. urlencode(v[2])

        if i ~= # tab then
            str = str .. "&"
        end
    end

    return str
end


return contactMOBCtrl
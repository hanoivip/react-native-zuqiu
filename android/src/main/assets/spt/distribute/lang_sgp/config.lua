___CONFIG__ACCOUNT_URL = "http://sgpt.capstones.cn/" -- must end with '/'

luaevt.trig('___EVENT__ACCOUNT_SERVER_CONFIG')

___CONFIG__BASE_URL = ___CONFIG__ACCOUNT_URL

luaevt.reg("__SGP__VERSION__", function()
    return true
end)

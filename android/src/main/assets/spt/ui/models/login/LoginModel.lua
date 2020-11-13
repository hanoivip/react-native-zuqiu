local LoginModel = {}

function LoginModel.SetServers(servers)
    if type(servers) == "table" then
        local players = {}
        local serversWithIndex = {}
        for i, v in ipairs(servers) do
            local server = clone(v)
            server.index = i
            table.insert(serversWithIndex, server)
            if v.id and type(v.player) == "table" and v.player.name and v.player.token then
                local player = clone(server)
                player.sid = v.id
                table.insert(players, player)
            end
        end
        LoginModel.servers = serversWithIndex
        LoginModel.players = players
    end
end

function LoginModel.GetServers()
    return LoginModel.servers
end

function LoginModel.GetRoleToken()
    local currentServer = LoginModel.GetCurrentServer()
    if type(currentServer) == "table" and type(currentServer.player) == "table" then
        return currentServer.player.token
    end
end

function LoginModel.SetAccount(account)
    return cache.setAccount(account)
end

function LoginModel.GetAccount()
    return cache.getAccount()
end

function LoginModel.IsFirstLogin()
    local accountData = LoginModel.GetAccount() or {}
    return accountData.isFirstLogin 
end

function LoginModel.SetCurrentServer(server)
    if not server then
        -- 自动连接第一个服务器
        local servers = LoginModel.GetServers()
        if type(servers) == "table" and #servers > 0 then
            server = servers[1]
        end
    end
    if server then
        cache.setCurrentServer(server)
        EventSystem.SendEvent("SetCurrentServer", server)
    end
end

function LoginModel.GetCurrentServer()
    return cache.getCurrentServer()
end

function LoginModel.GetPlayers()
    return LoginModel.players
end

return LoginModel


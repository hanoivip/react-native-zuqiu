local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local ClubNameGenerate = require("data.ClubNameGenerate")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local FilterWords = require("data.FilterWords")
local TeamNameCtrl = class(BaseCtrl)

TeamNameCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/TeamCreate/Prefab/TeamName.prefab"

function TeamNameCtrl:Init()
    self.view:RegOnRandomNameBtnClick(function()
        local teamName = self:RandomTeamName()        
        self.view:SetTeamName(teamName)
    end)
    self.view:RegOnBackBtnClick(function()
        self.exitFunc = function ()
            local lastSceneData = res.ctrlStack[#res.ctrlStack]
            local ctrlPath = "ui.controllers.teamCreate.TeamUniformCtrl"
            if lastSceneData.path == ctrlPath then
                res.PopSceneWithoutCurrent()
            else
                res.ChangeScene(ctrlPath)
            end
        end
        self.view:onExitScene()
    end)
    self.view:RegOnContinueBtnClick(function()
        local teamName = self.view:GetTeamName()
        if teamName == "" then
            DialogManager.ShowToastByLang("team_name_empty_warning")
            return
        end
        self.view:coroutine(function ()
            local response = req.setTeamName(teamName)
            if api.success(response) then
                local playerInfoModel = PlayerInfoModel.new()
                playerInfoModel:SetName(teamName)
                local server = cache.getCurrentServer()
                local serverCode = server.id
                local serverName = server.name
                local playerName = playerInfoModel:GetName()
                local roleId = playerInfoModel:GetID()
                local roleLvl = playerInfoModel:GetLevel()
                luaevt.trig("SDK_Report", "created_role", playerInfoModel:GetID(), playerInfoModel:GetName(), teamName, serverCode, serverName, roleId, playerName, roleLvl)
                luaevt.trig("HoolaiBISendCounterTask", 15)
                luaevt.trig("SendBIReport", "name", "27")
                luaevt.trig("HoolaiBISendGameinfo", "name", "27")
                self.exitFunc = function ()
                    res.ChangeScene("ui.controllers.home.HomeMainCtrl")

                    local function ShowSDKPlatform()
                        local userId = cache.getCuid()
                        local sid = playerInfoModel:GetSID()
                        local roleId = playerInfoModel:GetID()
                        local roleName = playerInfoModel:GetName()
                        local roleLevel = playerInfoModel:GetLevel()
                        -- 显示SDK的气泡浮窗(要在创建角色后调用)
                        luaevt.trig("SDK_ShowPlatform", userId, sid, roleId, roleName, roleLevel)
                    end
                    ShowSDKPlatform()
                end
                self.view:onExitScene()
            end
        end)
    end)
    self.view:RegOnExitScene(function ()
        if type(self.exitFunc) == "function" then
            self.exitFunc()
        end
    end)
end

function TeamNameCtrl:Refresh()
    TeamNameCtrl.super.Refresh(self)
    local teamName = self:RandomTeamName()        
    self.view:Init(teamName)
end

function TeamNameCtrl:GetStatusData()
    return nil
end

function TeamNameCtrl:OnEnterScene()
end

function TeamNameCtrl:RandomTeamName()
    local function CheckAndReturn(str)
        for i, v in ipairs(FilterWords) do
            if string.find(str, v) then
                return self:RandomTeamName()
            end
        end
        return str
    end
    local lengthLimit = 7
    local useObjectName = math.random() > 0.5
    local cityName, cityNameLength = self:RandomSomeStaticName('cityName')
    
    if lengthLimit - cityNameLength <= 0 then
        return CheckAndReturn(cityName)
    end
    
    local fcName, fcNameLength = self:RandomSomeStaticName('fcName', lengthLimit - cityNameLength)
    
    if lengthLimit - cityNameLength - fcNameLength <= 0 or not useObjectName then
        return CheckAndReturn(cityName .. fcName)
    else
        local objectName = self:RandomSomeStaticName('objectName', lengthLimit - cityNameLength - fcNameLength)
        return CheckAndReturn(cityName .. objectName .. fcName)
    end

    return 'randomName'
end

function TeamNameCtrl:RandomSomeStaticName(key, lengthLimit)
    if type(ClubNameGenerate[key]) == 'table' then
        local total = 0
        local countTab = {}

        for length, nameTab in pairs(ClubNameGenerate[key]) do
            if not lengthLimit or lengthLimit >= tonumber(length) then
                total = total + #nameTab
                table.insert(countTab, {length = length, total = total})
            end
        end

        local name, length

        if total > 0 then
            local randomNum = math.floor(math.randomInRange(1, total))
            for i, v in ipairs(countTab) do
                if randomNum <= v.total then
                    name = ClubNameGenerate[key][v.length][#ClubNameGenerate[key][v.length] - (v.total - randomNum)]
                    length = tonumber(v.length)

                    return name, length
                end
            end
        end
    end

    return '', 0
end

return TeamNameCtrl


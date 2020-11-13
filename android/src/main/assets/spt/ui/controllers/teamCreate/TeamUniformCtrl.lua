local BaseCtrl = require("ui.controllers.BaseCtrl")
local TeamUniformModel = require("ui.models.common.TeamUniformModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local ShirtMask = require("data.ShirtMask")
local ClothUtils = require("cloth.ClothUtils")

local TeamUniformCtrl = class(BaseCtrl)

TeamUniformCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/TeamCreate/Prefab/TeamUniform.prefab"

function TeamUniformCtrl:Init()
    self.view:RegOnRandomBtnClick(function (eventData)
        self.homeUniformData, self.awayUniformData, self.homeGkUniformData, self.awayGkUniformData, self.smallUniformId, self.gkSmallUniformId, self.spectators = self:RandomUniform(true)
        self.view:OnRandomUniform(TeamUniformModel.new(self.homeUniformData), TeamUniformModel.new(self.awayUniformData))
    end)

    self.view:RegOnExitScene(function ()
        if type(self.exitFunc) == "function" then
            self.exitFunc()
        end
    end)

    self.view:RegOnContinueBtnClick(function (eventData)
        self.view:coroutine(function ()
            local response = req.setTeamUniform(self.homeUniformData, self.awayUniformData, self.homeGkUniformData, self.awayGkUniformData, self.smallUniformId, self.gkSmallUniformId, self.spectators)
            if api.success(response) then
                local playerInfoModel = PlayerInfoModel.new()
                playerInfoModel:SetTeamUniform(TeamUniformModel.UniformType.Home, self.homeUniformData)
                playerInfoModel:SetTeamUniform(TeamUniformModel.UniformType.Away, self.awayUniformData)
                playerInfoModel:SetTeamUniform(TeamUniformModel.UniformType.HomeGk, self.homeGkUniformData)
                playerInfoModel:SetTeamUniform(TeamUniformModel.UniformType.AwayGk, self.awayGkUniformData)
                playerInfoModel:SetSmallTeamUniform(self.smallTeamUniformId)
                playerInfoModel:SetGkSmallTeamUniform(self.gkSmallTeamUniformId)
                playerInfoModel:SetSpectators(self.spectators)
                luaevt.trig("HoolaiBISendCounterTask", 14)
                luaevt.trig("SendBIReport" ,"cloth", "26")
                luaevt.trig("HoolaiBISendGameinfo", "cloth", "26")
                self.exitFunc = function ()
                    res.ChangeScene("ui.controllers.teamCreate.TeamNameCtrl")
                end
                self.view:DoExitSceneAnimation()
            end
        end)
    end)

    self.view:RegOnBackBtnClick(function ()
        self.exitFunc = function ()
            local lastSceneData = res.ctrlStack[#res.ctrlStack]
            local ctrlPath = "ui.controllers.teamCreate.TeamLogoCreateCtrl"
            if lastSceneData.path == ctrlPath then
                res.PopSceneWithoutCurrent()
            else
                res.ChangeScene(ctrlPath)
            end
        end
        self.view:DoExitSceneAnimation()
    end)
end

function TeamUniformCtrl:Refresh()
    TeamUniformCtrl.super.Refresh(self)
    local playerInfoModel = PlayerInfoModel.new()
    --[[
    self.homeUniformData = playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.Home)
    self.awayUniformData = playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.Away)
    if type(self.homeUniformData) ~= "table" or type(self.awayUniformData) ~= "table" then
        self.homeUniformData, self.awayUniformData, self.homeGkUniformData, self.awayGkUniformData = self:RandomUniform()
    end
    --]]
    self.homeUniformData, self.awayUniformData, self.homeGkUniformData, self.awayGkUniformData, self.smallUniformId, self.gkSmallUniformId, self.spectators = self:RandomUniform()

    local teamLogo = TeamLogoCtrl.new()
    teamLogo:Init(playerInfoModel:GetTeamLogo())

    self.view:InitView(TeamUniformModel.new(self.homeUniformData), TeamUniformModel.new(self.awayUniformData), teamLogo.view)
end

function TeamUniformCtrl:GetStatusData()
    return nil
end

function TeamUniformCtrl:OnEnterScene()
    self.view:DoEnterSceneAnimation()
end

local constNumColor = {
    Black = "0.141,0.141,0.141,1",
    White = "0.803,0.803,0.803,1",
    Red = "0.690,0.047,0.047,1",
    Blue = "0.086,0.270,0.705,1",
}

function TeamUniformCtrl:RandomUniform(randomMask)
    -- 主队的配色由队徽底色方案决定，能随机的只有mask
    -- 客队只能从AwayShirt中随机
    -- 门将只能从GKShirt中随机

    local playerInfoModel = PlayerInfoModel.new()
    local teamLogo = playerInfoModel:GetTeamLogo()
    if type(teamLogo) == "table" then
        local colorId = tostring(teamLogo.colorId)

        local homeUniformData = TeamUniformModel.GetHomeUniformColorData(colorId)
        homeUniformData.mask = TeamUniformModel.InitShirtMask[math.random(#TeamUniformModel.InitShirtMask)]
        local homeUniformModel = TeamUniformModel.new(homeUniformData)

        local awayUniformModel = TeamUniformModel.GenerateAwayUniformModel(homeUniformModel, randomMask)
        local awayUniformData = awayUniformModel.data
        local homeGkUniformData = TeamUniformModel.GenerateGkUniformModel(homeUniformModel).data
        local awayGkUniformData = TeamUniformModel.GenerateGkUniformModel(awayUniformModel).data

        local smallUniformId, gkSmallUniformId = TeamUniformModel.GenerateSmallAndGkSmallTeamUniformId()

        local firstColor, secondColor = TeamUniformModel.GetSpectatorColors(colorId)
        local spectators = {
            firstColor = firstColor,
            secondColor = secondColor,
            maskTex = ShirtMask[homeUniformData.mask].auditorMask,
        }
        return homeUniformData, awayUniformData, homeGkUniformData, awayGkUniformData, smallUniformId, gkSmallUniformId, spectators
    else
        local homeUniformData = TeamUniformModel.GetHomeUniformInitData(teamLogo)
        local homeUniformModel = TeamUniformModel.new(homeUniformData)

        local awayUniformData = TeamUniformModel.GetAwayUniformInitData(teamLogo)
        local awayUniformModel = TeamUniformModel.new(awayUniformData)
        local homeGkUniformData = TeamUniformModel.GenerateGkUniformModel(homeUniformModel).data
        local awayGkUniformData = TeamUniformModel.GenerateGkUniformModel(awayUniformModel).data

        if randomMask then
            homeUniformData.mask = TeamUniformModel.InitShirtMask[math.random(#TeamUniformModel.InitShirtMask)]
            awayUniformData.mask = homeUniformData.mask

            -- 随机mask之后可能会造成背号颜色与队服颜色撞色
            -- home
            local hue1, saturation1, value1 = ClothUtils.getHsvFromRgb(ClothUtils.parseColorString(homeUniformData.maskRedChannel))
            local isMainWhite = false
            local isMainBlack = false
            local isAssistWhite = false
            local isAssistBlack = false
            if saturation1 <= 0.3 and value1 >= 0.6 then
                -- white
                isMainWhite = true
                isMainBlack = false
            elseif value1 < 0.3 then
                isMainWhite = false
                isMainBlack = true
            end
            hue1, saturation1, value1 = ClothUtils.getHsvFromRgb(ClothUtils.parseColorString(homeUniformData.maskGreenChannel))
            if saturation1 <= 0.3 and value1 >= 0.6 then
                -- white
                isAssistWhite = true
                isAssistBlack = false
            elseif value1 < 0.3 then
                isAssistWhite = false
                isAssistBlack = true                    
            end
            if isMainWhite and isAssistWhite then
                homeUniformData.backNumColor = constNumColor.Black
            elseif isMainBlack and isAssistBlack then
                homeUniformData.backNumColor = constNumColor.White
            elseif (isMainBlack and isAssistWhite) or (isMainWhite and isAssistBlack) then
                homeUniformData.backNumColor = constNumColor.Red
            elseif (isMainWhite and not isAssistWhite) or (not isMainWhite and isAssistWhite) then
                homeUniformData.backNumColor = constNumColor.Black
            elseif (isMainBlack and not isAssistBlack) or (not isMainBlack and isAssistBlack) then
                homeUniformData.backNumColor = constNumColor.White
            elseif not isMainWhite and not isMainBlack and not isAssistWhite and not isAssistBlack then
                homeUniformData.backNumColor = constNumColor.White
            else
                homeUniformData.backNumColor = constNumColor.Blue         
            end
            -- trousersNum
            hue1, saturation1, value1 = ClothUtils.getHsvFromRgb(ClothUtils.parseColorString(homeUniformData.maskBlueChannel))
            local needBlackNum = false
            if saturation1 <= 0.3 and value1 >= 0.6 then
                -- white
                needBlackNum = true
            end
            homeUniformData.trouNumColor = needBlackNum and constNumColor.Black or constNumColor.White

            -- away
            hue1, saturation1, value1 = ClothUtils.getHsvFromRgb(ClothUtils.parseColorString(awayUniformData.maskRedChannel))
            isMainWhite = false
            isMainBlack = false
            isAssistWhite = false
            isAssistBlack = false
            if saturation1 <= 0.3 and value1 >= 0.6 then
                -- white
                isMainWhite = true
                isMainBlack = false
            elseif value1 < 0.3 then
                isMainWhite = false
                isMainBlack = true
            end
            hue1, saturation1, value1 = ClothUtils.getHsvFromRgb(ClothUtils.parseColorString(awayUniformData.maskGreenChannel))
            if saturation1 <= 0.3 and value1 >= 0.6 then
                -- white
                isAssistWhite = true
                isAssistBlack = false
            elseif value1 < 0.3 then
                isAssistWhite = false
                isAssistBlack = true                    
            end
            if isMainWhite and isAssistWhite then
                awayUniformData.backNumColor = constNumColor.Black
            elseif isMainBlack and isAssistBlack then
                awayUniformData.backNumColor = constNumColor.White
            elseif (isMainBlack and isAssistWhite) or (isMainWhite and isAssistBlack) then
                awayUniformData.backNumColor = constNumColor.Red
            elseif (isMainWhite and not isAssistWhite) or (not isMainWhite and isAssistWhite) then
                awayUniformData.backNumColor = constNumColor.Black
            elseif (isMainBlack and not isAssistBlack) or (not isMainBlack and isAssistBlack) then
                awayUniformData.backNumColor = constNumColor.White
            elseif not isMainWhite and not isMainBlack and not isAssistWhite and not isAssistBlack then
                awayUniformData.backNumColor = constNumColor.White
            else
                awayUniformData.backNumColor = constNumColor.Blue         
            end

            -- trousersNum
            hue1, saturation1, value1 = ClothUtils.getHsvFromRgb(ClothUtils.parseColorString(awayUniformData.maskBlueChannel))
            needBlackNum = false
            if saturation1 <= 0.3 and value1 >= 0.6 then
                -- white
                needBlackNum = true
            end
            awayUniformData.trouNumColor = needBlackNum and constNumColor.Black or constNumColor.White
        end

        local smallUniformId = TeamUniformModel.GetSmallTeamUniformId(teamLogo)
        local gkSmallUniformId = TeamUniformModel.GetGkSmallTeamUniformId(teamLogo)

        local spectators = TeamUniformModel.GetSpectators(teamLogo)

        return homeUniformData, awayUniformData, homeGkUniformData, awayGkUniformData, smallUniformId, gkSmallUniformId, spectators 
    end
end

return TeamUniformCtrl

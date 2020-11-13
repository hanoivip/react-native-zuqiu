local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TeamUniformModel = require("ui.models.common.TeamUniformModel")
local TeamLogoModel = require("ui.models.common.TeamLogoModel")
local ShirtMask = require("data.ShirtMask")
local DialogManager = require("ui.control.manager.DialogManager")
local UISoundManager = require("ui.control.manager.UISoundManager")
local Toggle = clr.UnityEngine.UI.Toggle
local TeamUniformModifyCtrl = class(BaseCtrl)
local ClothUtils = require("cloth.ClothUtils")

local constNumColor = {
    Black = "0.141,0.141,0.141,1",
    White = "0.803,0.803,0.803,1",
    Red = "0.690,0.047,0.047,1",
    Blue = "0.086,0.270,0.705,1",
}

TeamUniformModifyCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/TeamCreate/Prefab/TeamUniformModify.prefab"

function TeamUniformModifyCtrl:Init()
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
    end)

    self.view:RegOnSave(function()
        UISoundManager.play("Player/encourageSound", 1)
        self.view:coroutine(function()
            local playerInfoModel = PlayerInfoModel.new()
            local homeUniformData, homeUniformModel, awayUniformData, awayUniformModel, homeGkUniformData, awayGkUniformData, spectators
            local smallUniformId, gkSmallUniformId = TeamUniformModel.GenerateSmallAndGkSmallTeamUniformId()

            if self.isHomeShirt then
                homeUniformData = self.currentTeamUniformData
                homeUniformModel = TeamUniformModel.new(homeUniformData)
                awayUniformData = playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.Away)
                awayUniformModel = TeamUniformModel.new(awayUniformData)
                homeGkUniformData = TeamUniformModel.GenerateGkUniformModel(homeUniformModel).data

                awayGkUniformData = playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.AwayGk)

                if homeUniformData.colorId then
                    firstColor, secondColor = TeamUniformModel.GetSpectatorColors(homeUniformData.colorId)
                    spectators = {
                        firstColor = firstColor,
                        secondColor = secondColor,
                        maskTex = ShirtMask[homeUniformData.mask].auditorMask,
                    }
                else
                    spectators = playerInfoModel:GetSpectators()
                end
            else
                homeUniformData = playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.Home)
                homeUniformModel = TeamUniformModel.new(homeUniformData)

                awayUniformData = self.currentTeamUniformData
                awayUniformModel = TeamUniformModel.new(awayUniformData)
                homeGkUniformData = playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.HomeGk)

                awayGkUniformData = TeamUniformModel.GenerateGkUniformModel(awayUniformModel).data

                spectators = playerInfoModel:GetSpectators()
            end

            local response = req.changeTeamUniform(homeUniformData, awayUniformData, homeGkUniformData, awayGkUniformData, smallUniformId,gkSmallUniformId, spectators)
            if api.success(response) then
                local playerInfoModel = PlayerInfoModel.new()
                playerInfoModel:SetTeamUniform(TeamUniformModel.UniformType.Home, homeUniformData)
                playerInfoModel:SetTeamUniform(TeamUniformModel.UniformType.Away, awayUniformData)
                playerInfoModel:SetTeamUniform(TeamUniformModel.UniformType.HomeGk, homeGkUniformData)
                playerInfoModel:SetTeamUniform(TeamUniformModel.UniformType.AwayGk, awayGkUniformData)
                playerInfoModel:SetSmallTeamUniform(smallUniformId)
                playerInfoModel:SetGkSmallTeamUniform(gkSmallUniformId)
                playerInfoModel:SetSpectators(spectators)
                EventSystem.SendEvent("SetShirtBG")
                DialogManager.ShowToast(lang.trans("formation_saveSuccess"))
                -- res.PopScene()
            end
        end)
    end)

    self:InitScroll()

    self.view:RegOnMenuMask(function()
        self:SwitchMenu("mask")
    end)

    self.view:RegOnMenuColor(function()
        self:SwitchMenu("color")
    end)
end

function TeamUniformModifyCtrl:InitScroll()
    local scroll = self.view:GetScroll()
    scroll:regOnCreateItem(function (scrollSelf, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/TeamCreate/Prefab/SmallShirt.prefab")
        scrollSelf:resetItem(spt, index)
        spt:regOnButtonClick(function()
            local data = spt.data
            if self.currentTag == "mask" then
                self.currentTeamUniformData.mask = data.mask
            elseif self.currentTag == "color" then
                self.currentTeamUniformData.colorId = data.colorId
                self.currentTeamUniformData.maskRedChannel = data.maskRedChannel
                self.currentTeamUniformData.maskGreenChannel = data.maskGreenChannel
                self.currentTeamUniformData.maskBlueChannel = data.maskBlueChannel
            end
            
            local hue1, saturation1, value1 = ClothUtils.getHsvFromRgb(ClothUtils.parseColorString(self.currentTeamUniformData.maskRedChannel))
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
            hue1, saturation1, value1 = ClothUtils.getHsvFromRgb(ClothUtils.parseColorString(self.currentTeamUniformData.maskGreenChannel))
            if saturation1 <= 0.3 and value1 >= 0.6 then
                -- white
                isAssistWhite = true
                isAssistBlack = false
            elseif value1 < 0.3 then
                isAssistWhite = false
                isAssistBlack = true                    
            end
            if isMainWhite and isAssistWhite then
                self.currentTeamUniformData.backNumColor = constNumColor.Black
            elseif isMainBlack and isAssistBlack then
                self.currentTeamUniformData.backNumColor = constNumColor.White
            elseif (isMainBlack and isAssistWhite) or (isMainWhite and isAssistBlack) then
                self.currentTeamUniformData.backNumColor = constNumColor.Red
            elseif (isMainWhite and not isAssistWhite) or (not isMainWhite and isAssistWhite) then
                self.currentTeamUniformData.backNumColor = constNumColor.Black
            elseif (isMainBlack and not isAssistBlack) or (not isMainBlack and isAssistBlack) then
                self.currentTeamUniformData.backNumColor = constNumColor.White
            elseif not isMainWhite and not isMainBlack and not isAssistWhite and not isAssistBlack then
                self.currentTeamUniformData.backNumColor = constNumColor.White
            else
                self.currentTeamUniformData.backNumColor = constNumColor.Blue         
            end
            -- trousersNum
            hue1, saturation1, value1 = ClothUtils.getHsvFromRgb(ClothUtils.parseColorString(self.currentTeamUniformData.maskBlueChannel))
            local needBlackNum = false
            if saturation1 <= 0.3 and value1 >= 0.6 then
                -- white
                needBlackNum = true
            end
            self.currentTeamUniformData.trouNumColor = needBlackNum and constNumColor.Black or constNumColor.White

            EventSystem.SendEvent("SetShirtBG", spt)
            self.view:SetPlayerCloth(self.currentTeamUniformData)
        end)
        return obj
    end)
    scroll:regOnResetItem(function (scrollSelf, spt, index)
        spt:Init(self.data[index])
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function TeamUniformModifyCtrl:Refresh(isHomeShirt, tag)
    self.view:ResetCameraPosition()
    tag = tag or "mask"
    self.isHomeShirt = isHomeShirt
    TeamUniformModifyCtrl.super.Refresh(self)
    self:SwitchMenu(tag)
    self.view.buttonGroup:selectMenuItem(tag)

    local playerInfoModel = PlayerInfoModel.new()
    self.currentTeamUniformData = clone(playerInfoModel:GetTeamUniform(isHomeShirt and TeamUniformModel.UniformType.Home or TeamUniformModel.UniformType.Away))
    self.view:SetPlayerCloth(self.currentTeamUniformData)
    self.view:SetPlyaerName(isHomeShirt)
end

function TeamUniformModifyCtrl:GetStatusData()
    return self.isHomeShirt, self.currentTag
end

function TeamUniformModifyCtrl:SwitchMenu(tag)
    self.currentTag = tag
    local data = {}
    if tag == "mask" then
        local maskData = TeamUniformModel.GetHomeUniformColorData("10")
        for i, v in ipairs(TeamUniformModel.InitShirtMask) do
            local clonedData = clone(maskData)
            clonedData.mask = v 
            table.insert(data, clonedData)
        end
    elseif tag == "color" then
        for i, v in ipairs(TeamLogoModel.Color) do
            local colorData = TeamUniformModel.GetHomeUniformColorData(v)
            colorData.mask = "Mask_24"
            table.insert(data, colorData)
        end
    end
    self.data = data
    self.view:JudgeScrollBarVisibility(#self.data)
    self.view:GetScroll():refresh(self.data)
    EventSystem.SendEvent("SetShirtBG")
end

return TeamUniformModifyCtrl

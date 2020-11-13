local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local AdventureItem = require("data.AdventureItem")
local LuaButton = require("ui.control.button.LuaButton")
local OpponentEventView = class(LuaButton)

function OpponentEventView:ctor()
    self.super.ctor(self)
    self.image = self.___ex.image
    self.frame = self.___ex.frame
    self.nameTxt = self.___ex.nameTxt
	self.signContent = self.___ex.signContent
	self.nameImg = self.___ex.nameImg
	self.signPrefabSpt = nil
    self:Init()
end

function OpponentEventView:Init()
    self:regOnButtonClick(function (eventData)
        if self.eventModel:IsShowDialog() then
            self.eventModel:TriggerEvent()
        end
    end)
end

local ColorRate = 255
function OpponentEventView:InitView(eventModel, greenswardResourceCache)
    self.eventModel = eventModel
    local opRes = eventModel:GetOpponentPic()
    local logoIndex = opRes.badge or "10001"
	local logoPic = AdventureItem[logoIndex] and AdventureItem[logoIndex].picIndex or "Logo1"
    self.image.overrideSprite = greenswardResourceCache:GetLogoRes(logoPic)
    local frameIndex = opRes.frame or "20001"
	local framePic = AdventureItem[frameIndex] and AdventureItem[frameIndex].picIndex or "Head_Frame1"
    self.frame.overrideSprite = greenswardResourceCache:GetHeadFrameRes(framePic)

	local nameTxt = eventModel:GetNameBorderName()
	self.nameImg.overrideSprite = greenswardResourceCache:GetNameBorderRes(nameTxt)
    self.nameTxt.text = eventModel:GetEventName()
	local r, g, b = eventModel:GetNameColorParam()
	self.nameTxt.color = Color(r/ColorRate, g/ColorRate, b/ColorRate)

	local signPrefabName = eventModel:GetSignPrefabName()
	if signPrefabName and signPrefabName ~= "" then 
		if self.signPrefabSpt then
			self.signPrefabSpt:InitView(eventModel)
		else
			local prefabRes = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Event/" .. signPrefabName .. ".prefab"
			local obj, spt = res.Instantiate(prefabRes)
			obj.transform:SetParent(self.signContent, false)
			self.signPrefabSpt = spt
			if self.signPrefabSpt then
				self.signPrefabSpt:InitView(eventModel)
			end
		end
	end
end

return OpponentEventView
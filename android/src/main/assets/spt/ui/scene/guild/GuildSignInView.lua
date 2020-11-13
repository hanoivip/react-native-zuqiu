local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color

local GuildSignInView = class(unity.base)

function GuildSignInView:ctor()
    self.infoBarDynParent = self.___ex.infoBar
    self.btnLog = self.___ex.btnLog
    self.btnCoinSign = self.___ex.btnCoinSign
    self.btnDiamonSign = self.___ex.btnDiamonSign
    self.signNumText = self.___ex.signNumText
    self.allNumText = self.___ex.allNumText
    self.contentArea = self.___ex.contentArea
    self.signedImg = self.___ex.signedImg
    self.signedImg2 = self.___ex.signedImg2
end

function GuildSignInView:start()
    self.btnLog:regOnButtonClick(function()
        if type(self.onBtnLogClick) == "function" then
            self.onBtnLogClick()
        end
    end)

    self.btnCoinSign:regOnButtonClick(function()
        if type(self.onBtnCoinSignClick) == "function" then
            self.onBtnCoinSignClick()
        end
    end)

    self.btnDiamonSign:regOnButtonClick(function()
        if type(self.onBtnDiamonSignClick) == "function" then
            self.onBtnDiamonSignClick()
        end
    end)

end

function GuildSignInView:InitView(model)
   self.signNumText.text = tostring(model:GetSignNum())
   self.allNumText.text =  "/" .. tostring(model:GetMemberNum())
   local signState = model:GetSelfSignState()
   if signState == 0 then
        self.signedImg:SetActive(false)
        self.signedImg2:SetActive(false)
        self:ShowButtons()
   elseif signState == 1 then
        self.signedImg:SetActive(true)
        self.signedImg2:SetActive(false)
        self:HideButtons()
   elseif signState == 2 then
        self.signedImg:SetActive(false)
        self.signedImg2:SetActive(true)
        self:HideButtons()
   end

   self:InitPacketState(model)
end

function GuildSignInView:HideButtons()
    self.btnCoinSign.gameObject:SetActive(false)
    self.btnDiamonSign.gameObject:SetActive(false)
end

function GuildSignInView:ShowButtons()
    self.btnCoinSign.gameObject:SetActive(true)
    self.btnDiamonSign.gameObject:SetActive(true)
end

function GuildSignInView:InitPacketState(model)
    local count = self.contentArea.transform.childCount
    local config = model:GetConfig()
    local packetList = model:GetRedPacketInfo()
    
    for i = 1, count do 
        local node = self.contentArea.transform:GetChild(i - 1).gameObject
        local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
        if nodeScript ~= nil then
            local configItem = config[tostring(i)]
            local isSend = packetList[i].send

            nodeScript:InitView(i, configItem.diamond, configItem.getNumber, configItem.signNumber, model:GetProgress(), isSend)
            nodeScript.packetContentClick = function()
                if type(self.packetItemContentClick) == "function" then
                    self.packetItemContentClick(i)
                end
            end
        end
    end
end


function GuildSignInView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return GuildSignInView

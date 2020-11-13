local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local TextAnchor = UnityEngine.TextAnchor

local ChatRedPacketView = class(unity.base)

function ChatRedPacketView:ctor()
    self.close1 = self.___ex.close1
    self.close2 = self.___ex.close2
    self.packetArea1 = self.___ex.packetArea1
    self.packetArea2 = self.___ex.packetArea2
    self.area1Panel1 = self.___ex.area1Panel1
    self.area1Panel2 = self.___ex.area1Panel2
    self.btnOpen = self.___ex.btnOpen
    self.date1 = self.___ex.date1
    self.date2 = self.___ex.date2
    self.scrollerView = self.___ex.scrollerView
    self.selfDiamondNum = self.___ex.selfDiamondNum
    self.packetNum = self.___ex.packetNum
    self.btnView = self.___ex.btnView
    self.animator = self.___ex.animator
    self.contentTxt = self.___ex.contentTxt
    self.contentTxt1 = self.___ex.contentTxt1
    self.parentRect = self.___ex.parentRect
    self.parentRect1 = self.___ex.parentRect1
    self.diamond = self.___ex.diamond
    self.diamond1 = self.___ex.diamond1

end

function ChatRedPacketView:start()
    DialogAnimation.Appear(self.transform)
    self.close1:regOnButtonClick(function()
        self:Close()
    end)
    self.close2:regOnButtonClick(function()
        self:Close()
    end)
    self.btnOpen:regOnButtonClick(function()
        if type(self.onBtnOpenPacketClick) == "function" then
            self.onBtnOpenPacketClick()
        end
    end)
    self.btnView:regOnButtonClick(function()
        if type(self.onBtnViewPacketClick) == "function" then
            self.onBtnViewPacketClick()
        end
    end)
end

function ChatRedPacketView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function ChatRedPacketView:InitView(packetModel, notAnim)
    if packetModel:IsSelfGetState() == false and packetModel:GetCanViewState() then
        if notAnim then
            self.packetArea1:SetActive(true)
            self.packetArea2:SetActive(false)
        else
            self.packetArea1:SetActive(true)
            self.packetArea2:SetActive(true)
        end
        if packetModel:GetNum() > #packetModel:GetRecdList() then
            self.area1Panel1:SetActive(true)
            self.area1Panel2:SetActive(false)
        else
            self.area1Panel1:SetActive(false)
            self.area1Panel2:SetActive(true)
        end
    else
        if notAnim then
            self.packetArea1:SetActive(false)
            self.packetArea2:SetActive(true)
        else
            self.packetArea1:SetActive(true)
            self.packetArea2:SetActive(true)
        end
        self:InitScrollerView(packetModel:GetRecdList())
    end

    local function splitStr(str, p)
        local t = {}
        string.gsub(str, '[^'..p..']+', function(w) table.insert(t, w) end )
        return t
    end 

    local strTable = splitStr(packetModel:GetDate(), "-")
    local timestr = strTable[2] .. "-" .. strTable[3] 
    self.date1.text = timestr
    self.date2.text = timestr
    
    local mDiamond = packetModel:GetSelfDiamond()
    if mDiamond and mDiamond > 0 then
        self.selfDiamondNum.gameObject:SetActive(true)
        self.selfDiamondNum.text = tostring(mDiamond)
    else
        self.selfDiamondNum.gameObject:SetActive(false)
    end

    self.packetNum.text = lang.transstr("chatpacket_num", #packetModel:GetRecdList(), packetModel:GetNum())
    self.contentTxt.text = packetModel:GetContent() or lang.transstr("guild_rp")
    self.contentTxt1.text = packetModel:GetContent() or lang.transstr("guild_rp")

    local contents = packetModel:GetRewardContents()
    GameObjectHelper.FastSetActive(self.parentRect.gameObject, contents)
    GameObjectHelper.FastSetActive(self.parentRect1.gameObject, contents)
    GameObjectHelper.FastSetActive(self.diamond, not contents)
    GameObjectHelper.FastSetActive(self.diamond1, not contents)

    if contents then
        local rewardParams = {
            parentObj = self.parentRect,
            rewardData = contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        res.ClearChildren(self.parentRect)
        RewardDataCtrl.new(rewardParams)

        rewardParams = {
            parentObj = self.parentRect1,
            rewardData = contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        res.ClearChildren(self.parentRect1)
        RewardDataCtrl.new(rewardParams)
    end
end

function ChatRedPacketView:PlayOpenAnimation()
    self.animator:Play("ChatRedPacket1")
end

function ChatRedPacketView:PlayViewAnimation()
    self.animator:Play("ChatRedPacket2")
end

function ChatRedPacketView:InitScrollerView(data)
    self.scrollerView:InitView(data)
end

function ChatRedPacketView:onCalAnimation()
    if type(self.onCalAnimationShow) == "function" then
        self.onCalAnimationShow()
    end
end

function ChatRedPacketView:onAminationLeave()
    if type(self.onAnimationLeaveShow) == "function" then
        self.onAnimationLeaveShow()
    end
end

function ChatRedPacketView:onAnimationLeave()
    if type(self.onAnimationLeaveShow) == "function" then
        self.onAnimationLeaveShow()
    end
end

return ChatRedPacketView

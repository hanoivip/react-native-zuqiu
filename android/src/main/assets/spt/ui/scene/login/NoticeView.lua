local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Application = UnityEngine.Application

local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local NoticeView = class(unity.base)

function NoticeView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.detailContent = self.___ex.detailContent
    self.labelScroll = self.___ex.labelScroll
    self.joinQQBtn = self.___ex.joinQQBtn
    self.joinQQGo = self.___ex.joinQQGo
    self.joinQQTxt = self.___ex.joinQQTxt
    self.leftImage = self.___ex.leftImage
    self.lbQQGroup = self.___ex.lbQQGroup
    self.lbQQGroupText = self.___ex.lbQQGroupText
    self.lbQQNum = self.___ex.lbQQNum
    self.lbQQNumGo = self.___ex.lbQQNumGo
    self.scrollRect = self.___ex.scrollRect
    -- 缓存之前显示的详细公告 key:index value:NoticeSingle
    self.detailConMap = {}

    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform, nil)
    luaevt.trig("SDK_Report", "announcement_open")
end

function NoticeView:Init(data, qqData)
    self.data = data
    
    if qqData ~= nil and qqData.show == 1 then
        self.leftImage:SetActive(false)
        self.joinQQGo:SetActive(true)
        self.lbQQGroup:SetActive(true)
        self.lbQQNumGo:SetActive(true)

        self.lbQQNum.text = tostring(qqData.QQ)
        self.joinQQTxt.text = lang.transstr("notice_group_key")
        self.lbQQGroupText.text = lang.transstr("notice_official_qq")

        self.joinQQBtn:regOnButtonClick(function ()
            Application.OpenURL(qqData.url);
        end)
    else
        self.joinQQGo:SetActive(false)
        self.lbQQGroup:SetActive(false)
        self.lbQQNumGo:SetActive(false)
    end
end

-- 显示公告详细信息
function NoticeView:Show(selIndex)
    local data = self.data[selIndex]
    if not data then return end

    self:ClearChild(self.detailContent)
    local go = self.detailConMap[selIndex]
    if not go then
        prefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Login/NoticeSingle.prefab")
        go = Object.Instantiate(prefab)
        local spt = res.GetLuaScript(go)
        spt:Init(data.title, data.body)
        go.transform:SetParent(self.detailContent, false)
        self.detailConMap[selIndex] = go
    else
        go:SetActive(true)
    end
    self.scrollRect.verticalNormalizedPosition = 1
end

function NoticeView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            if type(self.closeCallback) == "function" then
                self.closeCallback()
            end
            self.closeDialog()
        end)
    end
    luaevt.trig("SDK_Report", "announcement_close")
end

function NoticeView:ClearChild(parentRect)
    if parentRect.childCount > 0 then 
        for i = parentRect.childCount, 1, -1 do
            local child = parentRect:GetChild(i - 1).gameObject
            if child.activeSelf then
                child:SetActive(false)
            end
        end
    end
end

function NoticeView:OnExitScene()
    local size = table.nums(self.detailConMap)
    for i=1,size do
        local item = self.detailConMap[i]
        Object.Destroy(item)
    end
    self.detailConMap = nil
    self.labelScroll:Clear()
end

return NoticeView

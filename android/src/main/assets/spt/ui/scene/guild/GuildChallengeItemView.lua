local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

local GuildChallengeItemView = class(unity.base)

function GuildChallengeItemView:ctor()
    self.content = self.___ex.content
    self.select = self.___ex.select
    self.unSelect = self.___ex.unSelect
    self.btnEntry = self.___ex.btnEntry
    self.double = self.___ex.double
    self.leftCount = self.___ex.leftCount
    self.openTime = self.___ex.openTime
    self.openTimeArea = self.___ex.openTimeArea
    self.layout1 = self.___ex.layout1
    self.layout2 = self.___ex.layout2
    self.animator = self.___ex.animator
    self.canvasGroup = self.___ex.canvasGroup
    self.redPoint = self.___ex.redPoint
    self.nameTxt = self.___ex.name
    self.name2 = self.___ex.name2
    self.itemSpt = {}

    EventSystem.AddEvent("GuildChallengeItemClick", self, self.EventItemClick)
end

function GuildChallengeItemView:start()
    self.content:regOnButtonClick(function()
        if type(self.onContentClick) == "function" and self.isOpen and self.isOpen == true then
            self.onContentClick()
        end
    end)
    self.btnEntry:regOnButtonClick(function()
        if type(self.onBtnEntryClick) == "function" then
            self.onBtnEntryClick()
        end
    end)
end

local weekNum = {lang.transstr("number_1"), lang.transstr("number_2"), lang.transstr("number_3"), lang.transstr("number_4"),
                lang.transstr("number_5"), lang.transstr("number_6"), lang.transstr("day_1")}
function GuildChallengeItemView:InitView(data)
    self.data = data
    self.index = data.index
    self.isOpen = data.isOpen
    local italicsStr = "<i>%s</i>"

    self.nameTxt.text = data.name
    self.name2.text = data.name2
    if self.isOpen == true then
        self.openTimeArea:SetActive(false)
        self.leftCount.gameObject:SetActive(true)
        self.btnEntry.gameObject:SetActive(true)
        self.leftCount.text = string.format(italicsStr, lang.transstr("challenge_leftCount2", data.count))
        self.double:SetActive(data.isDouble)
        if data.count > 0 then
            self.redPoint:SetActive(true)
        else
            self.redPoint:SetActive(false)
        end
    else
        self.openTimeArea:SetActive(true)
        self.leftCount.gameObject:SetActive(false)
        self.btnEntry.gameObject:SetActive(false)
        local opentimes = data.openTime
        local timestr = lang.transstr("guild_challengeWeek")
        for i = 1, #opentimes do 
            timestr = timestr .. weekNum[tonumber(opentimes[i])]
            if i ~= #opentimes then
                timestr = timestr .. "/"
            end
        end
        timestr = timestr .. " " .. lang.transstr("guild_challengeOpen")
        self.openTime.text = string.format(italicsStr, timestr)
    end
    
    self:InitRewardList()
    self:coroutine(function ()
        coroutine.yield(UnityEngine.WaitForSeconds(0.05 * (self.index - 1)))
        self.animator.enable = true        
        self.gameObject:SetActive(true)
        self.animator:Play("GuildChallengeItem")
    end)
end

function GuildChallengeItemView:HideContent()
    self.animator.enable = false
    self.canvasGroup.alpha = 0
end

function GuildChallengeItemView:EventItemClick(index)
    local isSelected = (self.index == index and self.isOpen)
    self.select:SetActive(isSelected)
    self.unSelect:SetActive(not isSelected)
    if isSelected then
        self.animator:Play("GuildChallengeItem2")
    else
        self.animator:Play("GuildChallengeItemIdle")
    end
end

function GuildChallengeItemView:InitRewardList()
    if #self.itemSpt > 0 then return end    

    local id = "G" .. self.index .. "07"
    local diamond = self.data.diamondList[id]
    local money = self.data.moneyList[id]
    local itemList = self.data.itemList[id]
    local eqsList = self.data.eqsList[id]
    local path = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildChallengeRewardItem.prefab"
    self.itemSpt = {}

    for i = 1, 7 do
        local parent = self.layout1
        if i > 3 then parent = self.layout2 end
        local itemBoxObj, itemBoxView = res.Instantiate(path)
        itemBoxObj.transform:SetParent(parent, false)
        self.itemSpt[i] = itemBoxView
    end

    if diamond > 0 then
        self.itemSpt[1]:InitViewByDiamond(diamond)
    elseif money > 0 then
        self.itemSpt[1]:InitViewByMoney(money)
    else
        for key, value in pairs(itemList) do
            self.itemSpt[1]:InitViewByItem(key, tonumber(value))
        end
    end

    for i = 2, 7 do
        self.itemSpt[i]:InitViewByEqs(eqsList[i-1])
    end
end

function GuildChallengeItemView:onDestroy()
    EventSystem.RemoveEvent("GuildChallengeItemClick", self, self.EventItemClick)
end

return GuildChallengeItemView

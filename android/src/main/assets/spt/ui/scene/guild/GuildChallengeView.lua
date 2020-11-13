local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

local GuildChallengeView = class(unity.base)

function GuildChallengeView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.contentArea = self.___ex.contentArea
    self.title = self.___ex.title
    self.btnHelp = self.___ex.btnHelp
    self.itemSptList = {}
end

function GuildChallengeView:start()
    self.btnHelp:regOnButtonClick(function()
        if type(self.OnBtnHelpClick) == "function" then
            self.OnBtnHelpClick()
        end
    end)
end

function GuildChallengeView:HideContentArea()
    self.contentArea.gameObject:SetActive(false)
    for i = 1, #self.itemSptList do
        self.itemSptList[i]:HideContent()
    end
end

local weekNum = {lang.transstr("Monday"), lang.transstr("Tuesday"), lang.transstr("Wednesday"), lang.transstr("Thursday"),
                lang.transstr("Friday"), lang.transstr("Saturday"), lang.transstr("Sunday")}
local MaxChallengeLevel = 7
function GuildChallengeView:InitView(model)
    self.contentArea.gameObject:SetActive(true)
    local count = self.contentArea.childCount
    for i = 1, count do 
        local node = self.contentArea:GetChild(i - 1).gameObject
        local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
        local baseInfo = model:GetChallengeSingleLevel("G"..i)
        baseInfo.index = i
        if nodeScript ~= nil then
            nodeScript:InitView(baseInfo)
            nodeScript.onContentClick = function()
                self.instanceItemClick(i)
            end
            nodeScript.onBtnEntryClick = function()
                self.onItemBtnEntryClick(baseInfo)
            end
        end
        self.itemSptList[i] = nodeScript
    end

    local war = model:GetWarReward()
    if war then
        local timestr = lang.transstr("guild_challenge_tips_1")
        local endStr = lang.transstr("guild_challenge_tips_2", lang.transstr("number_" .. math.min(war.level, MaxChallengeLevel)))
        for i = 1, #war.weeks do 
            timestr = timestr .. weekNum[tonumber(war.weeks[i])]
            if i ~= #war.weeks then
                timestr = timestr .. "/"
            end
        end
        self.title.text = timestr .. " " .. endStr
    else
        self.title.text = ""
    end

end

function GuildChallengeView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return GuildChallengeView

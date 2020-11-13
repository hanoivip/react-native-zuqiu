local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Object = UnityEngine.Object
local DreamLeagueSkillName = require("data.DreamLeagueSkillName")

local DreamHallHistoryItemSmallView = class(unity.base, "DreamHallHistoryItemSmallView")

function DreamHallHistoryItemSmallView:ctor()
    self.itemType = self.___ex.itemType
    self.parentTrans = self.___ex.parentTrans
    self.otherObj = self.___ex.otherObj
    self.backImage = self.___ex.backImage
    self.fixTitle = self.___ex.fixTitle
end


function DreamHallHistoryItemSmallView:InitView(data, width)
    if self.itemType == "score" then
        self:InitAsContent(data, width)
    else
        self:InitAsTitle()
    end
end

function DreamHallHistoryItemSmallView:InitAsTitle()
    local skillName = {}
    for k,v in pairs(DreamLeagueSkillName) do
        table.insert(skillName, v)
    end
    table.sort(skillName, function(a, b)
        if a.sort < b.sort then
            return true
        else
            return false
        end
    end)

    self.fixTitle:AddTitle(lang.trans("footballerName"), false, 144)
    for k, v in ipairs(skillName) do
       self:InstantiateObj(tostring(v.desc2))
    end
end

function DreamHallHistoryItemSmallView:InitAsContent(data, width)
    if self.backImage then
        self.backImage.enabled = data.isShowBackImage
    end

    local skillData = {}
    for k,v in pairs(data) do
        if DreamLeagueSkillName[k] then
            local skillSortNum = DreamLeagueSkillName[k].sort
            skillData[skillSortNum] = v
        end
    end

    self:SetWidth(width)
    self.fixTitle:AddTitle(tostring(data.nameIdCn or "Lmessi"), data.isShowBackImage, width)
    for k, v in ipairs(skillData) do
       self:InstantiateObj(tostring(v))
    end
end

function DreamHallHistoryItemSmallView:SetWidth(width)
    self.parentTrans.sizeDelta = Vector2(width, 40)
end

function DreamHallHistoryItemSmallView:InstantiateObj(text)
    local textObj = Object.Instantiate(self.otherObj)
    textObj.transform:SetParent(self.parentTrans, false)
    local textCom = textObj:GetComponent(Text)
    textCom.text = text
end

return DreamHallHistoryItemSmallView

local UnityEngine = clr.UnityEngine
local System = UnityEngine.System
local Collections = System.Collections
local UI = UnityEngine.UI
local Text = UI.Text
local Image = UI.Image
local Generic = Collections.Generic
local Sprite = UnityEngine.Sprite
local Object = UnityEngine.Object
local PlayerFoulData = class(unity.base)
local Mathf = UnityEngine.Mathf
local Resources = UnityEngine.Resources

function PlayerFoulData:ctor()
    self.numText = self.___ex.numText:GetComponent(Text)
    self.nameText = self.___ex.nameText:GetComponent(Text)
    self.timeText = self.___ex.timeText:GetComponent(Text)
    self.foulTypeImage = self.___ex.foulTypeImage:GetComponent(Image)
end         
                                                                                                                 
function PlayerFoulData:InitChildren(num, playerName, foulType, time)
    self.numText.text = tostring(num)
    self.nameText.text = playerName
    self.timeText.text = time .. "’"
    self.path = self:SwitchCardPath(foulType)
    if self.path ~= nil then
        self.foulTypeImage.overrideSprite = res.LoadRes(self.path, Sprite)
    else
        self.foulTypeImage.gameObject:SetActive(false)
    end
end

function PlayerFoulData:SwitchCardPath(type)
    local path = nil
    if type == "goal" then
    elseif type == "OwnGoal" then
    elseif type == "RedCard" then
        path = "Assets/CapstonesRes/Game/UI/Match/MatchMenu/redCard.png"
    elseif type == "Shoot" then
    elseif type == "yellowCard" then
        path = "Assets/CapstonesRes/Game/UI/Match/MatchMenu/yellowCard.png"
    end
    return path
end

return PlayerFoulData

local Object = clr.UnityEngine.Object
local LuaScrollRectEx = require("ui.control.scroll.LuaScrollRectEx")
local GuildMistDataShowScheduleScrollView = class(LuaScrollRectEx)

function GuildMistDataShowScheduleScrollView:ctor()
    GuildMistDataShowScheduleScrollView.super.ctor(self)
    self.content = self.___ex.content
    self.cScrollRectSpt = self.___ex.cScrollRect
end

function GuildMistDataShowScheduleScrollView:InitView(data, myGid)
    self.myGid = myGid
    self.cScrollRectSpt:refresh(data)
end 

function GuildMistDataShowScheduleScrollView:GetScheduleItemRes()
    if not self.scheduleRes then
        local prefabPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarScheduleItem.prefab"
        self.scheduleRes = res.LoadRes(prefabPath)
    end
    return self.scheduleRes
end

function GuildMistDataShowScheduleScrollView:getItemTag(index)
    return "Default"
end

function GuildMistDataShowScheduleScrollView:createItemByTagDefault(index)
    local obj = Object.Instantiate(self:GetScheduleItemRes())
    obj.transform:SetParent(self.content, false)
    local objScript = obj:GetComponent("CapsUnityLuaBehav")
    obj.script = objScript
    return obj
end

function GuildMistDataShowScheduleScrollView:resetItemByTagDefault(spt, index)
    spt:InitView(self.itemDatas[index], self.myGid)
end

function GuildMistDataShowScheduleScrollView:Clear()
    self.cScrollRect.ClearData()
end

return GuildMistDataShowScheduleScrollView

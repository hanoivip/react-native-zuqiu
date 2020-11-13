local Object = clr.UnityEngine.Object
local LuaScrollRectEx = require("ui.control.scroll.LuaScrollRectEx")
local GuildDataShowScheduleScrollView = class(LuaScrollRectEx)

function GuildDataShowScheduleScrollView:ctor()
    GuildDataShowScheduleScrollView.super.ctor(self)
    self.content = self.___ex.content
    self.cScrollRect = self.___ex.cScrollRect
end

function GuildDataShowScheduleScrollView:InitView(data, myGid)
    self.myGid = myGid
    self:refresh(data)
end 

function GuildDataShowScheduleScrollView:GetScheduleItemRes()
    if not self.scheduleRes then 
        self.scheduleRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWarScheduleItem.prefab")
    end
    return self.scheduleRes
end

function GuildDataShowScheduleScrollView:getItemTag(index)
    return "Default"
end

function GuildDataShowScheduleScrollView:createItemByTagDefault(index)
    local obj = Object.Instantiate(self:GetScheduleItemRes())
    obj.transform:SetParent(self.content, false)
    local objScript = obj:GetComponent(clr.CapsUnityLuaBehav)
    obj.script = objScript
    return obj
end

function GuildDataShowScheduleScrollView:resetItemByTagDefault(spt, index)
    spt:InitView(self.itemDatas[index], self.myGid)
end

function GuildDataShowScheduleScrollView:Clear()
    self.cScrollRect:ClearData()
end

return GuildDataShowScheduleScrollView

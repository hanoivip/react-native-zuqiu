local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local ArenaType = require("ui.scene.arena.ArenaType")
local ArenaTips = require("data.ArenaTips")
local ArenaRuleView = class(unity.base)

function ArenaRuleView:ctor()
    self.menuGroup = self.___ex.menuGroup
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.menuArea = self.___ex.menuArea
    self.contentTitle = self.___ex.contentTitle
    self.desc = self.___ex.desc
    self:Init()
end

function ArenaRuleView:Init()
    self.menuGroup.menu = {}
    local tipsMap = {}
    for k, v in pairs(ArenaTips) do
        v.id = k
        table.insert(tipsMap, v)
    end
    table.sort(tipsMap, function(a, b) return tonumber(a.id) < tonumber(b.id) end) 

    local defaultId = tipsMap and tipsMap[1].id
    for i, v in ipairs(tipsMap) do
        local id = v.id
        local obj = Object.Instantiate(self:GetRuleBarRes())
        obj.transform:SetParent(self.menuArea, false)
        local spt = res.GetLuaScript(obj)
        self.menuGroup.menu[tostring(id)] = spt
        spt:InitView(v.position)
        self:RegOnMenuGroup(id, function () self:SwitchPanel(id) end)
    end
end

function ArenaRuleView:SwitchPanel(id)
    local arenaData = ArenaTips[tostring(id)]
    self.contentTitle.text = arenaData.title
    self.desc.text = arenaData.desc
    self.menuGroup:selectMenuItem(tostring(id))
end

function ArenaRuleView:GetRuleBarRes()
    if not self.ruleBar then 
        self.ruleBar = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/RuleBar.prefab")
    end
    return self.ruleBar
end

function ArenaRuleView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function ArenaRuleView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return ArenaRuleView

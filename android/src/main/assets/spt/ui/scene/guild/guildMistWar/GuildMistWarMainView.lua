local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")

local GuildMistWarMainView = class(unity.base, "GuildMistWarMainView")

function GuildMistWarMainView:ctor()
    self.mapSpt = self.___ex.mapSpt
    self.registerSpt = self.___ex.registerSpt
    self.infoBarSpt = self.___ex.infoBarSpt
    self.fightSpt = self.___ex.fightSpt
    self.editorMapSpt = self.___ex.editorMapSpt
    self.mapScrollTrans = self.___ex.mapScrollTrans
end

function GuildMistWarMainView:start()
    self:RegBtnEvent()
end

function GuildMistWarMainView:RegBtnEvent()

end

function GuildMistWarMainView:InitView(guildMistWarMainModel)
    self.model = guildMistWarMainModel
    self:RefreshView()
end

function GuildMistWarMainView:RefreshView()
    local state = self.model:GetWarState()
    -- 报名
    if state ~= GUILDWAR_STATE.FIGHTING then
        self.registerSpt:InitView(self.model)
        self:RefreshMap()
    elseif state == GUILDWAR_STATE.FIGHTING then -- 战斗
        if self.refreshFight then
            self.refreshFight()
        end
    else
        self:RefreshMap()
    end
    GameObjectHelper.FastSetActive(self.registerSpt.gameObject, state ~= GUILDWAR_STATE.FIGHTING)
    GameObjectHelper.FastSetActive(self.fightSpt.gameObject, state == GUILDWAR_STATE.FIGHTING)
end

function GuildMistWarMainView:RefreshAttack()
    self.fightSpt:RefreshAttack(self.model)
    self:RefreshMap()
end

function GuildMistWarMainView:RefreshDefender()
    self.fightSpt:RefreshDefender(self.model)
    self:RefreshMap()
end

-- 地图刷新
function GuildMistWarMainView:RefreshMap()
    local mistMapModel = self.model:GetMistMapModel()
    self.mapSpt:InitView(mistMapModel)
end

function GuildMistWarMainView:RegOnDynamicLoad(func)
    self.infoBarSpt:RegOnDynamicLoad(func)
end

function GuildMistWarMainView:OnEditorMap(isEditor)
    if isEditor then
        GameObjectHelper.FastSetActive(self.fightSpt.gameObject, false)
        GameObjectHelper.FastSetActive(self.registerSpt.gameObject, false)
        local mistMapModel = self.model:GetMistMapModel()
        self.editorMapSpt:InitView(self.model, mistMapModel)
        self.mapSpt:MistCanEditorRefresh()
        GameObjectHelper.FastSetActive(self.editorMapSpt.gameObject, true)
    else
        local mistMapModel = self.model:GetMistMapModel()
        local isMapChanged = mistMapModel:IsMapChanged()
        if isMapChanged then
            DialogManager.ShowConfirmPopByLang("tips", "mist_map_save_tip",function()
                EventSystem.SendEvent("GuildWarMist_SaveMap")
            end, function()
                self:ExitEditor()
            end)
        else
            self:ExitEditor()
        end
    end
end

function GuildMistWarMainView:ExitEditor()
    local mistMapModel = self.model:GetMistMapModel()
    mistMapModel:CloneMap()
    EventSystem.SendEvent("GuildMistWarMainCtrl_RefreshPage")
    self.mapSpt:ResetButtons()
    GameObjectHelper.FastSetActive(self.editorMapSpt.gameObject, false)
end

function GuildMistWarMainView:SetMapPos(isLeft)
    if isLeft then
        self.mapScrollTrans.localPosition = Vector3(-139, 0, 0)
    else
        self.mapScrollTrans.localPosition = Vector3(110, 0, 0)
    end
end

function GuildMistWarMainView:OnEnterScene()
    self:RegEvent()
    self.mapSpt:OnEnterScene()
    self.registerSpt:OnEnterScene()
    self.fightSpt:OnEnterScene()
    self.editorMapSpt:OnEnterScene()
end

function GuildMistWarMainView:OnExitScene()
    self:UnRegEvent()
    self.mapSpt:OnExitScene()
    self.registerSpt:OnExitScene()
    self.fightSpt:OnExitScene()
    self.editorMapSpt:OnExitScene()
end

function GuildMistWarMainView:RegEvent()
    EventSystem.AddEvent("GuildWarMist_EditorMap", self, self.OnEditorMap)  --编辑地图
    EventSystem.AddEvent("GuildWarMist_SetMapPos", self, self.SetMapPos)  --地图整体的位置
end

function GuildMistWarMainView:UnRegEvent()
    EventSystem.RemoveEvent("GuildWarMist_EditorMap", self, self.OnEditorMap)
    EventSystem.RemoveEvent("GuildWarMist_SetMapPos", self, self.SetMapPos)
end

return GuildMistWarMainView

local GameObjectHelper = require("ui.common.GameObjectHelper")
local PasterMenuType = require("ui.scene.pasterBag.PasterMenuType")
local PasterBagMainView = class(unity.base)

function PasterBagMainView:ctor()
    self.infoBarDynParent = self.___ex.infoBar
    self.pasterView = self.___ex.pasterView
    self.menuButtonGroup = self.___ex.menuButtonGroup
end

function PasterBagMainView:start()
    for k,v in pairs(self.menuButtonGroup.menu) do
        local tag = k
        self.menuButtonGroup:BindMenuItem(tag, function()
            self:OnMenuClick(tag)
        end)
    end
end

function PasterBagMainView:InitView(menuType, playerPasterListModel, competePasterListModel, cardResourceCache)
    if not menuType then
        menuType = PasterMenuType.PLAYER
    end
    self.menuButtonGroup:selectMenuItem(menuType)
    self.pasterView:InitView(playerPasterListModel, competePasterListModel, cardResourceCache)
    self:OnMenuClick(menuType)
end

function PasterBagMainView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function PasterBagMainView:OnMenuClick(tag)
    self.pasterView:ClickMenu(tag)
    if self.clickMenu then
        self.clickMenu(tag)
    end
end

function PasterBagMainView:OnEnterScene()
    self.pasterView:EnterScene()
end

function PasterBagMainView:OnExitScene()
    self.pasterView:ExitScene()
end

return PasterBagMainView
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaType = require("ui.scene.arena.ArenaType")
local HonorPageType = require("ui.scene.arena.honor.HonorPageType")

local HonorView = class(unity.base)
local ShowState = {Spread = 1, Retract = 2}

function HonorView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.silverView = self.___ex.silverView
    self.goldView = self.___ex.goldView
    self.blackGoldView = self.___ex.blackGoldView
    self.platinaView = self.___ex.platinaView
    self.redView = self.___ex.redView
    self.yellowView = self.___ex.yellowView
    self.blueView = self.___ex.blueView
    self.menuScript = self.___ex.menuScript
    self.content = self.___ex.content
    self.honorPageMap = {}
end

function HonorView:start()
    local menu = self.menuScript.menu
    for key, page in pairs(menu) do
        page:regOnButtonClick(function()
            self:OnBtnMenu(key)
        end)
    end
end

function HonorView:OnBtnMenu(key)
    if key == self.currentPageTag then return end
    self.currentPageTag = key
    self:OnBtnPage(key)
    self.menuScript:selectMenuItem(key)
end

function HonorView:OnBtnPage(key)
    if self.honorPageMap[self.prePage] then 
        self.honorPageMap[self.prePage]:ShowPageVisible(false)
    end
    local fixKey = key
    if key ~= HonorPageType.Total then
        fixKey = HonorPageType.Silver
    end 
    
    if not self.honorPageMap[fixKey] then 
        if fixKey == HonorPageType.Total then 
            local obj, script = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/TotalHonorReward.prefab")
            obj.transform:SetParent(self.content, false)
            self.honorPageMap[fixKey] = script
        elseif fixKey == HonorPageType.Silver then 
            local obj, script = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/SingleArenaReward.prefab")
            obj.transform:SetParent(self.content, false)
            self.honorPageMap[fixKey] = script
        end
        self.honorPageMap[fixKey].clickReward = function(id) self:OnClickReward(id) end
        self.honorPageMap[fixKey]:EnterScene()
    end
    self.prePage = fixKey
    self.honorPageMap[fixKey]:ShowPageVisible(true)
    self.honorPageMap[fixKey]:InitView(self.arenaModel, self.arenaHonorModel, key)
end

function HonorView:OnClickReward(id)
    if self.clickReward then 
        self.clickReward(id)
    end
end

function HonorView:InitView(arenaModel, arenaHonorModel, page)
    self.arenaModel = arenaModel
    self.arenaHonorModel = arenaHonorModel
    self.silverView:InitView(arenaModel, arenaHonorModel, ArenaType.SilverStage)
    self.goldView:InitView(arenaModel, arenaHonorModel, ArenaType.GoldStage)
    self.blackGoldView:InitView(arenaModel, arenaHonorModel, ArenaType.BlackGoldStage)
    self.platinaView:InitView(arenaModel, arenaHonorModel, ArenaType.PlatinumStage)
    self.redView:InitView(arenaModel, arenaHonorModel, ArenaType.RedGoldStage)
    self.yellowView:InitView(arenaModel, arenaHonorModel, ArenaType.YellowGoldStage)
    self.blueView:InitView(arenaModel, arenaHonorModel, ArenaType.BlueGoldStage)

    self.currentPageTag = nil
    self.pageTag = page
    self:OnBtnMenu(self.pageTag)

    if luaevt.trig("__SGP__VERSION__") or luaevt.trig("__VN__VERSION__") or luaevt.trig("__KR__VERSION__") then
        GameObjectHelper.FastSetActive(self.redView.gameObject, false)
        GameObjectHelper.FastSetActive(self.yellowView.gameObject, false)
        GameObjectHelper.FastSetActive(self.blueView.gameObject, false)
    end
end

function HonorView:EnterScene()
end

function HonorView:ExitScene()
end

function HonorView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function HonorView:IsShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.displayArea.gameObject, isShow)
end

function HonorView:OnBtnBack()
    if self.clickBack then 
        self.clickBack()
    end
end

return HonorView

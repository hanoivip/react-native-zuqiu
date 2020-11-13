local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2

local GuildWarGuardView = class(unity.base)

function GuildWarGuardView:ctor()
    self.posArea = self.___ex.posArea
    self.guardPositionSptList = {}
end

function GuildWarGuardView:start()

end

function GuildWarGuardView:HideGuardPosition()
    if #self.guardPositionSptList > 0 then
        for i = 1, #self.guardPositionSptList do
            local spt = self.guardPositionSptList[i]
            spt.itemArea:SetActive(false)
            spt:Reset()
        end
    end
end

function GuildWarGuardView:PlayPosSeizeAnim()
    if #self.guardPositionSptList > 0 then
        for i = 1, #self.guardPositionSptList do
            local spt = self.guardPositionSptList[i]
            if spt.data.seizeCnt >= 2 then
                spt:PlaySeizeAnim()
            end
        end
    end
end

function GuildWarGuardView:SetGuardPosition(model)
    local guardList = model:GetGuardList()
    local count = self.posArea.childCount
    if #self.guardPositionSptList > 0 then
        for i = 1, #self.guardPositionSptList do
            local spt = self.guardPositionSptList[i]
            spt:InitView(guardList[i], i, model)
        end
    else
        for i = 1, count do
            local posItem = self.posArea:GetChild(i - 1).gameObject.transform
            local item, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWar/GuardPosItem.prefab")
            item.transform:SetParent(posItem, false)
            spt:InitView(guardList[i], i, model)
            spt.guardItemClick = function(index) self.GuardItemClick(index) end
            self.guardPositionSptList[i] = spt
        end
    end 
end


return GuildWarGuardView

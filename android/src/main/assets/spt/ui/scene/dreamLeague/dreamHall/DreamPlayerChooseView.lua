local DreamLeagueCardHelper = require("ui.scene.dreamLeague.DreamLeagueCardHelper")
local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DreamPlayerChooseView = class(unity.base)
function DreamPlayerChooseView:ctor()
    self.close = self.___ex.close
    self.position = self.___ex.position

    DialogAnimation.Appear(self.transform, nil)
end

function DreamPlayerChooseView:InitView(dreamPlayerChooseModel)
    self.close:regOnButtonClick(function()
        self:Close()
    end)
    self.cardPrefabPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamLeagueCard.prefab"
    self.addPrefabPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamHall/AddItem.prefab"
    self.fullPrefabPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamHall/FullItem.prefab"
    for i=1,4 do
        local posData = dreamPlayerChooseModel:GetPlayerByPositionIndex(i)
        self:InitPosition(i, posData)
    end
end

function DreamPlayerChooseView:InitPosition(index, posData)
    local posTrans = self.position[tostring(index)]
    res.ClearChildren(posTrans)
    for i,v in ipairs(posData) do
        if v.dcid then
            local obj, spt = res.Instantiate(self.cardPrefabPath)
            local dreamLeagueCardModel = DreamLeagueCardModel.new(v.dcid)
            local notShowDecomposeBtn = true
            spt:InitView(dreamLeagueCardModel, notShowDecomposeBtn)
            obj.transform:SetParent(posTrans, false)
        elseif v.state == "full" then
            local obj, spt = res.Instantiate(self.fullPrefabPath)
            obj.transform:SetParent(posTrans, false)
        elseif v.state == "add" then
            local obj, spt = res.Instantiate(self.addPrefabPath)
            obj.transform:SetParent(posTrans, false)
            spt:regOnButtonClick(function()
                if self.onAddPlayerClick then
                    self.onAddPlayerClick(index)
                end
            end)
        end
    end
end

function DreamPlayerChooseView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

return DreamPlayerChooseView

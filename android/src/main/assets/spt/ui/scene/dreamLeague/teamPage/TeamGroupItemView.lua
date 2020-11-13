local TeamGroupItemView = class(unity.base)

function TeamGroupItemView:ctor()
    self.itemParent = self.___ex.itemParent
    self.titleText = self.___ex.titleText
end

function TeamGroupItemView:InitView(scrollData, onPlayerClickCallBack, onlyNeedPlayerName)
    self.titleText.text = scrollData.mainPosition
    res.ClearChildren(self.itemParent)
    if type(scrollData.player) == "table" then
        for k, data in pairs(scrollData.player) do
            if type(data) ~= "table" then
                data = {}
                data.isOwner = false
            end
            data.listModel = scrollData.listModel
            data.isOwner = true
            data.playerName = k
            local teamPlayerObj, teamPlayerSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/DreamLeague/TeamPage/TeamPlayerItem.prefab")
            teamPlayerSpt.transform:SetParent(self.itemParent, false)
            teamPlayerSpt:InitView(data, onPlayerClickCallBack, onlyNeedPlayerName)
        end
    end
end

return TeamGroupItemView

local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local Nation = require("data.Nation")

local DreamBagNationItemView = class(unity.base)


function DreamBagNationItemView:ctor()
    self.nationFlag = self.___ex.nationFlag
    self.nationName = self.___ex.nationName
    self.ownerNum = self.___ex.ownerNum
    self.lightNum = self.___ex.lightNum
    self.enterBtn = self.___ex.enterBtn
    self.newFlag = self.___ex.newFlag
end

function DreamBagNationItemView:InitView(data, clickNationCallBack, needFilterPosIndex)
    nationRes = AssetFinder.GetNationIcon(data.teamName)
    self.nationFlag.overrideSprite = nationRes
    self.nationName.text = Nation[data.teamName].nation
    local newState = data.listModel:IsTeamContainsNewPlayer(data.teamName) or false
    GameObjectHelper.FastSetActive(self.newFlag, newState)
    local teamMember = 0
    local light = 0
    local owner = 0
    for playerName, qualitys in pairs(data.teamMember) do
        -- 这里将该位置的球员筛选出来
        if needFilterPosIndex == nil or data.teamPosIndex[playerName] == needFilterPosIndex then
            teamMember = teamMember + 1
        end
        if type(qualitys) == "table" then
            if needFilterPosIndex == nil or data.teamPosIndex[playerName] == needFilterPosIndex then
                light = light + 1
            end
            for quality, dcids in pairs(qualitys) do
                assert(type(dcids) == "table", "dcids must be table")
                local dreamLeagueCardModel = nil
                for dcid, v in pairs(dcids) do
                    dreamLeagueCardModel = DreamLeagueCardModel.new(dcid)
                    if needFilterPosIndex == nil or tostring(dreamLeagueCardModel:GetPostionType()) == tostring(needFilterPosIndex) then
                        owner = owner + 1
                    end
                end
            end
        end
    end
    self.lightNum.text = lang.transstr("dream_light_num", light, teamMember)
    self.ownerNum.text = lang.transstr("dream_owner_num", owner)
    self.enterBtn:regOnButtonClick(function()
        local teamPageIndex = {}
        teamPageIndex.firstLetter = data.firstLetter
        teamPageIndex.nationName = data.nationName
        teamPageIndex.teamName = data.teamName
        if clickNationCallBack then
            clickNationCallBack(teamPageIndex)
        end
    end)
end

return DreamBagNationItemView

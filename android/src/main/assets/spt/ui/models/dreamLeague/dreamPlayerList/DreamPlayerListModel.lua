local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local DreamLeagueCardBaseModel = require("ui.models.dreamLeague.DreamLeagueCardBaseModel")
local PlayerDreamCardsMapModel = require("ui.models.dreamLeague.PlayerDreamCardsMapModel")
local DreamLeagueCardHelper = require("ui.scene.dreamLeague.DreamLeagueCardHelper")
local Model = require("ui.models.Model")
local DreamPlayerListModel = class(Model, "DreamPlayerListModel")

function DreamPlayerListModel:ctor(playerPageIndex, dreamLeagueListModel, isSelectMode)
    self.modelsByQuality = {}
    self.playerPageIndex = playerPageIndex
    self.isSelectMode = isSelectMode
    self.dreamLeagueListModel = dreamLeagueListModel
end

function DreamPlayerListModel:GetScrollDataQuality()
    local playerData = self.dreamLeagueListModel:GetPlayerPageData(self.playerPageIndex)
    local modelsByQuality = {}
    if type(playerData) ~= "table" then
        return modelsByQuality
    end
    for i = 1, 4 do
        local tempList = playerData[i]
        if tempList then
            for dcid, v in pairs(tempList) do
                local model = DreamLeagueCardModel.new(v)
                model.listModel = self.dreamLeagueListModel
                model.decomposeCallBack = self.decomposeCallBack
                if self.isSelectMode then
                    model.selectMode = DreamLeagueCardHelper.CardSelectMode.SELECT
                    model.checkBoxCallBack = self.checkBoxCallBack
                end
                table.insert(modelsByQuality, model)
            end
        end
    end
    self.modelsByQuality = modelsByQuality

    -- 应需求，按品质排序
    table.sort(self.modelsByQuality, function (a, b)
        return a:GetQuality() > b:GetQuality()
    end)

    return modelsByQuality
end

function DreamPlayerListModel:SetScrollDataFilter(scrollDataFilter)
    self:SetFilterState(true)
    for i,v in ipairs(scrollDataFilter) do
        v.decomposeCallBack = self.decomposeCallBack
        if self.isSelectMode then
            v.selectMode = DreamLeagueCardHelper.CardSelectMode.SELECT
            v.checkBoxCallBack = self.checkBoxCallBack
        end
    end
    self.scrollDataFilter = scrollDataFilter
end

function DreamPlayerListModel:GetAllDcids()
    local allDcids = {}
    for k,v in pairs(self.modelsByQuality) do
        local dcid = v:GetDcid()
        table.insert(allDcids, dcid)
    end
    return allDcids
end

function DreamPlayerListModel:GetFilterState()
    return self.filterState or false
end

function DreamPlayerListModel:SetFilterState(state)
    self.filterState = state
end

function DreamPlayerListModel:GetScrollDataFilter()
    return self.scrollDataFilter or {}
end

function DreamPlayerListModel:GetDreamLeagueListModel()
    return self.dreamLeagueListModel
end

function DreamPlayerListModel:GetPlayerPageIndex()
    return self.playerPageIndex
end

function DreamPlayerListModel:GetDecomposeCallBack()
    return self.decomposeCallBack
end

function DreamPlayerListModel:SetDecomposeCallBack(decomposeCallBack)
    self.decomposeCallBack = decomposeCallBack
end

function DreamPlayerListModel:SetCheckBoxCallBack(checkBoxCallBack)
    self.checkBoxCallBack = checkBoxCallBack
end

function DreamPlayerListModel:GetSelectDcid()
    return self.selectDcid
end

function DreamPlayerListModel:SetSelectDcid(selectState, dcid)
    if selectState then
        self.selectDcid = dcid
    else
        self.selectDcid = nil
    end
end

function DreamPlayerListModel:GetPlayerName()
    local dreamCardId = self.playerPageIndex.playerName .. 1
    local model = DreamLeagueCardBaseModel.new(dreamCardId)
    return model:GetName()
end

function DreamPlayerListModel:GetTeamCode()
    return self.playerPageIndex.teamName
end

function DreamPlayerListModel:GetPlayerNum()
    local qualityNum = {0, 0, 0, 0}
    for i,v in ipairs(self.modelsByQuality) do
        local quiality = v:GetQuality()
        quiality = tonumber(quiality)
        qualityNum[quiality] = qualityNum[quiality] + 1
    end
    return qualityNum
end

function DreamPlayerListModel:GetSelectModeState()
    return self.isSelectMode
end

return DreamPlayerListModel

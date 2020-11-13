local BaseCtrl = require("ui.controllers.BaseCtrl")

local MedalSearchCtrl = class(BaseCtrl, "MedalSearchCtrl")

MedalSearchCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalSearchBoard.prefab"

function MedalSearchCtrl:Init(medalListModel, medalListSkillSearchModel)
    self.view.clickConfirm = function(selectAttr, selectBody, selectQuality, selectSkill) self:ClickConfirm(selectAttr, selectBody, selectQuality, selectSkill) end
    self.view.clickReset = function() self:ClickReset() end
    self.view.onClickEventSkillSearch = function() self:OnClickEventSkillSearch() end
    self.view.onClickMedalSkillSearch = function() self:OnClickMedalSkillSearch() end
    self:SavePreData(medalListSkillSearchModel)
end

function MedalSearchCtrl:Refresh(medalListModel, medalListSkillSearchModel)
    MedalSearchCtrl.super.Refresh(self)
    self.medalListModel = medalListModel
    self.medalListSkillSearchModel = medalListSkillSearchModel
    self.view:InitView(medalListModel, self.medalListSkillSearchModel)
    self:CreateSkillItemList()
end

function MedalSearchCtrl:OnEnterScene()
    self.view:EnterScene()
end

function MedalSearchCtrl:OnExitScene()
    self.view:ExitScene()
end

function MedalSearchCtrl:ClickConfirm(selectAttr, selectBody, selectQuality, selectSkill)
    self.medalListModel:SearchSort(selectAttr, selectBody, selectQuality, selectSkill)
end

function MedalSearchCtrl:ClickReset()
    self.medalListSkillSearchModel:ResetSelectSkill()
    self.view:OnReset()
    self.medalListModel:ResetSearchCache()
    self.view:Close()
end

function MedalSearchCtrl:OnClickEventSkillSearch()
    self:RefreshEventSkillList()
end

function MedalSearchCtrl:OnClickMedalSkillSearch()
    self:RefreshMedalSkillList()
end

function MedalSearchCtrl:CreateSkillItemList()
    self.view.skillScrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardIndex/SkillItemListButton.prefab")
        return obj, spt
    end
    self.view.skillScrollView.onScrollResetItem = function(spt, index)
        local itemData = self.view.skillScrollView.itemDatas[index]
        spt:InitView(self.view, 2, itemData)
        self.view.skillScrollView:updateItemIndex(spt, index)
    end
end

function MedalSearchCtrl:RefreshEventSkillList()
    local selectEventSkillData = self.medalListSkillSearchModel:GetSelectEventSkillData()
    local skills = self.medalListSkillSearchModel:GetEventSkillList(selectEventSkillData)
    self.view.skillScrollView:clearData()
    for i = 1, #skills do
        table.insert(self.view.skillScrollView.itemDatas, skills[i])
    end
    self.view.skillScrollView:refresh()
end

function MedalSearchCtrl:RefreshMedalSkillList()
    local selectMedalSkillData = self.medalListSkillSearchModel:GetSelectMedalSkillData()
    local skills = self.medalListSkillSearchModel:GetMedalSkillList(selectMedalSkillData)
    self.view.skillScrollView:clearData()
    for i = 1, #skills do
        table.insert(self.view.skillScrollView.itemDatas, skills[i])
    end
    self.view.skillScrollView:refresh()
end

function MedalSearchCtrl:SavePreData(medalListSkillSearchModel)
    medalListSkillSearchModel:SavePreSkillSelectData()
end

return MedalSearchCtrl

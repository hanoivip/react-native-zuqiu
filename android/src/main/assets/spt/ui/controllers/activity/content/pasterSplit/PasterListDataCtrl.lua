local PasterListModel = require("ui.models.itemList.PasterListModel")

local PasterListDataCtrl = class()

function PasterListDataCtrl:ctor(view, cardResourceCache)
    self.view = view
    self.scrollView = view.scrollView
    self.cardResourceCache = cardResourceCache
    self.scrollView.clickCardPaster = function(spt) self:OnClickCardPaster(spt) end
    self.pasterListModel = {}
    self.pasterListSortModel = {}
    self.pasterSplitableModelList = {}
end

function PasterListDataCtrl:RefreshView()
    self.pasterListModel = PasterListModel.new()   --obtain paster list data
    self.pasterListSortModel = self.pasterListModel:GetListModel()
    self:SortOutSplitablePasters()
    self.scrollView:InitView(self.view, self.pasterSplitableModelList, self.cardResourceCache)
end

function PasterListDataCtrl:SortOutSplitablePasters()
    if self.pasterListSortModel and type(self.pasterListSortModel) == "table" then
        for k, cardPasterModel in pairs(self.pasterListSortModel) do
            if tonumber(cardPasterModel:GetPasterType()) == 1 or tonumber(cardPasterModel:GetPasterType()) == 2 then
                local hasDuplicate = false
                local canSplit = false
                hasDuplicate = self.pasterListModel.cardPastersMapModel:HasSamePaster(cardPasterModel)
                canSplit = cardPasterModel:CanPasterSplit()

                if not hasDuplicate and canSplit then
                    table.insert(self.pasterSplitableModelList, cardPasterModel)
                end
            end
        end
    end
end

return PasterListDataCtrl

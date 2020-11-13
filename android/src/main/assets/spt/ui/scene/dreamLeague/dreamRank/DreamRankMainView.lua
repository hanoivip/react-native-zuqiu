local DreamRankMainView = class(unity.base)

function DreamRankMainView:ctor()
    self.btnBack = self.___ex.btnBack
    self.scrollView = self.___ex.scrollView
    self.tabScrollView = self.___ex.tabScrollView
end

function DreamRankMainView:start()
end

function DreamRankMainView:InitView(dreamRankModel)
    self:InitScrollView(dreamRankModel)
end

function DreamRankMainView:InitScrollView(dreamRankModel)
    for k, v in pairs(dreamRankModel:GetRankTabList()) do
        if v.isSelect then
            self.scrollView:InitView(dreamRankModel:GetContentWithTab(v.matchTag))
        end
    end
end

return DreamRankMainView

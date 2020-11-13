local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GuildMemberRankingItemView = class(unity.base)

function GuildMemberRankingItemView:ctor()
    self.itemName = self.___ex.name
    self.logo = self.___ex.logo
    self.contribute = self.___ex.contribute
    self.first = self.___ex.first
    self.second = self.___ex.second
    self.third = self.___ex.third
    self.normal = self.___ex.normal
    self.rankList = {self.first, self.second, self.third}
    self.btnDetail = self.___ex.btnDetail
end

function GuildMemberRankingItemView:start()
    self.btnDetail:regOnButtonClick(function()
        if type(self.onBtnDetailClick) == "function" then
            local pid = self.itemModel:GetPid()
            local sid = self.itemModel:GetSid()
            self.onBtnDetailClick(pid, sid)
        end
    end)
end

local iconMaxRankingNum = 3
function GuildMemberRankingItemView:InitView(itemModel)
    self.itemModel = itemModel
    TeamLogoCtrl.BuildTeamLogo(self.logo, itemModel:GetLogoData())
    self.itemName.text = itemModel:GetName()
    if itemModel:GetIsMySelf() then
        self.itemName.text = "<color=#FAEB46FF>" .. itemModel:GetName() .. "</color>"
    end
    self.contribute.text = tostring(itemModel:GetContributeValue())
    local rankOrder = tonumber(itemModel:GetRank())
    --排名为1/2/3时显示图片，大于3时显示数字
    for i = 1, iconMaxRankingNum do
        self.rankList[i]:SetActive(rankOrder == i)
    end
    self.normal.gameObject:SetActive(rankOrder > iconMaxRankingNum)
    self.normal.text = tostring(rankOrder)
end

function GuildMemberRankingItemView:onDestroy()
end

return GuildMemberRankingItemView

local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

-- 公会信息显示
local PlayerDetailGuildShowView = class(unity.base)

function PlayerDetailGuildShowView:ctor()
    self.adminLb = self.___ex.adminLb
    self.adminName = self.___ex.adminName
    self.adminLogo = self.___ex.adminLogo
    self.guildName = self.___ex.guildName
    self.guildNotice = self.___ex.guildNotice
    self.guildIcon = self.___ex.guildIcon
    self.contributionNum = self.___ex.contributionNum
    self.contributionTxt = self.___ex.contributionTxt
    self.contributionIcon = self.___ex.contributionIcon
    self.goodResultNum = self.___ex.goodResultNum
    self.goodResultTxt = self.___ex.goodResultTxt
    self.livelyTxt = self.___ex.livelyTxt
    self.livelyNum = self.___ex.livelyNum
    self.strengthTxt = self.___ex.strengthTxt
    self.strengthNum = self.___ex.strengthNum
    self.memberTxt = self.___ex.memberTxt
    self.memberNum = self.___ex.memberNum
    self.applyTypeTxt = self.___ex.applyTypeTxt
    self.applyType = self.___ex.applyType
    self.limitLvTxt = self.___ex.limitLvTxt
    self.limitLv = self.___ex.limitLv
    self.guildNoticeTitle = self.___ex.guildNoticeTitle
    self.powerTxt = self.___ex.powerTxt
    self.mistNum = self.___ex.mistNum
end

function PlayerDetailGuildShowView:InitView(detailModel, guildDetailModel)
    self.adminLb.text = lang.transstr("pd_guild_admin")
    self.contributionTxt.text = lang.transstr("pd_guild_contribution")
    self.goodResultTxt.text = lang.transstr("pd_guild_result")
    self.livelyTxt.text = lang.transstr("pd_guild_lively_rank")
    self.strengthTxt.text = lang.transstr("pd_guild_strength_rank")
    self.memberTxt.text = lang.transstr("pd_guild_member")
    self.applyTypeTxt.text = lang.transstr("pd_guild_apply_type")
    self.limitLvTxt.text = lang.transstr("pd_guild_limit_lv")
    self.guildNoticeTitle.text = lang.transstr("pd_guild_notice_title")

    self.guildDetailModel = guildDetailModel

    self.guildIcon.sprite = self.guildDetailModel:GetGuildLogo()
    self.guildName.text = self.guildDetailModel:GetGuildName()
    local logoTable = self.guildDetailModel:GetAdminLogo()
    TeamLogoCtrl.BuildTeamLogo(self.adminLogo, logoTable)
    self.adminName.text = self.guildDetailModel:GetAdminName()
    self.contributionNum.text = self.guildDetailModel:GetContribute()
    local bestMistWarInfo = self.guildDetailModel:GetBestMistWarInfo()
    local bestWarInfo = self.guildDetailModel:GetBestWarInfo()
    self.goodResultNum.text = bestWarInfo
    self.mistNum.text = bestMistWarInfo
    local contributeRank = self.guildDetailModel:GetContributeRank()
    if contributeRank == "nil" then
        self.livelyNum.text = "--"
    else
        self.livelyNum.text = contributeRank
    end
    local warRank = self.guildDetailModel:GetWarRank()
    if warRank == "nil" then
        self.strengthNum.text = "--"
    else
        self.strengthNum.text = warRank
    end
    self.memberNum.text = self.guildDetailModel:GetMemberNum() .. "/40"
    self.applyType.text = self.guildDetailModel:GetReqType()
    self.limitLv.text = self.guildDetailModel:GetReqLevel()
    self.guildNotice.text = self.guildDetailModel:GetNotice()
    self.powerTxt.text = string.formatIntWithTenThousands(self.guildDetailModel:GetPower())
end

return PlayerDetailGuildShowView
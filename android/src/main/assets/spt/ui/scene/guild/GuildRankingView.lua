local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local Ease = Tweening.Ease
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local GuildWar = require("data.GuildWar")
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local GuildRankingView = class(unity.base)

function GuildRankingView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.scrollerView = self.___ex.scrollerView
    self.powerScrollerView = self.___ex.powerScrollerView
    self.logo = self.___ex.logo
    self.nameInfoTxt = self.___ex.name
    self.title = self.___ex.title
    self.order = self.___ex.order
    self.contribute = self.___ex.contribute
    self.btnArrow = self.___ex.btnArrow
    self.panel = self.___ex.panel
    self.centerArea = self.___ex.centerArea
    self.menuGroup = self.___ex.menuGroup
    self.livnessInfo = self.___ex.livnessInfo
    self.powerInfo = self.___ex.powerInfo
    self.livnessScroll = self.___ex.livnessScroll
    self.powerScroll = self.___ex.powerScroll
    self.powerRankTxt = self.___ex.powerRankTxt
    self.nameTxt = self.___ex.nameTxt
    self.bestResultTxt = self.___ex.bestResultTxt
    self.titleTxt = self.___ex.titleTxt
    self.commonBtn = self.___ex.commonBtn
    self.mistBtn = self.___ex.mistBtn
end

function GuildRankingView:start()
    self.btnArrow:regOnButtonClick(function()
        if type(self.onBtnArrowClick) == "function" then
            self.onBtnArrowClick()
        end
    end)
    self.commonBtn:regOnButtonClick(function()
        if type(self.onBtnCommonClick) == "function" then
            self.onBtnCommonClick()
        end
    end)
    self.mistBtn:regOnButtonClick(function()
        if type(self.onBtnMistClick) == "function" then
            self.onBtnMistClick()
        end
    end)
end

function GuildRankingView:InitView(guildRankingModel)
    self.model = guildRankingModel
    local livesData = guildRankingModel:GetLivesData()
    self:InitInfoView(guildRankingModel)
    self:InitLivesScrollerView(livesData)
end

local distance = 360
function GuildRankingView:MoveUpThePanel()
    local tweener = ShortcutExtensions.DOAnchorPosY(self.panel, distance, 0.5)
    TweenSettingsExtensions.SetEase(tweener, Ease.InOutQuad)
    TweenSettingsExtensions.OnComplete(tweener, function()  --Lua assist checked flag
        self.onCompleteCallBack()
    end)
end

function GuildRankingView:MoveDownThePanel()
    local tweener = ShortcutExtensions.DOAnchorPosY(self.panel, 0, 0.5)
    TweenSettingsExtensions.SetEase(tweener, Ease.InOutQuad)
end

function GuildRankingView:SetArrowUpState()
    self.btnArrow.gameObject.transform.localScale = Vector3(1, 1, 1)
end

function GuildRankingView:SetArrowDownState()
    self.btnArrow.gameObject.transform.localScale = Vector3(1, -1, 1)
end

function GuildRankingView:SetCenterAreaState(state)
    self.centerArea:SetActive(state)
end

function GuildRankingView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function GuildRankingView:InitPowerView()
    GameObjectHelper.FastSetActive(self.commonBtn.gameObject, true)
    GameObjectHelper.FastSetActive(self.mistBtn.gameObject, true)
    local powerTopData = self.model:GetPowerTopData()
    local powerSelfData = self.model:GetPowerSelfData()
    self:InitPowerScrollerView(powerTopData)
    self:InitPowerInfoView(powerSelfData)
    self:ShowContent(true)
    self.titleTxt.text = lang.trans("guild_power")
end

function GuildRankingView:InitLivnessView()
    GameObjectHelper.FastSetActive(self.commonBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.mistBtn.gameObject, false)
    self:ShowContent(false)
    self.titleTxt.text = lang.trans("guild_rank")
end

function GuildRankingView:InitMistView()
    GameObjectHelper.FastSetActive(self.commonBtn.gameObject, true)
    GameObjectHelper.FastSetActive(self.mistBtn.gameObject, true)
    local mistTopData = self.model:GetMistTopData()
    local mistSelfData = self.model:GetMistSelfData()
    self:InitMistScrollerView(mistTopData)
    self:InitMistInfoView(mistSelfData)
    self:ShowContent(true)
    self.titleTxt.text = lang.trans("mist_power")
end

function GuildRankingView:ShowContent(isPower)
    GameObjectHelper.FastSetActive(self.livnessInfo, not isPower)
    GameObjectHelper.FastSetActive(self.livnessScroll, not isPower)
    GameObjectHelper.FastSetActive(self.powerInfo, isPower)
    GameObjectHelper.FastSetActive(self.powerScroll, isPower)
end

function GuildRankingView:InitInfoView(rankingModel)
    self.nameInfoTxt.text = rankingModel:GetName()
    self.nameTxt.text = rankingModel:GetName()
    self.contribute.text = tostring(rankingModel:GetThreeContribute())
    self.logo.overrideSprite = AssetFinder.GetGuildIcon("GuildLogo" .. rankingModel:GetEid())
    self.order.text = tostring(rankingModel:GetRank())
end

function GuildRankingView:InitPowerInfoView(data)
    self.powerRankTxt.text = "<size=80>" .. tostring(data.rank) .. "</size>"
    if tonumber(data.rank) == -1 then
        self.powerRankTxt.text = "<size=45>" .. lang.transstr("train_rankOut") .. "</size>"
    end
    if data.bestWar then
        self.bestResultTxt.text = lang.trans("guild_power_top", data.bestWar.sucCnt, data.bestWar.capCnt, data.bestWar.seiCnt, data.bestWar.level, data.bestWar.rank)
    else
        self.bestResultTxt.text = lang.trans("guild_power_no_join")
    end
end

function GuildRankingView:InitMistInfoView(data)
    self.powerRankTxt.text = "<size=80>" .. tostring(data.rank) .. "</size>"
    if tonumber(data.rank) == -1 then
        self.powerRankTxt.text = "<size=45>" .. lang.transstr("train_rankOut") .. "</size>"
    end
    if data.bestMistWar then
        local totalScore = data.bestMistWar.ackScore + data.bestMistWar.defScore
        local level = tostring(data.bestMistWar.level)
        local minLevel = GuildWar[level].minLevel
        self.bestResultTxt.text = lang.trans("mist_power_top", totalScore, minLevel, data.bestMistWar.rank)
    else
        self.bestResultTxt.text = lang.trans("guild_power_no_join")
    end
end

function GuildRankingView:InitLivesScrollerView(data)
    self.scrollerView:InitView(data)
end

function GuildRankingView:InitPowerScrollerView(data)
    self.powerScrollerView:InitView(data)
end

function GuildRankingView:InitMistScrollerView(data)
    self.powerScrollerView:InitView(data)
end

function GuildRankingView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return GuildRankingView

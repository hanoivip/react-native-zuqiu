local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")

local PeakPlayerDetailView = class(unity.base)

function PeakPlayerDetailView:ctor()
    self.title = self.___ex.title
    self.closeBtn = self.___ex.closeBtn
    self.uiRectTransform = self.___ex.uiRectTransform

    -- left btn
    self.guildDetailBtnGo = self.___ex.guildDetailBtnGo
    self.playerDetailBtn = self.___ex.playerDetailBtn
    self.formationDetail1Btn = self.___ex.formationDetail1Btn
    self.formationDetail2Btn = self.___ex.formationDetail2Btn
    self.formationDetail3Btn = self.___ex.formationDetail3Btn
    self.formationFirstHide = self.___ex.formationFirstHide
    self.formationSecHide = self.___ex.formationSecHide
    self.formationThirdHide = self.___ex.formationThirdHide
    self.guildDetailBtn = self.___ex.guildDetailBtn
    self.honorBtn = self.___ex.honorBtn

    -- right btn
    self.delFriendBtnGo = self.___ex.delFriendBtnGo
    self.delFriendBtn = self.___ex.delFriendBtn
    self.addFriendBtnGo = self.___ex.addFriendBtnGo
    self.addFriendBtn = self.___ex.addFriendBtn
    self.privateChatBtn = self.___ex.privateChatBtn
    self.friendlyMathBtnGo = self.___ex.friendlyMathBtnGo
    self.friendlyMathBtn = self.___ex.friendlyMathBtn
    -- self.visitBtnGo = self.___ex.visitBtnGo
    -- self.visitBtn = self.___ex.visitBtn
    self.applyGuildBtnGo = self.___ex.applyGuildBtnGo
    self.applyGuildBtn = self.___ex.applyGuildBtn
    self.delFriendBtnTxt = self.___ex.delFriendBtnTxt
    self.addFriendBtnTxt = self.___ex.addFriendBtnTxt
    self.privateChatBtnTxt = self.___ex.privateChatBtnTxt
    self.friendlyMathBtnTxt = self.___ex.friendlyMathBtnTxt
    self.applyGuildBtnTxt = self.___ex.applyGuildBtnTxt
    self.rightArea = self.___ex.rightArea

    -- data
    self.playerData = nil
    self.formationData = nil
    self.guildData = nil
    self.honorData = nil

    -- 详细显示
    self.playerShowGo = self.___ex.playerShowGo
    self.formationShowGo = self.___ex.formationShowGo
    self.guildShowGo = self.___ex.guildShowGo
    self.honorShowGo = self.___ex.honorShowGo

    -- 对应的lua脚本
    self.playerShowLua = res.GetLuaScript(self.playerShowGo)
    self.formationShowLua = res.GetLuaScript(self.formationShowGo)
    self.guildShowLua = res.GetLuaScript(self.guildShowGo)
    self.honorShowLua = res.GetLuaScript(self.honorShowGo)

    self.selLabelBtnIndex = 1

    -- 记录界面原始宽度
    self.w = self.uiRectTransform.sizeDelta.x
end

function PeakPlayerDetailView:start()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)

    self.playerDetailBtn.clickBack = function()
        self:ChangeSelectState(1)
    end
    self.formationDetail1Btn.clickBack = function()
        self:ChangeSelectState(2)
    end
    self.formationDetail2Btn.clickBack = function()
        self:ChangeSelectState(3)
    end
    self.formationDetail3Btn.clickBack = function()
        self:ChangeSelectState(4)
    end
    self.guildDetailBtn.clickBack = function()
        self:ChangeSelectState(5)
    end
    self.honorBtn.clickBack = function()
        self:ChangeSelectState(6)
    end

    self.addFriendBtn:regOnButtonClick(function()
        if type(self.onAddFriend) == 'function' then
            self.onAddFriend()
        end
    end)

    self.delFriendBtn:regOnButtonClick(function()
        if type(self.onDeleteFriend) == 'function' then
            self.onDeleteFriend()
        end
    end)

    self.privateChatBtn:regOnButtonClick(function()
        if type(self.onPrivateChat) == 'function' then
            self.onPrivateChat()
        end
    end)

    self.friendlyMathBtn:regOnButtonClick(function()
        if type(self.onStartMatch) == 'function' then
            self.onStartMatch()
        end
    end)

    self.applyGuildBtn:regOnButtonClick(function()
        if type(self.onApplyGuild) == 'function' then
            self.onApplyGuild()
        end
    end)
    
    self:PlayInAnimator()
end

function PeakPlayerDetailView:InitView(playerDetailModel, guildDetailModel, honorPalaceModel, sameGuild, isMe, showIndex, hideFunBtn)
    self.playerDetailModel = playerDetailModel
    self.title.text = lang.transstr(isMe and "pd_title_me" or "pd_title")

    -- left
    self.playerDetailBtn:InitView(lang.transstr(isMe and "pd_detail_btn_me" or "pd_detail_btn"))
    self.formationDetail1Btn:InitView(lang.transstr("pd_peak_formation_1_btn"))
    self.formationDetail2Btn:InitView(lang.transstr("pd_peak_formation_2_btn"))
    self.formationDetail3Btn:InitView(lang.transstr("pd_peak_formation_3_btn"))
    self.guildDetailBtn:InitView(lang.transstr("pd_guild_btn"))
    self.honorBtn:InitView(lang.transstr("pd_honor_btn"))

    -- right
    self.delFriendBtnTxt.text = lang.transstr("pd_del_friend_btn")
    self.addFriendBtnTxt.text = lang.transstr("pd_add_friend_btn")
    self.privateChatBtnTxt.text = lang.transstr("pd_private_chat_btn")
    self.friendlyMathBtnTxt.text = lang.transstr("pd_friendly_match_btn")
    self.applyGuildBtnTxt.text = lang.transstr("pd_apply_guild_btn")

    -- center
    self.playerShowLua:InitView(playerDetailModel)
    if guildDetailModel then
        self.guildShowLua:InitView(playerDetailModel, guildDetailModel)
    end
    self.honorShowLua:InitView(playerDetailModel, honorPalaceModel)

    -- 查看自己，或主动隐藏功能按钮
    if isMe or hideFunBtn then
        GameObjectHelper.FastSetActive(self.rightArea, false)
        local width = self.uiRectTransform.sizeDelta.x
        -- 由于可能有缓存，所以要判断，不然界面越缩越小
        if self.w == width then
            self.uiRectTransform.sizeDelta = Vector2(width - 200, self.uiRectTransform.sizeDelta.y)
        end
    else
        -- 控制右侧按钮显示
        local isFirend = self.playerDetailModel:isFriend()
        if isFirend then
            GameObjectHelper.FastSetActive(self.delFriendBtnGo, true)
            GameObjectHelper.FastSetActive(self.addFriendBtnGo, false)
            GameObjectHelper.FastSetActive(self.friendlyMathBtnGo, true)
        else
            GameObjectHelper.FastSetActive(self.delFriendBtnGo, false)
            GameObjectHelper.FastSetActive(self.addFriendBtnGo, true)
            GameObjectHelper.FastSetActive(self.friendlyMathBtnGo, false)
        end
    end

    -- 没有公会
    if guildDetailModel == nil then
        GameObjectHelper.FastSetActive(self.guildDetailBtnGo, false)
        GameObjectHelper.FastSetActive(self.applyGuildBtnGo, false)
    end

    self.canShowGuildBtn = (guildDetailModel ~= nil and sameGuild == false and isMe == false)
    GameObjectHelper.FastSetActive(self.applyGuildBtnGo, self.canShowGuildBtn)

    if showIndex then
        self:ShowViewBySelectIndex(showIndex)
    else
        self:ShowViewBySelectIndex(self.selLabelBtnIndex)
    end

    self:InitFormationHideState()
end

function PeakPlayerDetailView:InitFormationHideState()
    GameObjectHelper.FastSetActive(self.formationFirstHide, self.playerDetailModel:GetTeamShowByIndex(1) == 0)
    GameObjectHelper.FastSetActive(self.formationSecHide, self.playerDetailModel:GetTeamShowByIndex(2) == 0)
    GameObjectHelper.FastSetActive(self.formationThirdHide, self.playerDetailModel:GetTeamShowByIndex(3) == 0)
end

function PeakPlayerDetailView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function PeakPlayerDetailView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function PeakPlayerDetailView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function PeakPlayerDetailView:onDestroy()
    cache.setOtherPlayerTeams(nil)
end

-- 显示玩家详细信息
function PeakPlayerDetailView:ShowPlayerDetail()
    GameObjectHelper.FastSetActive(self.playerShowGo, true)
    GameObjectHelper.FastSetActive(self.formationShowGo, false)
    GameObjectHelper.FastSetActive(self.guildShowGo, false)
    GameObjectHelper.FastSetActive(self.honorShowGo, false)
    self:IfShowApplGuildBtn(false)
end

-- 显示阵容详细信息
function PeakPlayerDetailView:ShowFormationDetail()
    GameObjectHelper.FastSetActive(self.playerShowGo, false)
    GameObjectHelper.FastSetActive(self.formationShowGo, true)
    GameObjectHelper.FastSetActive(self.guildShowGo, false)
    GameObjectHelper.FastSetActive(self.honorShowGo, false)
    self:IfShowApplGuildBtn(false)
end

-- 显示公会详细信息
function PeakPlayerDetailView:ShowGuildDetail()
    GameObjectHelper.FastSetActive(self.playerShowGo, false)
    GameObjectHelper.FastSetActive(self.formationShowGo, false)
    GameObjectHelper.FastSetActive(self.guildShowGo, true)
    GameObjectHelper.FastSetActive(self.honorShowGo, false)
    self:IfShowApplGuildBtn(true)
end

-- 显示荣誉详情
function PeakPlayerDetailView:ShowHonorDetail()
    GameObjectHelper.FastSetActive(self.playerShowGo, false)
    GameObjectHelper.FastSetActive(self.formationShowGo, false)
    GameObjectHelper.FastSetActive(self.guildShowGo, false)
    GameObjectHelper.FastSetActive(self.honorShowGo, true)
    self:IfShowApplGuildBtn(false)
end

function PeakPlayerDetailView:ShowViewBySelectIndex(index)
    if index < 5 and index > 1 then
        local teamIndex = index - 1
        local teamNameMap = 
        {
            [1] = lang.transstr("pd_peak_formation_1_btn"),
            [2] = lang.transstr("pd_peak_formation_2_btn"),
            [3] = lang.transstr("pd_peak_formation_3_btn")
        }
        if self.playerDetailModel:GetTeamFlagByIndex(teamIndex) then
            self.playerDetailModel:InitTeamModelByIndex(teamIndex)
            self.playerDetailModel:SetTeamName(teamNameMap[teamIndex])
            self.formationShowLua:ClearView()
            self.formationShowLua:InitView(self.playerDetailModel)
        else
            DialogManager.ShowToastByLang("pd_peak_empty_team")
            return
        end
    end
    self:ChangeLabelBtnState(self.selLabelBtnIndex, false)
    self:ShowView(index)
end

function PeakPlayerDetailView:ChangeSelectState(index)
    if self.selLabelBtnIndex == index then
        return
    end

    if index < 5 and index > 1 then
        local teamIndex = index - 1
        local teamNameMap = 
        {
            [1] = lang.transstr("pd_peak_formation_1_btn"),
            [2] = lang.transstr("pd_peak_formation_2_btn"),
            [3] = lang.transstr("pd_peak_formation_3_btn")
        }
        -- 代表该阵型是锁定的
        if self.playerDetailModel:GetTeamShowByIndex(teamIndex) == 0 then
            DialogManager.ShowToastByLang("pd_peak_lock")
            return
        end

        if self.playerDetailModel:GetTeamFlagByIndex(teamIndex) then
            self.playerDetailModel:InitTeamModelByIndex(teamIndex)
            self.playerDetailModel:SetTeamName(teamNameMap[teamIndex])
            self.formationShowLua:ClearView()
            self.formationShowLua:InitView(self.playerDetailModel)
        else
            DialogManager.ShowToastByLang("pd_peak_empty_team")
            return
        end
    end
    self:ChangeLabelBtnState(self.selLabelBtnIndex, false)
    self:ShowView(index)
end

function PeakPlayerDetailView:ChangeLabelBtnState(index, isSel)
    if index == 1 then
        self.playerDetailBtn:ChangeSelectState(isSel)
    elseif index == 2 then
        self.formationDetail1Btn:ChangeSelectState(isSel)
    elseif index == 3 then
        self.formationDetail2Btn:ChangeSelectState(isSel)
    elseif index == 4 then
        self.formationDetail3Btn:ChangeSelectState(isSel)
    elseif index == 5 then
        self.guildDetailBtn:ChangeSelectState(isSel)
    elseif index == 6 then
        self.honorBtn:ChangeSelectState(isSel)
    end
end

function PeakPlayerDetailView:ShowView(index)
    if index == 1 then
        self.playerDetailBtn:ChangeSelectState(true)
        self:ShowPlayerDetail()
    elseif index == 2 then
        self.formationDetail1Btn:ChangeSelectState(true)
        self:ShowFormationDetail()
    elseif index == 3 then
        self.formationDetail2Btn:ChangeSelectState(true)
        self:ShowFormationDetail()
    elseif index == 4 then
        self.formationDetail3Btn:ChangeSelectState(true)
        self:ShowFormationDetail()
    elseif index == 5 then
        self.guildDetailBtn:ChangeSelectState(true)
        self:ShowGuildDetail()
    elseif index == 6 then
        self.honorBtn:ChangeSelectState(true)
        self:ShowHonorDetail()
    end
    if self.playerDetailModel:GetIndex() ~= index then
        self.playerDetailModel:SetIndex(index)
    end
    self.selLabelBtnIndex = index
end

-- 申请公会按钮
function PeakPlayerDetailView:IfShowApplGuildBtn(isShow)
    if self.canShowGuildBtn then
        GameObjectHelper.FastSetActive(self.applyGuildBtnGo, isShow)
    end
end

return PeakPlayerDetailView
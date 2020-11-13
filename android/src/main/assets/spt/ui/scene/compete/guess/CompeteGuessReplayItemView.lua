local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local CompeteGuessReplayItemView = class(unity.base, "CompeteGuessReplayItemView")

function  CompeteGuessReplayItemView:ctor()
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- content
    self.objContent = self.___ex.objContent
    -- 左侧玩家
    self.objLeftPlayer = self.___ex.objLeftPlayer
    self.left_ImgLogo = self.___ex.left_ImgLogo
    self.left_TxtName = self.___ex.left_TxtName
    self.left_ImgCompeteSign = self.___ex.left_ImgCompeteSign
    -- 右侧玩家
    self.objRightPlayer = self.___ex.objRightPlayer
    self.right_ImgLogo = self.___ex.right_ImgLogo
    self.right_TxtName = self.___ex.right_TxtName
    self.right_ImgCompeteSign = self.___ex.right_ImgCompeteSign
    -- 中间比分
    self.objMiddle = self.___ex.objMiddle
    self.txtResult = self.___ex.txtResult
    -- 回放按钮
    self.btnReplay = self.___ex.btnReplay

    self.idx = 0  -- 外部设置
end

function CompeteGuessReplayItemView:start()
    self:RegBtnEvent()
end

function CompeteGuessReplayItemView:RegBtnEvent()
    self.btnReplay:regOnButtonClick(function()
        self:OnClickBtnReplay()
    end)
end

function CompeteGuessReplayItemView:InitView(vid, defender, attacker)
    self.vid = vid
    self.defender = defender
    self.attacker = attacker

    if self.vid == nil then
        GameObjectHelper.FastSetActive(self.objContent.gameObject, false)
        return
    end
    self.txtTitle.text = lang.trans("peak_num_scene", self.idx)
    -- 左侧主场
    if defender == nil then
        GameObjectHelper.FastSetActive(self.objLeftPlayer.gameObject, false)
    else
        self:InitTeamLogo(self.left_ImgLogo, defender.logo)
        self:InitCompeteSign(self.left_ImgCompeteSign, defender.worldTournamentLevel)
        self.left_TxtName.text = defender.name .. " " .. defender.serverName
    end
    -- 右侧客场
    if attacker == nil then
        GameObjectHelper.FastSetActive(self.objRightPlayer.gameObject, false)
    else
        self:InitTeamLogo(self.right_ImgLogo, attacker.logo)
        self:InitCompeteSign(self.right_ImgCompeteSign, attacker.worldTournamentLevel)
        self.right_TxtName.text = attacker.name .. " " .. attacker.serverName
    end
    -- 中间比分
    self.txtResult.text = (defender.scores[self.idx] or "") .. ":" .. (attacker.scores[self.idx] or "")
end

-- 球队logo
function CompeteGuessReplayItemView:InitTeamLogo(logoRct, logoData)
    TeamLogoCtrl.BuildTeamLogo(logoRct, logoData)
end


-- 争霸赛标识
function CompeteGuessReplayItemView:InitCompeteSign(imgCompeteSign, competeSign)
    local hasCompeteSign = false
    if competeSign then
        local signData = CompeteSignConvert[tostring(competeSign)]
        if signData then
            imgCompeteSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Images/" .. signData.path .. ".png")
            hasCompeteSign = true
        end
    end
    GameObjectHelper.FastSetActive(imgCompeteSign.gameObject, hasCompeteSign)
end

function CompeteGuessReplayItemView:OnClickBtnReplay()
    if self.onClickBtnReplay then
        self.onClickBtnReplay(self.vid)
    end
end

return CompeteGuessReplayItemView

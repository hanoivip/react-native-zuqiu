local Timer = require('ui.common.Timer')
local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local RankingItemModel = require("ui.models.activity.goldCup.RankingItemModel")
local RewardItemModel = require("ui.models.activity.goldCup.RewardItemModel")
local StageRewardItemModel = require("ui.models.activity.goldCup.StageRewardItemModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GoldCupView = class(ActivityParentView)

local RANKING_REWARD_TAGS = {
    ranking = "ranking",
    reward = "reward",
}
local LINE_DOT_COLOR = {
    gold = "Gold",
    gray = "Gray",
    dot = "Dot",
}

function GoldCupView:ctor()
    self.rankingScrollObj = self.___ex.rankingScrollObj
    self.rewardScrollObj = self.___ex.rewardScrollObj
    self.rankingScroll = self.___ex.rankingScroll
    self.rewardScroll = self.___ex.rewardScroll
    self.rewardScrollRect = self.___ex.rewardScrollRect
    self.residualTimeTxt = self.___ex.residualTimeTxt
    self.rankingAndRewardBtnGroup = self.___ex.rankingAndRewardBtnGroup
    self.contributeRecordBtn = self.___ex.contributeRecordBtn
    self.myPointsTxt = self.___ex.myPointsTxt
    self.stage3Parent = self.___ex.stage3Parent
    self.stage2Parent = self.___ex.stage2Parent
    self.stage4Parent = self.___ex.stage4Parent
    self.stage1Parent = self.___ex.stage1Parent
    self.lineAndDotRect = self.___ex.lineAndDotRect
    self.myRankTxt = self.___ex.myRankTxt
    self.cupPointsTxt = self.___ex.cupPointsTxt
    self.goldCupMaskRect = self.___ex.goldCupMaskRect
    self.ruleBtn = self.___ex.ruleBtn
    self.cupMaskAnimator = self.___ex.cupMaskAnimator
    self.particleEffectObj = self.___ex.particleEffectObj

    self.stagesRewardParent = {self.stage1Parent, self.stage2Parent, self.stage3Parent, self.stage4Parent}
    self.residualTimer = nil
end

function GoldCupView:start()
    self.rankingAndRewardBtnGroup:BindMenuItem(RANKING_REWARD_TAGS.ranking, function()
        self:SwitchRankingAndReward(true)
    end)

    self.rankingAndRewardBtnGroup:BindMenuItem(RANKING_REWARD_TAGS.reward, function()
        self:SwitchRankingAndReward(false)
    end)

    self.contributeRecordBtn:regOnButtonClick(function()
        if type(self.clickContributeRecord) == "function" then
            self.clickContributeRecord()
        end
    end)

    self.ruleBtn:regOnButtonClick(function()
        if type(self.clickRuleBtn) == "function" then
            self.clickRuleBtn()
        end
    end)
end

function GoldCupView:InitView(goldCupModel)
    self.goldCupModel = goldCupModel
    self:RefreshCountDownTimer()
    self:InitMyActivityInfo()
    self:RefreshGoldCupView()
    self:RefreshActivityDurationTxt()
    self:InitRankingAndRewardArea()
    self:InitFourStagesReward()
    self:InitCupPointsTxt()
end

function GoldCupView:RefreshGoldCupView()
    self.cupMaskAnimator.speed = 0
    local maskWidth = 178
    local maskHeight = 449
    local assumingMaskHeight = 350
    local fullCupPointsVlaue = self.goldCupModel:GetFullCupPointsValue()
    local cupPointsValue = self.goldCupModel:GetCupPointsValue()

    if cupPointsValue >= fullCupPointsVlaue then
        assumingMaskHeight = 0
    else
        assumingMaskHeight = maskHeight - assumingMaskHeight * cupPointsValue / fullCupPointsVlaue
    end
    --assumingMaskHeight : 遮罩的高度
    --self.goldCupMaskRect.sizeDelta = Vector2(maskWidth, assumingMaskHeight)
    local effectMaskPosition = (maskHeight - assumingMaskHeight) / maskHeight
    self.goldCupModel:SetEffectMaskPosition(effectMaskPosition)
    self:SmoothEffectMaskAnimation()
end

function GoldCupView:SmoothEffectMaskAnimation()
    --上次金杯高度，和最新金杯高度（百分比0--1）
    local effectMaskAnimationLen = 1 --动画时长为1
    local lastEffectMaskPos = self.goldCupModel:GetLastEffectMaskPosition() * effectMaskAnimationLen
    local effectMaskPos = self.goldCupModel:GetEffectMaskPosition() * effectMaskAnimationLen
    assert(lastEffectMaskPos >= 0 and effectMaskPos <= 1 and lastEffectMaskPos <= effectMaskPos, "logic error!!!")

    if self.goldCupModel:IsFirstEnterActivity() or lastEffectMaskPos == effectMaskPos then
        self.cupMaskAnimator.speed = 0
        self.cupMaskAnimator:Play("SilverCupMaskAnimation", 0, effectMaskPos)  --Lua assist checked flag
        self:ShowOrHideParticleEffect(self.goldCupModel)
    else
        self:coroutine(function()
            GameObjectHelper.FastSetActive(self.particleEffectObj, true)
            self.cupMaskAnimator.speed = 1 --开启动画
            self.cupMaskAnimator:Play("SilverCupMaskAnimation", 0, lastEffectMaskPos)  --Lua assist checked flag
            --用coroutine.WaitForSeconds()效果不好
            while(self.cupMaskAnimator:GetCurrentAnimatorStateInfo(0).IsName("SilverCupMaskAnimation") and self.cupMaskAnimator:GetCurrentAnimatorStateInfo(0).normalizedTime < effectMaskPos) do
                coroutine.yield()
            end
            self.cupMaskAnimator.speed = 0 --终止动画
            self.cupMaskAnimator:Play("SilverCupMaskAnimation", 0, effectMaskPos)  --Lua assist checked flag
            self:ShowOrHideParticleEffect(self.goldCupModel)
        end)
    end
end

function GoldCupView:ShowOrHideParticleEffect(goldCupModel)
    local effectPos = goldCupModel:GetEffectMaskPosition()
    --金杯高度百分比为0和全满(1)的情况下隐藏粒子特效
    local isHideEffect = effectPos == 0 or effectPos == 1
    GameObjectHelper.FastSetActive(self.particleEffectObj, isHideEffect)
    GameObjectHelper.FastSetActive(self.particleEffectObj, not isHideEffect)
end

function GoldCupView:InitCupPointsTxt()
    local cupPointsValue = self.goldCupModel:GetCupPointsValue()
    self.cupPointsTxt.text = "-" .. cupPointsValue .. "-"
end

function GoldCupView:InitMyActivityInfo()
    self.myPointsTxt.text = tostring(self.goldCupModel:GetMyPointValue())
    self.myRankTxt.text = self.goldCupModel:GetMyRankStr()
end

function GoldCupView:InitFourStagesReward()
    self:InitStagesReward()
    self:InitLinesAndDots()
end

--金杯注满高度350
--右顶点(682, 174.5) (682, 309.5) (682, 444.5) (682, 579.5)
--左定点(618, 190 + 能量 / 金杯满能量点 * 350)
--水平长度 hl = 78 * cos(rad(34))
--根据左右顶点计算 角度
--真实长度 hl / cos(角度)
function GoldCupView:InitLinesAndDots()
    local LINE_RIGHT_COOR = {
        Vector2(682, 174.5),
        Vector2(682, 309.5),
        Vector2(682, 444.5),
        Vector2(682, 579.5),
    }
    local lineHorizontalLen = 64 -- = 682 - 618
    local cupPointsValue = self.goldCupModel:GetCupPointsValue()
    local fullCupPointsVlaue = self.goldCupModel:GetFullCupPointsValue() 

    local stagesNum = self.lineAndDotRect.childCount
    for i = 1, stagesNum do
        local stageTrans = self.lineAndDotRect:GetChild(i - 1).transform
        local stagePoints = self.goldCupModel:GetStagePointsByIndex(i)
        local isGold = stagePoints <= cupPointsValue
        local goldLineObj = stageTrans:Find(LINE_DOT_COLOR.gold).gameObject  --Lua assist checked flag
        GameObjectHelper.FastSetActive(goldLineObj, isGold)

        if i ~= stagesNum then
            local lineLeftCoor = self:CalculateLineLeftCoor(stagePoints, fullCupPointsVlaue)
            local bendAngle = math.deg(self:CalculateLineAngleOfStage(lineLeftCoor, LINE_RIGHT_COOR[i]))
            local lineLen = lineHorizontalLen / math.cos(math.rad(bendAngle))

            self:BendLineDot(stageTrans, LINE_DOT_COLOR.gray, lineLen, bendAngle)
            if isGold then
                self:BendLineDot(stageTrans, LINE_DOT_COLOR.gold, lineLen, bendAngle)
            end
        end
    end
end

function GoldCupView:BendLineDot(stageTrans, goldOrGray, lineLen, bendAngle)
    local lineTrans = stageTrans:Find(goldOrGray)  --Lua assist checked flag
    local lineDotTrans = lineTrans:Find(LINE_DOT_COLOR.dot)  --Lua assist checked flag

    lineDotTrans:GetComponent(UnityEngine.RectTransform).sizeDelta = Vector2(lineLen, 19)
    lineDotTrans.localEulerAngles = Vector3(0, 0, bendAngle)
end

function GoldCupView:CalculateLineLeftCoor(stagePoints, fullCupPointsVlaue)
    local assumingHight = 350
    local y = 190 + stagePoints / fullCupPointsVlaue * assumingHight
    return Vector2(618, y)
end

function GoldCupView:CalculateLineAngleOfStage(leftCoor, rightCoor)
    local angle = math.atan2(-leftCoor.y + rightCoor.y, -leftCoor.x + rightCoor.x)
    return angle
end

function GoldCupView:InitStagesReward()
    local prefabPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/GoldCup/StageRewardItem.prefab"
    if type(self.stagesRewardParent) == "table" then
        for k, v in pairs(self.stagesRewardParent) do
            res.ClearChildren(v)
            local obj, spt = res.Instantiate(prefabPath)
            obj.transform:SetParent(v, false)
            local itemData = self.goldCupModel:GetStageRewardDataByIndex(k)
            itemData.index = k
            local itemModel = StageRewardItemModel.new(itemData)
            spt:InitView(itemModel, self.goldCupModel)
        end
    end
end

function GoldCupView:RefreshActivityDurationTxt()
    if self.goldCupModel:IsActivityEnd() then
        self.residualTimeTxt.text = lang.transstr("goldCup_desc2")
    else
        self.residualTimeTxt.text = self.goldCupModel:GetActivityDuration()
    end
end

function GoldCupView:InitRankingAndRewardArea()
    self.rankingAndRewardBtnGroup:selectMenuItem(RANKING_REWARD_TAGS.ranking)
    self:CreateRankingAndRewardScroll()
    local isShowRanking = true
    self:SwitchRankingAndReward(isShowRanking)
end

function GoldCupView:CreateRankingAndRewardScroll()
    self:CreateRankingScroll()
    self:CreateRewardScroll()
end

function GoldCupView:CreateRankingScroll()
    self.rankingScroll:regOnCreateItem(function(scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/GoldCup/RankingScrollItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.rankingScroll:regOnResetItem(function(scrollSelf, spt, index)
        local itemData = scrollSelf.itemDatas[index]
        itemData.rank = index
        local itemModel = RankingItemModel.new(itemData)
        spt:InitView(self.goldCupModel, itemModel)
    end)

    local rankingList = self.goldCupModel:GetRankingList()
    self.rankingScroll:refresh(rankingList)
end

function GoldCupView:CreateRewardScroll()
    self.rewardScroll:regOnCreateItem(function(scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/GoldCup/RewardScrollItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.rewardScroll:regOnResetItem(function(scrollSelf, spt, index)
        spt.scrollDragSpt.scrollRectInParent = self.rewardScrollRect
        local itemData = scrollSelf.itemDatas[index]
        itemData.index = index
        local itemModel = RewardItemModel.new(itemData)
        spt:InitView(itemModel)
    end)

    local rewardList = self.goldCupModel:GetRewardList()
    self.rewardScroll:refresh(rewardList)
end

function GoldCupView:SwitchRankingAndReward(isShowRanking)
    GameObjectHelper.FastSetActive(self.rankingScrollObj, isShowRanking)
    GameObjectHelper.FastSetActive(self.rewardScrollObj, not isShowRanking)
end

function GoldCupView:RefreshCountDownTimer()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    if self.goldCupModel:IsActivityEnd() then return end

    local remainTime = self.goldCupModel:GetRemainTime()
    if remainTime <= 0 then
        self:DoIfActivityEnd()
        return
    end
    self.residualTimer = Timer.new(remainTime, function(time)
        if time <= 0 then
            self:DoIfActivityEnd()
        end
    end)
end

function GoldCupView:DoIfActivityEnd()
    self:RefreshActivityDurationTxt()
end

function GoldCupView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return GoldCupView

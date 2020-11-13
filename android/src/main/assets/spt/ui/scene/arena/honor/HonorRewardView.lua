local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ArenaHelper = require("ui.scene.arena.ArenaHelper")
local HonorRewardView = class(unity.base)

function HonorRewardView:ctor()
    self.desc = self.___ex.desc
    self.stageIcon = self.___ex.stageIcon
    self.starMap = self.___ex.starMap
    self.content = self.___ex.content
    self.beRecieve = self.___ex.beRecieve
    self.btnReward = self.___ex.btnReward
    self.rewardButton = self.___ex.rewardButton
    self.gradientText = self.___ex.gradientText
    self.btnReward:regOnButtonClick(function()
        self:OnClickReward()
    end)
    self:RegEvent()
end

function HonorRewardView:RegEvent()
    EventSystem.AddEvent("ArenaHonorChange", self, self.ArenaHonorChange)
end

function HonorRewardView:onDestroy()
    EventSystem.RemoveEvent("ArenaHonorChange", self, self.ArenaHonorChange)
end

function HonorRewardView:ArenaHonorChange(id)
    if id == self.id then 
        self:ShowButtonState()
    end
end

function HonorRewardView:InitView(barData, arenaModel, arenaHonorModel)
    local score = barData.condition
    local stage, star, openStar, minStage = arenaModel:GetAreaState(score)
    for k, v in pairs(self.starMap) do
        local index = tonumber(string.sub(k, 2))
        local starData = ArenaHelper.GetStarPos[tostring(openStar)]
        local isOpen = starData and tobool(index <= openStar)
        if isOpen then
            local pos = starData[index]
            v.gameObject.transform.anchoredPosition = Vector2(pos.x, pos.y)
            local isShow = tobool(index <= star)
            v.interactable = isShow
        end
        GameObjectHelper.FastSetActive(v.gameObject, isOpen)
    end
    local minStageNum, minStageDesc = "", ""
    if stage then
        self.stageIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Main/Mid_Team" .. stage .. ".png")
        self.stageIcon:SetNativeSize()
        local minStagePos = ArenaHelper.GetMinStagePos[tostring(stage)]
        if minStagePos then
            if stage < ArenaHelper.StageType.StoryStage then 
                minStageDesc = lang.transstr("reduce_num", minStage) 
            else
                minStageDesc = lang.transstr("star_num", minStage) 
            end
        end
    end

    local contents = barData.contents
    local rewardParams = {
        parentObj = nil,
        rewardData = contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        itemParams = {numFont = 11}
    }
    self:ClearContent(self.content)
    rewardParams.parentObj = self.content
    RewardDataCtrl.new(rewardParams)

    self.id = barData.id
    self.arenaHonorModel = arenaHonorModel
    self:ShowButtonState()
    self.desc.text = arenaHonorModel:GetHonorDesc(self.id)
end

function HonorRewardView:ShowButtonState()
    local isShowReward = false
    local isBeRecieved = false
    if self.arenaHonorModel:IsCanRecieve(self.id) then
        isShowReward = true
    elseif self.arenaHonorModel:IsBeRecieve(self.id) then
        isBeRecieved = true
    end
    self.rewardButton.interactable = isShowReward
    self.gradientText.enabled = isShowReward
    GameObjectHelper.FastSetActive(self.btnReward.gameObject, not isBeRecieved)
    GameObjectHelper.FastSetActive(self.beRecieve.gameObject, isBeRecieved)
end

function HonorRewardView:ClearContent(content)
    for i = 1, content.childCount do
        Object.Destroy(content:GetChild(i - 1).gameObject)
    end
end

function HonorRewardView:OnClickReward()
    if self.clickReward then
        self.clickReward(self.id)
    end
end

return HonorRewardView

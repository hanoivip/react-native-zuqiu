local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GuideModel = require("ui.models.playerGuide.GuideModel")
local Guide = require("data.Guide")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuideConstants = require("ui.controllers.playerGuide.GuideConstants")
local FirstPayModel = require("ui.models.activity.FirstPayModel")
local LevelLimit = require("data.LevelLimit")

local GuideManager = { }
local GuidePageHandleMap = 
{
    MainLine = function() GuideManager.EnterMainLine() end,
    Reward = function() GuideManager.EnterReward() end,
    Management = function() GuideManager.EnterManagement() end,
    Card = function() GuideManager.EnterCard() end,
    TransferMarket = function() GuideManager.EnterTransferMarket() end,
    LeagueWelcome = function() GuideManager.EnterLeagueWelcome() end,
    LeagueMain = function() GuideManager.EnterLeagueMain() end,
    Training = function() GuideManager.EnterTraining() end,
    PlayerLetter = function() GuideManager.EnterPlayerLetter() end,
    FancyMain = function() GuideManager.EnterFancyMain() end,
}

--一次使用打開界面
local GuideDialogcallBack = 
{
    [14000] = function() res.PushDialogImmediate("ui.controllers.activity.content.FirstPaySingleCtrl") end,
    [13000] = function() res.PushScene("ui.controllers.home.HomeMainCtrl") end,
    [15000] = function() res.PushScene("ui.controllers.home.HomeMainCtrl") end,
    [60099] = function() res.PushScene("ui.controllers.home.HomeMainCtrl") end,
    [80100] = function() res.PushScene("ui.controllers.home.HomeMainCtrl") end,
}

function GuideManager.Show(moduleInstance)
	local playerGuide = cache.getPlayerGuide() or { }
	if playerGuide.skiped then return end

    if GuideConstants.isOpenGuide then
        GuideManager.guideModel = GuideModel.new()
        local curModule = GuideManager.guideModel:GetCurModule()
        if curModule and curModule ~= "" then
            GuideManager.moduleInstance = moduleInstance
            GuideManager.guideModel:SetCurStepWithModule()
            GuideManager.Init()
            GuideManager.guideModel:SetCurModuleWithMaxStep()
        else
            GuideManager.RemoveLastGuide()
        end
    end
end

function GuideManager.Init()
    local objs = GuideManager.ShowGuide()
    if objs then
        GuideManager.RemoveLastGuide()
        GuideManager.SetLastGuide(objs)
    end
end

local commonMask
-- 使用一个全屏的canvas来屏蔽点击事件
function getCommonMask()
    if commonMask == nil or commonMask == clr.null then
        commonMask = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/PlayerGuide/Common/CommonMask.prefab")
    end
    commonMask.transform:SetParent(clr.null, true)
    return commonMask
end

-- 屏蔽点击事件
function GuideManager.ShieldClick(shield)
    GameObjectHelper.FastSetActive(getCommonMask(), shield)
end

function GuideManager.ShowGuide()
    local step = GuideManager.guideModel:GetCurStep()
    if step and Guide[tostring(step)] then
        if GuideManager.moduleInstance then
            -- 设置强制引导时功能按钮的显示和隐藏状态
            if GuideManager.moduleInstance.InitButtonStatus and type(GuideManager.moduleInstance.InitButtonStatus) == "function" then
                GuideManager.moduleInstance.InitButtonStatus()
            end
            -- 播放强制引导时功能按钮的进入动画
            if GuideManager.moduleInstance.PlayButtonMoveInAnimation and type(GuideManager.moduleInstance.PlayButtonMoveInAnimation) == "function" then
                GuideManager.ShieldClick(true)
                GuideManager.moduleInstance.PlayButtonMoveInAnimation(function()
                    GuideManager.ShieldClick(false)
                    local objs = GuideManager.ShowPlayerGuide()
                    GuideManager.RemoveLastGuide()
                    GuideManager.SetLastGuide(objs)
                end)
                return nil
            end
        end
        return GuideManager.ShowPlayerGuide()
    end
    return nil
end

function GuideManager.ShowPlayerGuide()
    local guideModel = GuideManager.guideModel
    local step = guideModel:GetCurStep()
    local objs = { }
    local prefabName1 = guideModel:GetGuidance(step)
    if prefabName1 ~= "" then
        local guideDialog1, guideView1 = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/PlayerGuide/" .. prefabName1 .. ".prefab")
        if guideView1 then
            guideView1:InitView()
        end
        table.insert(objs, guideDialog1)
    end
    local prefabName2 = guideModel:GetTextType(step)
    if prefabName2 ~= "" then
        local guideDialog2, guideView2 = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/PlayerGuide/" .. prefabName2 .. ".prefab")
        if guideView2 then
            guideView2:InitView(GuideDialogcallBack[step])
        end
        table.insert(objs, guideDialog2)
    end
    return objs
end

function GuideManager.SetLastGuide(objs)
    local step = GuideManager.guideModel:GetCurStep()
    if step then
        cache.setGlobalTempData(objs, "GuideLastStep")
        GuideManager.ReportBI(step)
    end
end

function GuideManager.RemoveLastGuide()
    local lastObjs = cache.removeGlobalTempData("GuideLastStep")
    if lastObjs and lastObjs ~= clr.null then
        clr.coroutine(function()
            unity.waitForNextEndOfFrame()
            if lastObjs and lastObjs ~= clr.null then
                for i, obj in ipairs(lastObjs) do
                    Object.Destroy(obj)
                end
            end
            -- 避免新手引导点击过快导致的一系列奇怪问题
            GuideManager.ShieldClick(true)
            coroutine.yield(clr.UnityEngine.WaitForSeconds(0.5))
            GuideManager.ShieldClick(false)
        end)
    end
end

function GuideManager.HideLastGuide()
    if GuideConstants.isOpenGuide then
        local lastObjs = cache.getGlobalTempData("GuideLastStep")
        if lastObjs and lastObjs ~= clr.null then
            for i, obj in ipairs(lastObjs) do
                GameObjectHelper.FastSetActive(obj, false)
            end
        end
    end
end

function GuideManager.ReportBI(step)
    local moduleType = GuideManager.guideModel:GetCurModule()
    clr.coroutine(function()
        local function onfailed()
            clr.coroutine(function()
                for i = 1, 10 do
                    local resp = req.playerGuide(moduleType, step, nil, nil, true) 
                    if api.success(resp) then
                        break
                    end
                    coroutine.yield(clr.UnityEngine.WaitForSeconds(3))
                end
            end)
        end
        local function oncomplete()
            luaevt.trig("HoolaiBISendCounterTaskGuide", step)
        end
        req.playerGuide(moduleType, step, oncomplete, onfailed, true)
    end)
end

--一键跳过引导(请求失败按正常走新手引导)
function GuideManager.SkipGuide()
	if GuideConstants.isOpenGuide then 
		clr.coroutine(function()
			local response = req.playerGuide("skiped", 1, oncomplete, onfailed, true)
			if api.success(response) then
				local data = response.val
				local playerGuide = cache.getPlayerGuide() or {}
				playerGuide['skiped'] = data.skiped
				cache.setPlayerGuide(playerGuide) 
				luaevt.trig("SDK_Report", "guide_skip_done")
				EventSystem.SendEvent("GuideSkipSuccess")
			end
		end)
	end
end

-- 登录时进入指定场景
function GuideManager.EnterReturnPointScene()
	local playerGuide = cache.getPlayerGuide() or { }
	if playerGuide.skiped then return end

    if GuideConstants.isOpenGuide then
        local guideModel = GuideModel.new()
        local returnPointModule = guideModel:GetRturnPointModule()
        if returnPointModule then
            guideModel:InitCurModule(returnPointModule)
            local curStep = guideModel:GetCurStep()
            local returnPoint = guideModel:GetReturnPoint(curStep)
            guideModel:CacheStep(returnPoint)

            local preStep = guideModel:GetPreStep()
            guideModel:CacheStep(preStep)
            local page = guideModel:GetPage(returnPoint)
            if page ~= "HomePage" then
                local enterFunc = GuidePageHandleMap[page]
                if enterFunc then
                    enterFunc()
                end
                return true
            end
        end
    end
    return false
end

function GuideManager.InitCurModule(moduleType)
    if GuideConstants.isOpenGuide then
        local guideModel = GuideModel.new()
        guideModel:InitCurModule(moduleType)
    else
        local playerGuide = cache.getPlayerGuide()
        playerGuide["curModule"] = ""
        cache.setPlayerGuide(playerGuide)
    end
end

function GuideManager.GuideIsOnGoing(moduleType)
	local playerGuide = cache.getPlayerGuide() or { }
	if playerGuide.skiped then return false end

    if GuideConstants.isOpenGuide then
        return GuideModel.new():GuideIsOnGoing(moduleType)
    else
        return false
    end
end

function GuideManager.HasGuideOnGoing()
	local playerGuide = cache.getPlayerGuide() or { }
	if playerGuide.skiped then return false end

    if GuideConstants.isOpenGuide then
        local curModule = GuideModel.new():GetCurModule()
        return curModule and curModule ~= ""
    else
        return false
    end
end

function GuideManager.GetCurModelGuideStep()
    local guideModel = GuideModel.new()
    return guideModel:GetCurStep()
end

function GuideManager.EnterMainLine()
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        local questPageCtrl = res.PushSceneImmediate("ui.controllers.quest.QuestPageCtrl")
        GuideManager.Show(questPageCtrl)
    end)
end

function GuideManager.EnterReward()
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        res.PushScene("ui.controllers.quest.QuestPageCtrl", function()
            unity.waitForNextEndOfFrame()
            local rewardListCtrl = res.PushDialogImmediate("ui.controllers.rewards.RewardListCtrl")
            GuideManager.Show(rewardListCtrl)
        end)
    end)
end

function GuideManager.EnterManagement()
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        res.PushScene("ui.controllers.quest.QuestPageCtrl")
        unity.waitForNextEndOfFrame()
        local playerListMainCtrl = res.PushSceneImmediate("ui.controllers.playerList.PlayerListMainCtrl", nil, nil, nil, nil, true)
        GuideManager.Show(playerListMainCtrl)
    end)
end

function GuideManager.EnterCard()
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        local questPageCtrl = res.PushSceneImmediate("ui.controllers.quest.QuestPageCtrl")
        unity.waitForNextEndOfFrame()
        res.PushSceneImmediate("ui.controllers.playerList.PlayerListMainCtrl")

        local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
        local playerCardsMapModel = PlayerCardsMapModel.new()
        local pcid = playerCardsMapModel:GetPcidByCid("Andycarroll1")
        -- 点击卡牌，弹出卡牌详情页面
        local PlayerListModel = require("ui.models.playerList.PlayerListModel")
        local playerListModel = PlayerListModel.new()
        playerListModel:SortCardList(require("ui.controllers.playerList.SortType").DEFAULT)
        local CardBuilder = require("ui.common.card.CardBuilder")
        local cardList = playerListModel:GetSortCardList()
        for i, v in ipairs(cardList) do
            if tostring(v) == tostring(pcid) then
                local currentModel = CardBuilder.GetOwnCardModel(cardList[i])
                unity.waitForNextEndOfFrame()
                local CardDetailMainCtrl = res.PushSceneImmediate("ui.controllers.cardDetail.CardDetailMainCtrl", cardList, i, currentModel)
                -- 打开大卡界面
                GuideManager.Show(CardDetailMainCtrl)
                break
            end
        end
    end)
end

function GuideManager.EnterTransferMarket()
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        res.PushScene("ui.controllers.transferMarket.TransferMarketCtrl", {})
    end)
end

function GuideManager.EnterLeagueWelcome()
    require("ui.controllers.league.leagueCtrl").new()
end

function GuideManager.EnterLeagueMain()
    require("ui.controllers.league.leagueCtrl").new()
end

function GuideManager.EnterTraining()
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        res.PushScene("ui.controllers.training.TrainCtrl")
    end) 
end

function GuideManager.EnterFancyMain()
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        unity.waitForNextEndOfFrame()
        res.PushScene("ui.controllers.fancy.fancyEntry.FancyEntryCtrl")
    end)
end

function GuideManager.EnterPlayerLetter()
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        res.PushScene("ui.controllers.quest.QuestPageCtrl", function()
            GuideManager.ShieldClick(true)
            unity.waitForNextEndOfFrame()
            res.PushDialog("ui.controllers.playerLetter.PlayerLetterCtrl")
            GuideManager.ShieldClick(false)
        end)
    end)
end

function GuideManager.LevelGuide()
    if GuideManager_IsReward then
        return
    end
    local level = require("ui.models.PlayerInfoModel").new():GetLevel()
    if level == 4 then
        GuideManager.InitCurModule("beginnerCarnival")
        GuideManager.Show()
    elseif level == 5 then
        clr.coroutine(function()
            local response = req.activityFirstPayInfo()
            if api.success(response) then
                if response.val and next(response.val) then
                    local activityModel = FirstPayModel.new(response.val.list)
                    if activityModel:GetRemainTime() > 0 then
                        cache.setFirstPayInfo(activityModel)
                        local firstPaySingleCtrl = require("ui.controllers.activity.content.FirstPaySingleCtrl")
                        GuideManager.InitCurModule("freshGift")
                        GuideManager.Show(firstPaySingleCtrl)
                        return
                    end
                end
            end
        end)
    elseif level == 10 then
        GuideManager.InitCurModule("GrowthPlan")
        GuideManager.Show()
    elseif level == LevelLimit.Coach.playerLevel then
        GuideManager.InitCurModule("coach")
        GuideManager.Show()
    elseif level == LevelLimit.Fancy.playerLevel then
        GuideManager.InitCurModule("fancy")
        GuideManager.Show()
    end
end

return GuideManager
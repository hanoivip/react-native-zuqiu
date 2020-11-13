local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local RectTransform = UnityEngine.RectTransform

local ChapterMap = require("ui.scene.quest.ChapterMap")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local StageGroupView = class(unity.base)

function StageGroupView:ctor()
    -- 副本视图model
    self.questPageViewModel = nil
    -- 主线副本数据模型
    self.questInfoModel = nil
    -- 当前章节索引
    self.nowChapterIndex = nil
    -- 关卡组数据
    self.stageGroupData = nil
    self.stageBoxPool = nil
    self.arrowPool = nil
    self.stageBoxObj = nil
    self.arrowObj = nil
end

function StageGroupView:InitView(questPageViewModel, nowChapterIndex, stageGroupData)
    self.questPageViewModel = questPageViewModel
    self.questInfoModel = self.questPageViewModel:GetModel()
    self.nowChapterIndex = nowChapterIndex
    self.stageGroupData = stageGroupData
    self:BuildView()
end

function StageGroupView:BuildView()
    if self.stageBoxObj == nil then
        self.stageBoxObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Quest/StageBox.prefab")
    end
    if self.stageBoxPool == nil then
        self.stageBoxPool = {}
    end
    if self.arrowObj == nil then
        self.arrowObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Quest/Arrow.prefab")
    end
    if self.arrowPool == nil then
        self.arrowPool = {}
    end

    local stageBoxPoolCount = #self.stageBoxPool
    local arrowPoolCount = #self.arrowPool
    local arrowNeedCount = 0

    for i, stageInfoModel in ipairs(self.stageGroupData) do
        local stageConfig = ChapterMap[i]
        local isOpen = self.questInfoModel:CheckStageOpenedByIndex(self.nowChapterIndex, stageInfoModel:GetStageIndex())
        local node = nil
        local nodeTrans = nil
        if i <= stageBoxPoolCount then
            node = self.stageBoxPool[i]
            nodeTrans = node:GetComponent(RectTransform)
            GameObjectHelper.FastSetActive(node, true)
        else
            node = Object.Instantiate(self.stageBoxObj)
            self.stageBoxPool[i] = node
            nodeTrans = node:GetComponent(RectTransform)
            nodeTrans:SetParent(self.transform, false)
        end
        local nodeScript = res.GetLuaScript(node)
        nodeTrans.anchoredPosition = Vector2(tonumber(stageConfig.stageCoor[1]), tonumber(stageConfig.stageCoor[2]))
        nodeScript:InitView(self.questPageViewModel, stageInfoModel)

        if type(stageConfig.arrow) == "table" then
            arrowNeedCount = arrowNeedCount + 1
            local arrowConfig = stageConfig.arrow
            local arrowGo = nil
            local arrowTrans = nil
            if arrowNeedCount <= arrowPoolCount then
                arrowGo = self.arrowPool[arrowNeedCount]
                arrowTrans = arrowGo:GetComponent(RectTransform)
                GameObjectHelper.FastSetActive(arrowGo, true)
            else
                arrowGo = Object.Instantiate(self.arrowObj)
                self.arrowPool[arrowNeedCount] = arrowGo
                arrowTrans = arrowGo:GetComponent(RectTransform)
                arrowTrans:SetParent(self.transform, false)
            end
            local arrowScript = res.GetLuaScript(arrowGo)
            arrowTrans.anchoredPosition = Vector2(tonumber(arrowConfig[1]), tonumber(arrowConfig[2]))
            arrowTrans.localEulerAngles = Vector3(0, 0, tonumber(arrowConfig[3]))
            arrowTrans.localScale = Vector3(tonumber(arrowConfig[4]), 1, 1)
            arrowScript:InitView(isOpen)
        end
    end

    if stageBoxPoolCount > #self.stageGroupData then
        for i = #self.stageGroupData + 1, stageBoxPoolCount do
            GameObjectHelper.FastSetActive(self.stageBoxPool[i], false)
        end
    end

    if arrowPoolCount > arrowNeedCount then
        for i = arrowNeedCount + 1, arrowPoolCount do
            GameObjectHelper.FastSetActive(self.arrowPool[i], false)
        end
    end
end

function StageGroupView:onDestroy()
    self.stageBoxPool = nil
    self.arrowPool = nil
    self.stageBoxObj = nil
    self.arrowObj = nil
end

return StageGroupView

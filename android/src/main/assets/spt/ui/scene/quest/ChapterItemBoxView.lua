local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Color = UnityEngine.Color
local Image = UI.Image
local Text = UI.Text
local Object = UnityEngine.Object

local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local ChapterItemBoxView = class(unity.base)

function ChapterItemBoxView:ctor()
    -- 章节Icon
    self.icon = self.___ex.icon
    -- 章节索引名称
    self.chapterIndexText = self.___ex.chapterIndexText
    -- 进度条
    self.progressBar = self.___ex.progressBar
    -- 星星数量
    self.starNum = self.___ex.starNum
    -- 进入按钮
    self.enterBtn = self.___ex.enterBtn
    self.enterBtnComp = self.___ex.enterBtnComp
    -- 进入按钮正常状态文本
    self.enterBtnNormalText = self.___ex.enterBtnNormalText
    -- 进入按钮可不用状态文本
    self.enterBtnDisabledText = self.___ex.enterBtnDisabledText
    -- 章节标题
    self.chapterTitle = self.___ex.chapterTitle
    -- 星星
    self.starImg = self.___ex.starImg
    -- 背景光
    self.bgGlow = self.___ex.bgGlow
    -- 动画管理器
    self.animator = self.___ex.animator
    -- 选择按钮
    self.selectBtn = self.___ex.selectBtn
    -- 章节数据
    self.chapterData = nil
    -- 主线副本数据模型
    self.questInfoModel = nil
    -- 章节索引
    self.chapterIndex = nil
    -- 当前选择的章节索引
    self.nowSelectedChapterIndex = nil
end

function ChapterItemBoxView:InitView(questInfoModel, chapterIndex, nowSelectedChapterIndex)
    self.questInfoModel = questInfoModel
    self.chapterIndex = chapterIndex
    self.chapterData = self.questInfoModel:GetChapterDataByIndex(self.chapterIndex)
    self.nowSelectedChapterIndex = nowSelectedChapterIndex
    self:BuildView()
end

function ChapterItemBoxView:start()
    self:BindAll()
    self:RegisterEvent()
end

function ChapterItemBoxView:BindAll()
    -- 进入按妞
    self.enterBtn:regOnButtonClick(function ()
        EventSystem.SendEvent("SelectChapter.Destroy")
        EventSystem.SendEvent("QuestPageView.GoToChapter", self.chapterData.chapterId)
    end)

    -- 选择按钮
    self.selectBtn:regOnButtonClick(function ()
        EventSystem.SendEvent("Chapter_Select", self.chapterIndex)
    end)
end

--- 注册事件
function ChapterItemBoxView:RegisterEvent()
    EventSystem.AddEvent("Chapter_Select", self, self.SwitchSelectState)
end

--- 移除事件
function ChapterItemBoxView:RemoveEvent()
    EventSystem.RemoveEvent("Chapter_Select", self, self.SwitchSelectState)
end

function ChapterItemBoxView:BuildView()
    self.chapterIndexText.text = lang.trans("quest_chapterIndex", self.chapterIndex)
    self.chapterTitle.text = string.gsub(self.chapterData.staticData.title, " ", "\n")

    local allStarNum = #self.chapterData.stageList * 3
    local alightStarNum = 0
    for i, stageInfoModel in ipairs(self.chapterData.stageList) do
        alightStarNum = alightStarNum + stageInfoModel:GetStar()
    end
    self.starNum.text = alightStarNum .. "/" .. allStarNum
    self.progressBar.value = alightStarNum / allStarNum

    self.icon.sprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Quest/Images/ChapterIcon/ChapterIcon" .. self.chapterData.chapterId .. ".png")
    local isOpened = self.questInfoModel:CheckChapterOpenedById(self.chapterData.chapterId)
    if isOpened then
        self.icon.color = Color.white
        self.starImg.color = Color.white
    else
        self.icon.color = Color(0, 1, 1)
        self.starImg.color = Color(0, 1, 1)
    end
    self.enterBtnComp.interactable = isOpened
    self.enterBtn:onPointEventHandle(isOpened)
    self.selectBtn:onPointEventHandle(isOpened)
    GameObjectHelper.FastSetActive(self.enterBtnNormalText, isOpened)
    GameObjectHelper.FastSetActive(self.enterBtnDisabledText, not isOpened)

    self:SwitchSelectState()
end

function ChapterItemBoxView:SwitchSelectState(selectedChapterIndex)
    if selectedChapterIndex ~= nil then
        self.nowSelectedChapterIndex = selectedChapterIndex
    end
    local isSelected = self.chapterIndex == self.nowSelectedChapterIndex
    GameObjectHelper.FastSetActive(self.bgGlow, isSelected)
    if isSelected then
        self.animator:Play("Select", 0)
    else
        self.animator:Play("Default", 0)
    end
end

function ChapterItemBoxView:onDestroy()
    self:RemoveEvent()
end

return ChapterItemBoxView

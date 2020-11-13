local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Tweening = clr.DG.Tweening
local TweenExtensions = Tweening.TweenExtensions
local Tweener = Tweening.Tweener
local Sequence = Tweening.Sequence
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local BannerAssetFinder = require("ui.scene.compete.main.BannerAssetFinder")
local BannerView = class(unity.base)

-- param（左边栏显示）
-- type :1, 2 (两种类型交互显示)
-- index :a, b, c, d, e, f, g（几种情况选择显示）
--1	a玩家有参加联赛	显示玩家当前所在联赛的类型以及排名积分等，排名积分一次性玩家排名以及玩家前后共3个排名（包括玩家）
--1	b玩家当前未有资格参加联赛	显示玩家当前赛季所处天梯的排名
--2	a玩家参与跨服战中（和类别1交替出现）预选赛直接晋级	
--2	b玩家参与跨服战中（和类别1交替出现）预选赛未直接晋级	
--2	c玩家参与跨服战中（和类别1交替出现）预算赛晋级，小组赛未开始	
--2	d玩家没参加小组赛，且小组赛开始	
--2	e玩家参加跨服战，小组赛正赛切分组完成	
--2	f玩家参加跨服战进入淘汰赛，且未被淘汰	显示相应的比赛title，并且显示比赛信息
--2	g玩家参加跨服战进入淘汰赛，且被淘汰	显示相应的比赛title，并且显示比赛对阵信息。随机显示4个，超过4个则随机显示一组

-- param（右边栏显示）
-- type :1, 2 ,3, 4(type种类型交互显示)
-- index :1，2, 3（几种情况选择显示）
--1 a针对所有人，且有冠军的情况下	显示豪门大耳朵杯冠军以及小耳朵杯冠军，冠军名称会进行切换。上赛季冠军将进行全服推送
--4 a重点比赛介绍	豪门大耳朵杯/小耳朵杯的决赛，四分之一，八分之一，十六分之一比赛都会进行全服推送，比赛过则随机进行推送
--2 a区服英雄榜	展示本区服，区服贡献度最高的玩家，针对每个区的玩家看到的内容不一样
--3 a联赛当前第一	展示当前比赛本区超级联赛排行榜前3玩家
--4 b宣传出线名额	 展示本区进入大耳朵杯/小耳朵杯的人数，本区人只能看到该区玩家参与正赛的名额.推送本区小耳朵杯/小耳朵杯的晋级名额，档位或则分组
--4 c区服淘汰赛信息榜单	大耳朵杯/小耳朵杯小组赛结束后，每一轮比赛结束全服推送

function BannerView:ctor()
    self.banner = self.___ex.banner
	self.bannerMap = {}
	self.tweenersMap = {}
	self.selfBannerIndex = 1
end

function BannerView:RefreshView(bannerCollectionModel, isSelfBanner)
	self.bannerCollectionModel = bannerCollectionModel

	local bannerData = bannerCollectionModel:GetSortData()
	for i, v in ipairs(bannerData) do
		local typeIndex = v.typeIndex
		local index = v.index
		if not self.bannerMap[typeIndex] then
			self.bannerMap[typeIndex] = {}
		end
		if not self.bannerMap[typeIndex][index] then
			local obj = res.Instantiate(BannerAssetFinder.GetCrossPrefab(isSelfBanner, typeIndex, index))
			local spt = res.GetLuaScript(obj)
			obj.transform:SetParent(self.banner, false)
			obj.transform.anchoredPosition = Vector2(10000, 10000)
			self.bannerMap[typeIndex][index] = spt
		end
		self.bannerMap[typeIndex][index]:InitView(self.bannerCollectionModel, typeIndex, index)
	end
end

function BannerView:InitView(bannerCollectionModel, isSelfBanner)
	self:RefreshView(bannerCollectionModel, isSelfBanner)
	
	self:PlayInAnim1()
end

-- 距离Banner中心点移动的距离
local MoveDistance = 140
local costTime = 1
local delayTime = 8
local Tweeners = {}
function BannerView:PlayInAnim1()
	local bannerNum = self.bannerCollectionModel:GetBannerNum()
	if bannerNum <= 0 then return end

	local bannerData = self.bannerCollectionModel:GetBannerData(self.selfBannerIndex)
	local typeIndex = bannerData.typeIndex
	local index = bannerData.index

	local contentCanvasGroup = self.bannerMap[typeIndex][index].canvasGroup
	local bannerContent = self.bannerMap[typeIndex][index].content
	contentCanvasGroup.alpha = 0
	bannerContent.anchoredPosition = Vector2(0, -MoveDistance)
	
    local fadeInTweener = ShortcutExtensions.DOFade(contentCanvasGroup, 1, costTime)
    TweenSettingsExtensions.SetEase(fadeInTweener, Ease.OutCubic)
	TweenSettingsExtensions.SetAutoKill(fadeInTweener, false)
	table.insert(self.tweenersMap, fadeInTweener)

    local moveInTweener = ShortcutExtensions.DOAnchorPosY(bannerContent, 0, costTime)
    TweenSettingsExtensions.SetEase(moveInTweener, Ease.OutCubic)
	TweenSettingsExtensions.SetAutoKill(moveInTweener, false)
	table.insert(self.tweenersMap, moveInTweener)

    local delayInTweener = ShortcutExtensions.DOAnchorPosX(bannerContent, 0, delayTime)
    TweenSettingsExtensions.SetEase(delayInTweener, Ease.OutCubic)
    TweenSettingsExtensions.OnComplete(delayInTweener, function ()
		local bannerNum = self.bannerCollectionModel:GetBannerNum()
		if bannerNum > 1 then -- 有多个时候会顺序播放下一条
			local nextIndex = self.selfBannerIndex + 1
			if nextIndex > bannerNum then 
				nextIndex = 1
			end
			self.selfBannerIndex = nextIndex
			self:PlayOutAnim1(typeIndex, index)
			self:PlayInAnim1()
		else
			self.selfBannerIndex = 1
		end
    end)
	TweenSettingsExtensions.SetAutoKill(delayInTweener, false)
	table.insert(self.tweenersMap, delayInTweener)
end

function BannerView:PlayOutAnim1(typeIndex, index)
	local contentCanvasGroup = self.bannerMap[typeIndex][index].canvasGroup
	local bannerContent = self.bannerMap[typeIndex][index].content

    local fadeOutTweener = ShortcutExtensions.DOFade(contentCanvasGroup, 0, costTime)
    TweenSettingsExtensions.SetEase(fadeOutTweener, Ease.OutCubic)
	TweenSettingsExtensions.SetAutoKill(fadeOutTweener, false)
	table.insert(self.tweenersMap, fadeOutTweener)

    local moveOutTweener = ShortcutExtensions.DOAnchorPosY(bannerContent, MoveDistance, costTime)
    TweenSettingsExtensions.SetEase(moveOutTweener, Ease.OutCubic)
	TweenSettingsExtensions.SetAutoKill(moveOutTweener, false)
    TweenSettingsExtensions.OnComplete(moveOutTweener, function ()
    end)
	table.insert(self.tweenersMap, moveOutTweener)
end

function BannerView:OnExitScene()
	for k, v in pairs(self.tweenersMap) do
		if v then 
			TweenExtensions.Kill(v)
		end
	end

	for typeIndex, v in pairs(self.bannerMap) do
		for index, n in pairs(v) do
			local gameObject = self.bannerMap[typeIndex][index].gameObject
			Object.Destroy(gameObject)
		end
	end
	self.tweenersMap = {}
	self.bannerMap = {}
	self.selfBannerIndex = 1
end

return BannerView
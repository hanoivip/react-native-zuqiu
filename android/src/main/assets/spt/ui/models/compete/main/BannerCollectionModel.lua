local Model = require("ui.models.Model")
local BannerCollectionModel = class(Model, "BannerCollectionModel")

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
function BannerCollectionModel:ctor()
    BannerCollectionModel.super.ctor(self)
	self.sortData = {}
end

function BannerCollectionModel:InitWithProtocol(data)
    if not data then data = {} end
    self:Init(data)
	self:AllotData(data)
end

function BannerCollectionModel:AllotData(data)
	self.sortData = {}
	self.map = {}
	for i, v in ipairs(data) do
		local typeIndex = v.typeIndex or 1
		local index = v.index or 1
		local bannerData = {}
		bannerData.typeIndex = typeIndex
		bannerData.index = index
		bannerData.content = v
		table.insert(self.sortData, bannerData)
		if not self.map[typeIndex] then
			self.map[typeIndex] = {}
		end
		self.map[typeIndex][index] = v
	end
end

function BannerCollectionModel:GetSortData()
	return self.sortData
end

function BannerCollectionModel:GetBannerData(index)
	return self.sortData[index] or {}
end

function BannerCollectionModel:GetBannerNum()
	return table.nums(self.sortData)
end

function BannerCollectionModel:GetCollectionContent(typeIndex, index)
	return self.map[typeIndex] and self.map[typeIndex][index] or {}
end

return BannerCollectionModel
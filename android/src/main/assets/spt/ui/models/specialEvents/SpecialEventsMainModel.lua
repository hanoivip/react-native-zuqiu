local Model = require("ui.models.Model")
local EventSystem = require("EventSystem")
local SpecificMatchBase = require("data.SpecificMatchBase")
local SpecificMatchReward = require("data.SpecificMatchReward")

local SpecialEventsMainModel = class(Model, "SpecialEventsMainModel")

function SpecialEventsMainModel:ctor()
end

function SpecialEventsMainModel:InitWithProtocol(data)
    self.data = data
    self.main = {}
    -- build view model for main view
    self:InitMainItems("open")
    self:InitMainItems("mask")
    self:InitMainItems("grey")

    self:InitDifficultyItems()

    if self.data.nextBeginTime and self.data.serverTime then
        self.nextBeginLocalTime = os.time() + (self.data.nextBeginTime - self.data.serverTime)
    end
end

function SpecialEventsMainModel:InitMainItems(status)
    local source = self.data.openStatus[status]
    if not source then
        return
    end

    for i, id in pairs(source) do
        for j, s in pairs(SpecificMatchBase) do
            if s.id == id then
                local item = {}
                item.id = s.id
                item.openStatus = status
                item.title = s.title
                item.titleEnglish = s.titleEnglish
                item.desc = s.desc
                item.isSkill = s.nation == nil or type(s.nation) ~= "table" or #s.nation == 0
                item.showRedPoint =
                    status == "open" and self.data.typeList[tostring(s.id)] and
                    self.data.typeList[tostring(s.id)].times > 0 or
                    false

                table.insert(self.main, item)
                break
            end
        end
    end
end

function SpecialEventsMainModel:InitDifficultyItems()
    self.difficulty = {}
    self.difficultyIndex = {}
    local tempIndex = {}
    for i, base in pairs(SpecificMatchBase) do
        if not self.difficulty[base.id] then
            self.difficulty[base.id] = {}
            tempIndex[base.id] = 0
        end

        local clearRewards = {}
        for k, value in pairs(base.cleanReward) do
            local cleanRewardId = string.split(value, "=")[1]
            table.insert(clearRewards, SpecificMatchReward[cleanRewardId])
        end

        local openStatus = nil
        for k, value in pairs(self.main) do
            if value.id == base.id then
                openStatus = value.openStatus
                break
            end
        end
        local num = string.gsub(i, "_", ".")
        num = math.fmod(tonumber(num), 100)
        -- 不连续不能排序 用新的Index
        tempIndex[base.id] = tempIndex[base.id] + 1
        self.difficulty[base.id][tempIndex[base.id]] = {
            tabPosSort = num,
            matchId = base.matchId,
            title = base.title,
            titleEnglish = base.titleEnglish,
            preID = base.preID,
            coachPage = base.coachPage,
            attenuation = base.attenuation,
            openAbility = base.openAbility,
            energyCost = base.energyCost,
            initial = self.data.list[i] and self.data.list[i].initial or 0,
            winTimes = self.data.list[i] and math.min(self.data.list[i].winTimes or 0, self.data.cumulativePass) or 0,
            times = self.data.typeList[tostring(base.id)] and self.data.typeList[tostring(base.id)].times or 0,
            firstReward = SpecificMatchReward[tostring(base.firstReward)],
            cleanRewards = clearRewards,
            vipQuickPass = self.data.vipQuickPass,
            cumulativePass = self.data.cumulativePass,
            isSkill = (base.nation == nil or type(base.nation) ~= "table" or #base.nation == 0),
            openStatus = openStatus
        }
    end

    for key, value in pairs(self.difficulty) do
        table.sort(
            value,
            function(a, b)
                return a.tabPosSort < b.tabPosSort
            end
        )
        for k, v in pairs(value) do
            self.difficultyIndex[tostring(v.matchId)] = k
        end
    end
end

--有歧义，没法算，查表
function  SpecialEventsMainModel:GetOneIndexByMatchId(matchId)
    --old return math.floor(i / 100)  6-7之间 6050这种失效
    return tonumber(SpecificMatchBase[tostring(matchId)].id)
end

function  SpecialEventsMainModel:GetTwoIndexByMatchId(matchId)
    --old return math.fmod(matchId, 100)
    return self.difficultyIndex[tostring(matchId)]
end

function SpecialEventsMainModel:GetDifficulty(id)
    return self.difficulty[id]
end

-- 改表导致两个通关的之间有可能出现未通关的，之前方法不能用
function SpecialEventsMainModel:GetNextMatchIndex(eventId)
    if self.difficulty[eventId] then
        local count = #self.difficulty[eventId]
        local index = count
        for k, v in pairs(self.difficulty[eventId]) do
            if not v.initial or tonumber(v.initial) == 0 then
                index = self:GetTwoIndexByMatchId(v.matchId)
                break
            end
        end
        return math.min(index, count)
    else
        return 1
    end
end

function SpecialEventsMainModel:UpdateModel(data)
    if type(data.list) == "table" then
        for i, value in pairs(data.list) do
            self.data.list[i] = value

            local eventId = self:GetOneIndexByMatchId(i)
            local index = self:GetTwoIndexByMatchId(i)
            if value.initial ~= nil then
                self.difficulty[eventId][index].initial = value.initial
            end
        end
    end

    if type(data.history) == "table" then
        for i, value in pairs(data.history) do
            if value ~= nil then
                self.data.history[tostring(i)] = value
            end
        end
    end

    if type(data.typeList) == "table" then
        for i, value in pairs(data.typeList) do
            if value ~= nil then
                for j = 1, #self.difficulty[tonumber(i)] do
                    self.difficulty[tonumber(i)][j].times = value.times
                    self.main[tonumber(i)].showRedPoint = value.times > 0
                end
            end
        end
    end

    if type(data.video) == "table" then
        for i, value in pairs(data.video) do
            if value ~= nil then
                self.data.video[i] = value
            end
        end
    end

    if type(data.list) == "table" or type(data.typeList) == "table" then
        EventSystem.SendEvent("SpecialEventsMainModel:UpdateDifficulty")
    end
end

return SpecialEventsMainModel

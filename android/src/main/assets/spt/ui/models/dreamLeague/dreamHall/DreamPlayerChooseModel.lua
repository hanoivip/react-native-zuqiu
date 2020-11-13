local Model = require("ui.models.Model")
local DreamPlayerChooseModel = class(Model, "DreamPlayerChooseModel")

function DreamPlayerChooseModel:ctor(teamData, allDcids, allNations)
    self.data = teamData or {}
    self.allDcids = allDcids
    self.allNations = allNations
    -- 阵容限制个数 前锋2 中场3 后卫3 门将1
    self.postionNum = {2, 3, 3, 1}
    self:SetPlayerData(self.data)
end

function DreamPlayerChooseModel:SetPlayerData(teamData)
    self.positionData = {}
    self.allAddedPlayer = 0
    for k,v in pairs(teamData) do
        local posIndex = tonumber(v.position)
        if not self.positionData[posIndex] then
            self.positionData[posIndex] = {}
        end
        self.allAddedPlayer = self.allAddedPlayer + 1
        table.insert(self.positionData[posIndex], v)
    end

    for i=1, 4 do
        if not self.positionData[i] then
            self.positionData[i] = {}
        end
        for j=1, self.postionNum[i] do
            if self.allAddedPlayer <= 7 then
                if not self.positionData[i][j] then
                    self.positionData[i][j] = {}
                    self.positionData[i][j].state = "add"
                end
            else
                if not self.positionData[i][j] then
                    self.positionData[i][j] = {}
                    self.positionData[i][j].state = "full"
                end
            end
        end
    end
end

function DreamPlayerChooseModel:GetPlayerByPositionIndex(positionIndex)
    return self.positionData[positionIndex]
end

function DreamPlayerChooseModel:GetAllDcids()
    return self.allDcids
end

function DreamPlayerChooseModel:GetAllNations()
    return self.allNations
end

return DreamPlayerChooseModel
